function [original_codeword, received_string, num_candidate_messages, num_valid_messages, recovered_message, suggest_to_crash, recovered_successfully] = inst_recovery(architecture, n, k, original_message, error_pattern, code_type, policy, mnemonic_hotness_filename, rd_hotness_filename, verbose)
% This function attempts to heuristically recover from a DUE affecting a single received string.
% The message is assumed to be an instruction of the given architecture.
% To compute candidate codewords, we flip a single bit one at a time and decode using specified SECDED decoder..
% We should obtain a set of unique candidate codewords.
% Based on the policy, we then try to recover the most likely corresponding instruction-message.
% TODO: fully support DECTED and ChipKill codes
%
% Input arguments:
%   architecture --     String: '[rv64g]'
%   n --                String: '[39|72]'
%   k --                String: '[32|64]'
%   original_message -- Binary String of length k bits/chars
%   error_pattern --    Binary String of length n bits/chars
%   code_type --        String: '[hsiao1970|davydov1991]'
%   policy --           String: '[baseline-pick-random | filter-rank-pick-random | filter-rank-sort-pick-first | filter-rank-rank-sort-pick-first | filter-frequency-pick-random | filter-frequency-sort-pick-first | filter-frequency-sort-pick-longest-pad]'
%   mnemonic_hotness_filename -- String: full path to CSV file containing the relative frequency of each instruction to use for ranking
%   rd_hotness_filename -- String: full path to CSV file containing the relative frequency of each destination register address to use for ranking
%   verbose -- 1 if you want console printouts of progress to stdout.
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
    mnemonic_hotness_filename
    rd_hotness_filename
end

rng('shuffle'); % Seed RNG based on current time

% init some return values
recovered_message = repmat('X',1,k);
suggest_to_crash = 0;
recovered_successfully = 0;

if ~isdeployed
    addpath ecc common inst_recovery_policies rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
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

%% Warn if input message is actually illegal
original_message_hex = dec2hex(bin2dec(original_message),8);
[status, decoderOutput] = MyRv64gDecoder(original_message_hex);
if verbose == 1 && status ~= 0
    display('WARNING: Input message is not a legal instruction!');
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

%% Policies
if strcmp(policy, 'baseline-pick-random') == 1
    if verbose == 1
        display('RECOVERY STEP 1: PICK RANDOMLY from all candidate-correct messages.');
    end

    target_inst_indices = (1:size(candidate_correct_messages,1))';
    target_inst_index = target_inst_indices(randi(size(target_inst_indices,1),1));

