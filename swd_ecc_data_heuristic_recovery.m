function swd_ecc_data_heuristic_recovery(architecture, benchmark, n, k, num_words, words_per_block, input_filename, output_filename, n_threads, code_type)
% This function iterates over a series of data cache lines that are statically extracted
% from a compiled program that was executed and produced a dynamic memory trace.
% We choose a cache line and word within a cache line randomly.
% The script encodes the data/message in a specified SECDED encoder.
% The script then iterates over all possible 2-bit error patterns on the
% resulting codeword. Each of these 2-bit patterns are decoded by our
% SECDED code and should all be "detected but uncorrectable." For each of
% these 2-bit errors, we flip a single bit one at a time and decode again.
% We should obtain X received codewords that are indicated as corrected.
% These X codewords are "candidates" for the original encoded message.
% The function then tries to determine which of
% the X candidate messages was the most likely one to recover.
%
% Input arguments:
%   architecture --     String: '[mips|alpha|riscv]'
%   benchmark --        String
%   n --                String: '[39|72]'
%   k --                String: '[32|64]'
%   num_words --        String: '[1|2|3|...]'
%   words_per_block --  String: '[1|2|3|...]'
%   input_filename --   String
%   output_filename --  String
%   n_threads --        String: '[1|2|3|...]'
%   code_type --        String: '[hamming|pi]'
%
% Returns:
%   Nothing.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

architecture
benchmark
n = str2num(n)
k = str2num(k)
num_words = str2num(num_words)
words_per_block = str2num(words_per_block)
input_filename
output_filename
n_threads = str2num(n_threads)
code_type

r = n-k;

%% Set up parallel computing
%pctconfig('preservejobs', true);
%mypool = parpool(n_threads);

%% Read data under test as bit-strings from file
display('Reading inputs...');
fid = fopen(input_filename);
file_contents = textscan(fid, '%s', 'Delimiter', ',');
fclose(fid);
file_contents = file_contents{1};
file_contents = reshape(file_contents, (8+words_per_block), size(file_contents,1)/(8+words_per_block))';
%trace_hex = textread(input_filename, '%8c');
trace_paddr = char(file_contents(:,3));
trace_blkpos = char(file_contents(:,8));
trace_cachelines_hex = cell(size(file_contents,1),words_per_block);
trace_cachelines_bin = cell(size(file_contents,1),words_per_block);
for i=1:size(file_contents,1)
    for j=1:words_per_block
        trace_cachelines_hex{i,j} = char(file_contents(i,8+j));
        tmp = trace_cachelines_hex{i,j};
        trace_cachelines_hex{i,j} = tmp(1,3:end);
        trace_cachelines_bin{i,j} = my_hex2bin(trace_cachelines_hex{i,j});
    end
end

%% Construct a matrix containing all possible 2-bit error patterns as bit-strings.
display('Constructing error-pattern matrix...');
num_error_patterns = nchoosek(n,2);
error_patterns = repmat('0',num_error_patterns,n);
num_error = 1;
for i=1:n-1
    for j=i+1:n
        error_patterns(num_error, i) = '1';
        error_patterns(num_error, j) = '1';
        num_error = num_error + 1;
    end
end

%% Get our ECC encoder and decoder matrices
display('Getting ECC encoder and decoder matrices...');
[G,H] = getSECDEDCodes(n,code_type);

total_num_cachelines = size(trace_cachelines_bin,1);

%% Randomly choose words from the trace, and do the fun parts on those
rng('shuffle'); % Seed RNG based on current time
sampled_cacheline_indices = randperm(total_num_cachelines, num_words); % Randomly permute the indices of cachelines. We will choose the first num_words of the permuted list to evaluate. Then, from each of these cachelines, we randomly pick one word from within it.
sampled_blockpos_indices = randi(words_per_block, 1, num_words); % Randomly generate the block position within the cacheline
sampled_trace_cachelines_hex = trace_cachelines_hex(sampled_cacheline_indices,:);
sampled_trace_cachelines_bin = trace_cachelines_bin(sampled_cacheline_indices,:);

display(['Number of randomly-sampled words to test SWD-ECC: ' num2str(num_words)]);
display('Evaluating SWD-ECC...');

