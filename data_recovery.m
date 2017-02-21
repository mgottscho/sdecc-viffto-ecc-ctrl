function [candidate_correct_message_scores, recovered_message, suggest_to_crash, recovered_successfully] = data_recovery(architecture, n, k, original_message, candidate_correct_messages_bin, policy, cacheline_bin, message_blockpos, crash_threshold, verbose)
% This function attempts to heuristically recover from a DUE affecting a single received string.
% The message is assumed to be data of arbitrary type stored in memory.
% To compute candidate codewords, we trial flip bits and decode using specified ECC decoder.
% We should obtain a set of unique candidate codewords.
% Based on the policy, we then try to recover the most likely corresponding data-message.
%
% Note that all data words should be in their NATIVE ENDIANNESS for absolute correctness. This is because the data type of a value stored in memory is generally not equal to the message size k as used by the ECC encoder/decoder.
%
% Input arguments:
%   architecture --     String: '[rv64g]'
%   n --                String: '[17|18|19|33|34|35|39|45|72|79|144]'
%   k --                String: '[16|32|64|128]'
%   original_message -- Binary String of length k bits/chars
%   candidate_correct_messages_bin -- Set of k-bit binary strings, e.g. '00001111000...10010,0000000....00000,...'.
%   policy --           String: '[hamming-pick-random|hamming-pick-longest-run|longest-run-pick-random|delta-pick-random|fdelta-pick-random|dbx-longest-run-pick-random|dbx-weight-pick-longest-run|dbx-longest-run-pick-lowest-weight]'
%   cacheline_bin --    String: Set of words_per_block k-bit binary strings, e.g. '0001010101....00001,0000000000.....00000,...,111101010...00101'. words_per_block is inferred by the number of binary strings that are delimited by commas.
%   message_blockpos -- String: '[0-(words_per_block-1)]' denoting the position of the message under test within the cacheline. This message should match original_message argument above.
%   crash_threshold -- String of a scalar. Policy-defined semantics and range.
%   verbose -- '1' if you want console printouts of progress to stdout.
%
% Returns:
%   candidate_correct_message_scores -- Nx1 numeric scores corresponding to each candidate message, where lower is better.
%   recovered_message -- k-bit message that corresponds to our target for heuristic recovery
%   suggest_to_crash -- 0 if we are confident in recovery, 1 if we recommend crashing out instead
%   recovered_successfully -- 1 if we matched original_message, 0 otherwise
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

n = str2double(n);
k = str2double(k);
crash_threshold = str2double(crash_threshold);
verbose = str2double(verbose);

if verbose == 1
    architecture
    n
    k
    original_message
    candidate_correct_messages_bin
    policy
    cacheline_bin
    message_blockpos
    crash_threshold
    verbose
end

rng('shuffle'); % Seed RNG based on current time

%% Init some return values
recovered_message = repmat('X',1,k);
suggest_to_crash = 0;
recovered_successfully = 0;

if ~isdeployed
    addpath ecc common rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
end

%% Parse candidate_correct_messages_bin to convert into char matrix
candidate_correct_messages = repmat('X',1,k);
done_parsing = 0;
i = 1;
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

if verbose == 1
    candidate_correct_messages
end

%% Parse cacheline_bin to convert into cell array
remain = cacheline_bin;
parsed_cacheline_bin = cell(1,1); % Init
done_parsing = 0;
i = 1;
while done_parsing == 0
   [token,remain] = strtok(remain,',');

   % Check input validity of token to ensure k-bits of '0' or '1' and no other value
   if (sum(token == '1')+sum(token == '0')) ~= size(token,2)
       display(['FATAL! Cacheline entry ' num2str(i) ' has non-binary character: ' token]);
       return;
   end
   if size(token,2) ~= k
       display(['FATAL! Cacheline entry ' num2str(i) ' has ' num2str(size(token,2)) ' bits, but ' num2str(k) ' bits are needed.']);
       return;
   end

   parsed_cacheline_bin{i,1} = token;
   i = i+1;

   if size(remain,2) == 0
       done_parsing = 1;
   end
end

words_per_block = size(parsed_cacheline_bin,1);

if verbose == 1
    words_per_block
    parsed_cacheline_bin
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

%% Score the candidate-correct messages
candidate_correct_message_scores = NaN(size(candidate_correct_messages,1),1); % Init scores
if strcmp(policy, 'baseline-pick-random') == 1
    if verbose == 1
        display('RECOVERY STEP 1: Each candidate-correct message is scored equally.');
    end
    candidate_correct_message_scores = ones(size(candidate_correct_messages,1),1); % All outcomes equally scored
