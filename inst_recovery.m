function [original_codeword, received_string, num_candidate_messages, num_valid_messages, recovered_message, suggest_to_crash, recovered_successfully] = inst_recovery(architecture, n, k, original_message, error_pattern, code_type, policy, mnemonic_hotness_filename, rd_hotness_filename, verbose)
% This function attempts to heuristically recover from a DUE affecting a single received string.
% The message is assumed to be an instruction of the given architecture in big endian format.
% To compute candidate codewords, we flip a single bit one at a time and decode using specified ECC decoder.
% We should obtain a set of unique candidate codewords.
% Based on the policy, we then try to recover the most likely corresponding instruction-message.
%
% Input arguments:
%   architecture --     String: '[rv64g]'
%   n --                String: '[39|45|72|79|144]'
%   k --                String: '[32|64|128]'
%   original_message -- Binary String of length k bits/chars. Note that k might not be 32 which is the instruction size! We will treat original_message as being a set of packed 32-bit instructions.
%   error_pattern --    Binary String of length n bits/chars
%   code_type --        String: '[hsiao1970|davydov1991|bose1960|fujiwara1982]'
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

%% Init some return values
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

if strcmp(code_type, 'hsiao1970') == 1 || strcmp(code_type, 'davydov1991') == 1 % SECDED
    [G,H] = getSECDEDCodes(n,code_type);
elseif strcmp(code_type, 'bose1960') == 1 % DECTED
    [G,H] = getDECTEDCodes(n);
elseif strcmp(code_type, 'fujiwara1982') == 1 % ChipKill
    [G,H] = getChipkillCodes(n);
else
    display(['FATAL! Unsupported code type: ' code_type]);
end

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

original_codeword = ecc_encoder(original_message,G);
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

if strcmp(code_type, 'hsiao1970') == 1 || strcmp(code_type, 'davydov1991') == 1 % SECDED
    [recovered_message, num_error_bits] = secded_decoder(received_string, H, code_type);
elseif strcmp(code_type, 'bose1960') == 1 % DECTED
    [recovered_message, num_error_bits] = dected_decoder(received_string, H);
elseif strcmp(code_type, 'fujiwara1982') == 1 % ChipKill
    [recovered_message, num_error_bits, num_error_symbols] = chipkill_decoder(received_string, H, 4);
end % didn't check bad code type error condition because we should have caught it earlier anyway

if verbose == 1
    display(['Sanity check: ECC decoder determined that there are ' num2str(num_error_bits) ' bits in error. The input error pattern had ' num2str(sum(error_pattern=='1')) ' bits flipped.']);

    if strcmp(code_type, 'fujiwara1982') == 1 % ChipKill
        display(['This is a ChipKill code with symbol size of 4 bits. The decoder found ' num2str(num_error_symbols) ' symbols in error.']);
    end
end

%% If the ECC decoder returned the correct message, we are done.
if strcmp(recovered_message,original_message) == 1
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
original_message_hex = my_bin2hex(original_message);
[status, decoderOutput] = MyRv64gDecoder(original_message_hex);
if verbose == 1 && status ~= 0
    display('WARNING: Input message is not a legal instruction!');
end

%% Flip bits on the corrupted codeword, and attempt decoding on each. We should find several bit flip combinations that decode successfully
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

num_packed_inst = k/32; % Assume 32 bits per instruction. Then if k is a multiple of 32 we have packed instructions. FIXME: only valid for RV64G
if verbose == 1
    num_packed_inst
end

%% Policies
bailout = 0;
if strcmp(policy, 'baseline-pick-random') == 1
    if verbose == 1
        display('RECOVERY STEP 1: PICK RANDOMLY from all candidate-correct messages.');
    end

    candidate_valid_messages = candidate_correct_messages;
    num_valid_messages = size(candidate_valid_messages,1);
    target_inst_indices = (1:size(candidate_correct_messages,1))';
    target_inst_index = target_inst_indices(randi(size(target_inst_indices,1),1));