results_candidate_messages = NaN(num_words,num_error_patterns); % Init
success = NaN(num_words, num_error_patterns); % Init

for i=1:num_words % Parallelize loop across separate threads, since this could take a long time. Each word is a totally independent procedure to perform.
    %% Get the cacheline and "message," which is the original word, i.e., the ground truth from input file.
    cacheline_hex  = sampled_trace_cachelines_hex{i,:};
    cacheline_bin  = sampled_trace_cachelines_bin{i,:};
    message_hex = cacheline_hex{sampled_blockpos_indices(i)};
    message_bin = cacheline_bin{sampled_blockpos_indices(i)};
    
    %% Progress indicator
    % This will not show accurate progress if the loop is parallelized
    % across threads with parfor, since they can execute out-of-order
    display(['Word # ' num2str(i) ' is index ' num2str(sampled_cacheline_indices(i)) ' cacheline in the program, block position ' num2str(sampled_blockpos_indices(i)) '. hex: ' message_hex]);
    
    %% Encode the message.
    codeword = secded_encoder(message_bin,G);
    
    %% Iterate over all possible 2-bit error patterns.
    for j=1:num_error_patterns
        %% Inject 2-bit error.
        error = error_patterns(j,:);
        received_codeword = my_bitxor(codeword, error);
        
        %% Attempt to decode the corrupted codeword, check that num_error_bits is 2
        [decoded_message, num_error_bits] = secded_decoder(received_codeword, H, code_type);
        
        % Sanity check
        if num_error_bits ~= 2
           display(['OOPS! Problem with error pattern #' num2str(j) ' on codeword #' num2str(i) '. Got ' num2str(num_error_bits) ' error bits in error.']);
           continue;
        end
        
        %% Flip 1 bit at a time on the received codeword, and attempt decoding on each. We should find several bit positions that decode successfully with just a single-bit error.
        x = 1;
        candidate_correct_messages = repmat('X',n,k); % Pre-allocate for worst-case capacity. X is placeholder
        for pos=1:n
           %% Flip the bit
           error = repmat('0',1,n);
           error(pos) = '1';
           candidate_codeword = my_bitxor(received_codeword,error);
           
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
        
        %% Now compute scores for each candidate message
        % For each candidate message, compute the average Hamming distance to each of its neighboring words in the cacheline
        % For Hamming distance metric, the score can take a range of [0,k], where the score is the average Hamming distance in bits.
        % FIXME: not yet tested this part
        candidate_correct_message_scores = NaN(size(candidate_correct_messages,1),1); % Init scores
        for x=1:size(candidate_correct_messages,1) % For each candidate message
            score = 0;
            for blockpos=1:words_per_block % For each message in the cacheline (need to skip the message under test)
                if blockpos ~= sampled_blockpos_indices(i) % Skip the message under test, its score will be NaN
                   score = score + my_hamming_dist(candidate_correct_messages(x,:),cacheline_bin{blockpos});
                end
            end
            score = score/(words_per_block-1);
            candidate_correct_message_scores(x) = score;
        end

        %% Now we have scores, let's rank and choose the best candidate message.
        % FIXME: not yet tested this part
        target_message_index = NaN;
        target_message_score = Inf;
        for x=1:size(candidate_correct_message_scores,1) % For each candidate message score
           if candidate_correct_message_scores(x) < target_message_score
               target_message_index = x;
               target_message_score = candidate_correct_message_scores(x);
           end
        end
        
        %% Store results of the number of candidate correct messages for this data/error pattern pair
        results_candidate_messages(i,j) = num_candidate_messages;

        %% Compute whether we got the correct answer or not for this data/error pattern pairing
        % FIXME: not yet tested this part
        if target_message_index == sampled_blockpos_indices(i) % Success!
            success(i,j) = 1;
        else % Failed to correct error -- corrupted recovery
            success(i,j) = 0;
        end

        %% TODO: Compute whether we would have crashed instead
    end        
end

%% Save all variables
display('Saving outputs...');
save(output_filename);
display('Done!');

%% Shut down parallel computing pool
delete(mypool);
