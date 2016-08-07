function [original_codeword, received_string, num_candidate_messages, num_valid_messages, recovered_message, suggest_to_crash, recovered_successfully] = inst_recovery(architecture, n, k, original_message, error_pattern, code_type, policy, tiebreak_policy, mnemonic_hotness_filename, rd_hotness_filename, verbose)
% This function attempts to heuristically recover from a DUE affecting a single received string.
% The message is assumed to be an instruction of the given architecture.
% To compute candidate codewords, we flip a single bit one at a time and decode using specified SECDED decoder..
% We should obtain a set of unique candidate codewords.
% Based on the policy, we then try to recover the most likely corresponding instruction-message.
% TODO: support codes other than SECDED, e.g. DECTED requires more than one trial flip
%
% Input arguments:
%   architecture --     String: '[rv64g]'
%   n --                String: '[39|72]'
%   k --                String: '[32|64]'
%   original_message -- Binary String of length k bits/chars
%   error_pattern --    Binary String of length n bits/chars
%   code_type --        String: '[hsiao|davydov1991]'
%   policy --           String: '[filter-rank|filter-rank-filter-rank]'
%   tiebreak_policy --   String: '[pick_first|pick_last|pick_random]'
%   mnemonic_hotness_filename -- String: full path to CSV file containing the relative frequency of each instruction to use for ranking
%   rd_hotness_filename -- String: full path to CSV file containing the relative frequency of each destination register address to use for ranking
%   verbose -- 1 if you want console printouts of progress.
%
% Returns:
%   original_codeword -- n-bit encoded version of original_message
%   received_string -- n-bit string that is corrupted by the bit flips specified by error_pattern
%   num_candidate_messages -- Scalar
%   num_valid_messages -- Scalar
%   recovered_message -- k-bit message that corresponds to our target for heuristic recovery
%   suggest_to_crash -- 0 if we are confident in recovery, 1 if we recommend crashing out instead
%   recovered_successfully -- 1 if we matched original_message, 0 otherwise
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

n = str2num(n);
k = str2num(k);
verbose = str2num(verbose);

if verbose == 1
    architecture
    n
    k
    original_message
    error_pattern
    code_type
    policy
    tiebreak_policy
    mnemonic_hotness_filename
    rd_hotness_filename
end

% init some return values
recovered_message = repmat('X',1,k);
suggest_to_crash = 0;
recovered_successfully = 0;

if ~isdeployed
    addpath ecc common rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
end

%% Get our ECC encoder and decoder matrices
if verbose == 1
    display('Getting ECC encoder and decoder matrices...');
end
[G,H] = getSECDEDCodes(n,code_type);

%% Read mnemonic and rd distributions from files now
if verbose == 1
    display('Importing static instruction distribution...');
end

% mnemonic frequency
fid = fopen(mnemonic_hotness_filename);
instruction_mnemonic_hotness_file = textscan(fid, '%s', 'Delimiter', ',');
fclose(fid);
instruction_mnemonic_hotness_file = instruction_mnemonic_hotness_file{1};
instruction_mnemonic_hotness_file = reshape(instruction_mnemonic_hotness_file, 2, size(instruction_mnemonic_hotness_file,1)/2)';
instruction_mnemonic_hotness = containers.Map(); % Init
for r=2:size(instruction_mnemonic_hotness_file,1)
    instruction_mnemonic_hotness(instruction_mnemonic_hotness_file{r,1}) = str2double(instruction_mnemonic_hotness_file{r,2});
end

% rd frequency
fid = fopen(rd_hotness_filename);
instruction_rd_hotness_file = textscan(fid, '%s', 'Delimiter', ',');
fclose(fid);
instruction_rd_hotness_file = instruction_rd_hotness_file{1};
instruction_rd_hotness_file = reshape(instruction_rd_hotness_file, 2, size(instruction_rd_hotness_file,1)/2)';
instruction_rd_hotness = containers.Map(); % Init
for r=2:size(instruction_rd_hotness_file,1)
    instruction_rd_hotness(instruction_rd_hotness_file{r,1}) = str2double(instruction_rd_hotness_file{r,2});
end

%% Encode the original message, then corrupt the codeword with the provided error pattern
if verbose == 1
    display('Getting the original codeword and generating the received (corrupted) string...');
end

original_codeword = secded_encoder(original_message,G);
received_string = my_bitxor(original_codeword, error_pattern);

if verbose == 1
    original_message
    original_codeword
    error_pattern
    received_string
end