elseif strcmp(policy, 'hamming-pick-random') == 1 ...
    || strcmp(policy, 'hamming-pick-longest-run') == 1
    %% Now compute scores for each candidate message
    % HAMMING METRIC
    % For each candidate message, compute the average Hamming distance to each of its neighboring words in the cacheline
    % For Hamming distance metric, the score can take a range of [0,k], where the score is the average Hamming distance in bits.
    if verbose == 1
        display('RECOVERY STEP 1: Compute scores of all candidate-correct messages by ARITHMETIC MEAN OF Hamming distance to neighboring words in the cacheline. Lower scores are better.');
    end
    for x=1:size(candidate_correct_messages,1) % For each candidate message
        score = 0;
        hamming_distances = NaN(words_per_block-1,1);
        y = 1;
        for blockpos=1:words_per_block % For each message in the cacheline (need to skip the message under test)
            if blockpos ~= message_blockpos
               hamming_distances(y) = sum(candidate_correct_messages(x,:) ~= parsed_cacheline_bin{blockpos});

               % MEAN HAMMING DISTANCE 
               score = score + hamming_distances(y);
               
               y = y+1;
            end
        end
        % MEAN HAMMING DISTANCE
        score = score/(words_per_block-1);
               
        % MEDIAN HAMMING DISTANCE
        %score = median(hamming_distances);

        candidate_correct_message_scores(x) = score;
    end
elseif strcmp(policy, 'longest-run-pick-random') == 1
    % LONGEST-0/1s METRIC
    % For each candidate message, compute the size of the longest sequence of consecutive 0s or 1s. The score is k - length of sequence, so that lower is better.
    % The score can take a range of [0,k], where the score is k - length of longest consecutive 0s or 1s in bits
    % Ignore the values of nearby words in the cache line.
    if verbose == 1
        display('RECOVERY STEP 1: Compute scores of all candidate-correct messages by longest run of either 0s or 1s. Ignore values of neighboring words in cacheline. Lower scores are better.');
    end
    for x=1:size(candidate_correct_messages,1) % For each candidate message
        score = k - count_longest_run(candidate_correct_messages(x,:));
        if score < 0 || score > k
            print(['Error! score for longest 0/1s was ' num2str(score)]);
        end
        candidate_correct_message_scores(x) = score;
    end
elseif strcmp(policy, 'delta-pick-random') == 1
    % DELTA METRIC
    % For each candidate message, compute the deltas from it to all the other words in the cacheline, using the candidate message as the base.
    % The score is the sum of squares of the deltas.
    % The score can take a range of [0,MAX_UNSIGNED_INT]. Lower scores are better.
    if verbose == 1
        display('RECOVERY STEP 1: Compute scores of all candidate-correct messages by squaring the sum of deltas to all neighboring words in the cacheline (when each word is interpreted as a k-bit unsigned integer). Lower scores are better.');
    end
    for x=1:size(candidate_correct_messages,1) % For each candidate message
        score = Inf;
        base = my_bin2dec(candidate_correct_messages(x,:),k); % Set base. This will be decimal uint64 value.
        deltas = NaN(words_per_block-1,1); % Init deltas. These will be decimal uint64 values
        for blockpos=1:words_per_block % For each message in the cacheline (need to skip the message under test)
            if blockpos ~= message_blockpos % Skip the message under test
                word = my_bin2dec(parsed_cacheline_bin{blockpos},k);
                % Due to behavior of uint64 in MATLAB, underflow and overflow do not occur - they simply "saturate" at 0 and max of respective unsigned int values. So we take the abs of deltas only to avoid losing information.
                if base > word
                    deltas(blockpos) = base - word;
                else
                    deltas(blockpos) = word - base;
                end
            end
        end
        score = sum(deltas(~isnan(deltas)).^2); % Sum of squares of abs-deltas. Score is now a double.
        candidate_correct_message_scores(x) = score; % Each score is a double.
    end
