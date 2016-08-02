function swd_ecc_offline_data_heuristic_recovery(architecture, benchmark, n, k, num_words, words_per_block, input_filename, output_filename, n_threads, code_type, policy, tiebreak_policy)
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
%   architecture --     String: '[mips|alpha|rv64g]'
%   benchmark --        String
%   n --                String: '[39|72]'
%   k --                String: '[32|64]'
%   num_words --        String: '[1|2|3|...]'
%   words_per_block --  String: '[1|2|3|...]'
%   input_filename --   String
%   output_filename --  String
%   n_threads --        String: '[1|2|3|...]'
%   code_type --        String: '[hsiao1970|davydov1991]'
%   policy --           String: '[hamming|longest_run|delta]'
%   tiebreak_policy --String: '[pick_first|pick_last|pick_random]'
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
policy
tiebreak_policy

r = n-k;

if ~isdeployed
    addpath ecc common rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
end

%% Set up parallel computing
pctconfig('preservejobs', true);
mypool = parpool(n_threads);

%% Read data under test as bit-strings from file
display('Reading inputs...');
fid = fopen(input_filename);
file_contents = textscan(fid, '%s', 'Delimiter', ',');
fclose(fid);
file_contents = file_contents{1};
file_contents = reshape(file_contents, (9+words_per_block), size(file_contents,1)/(9+words_per_block))';
%trace_hex = textread(input_filename, '%8c');
trace_paddr = char(file_contents(:,4));
trace_blkpos = char(file_contents(:,9));
trace_cachelines_hex = cell(size(file_contents,1),words_per_block);
trace_cachelines_bin = cell(size(file_contents,1),words_per_block);
for i=1:size(file_contents,1)
    for j=1:words_per_block
        trace_cachelines_hex{i,j} = char(file_contents(i,9+j));
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
%display('Getting ECC encoder and decoder matrices...');
%[G,H] = getSECDEDCodes(n,code_type);

%total_num_cachelines = size(trace_cachelines_bin,1);

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
could_have_crashed = NaN(num_words, num_error_patterns); % Init
success_with_crash_option = NaN(num_words, num_error_patterns); % Init
verbose_recovery = '0';

parfor i=1:num_words % Parallelize loop across separate threads, since this could take a long time. Each word is a totally independent procedure to perform.
    %% Get the cacheline and "message," which is the original word, i.e., the ground truth from input file.
    cacheline_hex  = sampled_trace_cachelines_hex(i,:);
    cacheline_bin  = sampled_trace_cachelines_bin(i,:);
    message_hex = cacheline_hex{sampled_blockpos_indices(i)};
    message_bin = cacheline_bin{sampled_blockpos_indices(i)};
    
    %% Iterate over all possible 2-bit error patterns.
    for j=1:num_error_patterns
        error = error_patterns(j,:);

        %% Do heuristic recovery for this message/error pattern combo.
        [original_codeword, received_string, num_candidate_messages, recovered_message, suggest_to_crash, recovered_successfully] = data_recovery('rv64g', num2str(n), num2str(k), message_bin, error, code_type, policy, tiebreak_policy, cacheline_bin, sampled_blockpos_indices(i), verbose_recovery);

        %% Store results for this message/error pattern pair
        results_candidate_messages(i,j) = num_candidate_messages;
        success(i,j) = recovered_successfully;
        could_have_crashed(i,j) = suggest_to_crash;
        if suggest_to_crash == 1
            success_with_crash_option(i,j) = ~success(i,j); % If success is 1, then we robbed ourselves of a chance to recover. Otherwise, if success is 0, we saved ourselves from corruption and potential failure!
        else
            success_with_crash_option(i,j) = success(i,j); % If we decide not to crash, success rate is same.
        end
    end

    %% Progress indicator
    % This will not show accurate progress if the loop is parallelized
    % across threads with parfor, since they can execute out-of-order
    display(['Completed word # ' num2str(i) ' is index ' num2str(sampled_cacheline_indices(i)) ' cacheline in the program, block position ' num2str(sampled_blockpos_indices(i)) '. hex: ' message_hex]);
end

%% Save all variables
display('Saving outputs...');
save(output_filename);
display('Done!');

%% Shut down parallel computing pool
delete(mypool);

end