%% Attempt to recover the original message. This could actually succeed depending on the code used and how many bits are in the error pattern.
if verbose == 1
    display('Attempting to decode the received string...');
end

[recovered_message, num_error_bits] = secded_decoder(received_string, H, code_type);

if verbose == 1
    display(['ECC decoder determined that there are ' num2str(num_error_bits) ' bits in error. The input error pattern had ' num2str(sum(error_pattern=='1')) ' bits flipped.']);
end

%% If the ECC decoder had no error or correctable error, we are done
if num_error_bits == 0 || num_error_bits == 1 
    if verbose == 1
        display('No error or correctable error. We are done, no need for heuristic recovery.');
    end
    if sum(error_pattern=='1') ~= num_error_bits && verbose == 1
        display('NOTE: This is a MIS-CORRECTION by the ECC decoder itself.');
    end
    return;
end

%% If we got to this point, we have to recover from a DUE. 
if verbose == 1
    display('Attempting heuristic recovery...');
end

%% Flip 1 bit at a time on the corrupted codeword, and attempt decoding on each. We should find several bit positions that decode successfully with just a single-bit error.
if verbose == 1
    display('Computing candidate codewords...');
end

recovered_message = repmat('X',1,k); % Re-init
[candidate_correct_messages, retval] = compute_candidate_correct_messages(received_string,H,code_type);
if retval ~= 0
    display('FATAL! Something went wrong computing candidate-correct messages!');
    return;
end

if verbose == 1
    candidate_correct_messages
end

%% RECOVERY STEP 1: FILTER. Check each of the candidate codewords to see which are valid instructions
if verbose == 1
    display('RECOVERY STEP 1: FILTER. Filtering candidate codewords for instruction legality...');
end
num_candidate_messages = size(candidate_correct_messages,1);
num_valid_messages = 0;
candidate_valid_messages = repmat('0',1,k); % Init
valid_messages_mnemonic = cell(1,1);
valid_messages_rd = cell(1,1);
for x=1:num_candidate_messages
    % Convert message to hex string representation
    message = candidate_correct_messages(x,:);
    message_hex = dec2hex(bin2dec(message),8);
    
    % Test the candidate message to see if it is a valid instruction and extract disassembly of the message hex
    [status, decoderOutput] = MyRv64gDecoder(message_hex);
    % Read disassembly of instruction from string spit back by the instruction decoder
    candidate_message_disassembly = textscan(decoderOutput, '%s', 'Delimiter', ':');
    candidate_message_disassembly = candidate_message_disassembly{1};
    candidate_message_disassembly = reshape(candidate_message_disassembly, 2, size(candidate_message_disassembly,1)/2)';
    
    if status == 0 % It is valid! Track it. Otherwise, ignore.
       num_valid_messages = num_valid_messages+1;
       candidate_valid_messages(num_valid_messages,:) = message;

       % Store disassembly in the list
       mnemonic = candidate_message_disassembly{4,2};
       rd = candidate_message_disassembly{6,2};
       valid_messages_mnemonic{num_valid_messages,1} = mnemonic;
       valid_messages_rd{num_valid_messages,1} = rd;

       if verbose == 1
           display(['Index ' num2str(x) ' candidate valid message: ' message]);
       end
    elseif verbose == 1
       display(['Candidate-correct BUT NOT VALID message: ' message]);
    end

    if verbose == 1
        candidate_message_disassembly
    end
end

%% RECOVERY STEP 2: RANK. Sort valid messages in order of their relative frequency as determined by the input file that we read.
if verbose == 1
    display('RECOVERY STEP 2: RANK. Sort valid messages in order of their relative frequency of mnemonic as determined by input tables...');
end
highest_rel_freq_mnemonic = 0;
target_mnemonic = '';
for x=1:num_valid_messages
    mnemonic = valid_messages_mnemonic{x,1};
    if instruction_mnemonic_hotness.isKey(mnemonic)
        rel_freq_mnemonic = instruction_mnemonic_hotness(mnemonic);
    else % This could happen legally
        rel_freq_mnemonic = 0;
    end
    
    % Find highest frequency mneumonic
    if rel_freq_mnemonic >= highest_rel_freq_mnemonic
       highest_rel_freq_mnemonic = rel_freq_mnemonic;
       target_mnemonic = mnemonic;
    end
end

if verbose == 1
    target_mnemonic
    highest_rel_freq_mnemonic
end

