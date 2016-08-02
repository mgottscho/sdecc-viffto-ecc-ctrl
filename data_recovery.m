function [original_codeword, received_string, num_candidate_messages, recovered_message, suggest_to_crash, recovered_successfully] = data_recovery(architecture, n, k, original_message, error_pattern, code_type, policy, tiebreak_policy, cacheline, message_blockpos, verbose)
% TODO: better error handling and input handling

%architecture
n = str2num(n)
k = str2num(k)
%original_message
%error_pattern
%code_type
%policy
%tiebreak_policy
%cacheline
verbose = str2num(verbose)

words_per_block = size(cacheline,2);

% Init some return values
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

%% Encode the original message, then corrupt the codeword with the provided error pattern
if verbose == 1
    display('Getting the original codeword and generating the received (corrupted) string...');
end

original_codeword = secded_encoder(original_message,G);
received_string = dec2bin(bitxor(bin2dec(original_codeword), bin2dec(error_pattern)), n);

if verbose == 1
    original_codeword
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
if retval ~= 1
    display('FATAL! Something went wrong computing candidate-correct messages!');
    return;
end

%% Score the candidate-correct messages
candidate_correct_message_scores = NaN(size(candidate_correct_messages,1),1); % Init scores
if strcmp(policy, 'hamming') == 1
    %% Now compute scores for each candidate message
    % HAMMING METRIC
    % For each candidate message, compute the average Hamming distance to each of its neighboring words in the cacheline
    % For Hamming distance metric, the score can take a range of [0,k], where the score is the average Hamming distance in bits.
    for x=1:size(candidate_correct_messages,1) % For each candidate message
        score = 0;
        for blockpos=1:words_per_block % For each message in the cacheline (need to skip the message under test)
            if blockpos ~= message_blockpos
               score = score + my_hamming_dist(candidate_correct_messages(x,:),cacheline_bin{blockpos});
            end
        end
        score = score/(words_per_block-1);
        candidate_correct_message_scores(x) = score;
    end
elseif strcmp(policy, 'longest_run') == 1
    % LONGEST-0/1s METRIC
    % For each candidate message, compute the size of the longest sequence of consecutive 0s or 1s. The score is k - length of sequence, so that lower is better.
    % The score can take a range of [0,k], where the score is k - length of longest consecutive 0s or 1s in bits
    % Ignore the values of nearby words in the cache line.
    for x=1:size(candidate_correct_messages,1) % For each candidate message
        score = k - count_longest_run(candidate_correct_messages(x,:));
        if score < 0 || score > k
            print(['Error! score for longest 0/1s was ' num2str(score)]);
        end
        candidate_correct_message_scores(x) = score;
    end
elseif strcmp(policy, 'delta') == 1
    % DELTA METRIC
    % For each candidate message, compute the deltas from it to all the other words in the cacheline, using the candidate message as the base.
    % The score is the sum of squares of the deltas. FIXME: probable overflow issue?
    % The score can take a range of [0,MAX_UNSIGNED_INT]. Lower scores are better.
    for x=1:size(candidate_correct_messages,1) % For each candidate message
        score = Inf;
        base = my_bin2dec(candidate_correct_messages(x,:)); % Set base. This will be decimal integer value.
        deltas = NaN(words_per_block-1,1); % Init deltas. These will be decimal integer values.
        for blockpos=1:words_per_block % For each message in the cacheline (need to skip the message under test)
            if blockpos ~= message_blockpos % Skip the message under test
                deltas(blockpos) = base - my_bin2dec(cacheline_bin{blockpos}); % will be signed decimal integer
            end
        end
        score = sum(deltas.^2); % Sum of squares of deltas
        if score < 0 || score > uint64(-1) % this should be impossible
            display(['Error! Score was ' num2str(score)]);
        end
        candidate_correct_message_scores(x) = score;
    end
%elseif strcmp(policy, 'dbxw') == 1 % TODO: implement me!
else % error
    print(['Error! policy was ' policy]);
end

%% Now we have scores, let's rank and choose the best candidate message. LOWER SCORES ARE BETTER.
% TODO: how to decide when to crash? need to quantify level of variation or distinguishability between candidates..
min_score = Inf;
min_score_indices = NaN;
for x=1:size(candidate_correct_message_scores,1) % For each candidate message score
   if candidate_correct_message_scores(x) < min_score
       min_score = candidate_correct_message_scores(x);
   end
end

for x=1:size(candidate_correct_message_scores,1) % For each candidate message score
   if candidate_correct_message_scores(x) == min_score
       min_score_indices = x;
   end
end

target_message_score = min_score;
target_message_index = NaN;
if strcmp(tiebreak_policy, 'pick_first') == 1
    target_message_index = min_score_indices(1);
elseif strcmp(tiebreak_policy, 'pick_last') == 1
    target_message_index = min_score_indices(size(min_score_indices,1));
elseif strcmp(tiebreak_policy, 'pick_random') == 1
    target_message_index = min_score_indices(randi(size(min_score_indices,1),1));
else
    target_message_index = -1;
    display(['Error! tiebreak_policy was ' tiebreak_policy]);
end

%cacheline_hex
%candidate_correct_message_scores
%min_score
%min_score_indices
%message_blockpos
%target_message_index


num_candidate_messages = size(candidate_correct_messages,1);

%% Compute whether we got the correct answer or not for this data/error pattern pairing
if target_message_index == message_blockpos % Success!
    recovered_successfully = 1;
    suggest_to_crash = 0; % TODO: implement crash policy
else % Failed to correct error -- corrupted recovery
    recovered_successfully = 0;
    suggest_to_crash = 0; % TODO: implement crash policy
end