elseif strcmp(policy, 'fdelta-pick-random') == 1
    % FLOAT-DELTA METRIC
    % For each candidate message, compute the float-deltas from it to all the other words in the cacheline, using the candidate message as the base.
    % The score is the sum of squares of the float-deltas.
    % The score can take a range of [0,MAX_UNSIGNED_INT]. Lower scores are better.
    if verbose == 1
        display('RECOVERY STEP 1: Compute scores of all candidate-correct messages by squaring the sum of float-deltas to all neighboring words in the cacheline (when each word is interpreted as a k-bit float). Lower scores are better.');
    end
    for x=1:size(candidate_correct_messages,1) % For each candidate message
        score = Inf;
        if k == 64
            base = typecast(my_bin2dec(candidate_correct_messages(x,:),k), 'double'); 
        elseif k == 32
            base = typecast(my_bin2dec(candidate_correct_messages(x,:),k), 'single');
        elseif k == 16 % TODO: support 16-bit float
            display('ERROR TODO: support 16-bit float');
        else
            display(['ERROR! Cannot use fdelta for k = ' k]);
        end
        deltas = NaN(words_per_block-1,1); % Init deltas. 
        for blockpos=1:words_per_block % For each message in the cacheline (need to skip the message under test)
            if blockpos ~= message_blockpos % Skip the message under test
                if k == 64
                    word = typecast(my_bin2dec(parsed_cacheline_bin{blockpos},k), 'double');
                elseif k == 32
                    word = typecast(my_bin2dec(parsed_cacheline_bin{blockpos},k), 'single');
                elseif k == 16 % TODO: support 16-bit float
                    display('ERROR TODO: support 16-bit float');
                else
                    display(['ERROR! Cannot use fdelta for k = ' k]);
                end
                deltas(blockpos) = base - word;
            end
        end

        if verbose == 1
            base
            deltas
        end

        score = sum(deltas(~isnan(deltas)).^2); % Sum of squares of abs-deltas. Score is now a double.
        candidate_correct_message_scores(x) = score; % Each score is a double.
    end
elseif strcmp(policy, 'dbx-longest-run-pick-random') == 1 ...
    || strcmp(policy, 'dbx-longest-run-pick-lowest-weight') == 1
    % DBX longest run metric
    % For each candidate message, compute the DBX transform of the cacheline using the given candidate-correct message. 
    % The score is avg k+1 - maximum 0 run length over all of DBX matrix.
    % The score can take a range of [0,k+1]. Lower scores are better.
    if verbose == 1
        display('RECOVERY STEP 1: Compute scores of all candidate-correct messages by performing the Delta-Bitplane-XOR (DBX) transform of the entire cacheline using the given candidate-correct message. Lower scores are better. Scores are averaged k+1 - maximum run length of 0 over all of DBX output matrix.')
    end
    for x=1:size(candidate_correct_messages,1)
        reordered_cacheline_with_candidate_message = repmat('X',size(parsed_cacheline_bin,1),k);
        reordered_cacheline_with_candidate_message(1,:) = candidate_correct_messages(x,:);
        z = 1;
        for y=2:size(reordered_cacheline_with_candidate_message,1)
            if z ~= message_blockpos 
                reordered_cacheline_with_candidate_message(y,:) = parsed_cacheline_bin{z,1};
            end
            z = z+1; 
        end
        [DBX_bin, delta_bin] = dbx_transform(reordered_cacheline_with_candidate_message);

        if verbose == 1
            delta_bin
            DBX_bin
        end

        score = 0;
        for y=1:size(DBX_bin,1)
            score = score + (k+1 - count_longest_run(DBX_bin(y,:)));
        end
        score = score / size(DBX_bin,1);
        candidate_correct_message_scores(x) = score;
    end
elseif strcmp(policy, 'dbx-weight-pick-longest-run') == 1 
    % DBX sparsity metric
    % For each candidate message, compute the DBX transform of the cacheline using the given candidate-correct message. 
    % The score is the fraction of 1s in the DBX matrix.
    % The score can take a range of [0,1]. Lower scores are better.
    if verbose == 1
        display('RECOVERY STEP 1: Compute scores of all candidate-correct messages by performing the Delta-Bitplane-XOR (DBX) transform of the entire cacheline using the given candidate-correct message. Lower scores are better. Scores are the fraction of 1s in the DBX output matrix.')
    end
    for x=1:size(candidate_correct_messages,1)
        cacheline_with_candidate_message = cell2mat(parsed_cacheline_bin);
        cacheline_with_candidate_message(message_blockpos,:) = candidate_correct_messages(x,:);
        [DBX_bin, delta_bin] = dbx_transform(cacheline_with_candidate_message);

        if verbose == 1
            delta_bin
            DBX_bin
        end

        score = sum(sum(DBX_bin=='1')) / prod(size(DBX_bin));
        candidate_correct_message_scores(x) = score;
    end
else % error
    display(['FATAL! Unknown policy: ' policy]);
    return;
end
    
if verbose == 1
    candidate_correct_message_scores
end

%% Now we have scores, let's rank and choose the best candidate message. LOWER SCORES ARE BETTER.
min_score = min(candidate_correct_message_scores);
min_score_indices = find(candidate_correct_message_scores <= min_score+1e-12);

if verbose == 1
    min_score
    min_score_indices
end

