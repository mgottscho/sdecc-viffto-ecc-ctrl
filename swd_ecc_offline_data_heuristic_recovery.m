function swd_ecc_offline_data_heuristic_recovery(architecture, benchmark, n, k, num_words, num_sampled_error_patterns, words_per_block, input_filename, output_filename, n_threads, code_type, policy, crash_threshold, verbose_recovery, file_version)
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
%   architecture --     String: '[rv64g]'
%   benchmark --        String
%   n --                String: '[17|18|19|33|34|35|39|45|72|79|144]'
%   k --                String: '[16|32|64|128]'
%   num_words --        String: '[1|2|3|...]'
%   num_sampled_error_patterns -- String: '[1|2|3|...|number of possible ways for given code to have DUE|-1 for all possible (automatic)]'
%   words_per_block --  String: '[1|2|3|...]'
%   input_filename --   String
%   output_filename --  String
%   n_threads --        String: '[1|2|3|...]'
%   code_type --        String: '[hsiao|davydov1991|bose1960|kaneda1982|ULEL_float|ULEL_even]'
%   policy --           String: '[baseline-pick-random|exact-single|exact-random|cluster3|cluster7|hamming-pick-random|hamming-pick-longest-run|longest-run-pick-random|delta-pick-random|fdelta-pick-random||dbx-longest-run-pick-random|dbx-weight-pick-longest-run|dbx-longest-run-pick-lowest-weight]'
%   crash_threshold -- String of a scalar. Policy-defined semantics and range.
%   verbose_recovery -- String: '[0|1]'
%   file_version --     String: '[isca17|micro17]'
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
num_sampled_error_patterns = str2num(num_sampled_error_patterns)
words_per_block = str2num(words_per_block)
input_filename
output_filename
n_threads = str2num(n_threads)
code_type
policy
crash_threshold
verbose_recovery = str2num(verbose_recovery);
file_version

rng('shuffle'); % Seed RNG based on current time

r = n-k;

if ~isdeployed
    addpath ecc common rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
end

%% Read data as hex-strings from file.

% Because the file may have a LOT of data, we don't want to read it into a buffer, as it may fail and use too much memory.
% Instead, we get the number of instructions by using the 'wc' command, with the assumption that each line in the file will
% contain a cache line.
display('Reading inputs...');
[wc_return_code, wc_output] = system(['wc -l ' input_filename]);
if wc_return_code ~= 0
    display(['FATAL! Could not get line count (# cache lines) from ' input_filename '.']);
    return;
end
total_num_cachelines = str2num(strtok(wc_output));
display(['Number of randomly-sampled words to test SWD-ECC: ' num2str(num_words) '. Total cache lines in trace: ' num2str(total_num_cachelines) '.']);

