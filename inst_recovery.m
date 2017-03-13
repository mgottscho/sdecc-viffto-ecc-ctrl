function [num_valid_messages, recovered_message, estimated_prob_correct, suggest_to_crash, recovered_successfully] = inst_recovery(architecture, k, original_message, candidate_correct_messages_bin, policy, instruction_mnemonic_hotness, instruction_rd_hotness, crash_threshold, verbose)
% This function attempts to heuristically recover from a DUE affecting a single received string.
% The message is assumed to be an instruction of the given architecture in big endian format.
% To compute candidate codewords, we flip a single bit one at a time and decode using specified ECC decoder.
% We should obtain a set of unique candidate codewords.
% Based on the policy, we then try to recover the most likely corresponding instruction-message.
% Note: currently, inst_recovery does not support message sizes of 16-bits because this is smaller than an individual instruction.
%
% Input arguments:
%   architecture --     String: '[rv64g]'
%   k --                String: '[32|64|128]'
%   original_message -- Binary String of length k bits/chars. Note that k might not be 32 which is the instruction size! We will treat original_message as being a set of packed 32-bit instructions. TODO: support k < 32!!
%   candidate_correct_messages_bin -- Set of k-bit binary strings, e.g. '00001111000...10010,0000000....00000,...'.
%   policy --           String: '[  baseline-pick-random 
%                                 | filter-pick-random
%                                 | filter-rank-pick-random
%                                 | filter-rank-sort-pick-first
%                                 | filter-rank-sort-pick-longest-pad -- TODO (low priority)
%                                 | filter-frequency-pick-random
%                                 | filter-frequency-sort-pick-first
%                                 | filter-frequency-sort-pick-longest-pad
%                                 | filter-rank-rank-pick-random -- TODO (low priority)
%                                 | filter-rank-rank-sort-pick-first
%                                 | filter-rank-rank-sort-pick-longest-pad -- TODO (low priority)
%                                 | filter-frequency-frequency-pick-random -- TODO (low priority)
%                                 | filter-frequency-frequency-sort-pick-first -- TODO (low priority)
%                                 | filter-frequency-frequency-sort-pick-longest-pad -- TODO (low priority)
%                                 | filter-joint-frequency-pick-random -- TODO (low priority)
%                                 | filter-joint-frequency-sort-pick-first -- TODO (low priority)
%                                 | filter-joint-frequency-sort-pick-longest-pad
%                                ]'
%   instruction_mnemonic_hotness -- Big 2D cell array imported from CSV file
%   instruction_rd_hotness -- Big 2D cell array imported from CSV file
%   crash_threshold -- fraction from 0 to 1, expressed as a string, e.g. '0.5'.
%   verbose -- '1' if you want console printouts of progress to stdout.
%
% Returns:
%   num_valid_messages -- Scalar
%   recovered_message -- k-bit message that corresponds to our target for heuristic recovery
%   estimated_prob_correct -- fraction from 0 to 1 estimating what the policy thinks is the probability of correctness of its chosen message
%   suggest_to_crash -- 0 if we are confident in recovery, 1 if we recommend crashing out instead
%   recovered_successfully -- 1 if we matched original_message, 0 otherwise
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

k = str2double(k);
crash_threshold = str2double(crash_threshold);
verbose = str2double(verbose);

if verbose == 1
    architecture
    k
    original_message
    candidate_correct_messages_bin
    policy
    instruction_mnemonic_hotness
    instruction_rd_hotness
    crash_threshold
end

%rng('shuffle'); % Seed RNG based on current time -- commented out for speed. If we RNG in swd_ecc_offline_inst_heuristic_recovery then we shouldn't need to do it again.

%% Init some return values
num_valid_messages = -1;
recovered_message = repmat('X',1,k);
estimated_prob_correct = 0;
suggest_to_crash = 0;
recovered_successfully = 0;

if ~isdeployed
    addpath ecc common rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
end

