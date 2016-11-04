function [candidate_correct_message_scores, recovered_message, suggest_to_crash, recovered_successfully] = data_recovery(architecture, n, k, original_message, candidate_correct_messages, policy, cacheline_bin, message_blockpos, crash_threshold, verbose)
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
%   n --                String: '[39|45|72|79|144]'
%   k --                String: '[32|64|128]'
%   original_message -- Binary String of length k bits/chars
%   candidate_correct_messages -- Nx1 cell array of binary strings, each k bits/chars long
%   policy --           String: '[hamming-pick-random|longest-run-pick-random|delta-pick-random|dbx-pick-random]'
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
    candidate_correct_messages
    policy
    cacheline_bin
    message_blockpos
    crash_threshold
    verbose
end

%rng('shuffle'); % Seed RNG based on current time -- FIXME: comment out for speed? If we RNG in swd_ecc_offline_data_heuristic_recovery then we shouldn't need to do it again...

%% Init some return values
recovered_message = repmat('X',1,k);
suggest_to_crash = 0;
recovered_successfully = 0;

if ~isdeployed
    addpath ecc common rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
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
elseif strcmp(policy, 'hamming-pick-random') == 1
    %% Now compute scores for each candidate message
    % HAMMING METRIC
    % For each candidate message, compute the average Hamming distance to each of its neighboring words in the cacheline
    % For Hamming distance metric, the score can take a range of [0,k], where the score is the average Hamming distance in bits.
    if verbose == 1
        display('RECOVERY STEP 1: Compute scores of all candidate-correct messages by average Hamming distance to neighboring words in the cacheline. Lower scores are better.');
    end
    for x=1:size(candidate_correct_messages,1) % For each candidate message
        score = 0;
        for blockpos=1:words_per_block % For each message in the cacheline (need to skip the message under test)
            if blockpos ~= message_blockpos
               %score = score + my_hamming_dist(candidate_correct_messages(x,:),parsed_cacheline_bin{blockpos});
               % my_hamming_dist() was very slow. here's a better version...
               score = score + sum(candidate_correct_messages(x,:) ~= parsed_cacheline_bin{blockpos});
            end
        end
        score = score/(words_per_block-1);
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
        base = my_bin2dec(candidate_correct_messages(x,:)); % Set base. This will be decimal uint64 value.
        deltas = NaN(words_per_block-1,1); % Init deltas. These will be decimal uint64 values
        for blockpos=1:words_per_block % For each message in the cacheline (need to skip the message under test)
            if blockpos ~= message_blockpos % Skip the message under test
                word = my_bin2dec(parsed_cacheline_bin{blockpos});
                % Due to behavior of uint64 in MATLAB, underflow and overflow do not occur - they simply "saturate" at 0 and max of uint64 values. So we take the abs of deltas only to avoid losing information.
                if base > word
                    deltas(blockpos) = base - word;
                else
                    deltas(blockpos) = word - base;
                end
            end
        end
        score = sum(deltas.^2); % Sum of squares of abs-deltas. Score is now a double.
        candidate_correct_message_scores(x) = score; % Each score is a double.
    end
elseif strcmp(policy, 'dbx-pick-random') == 1 
    % DBX sparsity metric
    % For each candidate message, compute the DBX transform of the cacheline using the given candidate-correct message. 
    % The score is the proportion of 1s in the matrix.
    % The score can take a range of [0,1]. Lower scores are better.
    if verbose == 1
        display('RECOVERY STEP 1: Compute scores of all candidate-correct messages by performing the Delta-Bitplane-XOR (DBX) transform of the entire cacheline using the given candidate-correct message. Lower scores are better. Scores are the proportion of 1s in the DBX output matrix.')
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
% TODO: how to decide when to crash? need to quantify level of variation or distinguishability between candidates..
min_score = min(candidate_correct_message_scores);
%min_score = Inf;
%for x=1:size(candidate_correct_message_scores,1) % For each candidate message score
%   if candidate_correct_message_scores(x) < min_score
%       min_score = candidate_correct_message_scores(x);
%   end
%end

min_score_indices = find(candidate_correct_message_scores <= min_score+1e-12);
%min_score_indices = zeros(1,1);
%y = 1;
%for x=1:size(candidate_correct_message_scores,1) % For each candidate message score
%   if candidate_correct_message_scores(x) >= min_score-1e-4 && candidate_correct_message_scores(x) <= min_score+1e-4 % Tolerance of 0.0001 as we are often comparing floating point scores
%       min_score_indices(y,1) = x;
%       y = y+1;
%   end
%end

if verbose == 1
    min_score
    min_score_indices
end

target_message_score = min_score;
target_message_index = NaN;
if strcmp(policy, 'baseline-pick-random') == 1
    target_message_index = randi(size(candidate_correct_messages,1),1);
elseif strcmp(policy, 'hamming-pick-random') == 1 || strcmp(policy, 'longest-run-pick-random') == 1 || strcmp(policy, 'delta-pick-random') == 1 || strcmp(policy, 'dbx-pick-random') == 1
    target_message_index = min_score_indices(randi(size(min_score_indices,1),1));
else
    display(['FATAL! Unknown policy: ' policy]);
    return;
end

if verbose == 1
    target_message_index
end

recovered_message = candidate_correct_messages(target_message_index,:);

%% Compute whether we got the correct answer or not for this data/error pattern pairing
recovered_successfully = (strcmp(recovered_message, original_message) == 1);

%% TODO: implement crash policy using crash_threshold
suggest_to_crash = 0;

if verbose == 1
    recovered_successfully
    suggest_to_crash
end

fprintf(1,'%s\n', recovered_message);