%% Randomly choose cache lines from the trace, and load them
sampled_cacheline_indices = sortrows(randperm(total_num_cachelines, num_words)'); % Randomly permute the indices of cachelines. We will choose the first num_words of the permuted list to evaluate. Then, from each of these cachelines, we randomly pick one word from within it.
sampled_blockpos_indices = randi(words_per_block, 1, num_words); % Randomly generate the block position within the cacheline

fid = fopen(input_filename);
if fid == -1
    display(['FATAL! Could not open file ' input_filename '.']);
    return;
end

% Loop over each line in the file and read it.
% Only save data from the line if it matches one of our sampled indices.
sampled_trace_raw = cell(num_words,1);
j = 1;
for i=1:total_num_cachelines
    line = fgetl(fid);
    if strcmp(line,'') == 1 || j > size(sampled_cacheline_indices,1)
        break;
    end
    if i == sampled_cacheline_indices(j)
        sampled_trace_raw{j,1} = line;
        j = j+1;
    end
end
fclose(fid);

%% Parse the raw trace (micro17 format shown)
% It is in CSV format, as output by our memdatatrace version of RISCV Spike simulator of the form
% STEP,OPERATION,REG_TYPE,MEM_ACCESS_SEQ_NUM,VADDR,PADDR,USER_PERM,SUPER_PERM,ACCESS_SIZE,PAYLOAD,CACHE_BLOCKPOS,CACHE_BLOCK0,CACHE_BLOCK1,...,
% like so:
% 1805000,D$ RD fr MEM,INT,1898719,VADDR 0x0000000000001718,PADDR 0x0000000000001718,u---,sRWX,4B,PAYLOAD 0x63900706,BLKPOS 3,0x33d424011374f41f,0x1314340033848700,0x0335040093771500,0x63900706638e0908,0xeff09ff21355c500,0x1315a50013651500,0x2330a4001355a500,0x1b0979ff9317c500,
% ...
% NOTE: memdatatrace payloads and cache blocks are in NATIVE byte order for
% the simulated architecture. For RV64G this is LITTLE-ENDIAN!
% NOTE: we only expect data cache lines to be in this file!
% NOTE: addresses and decimal values in these traces are in BIG-ENDIAN
% format.
sampled_trace_step = cell(num_words,1);
sampled_trace_operation = cell(num_words,1);
if strcmp(file_version, 'isca17') ~= 1
    sampled_trace_reg_type = cell(num_words,1);
end
sampled_trace_seq_num = cell(num_words,1);
sampled_trace_vaddr = cell(num_words,1);
sampled_trace_paddr = cell(num_words,1);
sampled_trace_user_perm = cell(num_words,1);
sampled_trace_supervisor_perm = cell(num_words,1);
sampled_trace_payload_size = cell(num_words,1);
sampled_trace_payload = cell(num_words,1);
sampled_trace_demand_blockpos = cell(num_words,1);
sampled_trace_cachelines_hex = cell(num_words,words_per_block);
sampled_trace_cachelines_bin = cell(num_words,words_per_block);
for i=1:num_words
    remain = sampled_trace_raw{i,1};
    [sampled_trace_step{i,1}, remain] = strtok(remain,',');
    [sampled_trace_operation{i,1}, remain] = strtok(remain,',');
    if strcmp(file_version, 'isca17') ~= 1
        [sampled_trace_reg_type{i,1}, remain] = strtok(remain,',');
    end
    [sampled_trace_seq_num{i,1}, remain] = strtok(remain,',');
    [sampled_trace_vaddr{i,1}, remain] = strtok(remain,',');
    [sampled_trace_paddr{i,1}, remain] = strtok(remain,',');
    [sampled_trace_user_perm{i,1}, remain] = strtok(remain,',');
    [sampled_trace_supervisor_perm{i,1}, remain] = strtok(remain,',');
    [sampled_trace_payload_size{i,1}, remain] = strtok(remain,',');
    [sampled_trace_payload{i,1}, remain] = strtok(remain,',');
    [sampled_trace_demand_blockpos{i,1}, remain] = strtok(remain,',');
    cacheline_stream_hex = repmat('X',1,128);
    for j=1:8
        [chunk, remain] = strtok(remain,',');
        cacheline_stream_hex((j-1)*16+1:(j-1)*16+16) = chunk(3:end);
    end
    for j=1:words_per_block
        sampled_trace_cachelines_hex{i,j} = cacheline_stream_hex((j-1)*(k/4)+1:(j-1)*(k/4)+(k/4));
        sampled_trace_cachelines_bin{i,j} = my_hex2bin(sampled_trace_cachelines_hex{i,j});
    end
end

%% Get error patterns
if verbose_recovery == 1
    display('Constructing error-pattern matrix...');
end
error_patterns = construct_error_pattern_matrix(n, code_type);
num_error_patterns = size(error_patterns,1);

if num_sampled_error_patterns < 0 || num_sampled_error_patterns > num_error_patterns
    num_sampled_error_patterns = num_error_patterns;
end

if verbose_recovery == 1
    num_sampled_error_patterns
end

%% Get our ECC encoder and decoder matrices
if verbose_recovery == 1
    display('Getting ECC encoder and decoder matrices...');
end
[G,H] = getECCConstruction(n,code_type);

results_candidate_messages = NaN(num_words,num_sampled_error_patterns); % Init
success = NaN(num_words, num_sampled_error_patterns); % Init
could_have_crashed = NaN(num_words, num_sampled_error_patterns); % Init
success_with_crash_option = NaN(num_words, num_sampled_error_patterns); % Init
results_miscorrect = NaN(num_words, num_sampled_error_patterns); % Init
avg_candidate_scores = NaN(num_words, num_sampled_error_patterns); % Init
var_candidate_scores = NaN(num_words, num_sampled_error_patterns); % Init
recovery_deltas = NaN(num_words, num_sampled_error_patterns); % Init
recovery_fdeltas = NaN(num_words, num_sampled_error_patterns); % Init
recovery_deltas_relative = NaN(num_words, num_sampled_error_patterns); % Init
recovery_deltas_frelative = NaN(num_words, num_sampled_error_patterns); % Init

%% Randomly generate sampled error pattern indices
sampled_error_pattern_indices = sortrows(randperm(num_error_patterns, num_sampled_error_patterns)'); % Increasing order of indices. This does not affect experiment correctness.

if verbose_recovery == 1
    sampled_error_pattern_indices
end

display('Evaluating SWD-ECC...');

%% Set up parallel computing
pctconfig('preservejobs', true);
mycluster = parcluster('local');
mycluster.NumWorkers = n_threads;
mypool = parpool(mycluster,n_threads);

%% Iterate over sampled number of detected-but-uncorrectable error patterns.
parfor j=1:num_sampled_error_patterns
    error = error_patterns(sampled_error_pattern_indices(j),:);
    
    zero_codeword = repmat('0',1,n);
    received_string_zero_message = my_bitxor(zero_codeword, error);
    
    [candidate_correct_messages_zero_message, retval] = compute_candidate_correct_messages(received_string_zero_message,H,code_type);
    num_candidate_messages = size(candidate_correct_messages_zero_message,1);

    if retval ~= 0
        display('FATAL! Something went wrong computing candidate-correct messages!');
    else
        for i=1:num_words % Parallelize loop across separate threads, since this could take a long time. Each word is a totally independent procedure to perform.
            %% Get the cacheline and "message," which is the original word, i.e., the ground truth from input file.
            cacheline_hex  = sampled_trace_cachelines_hex(i,:);
            original_message_hex = cacheline_hex{sampled_blockpos_indices(i)};

            % Swap byte order for policies. We assume that k is the native word size.
            if strcmp(policy, 'delta-pick-random') == 1 ...
                || strcmp(policy, 'fdelta-pick-random') == 1 
                cacheline_bin = cell(1,size(cacheline_hex,2));
                for x=1:size(cacheline_hex,2)
                    cacheline_hex{1,x} = reverse_byte_order(cacheline_hex{1,x});
                    cacheline_bin{1,x} = my_hex2bin(cacheline_hex{1,x});
                end
                original_message_hex = reverse_byte_order(original_message_hex);
                original_message_bin = my_hex2bin(original_message_hex);
            else
                cacheline_bin  = sampled_trace_cachelines_bin(i,:);
                original_message_bin = cacheline_bin{sampled_blockpos_indices(i)};
            end
           
            %% Compute candidate messages
            candidate_correct_messages = repmat('X',num_candidate_messages,k);
            for x=1:num_candidate_messages
                candidate_correct_messages(x,:) = my_bitxor(candidate_correct_messages_zero_message(x,:),original_message_bin); 
            end
            candidate_correct_messages = unique(candidate_correct_messages,'rows','sorted'); % Sort feature is important

            %% Serialize candidate messages into a string, as data_recovery() requires this instead of cell array.
            serialized_candidate_correct_messages_bin = candidate_correct_messages(1,:); % init
            for x=2:size(candidate_correct_messages,1)
                serialized_candidate_correct_messages_bin = [serialized_candidate_correct_messages_bin ',' candidate_correct_messages(x,:)];
            end

            %% Serialize cacheline_bin into a string, as data_recovery() requires this instead of cell array.
            serialized_cacheline_bin = cacheline_bin{1,1}; % init
            for x=2:size(cacheline_bin,2)
                serialized_cacheline_bin = [serialized_cacheline_bin ',' cacheline_bin{1,x}];
            end
            
            if verbose_recovery == 1
                original_message_hex
                original_message_bin
                error
                %received_string
                candidate_correct_messages
                for x=1:size(cacheline_bin,2)
                    x
                    cacheline_bin{1,x}
                end
            end

%            %% Attempt to recover the original message. This could actually succeed depending on the code used and how many bits are in the error pattern.
%            if verbose == 1
%                display('Attempting to decode the received string...');
%            end
%
%            if strcmp(code_type, 'hsiao1970') == 1 || strcmp(code_type, 'davydov1991') == 1 % SECDED
%                [recovered_message, num_error_bits] = secded_decoder(received_string, H, code_type);
%            elseif strcmp(code_type, 'bose1960') == 1 % DECTED
%                [recovered_message, num_error_bits] = dected_decoder(received_string, H);
%            elseif strcmp(code_type, 'kaneda1982') == 1 % ChipKill
%                [recovered_message, num_error_bits, num_error_symbols] = chipkill_decoder(received_string, H, 4);
%            end % didn't check bad code type error condition because we should have caught it earlier anyway
%
%            if verbose == 1
%                display(['Sanity check: ECC decoder determined that there are ' num2str(num_error_bits) ' bits in error. The input error pattern had ' num2str(sum(error_pattern=='1')) ' bits flipped.']);
%
%                if strcmp(code_type, 'kaneda1982') == 1 % ChipKill
%                    display(['This is a ChipKill code with symbol size of 4 bits. The decoder found ' num2str(num_error_symbols) ' symbols in error.']);
%                end
%            end

            %% Do heuristic recovery for this message/error pattern combo.
            [candidate_scores, recovered_message_bin, suggest_to_crash, recovered_successfully] = data_recovery('rv64g', num2str(k), original_message_bin, serialized_candidate_correct_messages_bin, policy, serialized_cacheline_bin, sampled_blockpos_indices(i), crash_threshold, num2str(verbose_recovery));

            %% Store results for this message/error pattern pair
            success(i,j) = recovered_successfully;
            could_have_crashed(i,j) = suggest_to_crash;
            avg_candidate_scores(i,j) = mean(candidate_scores);
            var_candidate_scores(i,j) = var(candidate_scores);
            if suggest_to_crash == 1
                success_with_crash_option(i,j) = ~success(i,j); % If success is 1, then we robbed ourselves of a chance to recover. Otherwise, if success is 0, we saved ourselves from corruption and potential failure!
                results_miscorrect(i,j) = 0;
            else
                success_with_crash_option(i,j) = success(i,j); % If we decide not to crash, success rate is same.
                results_miscorrect(i,j) = ~success(i,j);
            end
            results_candidate_messages(i,j) = num_candidate_messages;

            %% Compute recovery integer delta (measure of how much error to original message when treated as integers)
            original_message_dec = my_bin2dec(original_message_bin,k); % unsigned int value
            recovered_message_dec = my_bin2dec(recovered_message_bin,k); % unsigned int value

            % uint64 in MATLAB do not overflow or underflow, they saturate. So we take abs of delta and recover sign to avoid losing information.
            if original_message_dec >= recovered_message_dec
                deltasign = -1;
                delta = original_message_dec - recovered_message_dec;
            else
                deltasign = 1;
                delta = recovered_message_dec - original_message_dec;
            end
            recovery_deltas(i,j) = deltasign*double(delta); % Cast delta back to a double and re-apply the sign
            recovery_deltas_relative(i,j) = recovery_deltas(i,j) / double(original_message_dec);

            %% Compute recovery float delta
            if k == 64
                original_message_float = typecast(my_bin2dec(original_message_bin,k), 'double'); 
                recovered_message_float = typecast(my_bin2dec(recovered_message_bin,k), 'double'); 
            elseif k == 32
                original_message_float = typecast(my_bin2dec(original_message_bin,k), 'single'); 
                recovered_message_float = typecast(my_bin2dec(recovered_message_bin,k), 'single'); 
            elseif k == 16 % TODO: support 16-bit float
                display('ERROR TODO: support 16-bit float');
            end

            recovery_fdeltas(i,j) = recovered_message_float - original_message_float;
            recovery_fdeltas_relative(i,j) = recovery_fdeltas(i,j) / original_message_float;
        end
    end

    %% Progress indicator
    % This will not show accurate progress if the loop is parallelized
    % across threads with parfor, since they can execute out-of-order
    display(['Completed error pattern # ' num2str(j) ' is index ' num2str(sampled_error_pattern_indices(j)) '.']); 
end

%% Save all variables
display('Saving outputs...');
save(output_filename);
display('Done!');

%% Shut down parallel computing pool
delete(mypool);

end