%% Parse candidate_correct_messages_bin to convert into char matrix
candidate_correct_messages = repmat('X',1,k);
done_parsing = 0;
i = 1;
remain = candidate_correct_messages_bin;
while done_parsing == 0
   [token,remain] = strtok(remain,',');

   % Check input validity of token to ensure k-bits of '0' or '1' and no other value
   if (sum(token == '1')+sum(token == '0')) ~= size(token,2)
       display(['FATAL! Candidate entry ' num2str(i) ' has non-binary character: ' token]);
       return;
   end
   if size(token,2) ~= k
       display(['FATAL! Candidate entry ' num2str(i) ' has ' num2str(size(token,2)) ' bits, but ' num2str(k) ' bits are needed.']);
       return;
   end

   candidate_correct_messages(i,:) = token;
   i = i+1;

   if size(remain,2) == 0
       done_parsing = 1;
   end
end

num_candidate_messages = size(candidate_correct_messages,1);

if verbose == 1
    candidate_correct_messages
    num_candidate_messages
end

if verbose == 1
    display('Attempting heuristic recovery...');
end

%% Warn if original message is actually illegal
original_message_hex = my_bin2hex(original_message);
[~, legal] = parse_rv64g_decoder_output(original_message_hex);
if verbose == 1 && legal ~= 1
    display('WARNING: Original message is not a legal instruction!');
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

