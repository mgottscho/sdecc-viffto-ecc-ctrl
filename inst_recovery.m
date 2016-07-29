function [message, could_crash] = inst_recovery(architecture, n, k, received_string, code_type, policy, tiebreak_policy, mnemonic_hotness_filename, rd_hotness_filename)
% This function attempts to heuristically recover from a DUE affecting a single received string.
% The message is assumed to be an instruction of the given architecture.
% To compute candidate codewords, we flip a single bit one at a time and decode using specified SECDED decoder..
% We should obtain a set of unique candidate codewords.
% Based on the policy, we then try to recover the most likely corresponding instruction-message.
%
% Input arguments:
%   architecture --     String: '[mips|alpha|rv64g]'
%   n --                String: '[39|72]'
%   k --                String: '[32|64]'
%   received_string --  Binary String
%   code_type --        String: '[hsiao|davydov1991]'
%   policy --           String: '[filter-rank|filter-rank-filter-rank]'
%   tiebreak_policy --   String: '[pick_first|pick_last|pick_random]'
%   mnemonic_hotness_filename -- String: full path to CSV file containing the relative frequency of each instruction to use for ranking
%   rd_hotness_filename -- String: full path to CSV file containing the relative frequency of each destination register address to use for ranking
%
% Returns:
%   message -- k-bit message that is the recovery target.
%   could_crash -- 0 if we are confident in recovery, 1 if we may prefer to crash
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

architecture
n = str2num(n)
k = str2num(k)
received_string
code_type
policy
tiebreak_policy
mnemonic_hotness_filename
rd_hotness_filename

r = n-k;

%% Get our ECC encoder and decoder matrices
display('Getting ECC encoder and decoder matrices...');
[G,H] = getSECDEDCodes(n,code_type);

%% Read mnemonic and rd distributions from files now -- TODO
display('Importing static instruction distribution...');
instruction_mneumonic_hotness = containers.Map(); % Init
instruction_rd_hotness = containers.Map(); % Init

%% Attempt to decode the corrupted codeword, check that num_error_bits is 2
[decoded_message, num_error_bits] = secded_decoder(received_string, H, code_type);
        
% Sanity check
if num_error_bits ~= 2
   display(['OOPS! Number of bits in error in received string was ' num_error_bits '. Continuing anyway.']);
end
        
%% Flip 1 bit at a time on the received codeword, and attempt decoding on each. We should find several bit positions that decode successfully with just a single-bit error.
x = 1;
candidate_correct_messages = repmat('X',n,k); % Pre-allocate for worst-case capacity. X is placeholder
for pos=1:n
   %% Flip the bit
   error = repmat('0',1,n);
   error(pos) = '1';
   candidate_codeword = dec2bin(bitxor(bin2dec(received_string), bin2dec(error)), n);
   
   %% Attempt to decode
   [decoded_message, num_error_bits] = secded_decoder(candidate_codeword, H, code_type);
   
   if num_error_bits == 1           
       % We now know that num_error_bits == 1 if we got this far. This
       % is a candidate codeword.
       candidate_correct_messages(x,:) = decoded_message;
       x = x+1;
   end
end

%% Uniquify the candidate messages
if x > 1
    candidate_correct_messages = candidate_correct_messages(1:x-1, :);
    candidate_correct_messages = unique(candidate_correct_messages,'rows');
else
    display(['Something went wrong! x = ' num2str(x)]);
end


%% Now check each of the candidate codewords to see which are valid instructions :)
num_candidate_messages = size(candidate_correct_messages,1);
num_valid_messages = 0;
candidate_valid_messages = repmat('0',1,k); % Init
valid_messages_mneumonic = cell(1,1);
valid_messages_rd = cell(1,1);
for x=1:num_candidate_messages
    %% Convert message to hex string representation
    message = candidate_correct_messages(x,:);
    message_hex = dec2hex(bin2dec(message),8);
    
    %% Test the candidate message to see if it is a valid instruction and extract disassembly of the message hex
    %if strcmp(computer(), 'PCWIN64') == 1 % Windows version of the decode program
    %    status = dos([architecture 'decode ' message_hex ' >tmp_disassembly_' architecture '_' benchmark '_' num2str(i) '.txt']);
    %elseif strcmp(computer(), 'MACI64') == 1 % Mac version of the decode program
    %    status = unix(['./' architecture 'decode-mac ' message_hex ' >tmp_disassembly_' architecture '_' benchmark '_' num2str(i) '.txt']); % Mac version of the decode program
    %elseif strcmp(computer(), 'GLNXA64') == 1 % Linux version of the decode program
        %status = unix(['./' architecture 'decode-linux ' message_hex ' >tmp_disassembly_' architecture '_' benchmark '_' num2str(i) '.txt']); % Linux version of the decode program
        if strcmp(architecture,'mips') == 1
            [status, decoderOutput] = MyMipsDecoder(message_hex);
        elseif strcmp(architecture,'alpha') == 1
            [status, decoderOutput] = MyAlphaDecoder(message_hex);
        elseif strcmp(architecture,'rv64g') == 1
            [status, decoderOutput] = MyRv64gDecoder(message_hex);
        else
            display('ERROR! Supported ISAs are mips, alpha, and rv64g');
            status = -1;
            decoderOutput = '';
    %        exit(1);
        end 
    %else % Error
    %    display('Non-supported operating system detected!');
    %    status = 1;
    %end
    
    if status == 0 % It is valid!
       num_valid_messages = num_valid_messages+1;
       candidate_valid_messages(num_valid_messages,:) = message;
       
       % Read disassembly of instruction from file
       %tmpfid = fopen(['tmp_disassembly_' architecture '_' benchmark '_' num2str(i) '.txt']);
       %tmp_file_contents = textscan(tmpfid, '%s', 'Delimiter', ':');
       output_contents = textscan(decoderOutput, '%s', 'Delimiter', ':');
       %fclose(tmpfid);

       %tmp_file_contents = tmp_file_contents{1};
       output_contents = output_contents{1};
       %tmp_file_contents = reshape(tmp_file_contents, 2, size(tmp_file_contents,1)/2)';
       output_contents = reshape(output_contents, 2, size(output_contents,1)/2)';

       % Store disassembly in the list
       mneumonic = output_contents{4,2};
       rd = output_contents{6,2};
       valid_messages_mneumonic{num_valid_messages,1} = mneumonic;
       valid_messages_rd{num_valid_messages,1} = rd;
    end