elseif strcmp(policy, 'filter-rank-pick-random') == 1 || strcmp(policy, 'filter-rank-sort-pick-first') == 1 || strcmp(policy, 'filter-rank-rank-sort-pick-first') == 1 || strcmp(policy, 'filter-frequency-pick-random') == 1 || strcmp(policy, 'filter-frequency-sort-pick-first') == 1 || strcmp(policy, 'filter-frequency-sort-pick-longest-pad') == 1
    % RECOVERY STEP 1: FILTER. Check each of the candidate codewords to see which are valid instructions
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
               display(['Index ' num2str(num_valid_messages) ' valid candidate message: ' message]);
           end
        elseif verbose == 1
           display(['Candidate-correct BUT NOT VALID message: ' message]);
        end

        if verbose == 1
            candidate_message_disassembly
        end
    end

    if strcmp(policy, 'filter-rank-pick-random') == 1 || strcmp(policy, 'filter-rank-sort-pick-first') == 1 || strcmp(policy, 'filter-rank-rank-sort-pick-first') == 1
        % RECOVERY STEP 2: RANK. Sort valid messages in order of their relative frequency as determined by the input file that we read.
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

        target_inst_indices = mnemonic_inst_indices;
    end

    if strcmp(policy,'filter-rank-rank-sort-pick-first') == 1 % match
        % RECOVERY STEP 3: FILTER. Select only the valid messages with the most common mnemonic.
        if verbose == 1
            display('RECOVERY STEP 3: RANK. Out of the highest-ranked mnemonic candidates, rank again by the most common destination register address...');
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

    if strcmp(policy, 'filter-frequency-pick-random') == 1 || strcmp(policy, 'filter-frequency-sort-pick-first') == 1 || strcmp(policy, 'filter-frequency-sort-pick-longest-pad') == 1
        if verbose == 1
            display('RECOVERY STEP 2: FREQUENCY. Estimate the probability of each valid message being individually correct.');
        end

        %num_matching_message_mnemonics = containers.Map();
        rel_freq_mnemonics = zeros(num_valid_messages,1);
        for x=1:num_valid_messages
            mnemonic = valid_messages_mnemonic{x,1};
            if instruction_mnemonic_hotness.isKey(mnemonic)
                rel_freq_mnemonics(x) = instruction_mnemonic_hotness(mnemonic);
            else % This could happen legally
                rel_freq_mnemonics(x) = 0;
            end
            
            % Get number of valid messages with this mnemonic
            %if num_matching_message_mnemonics.isKey(mnemonic)
            %    num_matching_message_mnemonics(mnemonic) = num_matching_message_mnemonics(mnemonic) + 1;
            %else
            %    num_matching_message_mnemonics(mnemonic) = 1;
            %end
        end

        % Compute probability of each message according to their groups
        valid_messages_probabilities = zeros(num_valid_messages,1);
        for x=1:num_valid_messages
            valid_messages_probabilities(x,1) = rel_freq_mnemonics(x,1) / sum(rel_freq_mnemonics);%* (1 / num_matching_message_mnemonics(valid_messages_mnemonic{x,1}));
        end

        if verbose == 1
            rel_freq_mnemonics
            valid_messages_probabilities
        end

        % Determine list of equivalent targets - find all candidates with the highest probability
        highest_prob_mnemonic = 0;
        for x=1:num_valid_messages
            if valid_messages_probabilities(x,1) >= highest_prob_mnemonic
               highest_prob_mnemonic = valid_messages_probabilities(x,1);
            end
        end

        target_inst_indices = zeros(1,1);
        y = 1;
        for x=1:num_valid_messages
            if valid_messages_probabilities(x,1) == highest_prob_mnemonic
                target_inst_indices(y,1) = x;
                y = y+1;
            end
        end
    end

    % Choose recovery target
    bailout = 0;
    if size(target_inst_indices,1) == 1 % Have only one recovery target
        target_inst_index = target_inst_indices(1); 
        if verbose == 1
            display(['LAST STEP: CHOOSE TARGET. We have one recovery target: ' num2str(target_inst_index)]);
        end

        % Handle special case, where NO candidate-correct messages were valid, perhaps because input message was an illegal instruction. In this case, actually revert to picking randomly and advise to crash.
        if target_inst_index == 0
            suggest_to_crash = 1;
            target_inst_index = randi(num_candidate_messages,1);
            bailout = 1;
            if verbose == 1
                display(['SPECIAL CASE ENCOUNTERED: The recovery target is invalid, perhaps because none of the candidate messages are actually valid (perhaps the input instruction is illegal). We reverted to picking target randomly and got ' num2str(target_inst_index) '. Recommend always crashing in this case.']);
            end
        end
    else % Have several recovery targets
        if strcmp(policy, 'filter-rank-pick-random') == 1 || strcmp(policy, 'filter-frequency-pick-random') == 1
            if verbose == 1
                display('LAST STEP: CHOOSE TARGET. Pick randomly. We recommend crashing if there are more than 2 equivalent targets here.');
            end

            if size(target_inst_indices,1) > 2
                suggest_to_crash = 1;
            end
            target_inst_index = target_inst_indices(randi(size(target_inst_indices,1),1));
        end

        if strcmp(policy, 'filter-rank-sort-pick-first') == 1 || strcmp(policy, 'filter-rank-rank-sort-pick-first') == 1
            if verbose == 1
                display('LAST STEP: CHOOSE TARGET. Pick the first in the sorted list of equivalent targets. We recommend crashing if there are more than 2 equivalent targets here.');
            end

            if size(target_inst_indices,1) > 2
                suggest_to_crash = 1;
            end
            target_inst_index = target_inst_indices(1);
        end

        if strcmp(policy, 'filter-frequency-sort-pick-first') == 1
            if verbose == 1
                display('LAST STEP: CHOOSE TARGET. Pick the first in the sorted list of equivalent targets. We recommend crashing if Pr{guessing correctly} < 0.5');
            end


            target_inst_index = target_inst_indices(1);
            if valid_messages_probabilities(target_inst_index) < 0.5
                suggest_to_crash = 1;
            end
        end

        if strcmp(policy, 'filter-frequency-sort-pick-longest-pad') == 1
            if verbose == 1
                display('LAST STEP: CHOOSE TARGET. Pick the target that has the longest run of leading 0s or 1s (longest pad). In a tie, pick first in sorted order. We recommend crashing if Pr{guessing correctly} < 0.5');
            end
            
            y = 1;
            pad_lengths = zeros(size(target_inst_indices,1),1);
            for x=1:size(target_inst_indices,1)
                pad_lengths(x) = compute_pad_length(candidate_valid_messages(target_inst_indices(x),:));
            end
            max_pad_length = max(pad_lengths);

            if verbose == 1
                pad_lengths
            end

            max_pad_length_indices = 0;
            y = 1;
            for x=1:size(target_inst_indices,1)
                if pad_lengths(x) == max_pad_length
                    max_pad_length_indices(y) = x;
                    y = y+1;
                end
            end
            target_inst_index = max_pad_length_indices(1);
            if valid_messages_probabilities(target_inst_index) < 0.5
                suggest_to_crash = 1;
            end
        end
    end
end

if verbose == 1
    target_inst_indices
    target_inst_index
end

%% Final result
if bailout == 1 % Special case where no candidates were valid and we handled it above by setting target_inst_index
    recovered_message = candidate_correct_messages(target_inst_index,:);
else % Typical case
    recovered_message = candidate_valid_messages(target_inst_index,:);
end
recovered_successfully = (strcmp(recovered_message, original_message) == 1);

if verbose == 1
    recovered_successfully
    suggest_to_crash
end

fprintf(1, '%s\n', recovered_message);