% Find indices matching highest frequency mneumonic
mnemonic_inst_indices = zeros(1,1);
y=1;
for x=1:num_valid_messages
    mnemonic = valid_messages_mnemonic{x,1};
    if strcmp(mnemonic,target_mnemonic) == 1
        mnemonic_inst_indices(y,1) = x;
        y = y+1;
    end
end

target_inst_indices = mnemonic_inst_indices; % By default, targets are finished here unless we do filter-rank-filter-rank policy.

if strcmp(policy,'filter-rank-filter-rank') == 1 % match
    %% RECOVERY STEP 3 (OPTIONAL): FILTER. Select only the valid messages with the most common mnemonic.
    if verbose == 1
        display('RECOVERY STEP 3 (OPTIONAL): FILTER. Select only the valid messages with the most common mnemonic...');
    end
    target_inst_indices = zeros(1,1);
    highest_rel_freq_rd = 0;
    target_rd = '';
    for y=1:size(mnemonic_inst_indices,1)
       rd = valid_messages_rd{mnemonic_inst_indices(y,1),1};

       if instruction_rd_hotness.isKey(rd)
           rel_freq_rd = instruction_rd_hotness(rd);
       else % This can happen when rd is not used in an instr (NA)
           rel_freq_rd = 0;
       end

       % Find highest frequency rd
       if rel_freq_rd > highest_rel_freq_rd
          highest_rel_freq_rd = rel_freq_rd;
          target_rd = rd;
       end
    end

    if verbose == 1
        target_rd
        highest_rel_freq_rd
    end

    %% RECOVERY STEP 4 (OPTIONAL): RANK. Rank the set of valid messages with the most common mnemonic followed by the most common destination register address.
    if verbose == 1
        display('RECOVERY STEP 4 (OPTIONAL): RANK. Rank by the most common destination register address...');
    end
    z=1;
    for y=1:size(mnemonic_inst_indices,1)
       rd = valid_messages_rd{mnemonic_inst_indices(y,1),1};
       if strcmp(rd,target_rd) == 1
           target_inst_indices(z,1) = mnemonic_inst_indices(y,1);
           z = z+1;
       end
    end
    
    if target_inst_indices(1) == 0 % This is OK when rd is not used anywhere in the checked candidates
        target_inst_indices = mnemonic_inst_indices;
    end
end

if verbose == 1
    target_inst_indices
end

% REVELATION 7/24/2016: deterministically choosing the target instruction index has a HUGE effect on recovery rate!!!!!!! We thought this should never happen.
% For instance, in original SELSE/DSN work, we always chose the *last* of valid messages as the target. This corresponds to a candidate with trial flips towards the LSB in a codeword.
% In the more recent work, we always chose the *first* of valid messages as the target. This corresponds to a candidate with trial flips towards the MSB in a codeword.
% The latter strategy performs MUCH better: 60% vs 45% for bzip2 on filter-rank policy, typically. WHY?? We thought they should be equivalent to a random choice...
% FIXME and UNDERSTAND

%% Choose recovery target and decide if crashing is recommended
if target_inst_indices(1) == 0 % sanity check
    display('FATAL! No valid target instruction for recovery found.');
    target_inst_index = -2;
    return;
elseif size(target_inst_indices,1) == 1 % have one recovery target
    target_inst_index = target_inst_indices(1); 
    if verbose == 1
        display(['We have one recovery target: ' num2str(target_inst_index)]);
    end
else % multiple recovery targets: allowed crash.
    suggest_to_crash = 1;
    if strcmp(tiebreak_policy, 'pick_first') == 1
        target_inst_index = target_inst_indices(1);
    elseif strcmp(tiebreak_policy, 'pick_last') == 1
        target_inst_index = target_inst_indices(size(target_inst_indices,1));
    elseif strcmp(tiebreak_policy, 'pick_random') == 1
        target_inst_index = target_inst_indices(randi(size(target_inst_indices,1),1)); % Pick random of remaining targets as a guess. NOTE: see REVELATION above. The ordering apparently matters!
    else
        target_inst_index = -1;
        display(['FATAL! tiebreak_policy was ' tiebreak_policy]);
        return;
    end
    if verbose == 1
        display(['We had ' num2str(size(target_inst_indices,1)) ' recovery targets, chose: ' num2str(target_inst_index)]);
    end
end

%% Final result
recovered_message = candidate_valid_messages(target_inst_index,:);
%suggest_to_crash
recovered_successfully = (strcmp(recovered_message, original_message) == 1);

if verbose == 1
    recovered_message
    recovered_successfully
    suggest_to_crash
end