end

%% Choose decode target
highest_rel_freq_mneumonic = 0;
target_mneumonic = '';
for x=1:num_valid_messages
    mneumonic = valid_messages_mneumonic{x,1};
    if instruction_mneumonic_hotness.isKey(mneumonic)
        rel_freq_mneumonic = instruction_mneumonic_hotness(mneumonic);
    else % This could happen legally
        rel_freq_mneumonic = 0;
    end
    
    % Find highest frequency mneumonic
    if rel_freq_mneumonic >= highest_rel_freq_mneumonic
       highest_rel_freq_mneumonic = rel_freq_mneumonic;
       target_mneumonic = mneumonic;
    end
end

% Find indices matching highest frequency mneumonic
mneumonic_inst_indices = zeros(1,1);
y=1;
for x=1:num_valid_messages
    mneumonic = valid_messages_mneumonic{x,1};
    if strcmp(mneumonic,target_mneumonic) == 1
        mneumonic_inst_indices(y,1) = x;
        y = y+1;
    end
end

if strcmp(policy,'filter-rank-filter-rank') == 1 % match
    highest_rel_freq_rd = 0;
    target_rd = '';
    for y=1:size(mneumonic_inst_indices,1)
       rd = valid_messages_rd{mneumonic_inst_indices(y,1),1};

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

    % Find indices matching both highest frequency mneumonic and highest frequency rd
    target_inst_indices = zeros(1,1);
    z=1;
    for y=1:size(mneumonic_inst_indices,1)
       rd = valid_messages_rd{mneumonic_inst_indices(y,1),1};
       if strcmp(rd,target_rd) == 1
           target_inst_indices(z,1) = mneumonic_inst_indices(y,1);
           z = z+1;
       end
    end
    
    if target_inst_indices(1) == 0 % This is OK when rd is not used anywhere in the checked candidates
        target_inst_indices = mneumonic_inst_indices;
    end
elseif strcmp(policy, 'filter-rank') == 1 % match
    target_inst_indices = mneumonic_inst_indices; 
else % Error
    print(['Invalid recovery policy: ' policy]);
    target_inst_indices = -1;
end

% REVELATION 7/24/2016: deterministically choosing the target instruction index has a HUGE effect on recovery rate!!!!!!! We thought this should never happen.
% For instance, in original SELSE/DSN work, we always chose the *last* of valid messages as the target. This corresponds to a candidate with trial flips towards the LSB in a codeword.
% In the more recent work, we always chose the *first* of valid messages as the target. This corresponds to a candidate with trial flips towards the MSB in a codeword.
% The latter strategy performs MUCH better: 60% vs 45% for bzip2 on filter-rank policy, typically. WHY?? We thought they should be equivalent to a random choice...
% FIXME and UNDERSTAND
crash = 0;
if target_inst_indices(1) == 0 % sanity check
    display('Error! No valid target instruction for recovery found.');
    target_inst_index = -2;
elseif size(target_inst_indices,1) == 1 % have one recovery target
    target_inst_index = target_inst_indices(1); 
else % multiple recovery targets: allowed crash.
    crash = 1;
    if strcmp(tiebreak_policy, 'pick_first') == 1
        target_inst_index = target_inst_indices(1);
    elseif strcmp(tiebreak_policy, 'pick_last') == 1
        target_inst_index = target_inst_indices(size(target_inst_indices,1));
    elseif strcmp(tiebreak_policy, 'pick_random') == 1
        target_inst_index = target_inst_indices(randi(size(target_inst_indices,1),1)); % Pick random of remaining targets as a guess. NOTE: see REVELATION above. The ordering apparently matters!
    else
        target_inst_index = -1;
        display(['Error! tiebreak_policy was ' tiebreak_policy]);
    end
end

%% results
could_crash = crash;
message = candidate_valid_messages{target_inst_index};

display('Done!');