elseif strcmp(policy, 'filter-rank-pick-random') == 1 || strcmp(policy, 'filter-rank-sort-pick-first') == 1 || strcmp(policy, 'filter-rank-rank-sort-pick-first') == 1 || strcmp(policy, 'filter-frequency-pick-random') == 1 || strcmp(policy, 'filter-frequency-sort-pick-first') == 1 || strcmp(policy, 'filter-frequency-sort-pick-longest-pad') == 1
    % RECOVERY STEP 1: FILTER. Check each of the candidate codewords to see which are (sets of) valid instructions
    if verbose == 1
        display('RECOVERY STEP 1: FILTER. Filtering candidate codewords for (sets of) instruction legality...');
    end
    num_candidate_messages = size(candidate_correct_messages,1);
    num_valid_messages = 0;
    candidate_valid_messages = repmat('0',1,k); % Init
    valid_messages_mnemonic = cell(1,num_packed_inst);
    valid_messages_rd = cell(1,num_packed_inst);
    for x=1:num_candidate_messages
        % Convert message to hex string representation
        message = candidate_correct_messages(x,:);
        message_hex = my_bin2hex(message);
        
        % For each instruction packed in the candidate message, test to see if it is a valid instruction and extract disassembly of its hex representation
        all_packed_inst_valid = 1;
        candidate_message_packed_inst_disassemblies = cell((k/32),1);
        for packed_inst=1:num_packed_inst
            inst_hex = message_hex((packed_inst-1)*8+1:(packed_inst-1)*8+8);
            [status, decoderOutput] = MyRv64gDecoder(inst_hex);

            % Read disassembly of instruction from string spit back by the instruction decoder
            candidate_message_packed_inst_disassembly = textscan(decoderOutput, '%s', 'Delimiter', ':');
            candidate_message_packed_inst_disassembly = candidate_message_packed_inst_disassembly{1};
            candidate_message_packed_inst_disassembly = reshape(candidate_message_packed_inst_disassembly, 2, size(candidate_message_packed_inst_disassembly,1)/2)';
            candidate_message_packed_inst_disassemblies{packed_inst} = candidate_message_packed_inst_disassembly;

            if status ~= 0
                all_packed_inst_valid = 0;
            end
        end
        
        if all_packed_inst_valid == 1 % All packed instructions are valid! Track message. Otherwise, ignore.
           num_valid_messages = num_valid_messages+1;
           candidate_valid_messages(num_valid_messages,:) = message;

           % Store disassembly in the list
           for packed_inst=1:num_packed_inst
               candidate_message_packed_inst_disassembly = candidate_message_packed_inst_disassemblies{packed_inst};
               mnemonic = candidate_message_packed_inst_disassembly{4,2};
               rd = candidate_message_packed_inst_disassembly{6,2};

               valid_messages_mnemonic{num_valid_messages,packed_inst} = mnemonic;
               valid_messages_rd{num_valid_messages,packed_inst} = rd;
           end

           if verbose == 1
               display(['Index ' num2str(num_valid_messages) ' valid candidate message: ' message]);
           end
        elseif verbose == 1
           display(['Candidate-correct BUT NOT VALID message: ' message]);
        end

        if verbose == 1
            for packed_inst=1:num_packed_inst
                packed_inst
                candidate_message_packed_inst_disassemblies{packed_inst}
            end
        end
    end

    if strcmp(policy, 'filter-rank-pick-random') == 1 || strcmp(policy, 'filter-rank-sort-pick-first') == 1 || strcmp(policy, 'filter-rank-rank-sort-pick-first') == 1
        % RECOVERY STEP 2: RANK. Sort valid messages in order of their relative frequency as determined by the input file that we read. In the case of packed instructions per message, then we use the geometric mean of each packed inst's frequencies.
        if verbose == 1
            display('RECOVERY STEP 2: RANK. Sort valid messages in order of their geometric mean of relative frequency of packed mnemonics as determined by input tables...');
        end
        highest_rel_freq_mnemonic = 0;
        target_mnemonic = '';
        for x=1:num_valid_messages
            rel_freq_mnemonic = 1;
            mnemonic = valid_messages_mnemonic(x,:); % Potentially packed mnemonics
            for packed_inst=1:num_packed_inst
                if instruction_mnemonic_hotness.isKey(mnemonic{packed_inst})
                    rel_freq_mnemonic = instruction_mnemonic_hotness(mnemonic{packed_inst}) * rel_freq_mnemonic;
                else % This could happen legally
                    rel_freq_mnemonic = 0;
                end
            end
            rel_freq_mnemonic = nthroot(rel_freq_mnemonic,num_packed_inst);
                
            % Find highest frequency mnemonic. In case of packed instructions, we concatenate the mnemonics separated by the '&&' symbol.
            if rel_freq_mnemonic >= highest_rel_freq_mnemonic
               highest_rel_freq_mnemonic = rel_freq_mnemonic;
               target_mnemonic = mnemonic;
            end
        end

        if verbose == 1
            target_mnemonic_stringized = target_mnemonic{1};
            for packed_inst=2:num_packed_inst
                target_mnemonic_stringized = [target_mnemonic_stringized ' && ' target_mnemonic{packed_inst}];
            end
            target_mnemonic_stringized
            highest_rel_freq_mnemonic
        end

        % Find indices matching highest frequency (set of) mnemonics
        mnemonic_inst_indices = zeros(1,1);
        y=1;
        for x=1:num_valid_messages
            mnemonic = valid_messages_mnemonic(x,:);
            full_match = 1;
            for packed_inst=1:num_packed_inst
                if strcmp(mnemonic{packed_inst},target_mnemonic{packed_inst}) ~= 1
                    full_match = 0;
                    break;
                end
            end
            if full_match == 1
                mnemonic_inst_indices(y,1) = x;
                y = y+1;
            end
        end

        target_inst_indices = mnemonic_inst_indices;
    end

    if strcmp(policy,'filter-rank-rank-sort-pick-first') == 1 % match
        % RECOVERY STEP 3: FILTER. Select only the valid messages with the most common mnemonic.
        if verbose == 1
            display('RECOVERY STEP 3: RANK. Out of the highest-ranked mnemonic candidates, rank again by the most common (sets of) destination register addresses...');
        end
        target_inst_indices = zeros(1,1);
        highest_rel_freq_rd = 0;
        target_rd = '';
        for y=1:size(mnemonic_inst_indices,1)
           rd = valid_messages_rd(mnemonic_inst_indices(y,1),:); % Potentially sets of rds for packed instructions in a message
           rel_freq_rd = 1;
           for packed_inst=1:num_packed_inst
               if instruction_rd_hotness.isKey(rd{packed_inst})
                   rel_freq_rd = instruction_rd_hotness(rd{packed_inst}) * rel_freq_rd;
               else % This can happen when rd is not used in an instr (NA)
                   rel_freq_rd = 0;
               end
           end

           rel_freq_rd = nthroot(rel_freq_rd,num_packed_inst);

           % Find highest frequency rd
           if rel_freq_rd > highest_rel_freq_rd
              highest_rel_freq_rd = rel_freq_rd;
              target_rd = rd;
           end
        end

        if verbose == 1
            target_rd_stringized = target_rd{1};
            for packed_inst=2:num_packed_inst
                target_rd_stringized = [target_rd_stringized ' && ' target_rd{packed_inst}];
            end
            target_rd_stringized
            highest_rel_freq_rd
        end

        z=1;
        for y=1:size(mnemonic_inst_indices,1)
           rd = valid_messages_rd(mnemonic_inst_indices(y,1),:);
           full_match = 1;
           for packed_inst=1:num_packed_inst
               if strcmp(rd{packed_inst},target_rd{packed_inst}) ~= 1
                   full_match = 0;
                   break;
               end
           end
           if full_match == 1
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
        rel_freq_mnemonics = zeros(num_valid_messages,num_packed_inst);
        for x=1:num_valid_messages
            mnemonic = valid_messages_mnemonic(x,:);
            for packed_inst=1:num_packed_inst
                if instruction_mnemonic_hotness.isKey(mnemonic{packed_inst})
                    rel_freq_mnemonics(x,packed_inst) = instruction_mnemonic_hotness(mnemonic{packed_inst});
                else % This could happen legally
                    rel_freq_mnemonics(x,packed_inst) = 0;
                end
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
            valid_messages_probabilities(x,1) = prod(rel_freq_mnemonics(x,:)) / sum(prod(rel_freq_mnemonics'));%* (1 / num_matching_message_mnemonics(valid_messages_mnemonic{x,1}));
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
            if valid_messages_probabilities(x,1) >= highest_prob_mnemonic-1e-12 && valid_messages_probabilities(x,1) <= highest_prob_mnemonic+1e-12
                target_inst_indices(y,1) = x;
                y = y+1;
            end
        end
    end

    % Choose recovery target
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
                display('LAST STEP: CHOOSE TARGET. Pick the target that has the longest average (over packed instructions) run of leading 0s or 1s (longest pad). In a tie, pick first in sorted order. We recommend crashing if Pr{guessing correctly} < 0.5');
            end
            
            y = 1;
            pad_lengths = zeros(size(target_inst_indices,1),num_packed_inst);
            for x=1:size(target_inst_indices,1)
                for packed_inst=1:num_packed_inst
                    pad_lengths(x,packed_inst) = compute_pad_length(candidate_valid_messages(target_inst_indices(x),(packed_inst-1)*32+1:(packed_inst-1)*32+32)); % assume instructions are 32 bits. FIXME: only valid for RV64G
                end
            end
            if num_packed_inst > 1
                max_avg_pad_length = max(mean(pad_lengths'));
            else
                max_avg_pad_length = max(pad_lengths);
            end

            if verbose == 1
                pad_lengths
                max_avg_pad_length
            end

            max_avg_pad_length_indices = 0;
            y = 1;
            for x=1:size(target_inst_indices,1)
                if mean(pad_lengths(x,:)) == max_avg_pad_length
                    max_avg_pad_length_indices(y) = x;
                    y = y+1;
                end
            end
            target_inst_index = max_avg_pad_length_indices(1);
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