target_message_score = min_score;
target_message_index = NaN;
if strcmp(policy, 'baseline-pick-random') == 1
    target_message_index = randi(size(candidate_correct_messages,1),1);
elseif strcmp(policy, 'hamming-pick-random') == 1 || strcmp(policy, 'longest-run-pick-random') == 1 || strcmp(policy, 'delta-pick-random') == 1 || strcmp(policy, 'fdelta-pick-random') == 1 || strcmp(policy, 'dbx-longest-run-pick-random') == 1
    target_message_index = min_score_indices(randi(size(min_score_indices,1),1));
elseif strcmp(policy, 'hamming-pick-longest-run') == 1 ...
    || strcmp(policy, 'dbx-weight-pick-longest-run') == 1
    if verbose == 1
        display('LAST STEP: CHOOSE TARGET. Pick the target that has the longest run of 0s or 1s. In a tie, pick first in sorted order.');
    end

    run_lengths = zeros(size(min_score_indices,1),1);
    max_run_length = -1;
    target_message_index = 0;
    for x=1:size(min_score_indices,1)
        run_lengths(x) = count_longest_run(candidate_correct_messages(min_score_indices(x),:));
        if run_lengths(x) > max_run_length
            max_run_length = run_lengths(x);
            target_message_index = min_score_indices(x);
        end
    end
    
    % FIXME: this is a temporary analysis to see if the 2-fork idea may help
    %if size(min_score_indices,1) > 1
    %    target_inst_index_backup = min_score_indices(randi(size(min_score_indices,1)));
    %elseif size(candidate_valid_messages,1) > 1
    %    target_inst_index_backup = randi(size(candidate_correct_messages,1));
    %else
    %    target_inst_index_backup = 0;
    %end

elseif strcmp(policy, 'dbx-longest-run-pick-lowest-weight') == 1
    if verbose == 1
        display('LAST STEP: CHOOSE TARGET. Pick the target with the lowest Hamming weight.');
    end
    
    weights = zeros(size(min_score_indices,1),1);
    min_weight = Inf;
    target_message_index = 0;
    for x=1:size(min_score_indices,1)
        weights(x) = sum(candidate_correct_messages(min_score_indices(x),:) == '1');
        if weights(x) < min_weight
            min_weight = weights(x);
            target_message_index = min_score_indices(x);
        end
    end

    if verbose == 1
        weights
    end
else
    display(['FATAL! Unknown policy: ' policy]);
    return;
end

if verbose == 1
    target_message_index
end

%% Floating point-specific crash policy: suggest to crash if candidate messages or cacheline neighbors do not share common sign and exponent bits
if strcmp(policy, 'fdelta-pick-random') == 1
    if k == 32
        signexp_start = 1;
        signexp_end = 9;
    else
        display('Error! Currently do not support floats for k ~= 32');
        signexp_start = 0;
        signexp_end = 0;
    end
    suggest_to_crash = 0;
    if strcmp(repmat(candidate_correct_messages(1,signexp_start:signexp_end),size(candidate_correct_messages,1),1), candidate_correct_messages(:,signexp_start:signexp_end)) ~= 1 % Check to see if candidate messages share common sign and exp bits
        suggest_to_crash = 1;
    else % Check to see if cacheline words share common sign and exponent bits
        first_word = parsed_cacheline_bin{1};
        for word=2:words_per_block
           current_word = parsed_cacheline_bin{word};
           if strcmp(first_word(signexp_start:signexp_end), current_word(signexp_start:signexp_end)) ~= 1
               suggest_to_crash = 1;
               break;
           end
        end
    end
else
    %% Default crash policy: suggest crash if the min score is not at least crash_threshold*std dev below the mean score.
    std_dev_scores = std(candidate_correct_message_scores);
    mean_score = mean(candidate_correct_message_scores);
    if min_score <= mean_score - (crash_threshold * std_dev_scores)
        suggest_to_crash = 0;
    else
        suggest_to_crash = 1;
    end
end

%% Compute whether we got the correct answer or not for this data/error pattern pairing
recovered_message = candidate_correct_messages(target_message_index,:);

% FIXME: tmp fork-2 idea
%if target_inst_index_backup > 0
%    recovered_message_backup = candidate_valid_messages(target_inst_index_backup,:);
%else
%    recovered_message_backup = recovered_message;
%end

% FIXME: tmp fork-2 idea
recovered_successfully = (strcmp(recovered_message, original_message) == 1);% ...
%                         || (strcmp(recovered_message_backup, original_message) == 1);

if verbose == 1
    recovered_successfully
    suggest_to_crash
end

fprintf(1,'%s\n', recovered_message);