elseif strcmp(policy, 'filter-rank-pick-random') == 1 ...
    || strcmp(policy, 'filter-pick-random') == 1 ...
    || strcmp(policy, 'filter-rank-sort-pick-first') == 1 ...
    || strcmp(policy, 'filter-rank-rank-sort-pick-first') == 1 ...
    || strcmp(policy, 'filter-frequency-pick-random') == 1 ...
    || strcmp(policy, 'filter-frequency-sort-pick-first') == 1 ...
    || strcmp(policy, 'filter-frequency-sort-pick-longest-pad') == 1 ...
    || strcmp(policy, 'filter-joint-frequency-sort-pick-longest-pad') == 1
    % RECOVERY STEP 1: FILTER. Check each of the candidate codewords to see which are (sets of) valid instructions
    if verbose == 1
        display('RECOVERY STEP 1: FILTER. Filtering candidate codewords for (sets of) instruction legality...');
    end
    num_valid_messages = 0;
    candidate_valid_messages = repmat('0',1,k); % Init
    valid_messages_mnemonic = cell(1,num_packed_inst);
    valid_messages_rd = cell(1,num_packed_inst);
    valid_messages_rs1 = cell(1,num_packed_inst);
    valid_messages_rs2 = cell(1,num_packed_inst);
    valid_messages_rs3 = cell(1,num_packed_inst);
    for x=1:num_candidate_messages
        % Convert message to hex string representation
        message = candidate_correct_messages(x,:);
        message_hex = my_bin2hex(message);
        
        % For each instruction packed in the candidate message, test to see if it is a valid instruction and extract disassembly of its hex representation
        all_packed_inst_valid = 1;
        candidate_message_packed_inst_disassemblies = cell((k/32),1);
        for packed_inst=1:num_packed_inst
            inst_hex = message_hex((packed_inst-1)*8+1:(packed_inst-1)*8+8);
            [candidate_message_packed_inst_disassembly, legal] = parse_rv64g_decoder_output(inst_hex);

            % Read disassembly of instruction from string spit back by the instruction decoder
            candidate_message_packed_inst_disassemblies{packed_inst} = candidate_message_packed_inst_disassembly;

            if legal ~= 1
                all_packed_inst_valid = 0;
            end
        end
        
        if all_packed_inst_valid == 1 % All packed instructions are valid! Track message. Otherwise, ignore.
           num_valid_messages = num_valid_messages+1;
           candidate_valid_messages(num_valid_messages,:) = message;

           % Store disassembly in the list
           for packed_inst=1:num_packed_inst
               inst_hex = message_hex((packed_inst-1)*8+1:(packed_inst-1)*8+8);
               [~, ~, mnemonic, ~, rd, rs1, rs2, rs3, ~, ~] = parse_rv64g_decoder_output(inst_hex);

               valid_messages_mnemonic{num_valid_messages,packed_inst} = mnemonic;
               valid_messages_rd{num_valid_messages,packed_inst} = rd;
               valid_messages_rs1{num_valid_messages,packed_inst} = rs1;
               valid_messages_rs2{num_valid_messages,packed_inst} = rs2;
               valid_messages_rs3{num_valid_messages,packed_inst} = rs3;
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

    if verbose == 1
        num_valid_messages
    end

    if strcmp(policy, 'filter-pick-random') == 1
        target_inst_indices = (1:size(candidate_valid_messages,1))';
        target_inst_index = target_inst_indices(randi(size(target_inst_indices,1),1));

    end
    
    if strcmp(policy, 'filter-rank-pick-random') == 1 ...
        || strcmp(policy, 'filter-rank-sort-pick-first') == 1 ...
        || strcmp(policy, 'filter-rank-rank-sort-pick-first') == 1
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
                    break;
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
           if rel_freq_rd >= highest_rel_freq_rd
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

    if strcmp(policy, 'filter-frequency-pick-random') == 1 ...
        || strcmp(policy, 'filter-frequency-sort-pick-first') == 1 ...
        || strcmp(policy, 'filter-frequency-sort-pick-longest-pad') == 1
        if verbose == 1
            display('RECOVERY STEP 2: FREQUENCY. Estimate the probability of each valid message being individually correct.');
        end

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
        end

        % Compute probability of each message according to their groups
        valid_messages_probabilities = zeros(num_valid_messages,1);
        if num_packed_inst == 1
            valid_messages_probabilities = rel_freq_mnemonics ./ sum(rel_freq_mnemonics);
            %for x=1:num_valid_messages
            %    valid_messages_probabilities(x,1) = rel_freq_mnemonics(x) / sum(rel_freq_mnemonics);
            %end
        else
            valid_messages_probabilities = prod(rel_freq_mnemonics,2) ./ sum(prod(rel_freq_mnemonics,2));
            %for x=1:num_valid_messages
            %    valid_messages_probabilities(x,1) = prod(rel_freq_mnemonics(x,:)) / sum(prod(rel_freq_mnemonics,2));
            %end
        end

        if verbose == 1
            rel_freq_mnemonics
            valid_messages_probabilities
        end
        
        % Determine list of equivalent targets - find all candidates with the highest probability
        highest_prob_mnemonic = max(valid_messages_probabilities);
        %highest_prob_mnemonic = 0;
        %for x=1:num_valid_messages
        %    if valid_messages_probabilities(x,1) >= highest_prob_mnemonic
        %       highest_prob_mnemonic = valid_messages_probabilities(x,1);
        %    end
        %end

        target_inst_indices = find(valid_messages_probabilities >= highest_prob_mnemonic - (1e-12));
        %target_inst_indices = zeros(1,1);
        %y = 1;
        %for x=1:num_valid_messages
        %    if valid_messages_probabilities(x,1) >= highest_prob_mnemonic-1e-12 && valid_messages_probabilities(x,1) <= highest_prob_mnemonic+1e-12
        %        target_inst_indices(y,1) = x;
        %        y = y+1;
        %    end
        %end
        
        % Special case: it is entirely possible based on SI that no valid messages have a probability > 0. In this case, put all valid messages as targets.
        if size(target_inst_indices,1) == 0
            target_inst_indices = (1:num_valid_messages)';
        end
    end

    if strcmp(policy, 'filter-joint-frequency-sort-pick-longest-pad') == 1
        if verbose == 1
            display('RECOVERY STEP 2: FREQUENCY. Estimate the probability of each valid message being individually correct using the joint relative frequencies of the mnemonic and register set.');
        end

        rel_joint_freq = zeros(num_valid_messages,num_packed_inst);
        for x=1:num_valid_messages
            mnemonic = valid_messages_mnemonic(x,:);
            rd = valid_messages_rd(x,:);
            rs1 = valid_messages_rs1(x,:);
            rs2 = valid_messages_rs2(x,:);
            rs3 = valid_messages_rs3(x,:);
            for packed_inst=1:num_packed_inst
                if instruction_mnemonic_hotness.isKey(mnemonic{packed_inst})
                    reg_in_mnemonic_hotness = instruction_mnemonic_hotness(mnemonic{packed_inst});
                    curr_rd = rd{packed_inst};
                    curr_rs1 = rs1{packed_inst};
                    curr_rs2 = rs2{packed_inst};
                    curr_rs3 = rs3{packed_inst};
                    if reg_in_mnemonic_hotness.isKey(curr_rd) ...
                    && reg_in_mnemonic_hotness.isKey(curr_rs1) ...
                    && reg_in_mnemonic_hotness.isKey(curr_rs2)...
                    && reg_in_mnemonic_hotness.isKey(curr_rs3)
                        rel_joint_freq(x,packed_inst) = reg_in_mnemonic_hotness(curr_rd) * reg_in_mnemonic_hotness(curr_rs1) * reg_in_mnemonic_hotness(curr_rs2) * reg_in_mnemonic_hotness(curr_rs3);
                    else
                        break; % If one packed inst has a rel_joint_freq of 0, then the whole message will as well. We already initialized to 0.
                    end
                else % This could happen legally
                    rel_joint_freq(x,packed_inst) = 0;
                end
            end
        end
        
        % Compute probability of each message according to their groups
        valid_messages_probabilities = zeros(num_valid_messages,1);
        if num_packed_inst == 1
            valid_messages_probabilities = rel_joint_freq ./ sum(rel_joint_freq);
            %for x=1:num_valid_messages
            %    valid_messages_probabilities(x,1) = rel_joint_freq(x) / sum(rel_joint_freq);
            %end
        else
            valid_messages_probabilities = prod(rel_joint_freq,2) ./ sum(prod(rel_joint_freq,2));
            %for x=1:num_valid_messages
            %    valid_messages_probabilities(x,1) = prod(rel_joint_freq(x,:)) / sum(prod(rel_joint_freq,2));
            %end
        end
        
        if verbose == 1
            rel_joint_freq
            valid_messages_probabilities
        end
        
        % Determine list of equivalent targets - find all candidates with the highest probability
        highest_prob_mnemonic = max(valid_messages_probabilities);
        %highest_prob_mnemonic = 0;
        %for x=1:num_valid_messages
        %    if valid_messages_probabilities(x,1) >= highest_prob_mnemonic
        %       highest_prob_mnemonic = valid_messages_probabilities(x,1);
        %    end
        %end

        target_inst_indices = find(valid_messages_probabilities >= highest_prob_mnemonic - (1e-12));
        %target_inst_indices = zeros(1,1);
        %y = 1;
        %for x=1:num_valid_messages
        %    if valid_messages_probabilities(x,1) >= highest_prob_mnemonic-1e-12 && valid_messages_probabilities(x,1) <= highest_prob_mnemonic+1e-12
        %        target_inst_indices(y,1) = x;
        %        y = y+1;
        %    end
        %end

        % Special case: it is entirely possible based on SI that no valid messages have a probability > 0. In this case, put all valid messages as targets.
        if size(target_inst_indices,1) == 0
            target_inst_indices = (1:num_valid_messages)';
        end
    end

    % Choose recovery target
    if size(target_inst_indices,1) == 1 % Have only one recovery target
        target_inst_index = target_inst_indices(1); 
        %target_inst_index_backup = target_inst_index; % temp FIXME
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
            estimated_prob_correct = 0;
        else
            % FIXME won't work for non-probability based policies?
            if valid_messages_probabilities(target_inst_index) < crash_threshold
                suggest_to_crash = 1;
            end
            estimated_prob_correct = valid_messages_probabilities(target_inst_index);
        end
    else % Have several recovery targets
        if strcmp(policy, 'filter-pick-random') == 1 ...
            || strcmp(policy, 'filter-rank-pick-random') == 1 ...
            || strcmp(policy, 'filter-frequency-pick-random') == 1
            if verbose == 1
                display('LAST STEP: CHOOSE TARGET. Pick randomly. We recommend crashing if there are more than 2 equivalent targets here.');
            end

            if size(target_inst_indices,1) > 2
                suggest_to_crash = 1;
            end
            target_inst_index = target_inst_indices(randi(size(target_inst_indices,1),1));
            estimated_prob_correct = NaN;
        end

        if strcmp(policy, 'filter-rank-sort-pick-first') == 1 ...
            || strcmp(policy, 'filter-rank-rank-sort-pick-first') == 1
            if verbose == 1
                display('LAST STEP: CHOOSE TARGET. Pick the first in the sorted list of equivalent targets. We recommend crashing if there are more than 2 equivalent targets here.');
            end

            if size(target_inst_indices,1) > 2
                suggest_to_crash = 1;
            end
            target_inst_index = target_inst_indices(1);
            estimated_prob_correct = NaN;
        end

        if strcmp(policy, 'filter-frequency-sort-pick-first') == 1
            if verbose == 1
                display('LAST STEP: CHOOSE TARGET. Pick the first in the sorted list of equivalent targets. We recommend crashing if Pr{guessing correctly} < 0.5');
            end


            target_inst_index = target_inst_indices(1);
            if valid_messages_probabilities(target_inst_index) < crash_threshold
                suggest_to_crash = 1;
            end
            estimated_prob_correct = valid_messages_probabilities(target_inst_index);
        end

        if strcmp(policy, 'filter-frequency-sort-pick-longest-pad') == 1 ...
           || strcmp(policy, 'filter-joint-frequency-sort-pick-longest-pad') == 1
            if verbose == 1
                display('LAST STEP: CHOOSE TARGET. Pick the target that has the longest average (over packed instructions) run of leading 0s or 1s (longest pad). In a tie, pick first in sorted order. We recommend crashing if Pr{guessing correctly} < 0.5');
            end
            
            pad_lengths = zeros(size(target_inst_indices,1),num_packed_inst);
            for x=1:size(target_inst_indices,1)
                for packed_inst=1:num_packed_inst
                    pad_lengths(x,packed_inst) = compute_pad_length(candidate_valid_messages(target_inst_indices(x),(packed_inst-1)*32+1:(packed_inst-1)*32+32)); % assume instructions are 32 bits. FIXME: only valid for RV64G
                end
            end
            if num_packed_inst > 1
                max_avg_pad_length = max(mean(pad_lengths,2));
            else
                max_avg_pad_length = max(pad_lengths);
            end

            if verbose == 1
                pad_lengths
                max_avg_pad_length
            end

            max_avg_pad_length_indices = find(mean(pad_lengths,2) == max_avg_pad_length);
            %max_avg_pad_length_indices = 0;
            %y = 1;
            %for x=1:size(target_inst_indices,1)
            %    if mean(pad_lengths(x,:)) == max_avg_pad_length
            %        max_avg_pad_length_indices(y) = x;
            %        y = y+1;
            %    end
            %end
            target_inst_index = max_avg_pad_length_indices(1);

            % FIXME: this is a temporary analysis to see if the 2-fork idea may help
            %if size(max_avg_pad_length_indices,1) > 1
            %    target_inst_index_backup = max_avg_pad_length_indices(2);
            %elseif size(target_inst_indices,1) > 1
            %    target_inst_index_backup = target_inst_indices(2);
            %elseif size(candidate_valid_messages,1) > 1
            %    target_inst_index_backup = 2;
            %else
            %    target_inst_index_backup = 0;
            %end

            if valid_messages_probabilities(target_inst_index) < crash_threshold
                suggest_to_crash = 1;
            end
            estimated_prob_correct = valid_messages_probabilities(target_inst_index);
        end
    end
end

if verbose == 1
    target_inst_indices
    target_inst_index
    %target_inst_index_backup
end

%% Final result
if bailout == 1 % Special case where no candidates were valid and we handled it above by setting target_inst_index
    recovered_message = candidate_correct_messages(target_inst_index,:);
else % Typical case
    recovered_message = candidate_valid_messages(target_inst_index,:);
end

% FIXME: tmp fork-2 idea
%if target_inst_index_backup > 0
%    recovered_message_backup = candidate_valid_messages(target_inst_index_backup,:);
%else
%    recovered_message_backup = recovered_message;
%end
   
% FIXME: tmp fork-2 idea
recovered_successfully = (strcmp(recovered_message, original_message) == 1); %...
%                         || (strcmp(recovered_message_backup, original_message) == 1);

if verbose == 1
    recovered_successfully
    suggest_to_crash
end

if suggest_to_crash == 1
    fprintf(1, 'SUGGEST_TO_CRASH\n');
else
    fprintf(1,'%s\n', recovered_message);
end

