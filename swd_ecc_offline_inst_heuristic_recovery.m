function swd_ecc_offline_inst_heuristic_recovery(architecture, benchmark, n, k, num_messages, num_sampled_error_patterns, input_filename, output_filename, n_threads, code_type, policy, mnemonic_hotness_filename, rd_hotness_filename, crash_threshold, verbose_recovery, file_version, hash_mode)
% This function evaluates heuristic recovery from corrupted instructions in an offline manner.
%
% It iterates over a series of instructions that are statically extracted from a compiled program.
% For each instruction, it first checks if it is a valid instruction. If it is, the
% script encodes the instruction/message in a specified ECC encoder.
% The script then iterates over all possible detected-but-uncorrectable error patterns on the
% resulting codeword. Each of these (t+1)-bit patterns are decoded by our
% ECC code and should all be "detected but uncorrectable." For each of
% these errors, we flip a 1 bit one at a time and decode again.
% We should obtain X received codewords that are indicated as corrected.
% These X codewords are "candidates" for the original encoded message.
% The function then uses the instruction decoder to determine which of
% the X candidate messages are valid instructions.
%
% Input arguments:
%   architecture --     String: '[rv64g]'
%   benchmark --        String
%   n --                String: '[33|34|35|39|45|72|79|144]'
%   k --                String: '[32|64|128]'
%   num_messages --     String: '[1|2|3|...]'
%   num_sampled_error_patterns -- String: '[1|2|3|...|number of possible ways for given code to have DUE|-1 for all possible (automatic)]'
%   input_filename --   String
%   output_filename --  String
%   n_threads --        String: '[1|2|3|...]'
%   code_type --        String: '[hsiao|davydov1991|bose1960|kaneda1982|ULEL_float|ULEL_even]'
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
%   mnemonic_hotness_filename -- String: full path to CSV file containing the relative frequency of each instruction to use for ranking
%   rd_hotness_filename -- String: full path to CSV file containing the relative frequency of each destination register address to use for ranking
%   crash_threshold -- fraction from 0 to 1, expressed as a string, e.g. '0.5'.
%   verbose_recovery -- String: '[0|1]'
%   file_version --     String: '[isca17|micro17]'
%   hash_mode --        String: '[none|4|8|16]'
%
% Returns:
%   Nothing.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

architecture
benchmark
n = str2double(n)
k = str2double(k)
num_messages = str2double(num_messages)
num_sampled_error_patterns = str2double(num_sampled_error_patterns)
input_filename
output_filename
n_threads = str2double(n_threads)
code_type
policy
mnemonic_hotness_filename
rd_hotness_filename
crash_threshold = str2double(crash_threshold)
verbose_recovery = str2double(verbose_recovery)
file_version
hash_mode

rng('shuffle'); % Seed RNG based on current time

if ~isdeployed
    addpath ecc common rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
end

%% Read instructions as hex-strings from file.

% Because the file may have a LOT of data, we don't want to read it into a buffer, as it may fail and use too much memory.
% Instead, we get the number of instructions by using the 'wc' command, with the assumption that each line in the file will
% contain an instruction.
display('Reading inputs...');
[wc_return_code, wc_output] = system(['wc -l "' input_filename '"']);
if wc_return_code ~= 0
    display(['FATAL! Could not get line count (# inst) from ' input_filename '.']);
    return;
end
total_num_inst = str2double(strtok(wc_output));
num_packed_inst = k/32; % We assume 32-bits per instruction. For k as a multiple of 32, we have packed instructions per message. FIXME: this is only true for RV64G
display(['Number of randomly-sampled messages to test SWD-ECC: ' num2str(num_messages) '. Total instructions in trace: ' num2str(total_num_inst) '. Since k = ' num2str(k) ', we have ' num2str(num_packed_inst) ' packed instructions per ECC message.']);

%% Randomly choose instructions from the trace, and load them
fid = fopen(input_filename);
if fid == -1
    display(['FATAL! Could not open file ' input_filename '.']);
    return;
end

% Loop over each line in the file and read it.
% Only save data from the line if it matches one of our sampled indices.
% In the case of packed instructions per message, multiple instructions will be parsed and concatenated into one entry of the sampled trace.
%
%% Parse the raw trace depending on its format.
% If it is hexadecimal instructions in big-endian format, one (set of packed) instructions per line of the form
% 00000000
% deadbeef
% 01234567
% 0000abcd
% ...
%
% (micro17 format shown)
% If it is in CSV format, as output by our memdatatrace version of RISCV Spike simulator of the form
% STEP,OPERATION,REG_TYPE,MEM_ACCESS_SEQ_NUM,VADDR,PADDR,USER_PERM,SUPER_PERM,ACCESS_SIZE,PAYLOAD,CACHE_BLOCKPOS,CACHE_BLOCK0,CACHE_BLOCK1,...,
% like so:
% 1805000,I$ RD fr MEM,INT,1898719,VADDR 0x0000000000001718,PADDR 0x0000000000001718,u---,sRWX,4B,PAYLOAD 0x63900706,BLKPOS 3,0x33d424011374f41f,0x1314340033848700,0x0335040093771500,0x63900706638e0908,0xeff09ff21355c500,0x1315a50013651500,0x2330a4001355a500,0x1b0979ff9317c500,
% ...
% NOTE: memdatatrace payloads and cache blocks are in NATIVE byte order for
% the simulated architecture. For RV64G this is LITTLE-ENDIAN!
% NOTE: we only expect instruction cache lines to be in this file!
% NOTE: addresses and decimal values in these traces are in BIG-ENDIAN
% format.
rng('shuffle'); % Seed RNG based on current time
line = fgetl(fid);
if size(strfind(line, ',')) ~= 0 % Dynamic trace mode
    trace_mode = 'dynamic';
    sampled_message_indices = sortrows(randperm(total_num_inst, num_messages)'); % Increasing order of indices. This does not affect experiment correctness.
    display('Detected dynamic trace, parsing...');
else
    trace_mode = 'static';
    sampled_message_indices = sortrows(randperm(floor(total_num_inst/num_packed_inst), num_messages)' * num_packed_inst); % Increasing order of indices. This does not affect experiment correctness.
    display('Detected static trace, parsing...');
end
fclose(fid);
fid = fopen(input_filename);
if fid == -1
    display(['FATAL! Could not open file ' input_filename '.']);
    return;
end

num_messages_in_cacheline = 512 / k; % FIXME: hardcoded cacheline size
sampled_trace_raw = cell(num_messages,1);
i = 1;
j = 1;
while i <= total_num_inst && j <= num_messages
    line = fgetl(fid);
    if line == -1
        display(['Premature end-of-file. i == ' num2str(i) ', j == ' num2str(j) '.']);
        break;
    elseif strcmp(line, '') == 1
        display(['Error reading file. i == ' num2str(i) ', j == ' num2str(j) '.']);
        break;
    end
    i = i+1;
    if i == sampled_message_indices(j)
        if strcmp(trace_mode, 'static') == 1 % Static trace mode
            packed_message = line;
            for packed_inst=2:num_packed_inst
                line = fgetl(fid);
                if line == -1
                    display(['Premature end-of-file. i == ' num2str(i) ', j == ' num2str(j) '.']);
                    break;
                elseif strcmp(line, '') == 1
                    display(['Error reading file. i == ' num2str(i) ', j == ' num2str(j) '.']);
                    break;
                end
                i = i+1;
                packed_message = [packed_message line];
            end
        elseif strcmp(trace_mode, 'dynamic') == 1 % Dynamic trace mode
            remain = line;
            skip = 10;
            if strcmp(file_version, 'isca17') == 1
                skip = 9;
            end
            for x=1:skip % payload is skipth entry in a row of the above format
                [token,remain] = strtok(remain,',');
            end
            [~, payload_remain] = strtok(token,'x'); % Find the part of "PAYLOAD 0xDEADBEEF" after the "0x" part.
            payload = payload_remain(2:end);
            % Now we have target instruction of interest, but have to find its packed message representation.
            [token, remain] = strtok(remain,','); % Throw away blockpos
            cacheline = repmat('X',1,128);
            for x=1:8 % 8 iterations, one per word in cacheline. Assume 64 bits per word. This is 128 hex symbols per cacheline
                [token, remain] = strtok(remain,',');
                [~, word_remain] = strtok(token,'x'); % Find the part of "0x000000000DEADBEEF" after the "0x" part.
                cacheline(1,(x-1)*16+1:(x-1)*16+16) = word_remain(2:end);
            end

            % Find starting hexpos of payload in cacheline
            payload_start_hexpos = strfind(cacheline,payload);
            payload_start_hexpos = payload_start_hexpos(1); % If multiple payloads appear, choose the first one FIXME
            payload_offset_in_message = mod(payload_start_hexpos,k/4);
            packed_message = cacheline(1,payload_start_hexpos-payload_offset_in_message+1:payload_start_hexpos-payload_offset_in_message+k/4);

            for packed_inst=1:num_packed_inst
                packed_message((packed_inst-1)*8+1:(packed_inst-1)*8+8) = reverse_byte_order(packed_message((packed_inst-1)*8+1:(packed_inst-1)*8+8)); % Put the packed instruction in big-endian format.
            end
        else
            display(['FATAL! Unsupported trace mode: ' trace_mode]);
            return;
        end

        sampled_trace_raw{j,1} = packed_message;

        if verbose_recovery == 1
            sampled_trace_raw{j,1}
        end

        j = j+1;
    end
end
fclose(fid);

if verbose_recovery == 1
    display(['Number of messages in sampled_trace_raw: ' num2str(size(sampled_trace_raw,1)) ', num_messages: ' num2str(num_messages)]);
    sampled_message_indices
end

sampled_trace_packed_inst_disassembly = cell(1,num_packed_inst);
x = 1;
for i=1:num_messages
   packed_message = sampled_trace_raw{i,1};
   for packed_inst=1:num_packed_inst
       %% Disassemble each instruction that we sampled.
       inst_hex = packed_message((packed_inst-1)*8+1:(packed_inst-1)*8+8);

       [~, legal, mnemonic, codec, rd, rs1, rs2, rs3, imm, arg] = parse_rv64g_decoder_output(inst_hex);
       map = containers.Map();
       map('legal') = legal; 
       map('mnemonic') = mnemonic; 
       map('codec') = codec; 
       map('rd') = rd; 
       map('rs1') = rs1; 
       map('rs2') = rs2; 
       map('rs3') = rs3; 
       map('imm') = imm; 
       map('arg') = arg; 

       sampled_trace_packed_inst_disassembly{x,packed_inst} = map;
   end
   x = x+1;
end

sampled_trace_hex = char(sampled_trace_raw);
sampled_trace_bin = repmat('X',num_messages,k);
for i=1:num_messages
    sampled_trace_bin(i,:) = my_hex2bin(sampled_trace_hex(i,:));
end

if verbose_recovery == 1
    sampled_trace_hex
end

%% Get error patterns
if verbose_recovery == 1
    display('Constructing error-pattern matrix...');
end
error_patterns = construct_error_pattern_matrix(n, code_type);

if num_sampled_error_patterns < 0 || num_sampled_error_patterns > num_error_patterns
    num_sampled_error_patterns = num_error_patterns;
end

if verbose_recovery == 1
    num_sampled_error_patterns
end
    
%% Randomly generate sampled error pattern indices
sampled_error_pattern_indices = sortrows(randperm(num_error_patterns, num_sampled_error_patterns)'); % Increasing order of indices. This does not affect experiment correctness.

if verbose_recovery == 1
    sampled_error_pattern_indices
end

%% Get our ECC encoder and decoder matrices
if verbose_recovery == 1
    display('Getting ECC encoder and decoder matrices...');
end
[G,H] = getECCConstruction(n,code_type);

%% Read mnemonic and rd distributions from files now
display('Importing side information...');

% mnemonic frequency
fid = fopen(mnemonic_hotness_filename);
instruction_mnemonic_hotness_file = textscan(fid, '%s', 'Delimiter', ',');
fclose(fid);
instruction_mnemonic_hotness_file = instruction_mnemonic_hotness_file{1};
%instruction_mnemonic_hotness_file = reshape(instruction_mnemonic_hotness_file, 2, size(instruction_mnemonic_hotness_file,1)/2)';
instruction_mnemonic_hotness_file = reshape(instruction_mnemonic_hotness_file, 67, size(instruction_mnemonic_hotness_file,1)/67)'; % FIXME: 67 is hardcoded number of registers (64) + 'NA' + 'TOTAL' + mnemonic column
instruction_mnemonic_hotness = containers.Map(); % Init
if strcmp(policy, 'filter-joint-frequency-sort-pick-longest-pad') == 1
    for r=2:size(instruction_mnemonic_hotness_file,1)
        reg_in_mnemonic_hotness = containers.Map();
        for c=3:size(instruction_mnemonic_hotness_file,2)
            reg_in_mnemonic_hotness(instruction_mnemonic_hotness_file{1,c}) = str2double(instruction_mnemonic_hotness_file{r,c});
        end
        instruction_mnemonic_hotness(instruction_mnemonic_hotness_file{r,1}) = reg_in_mnemonic_hotness;
    end
else
    for r=2:size(instruction_mnemonic_hotness_file,1)
        instruction_mnemonic_hotness(instruction_mnemonic_hotness_file{r,1}) = str2double(instruction_mnemonic_hotness_file{r,2});
    end
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


display('Evaluating SWD-ECC...');

results_candidate_messages = NaN(num_messages,num_sampled_error_patterns); % Init
results_valid_messages = NaN(num_messages,num_sampled_error_patterns); % Init
success = NaN(num_messages, num_sampled_error_patterns); % Init
could_have_crashed = NaN(num_messages, num_sampled_error_patterns); % Init
success_with_crash_option = NaN(num_messages, num_sampled_error_patterns); % Init
results_estimated_prob_correct = NaN(num_messages, num_sampled_error_patterns); % Init
results_miscorrect = NaN(num_messages, num_sampled_error_patterns); % Init
    

%% Set up parallel computing
pctconfig('preservejobs', true);
mycluster = parcluster('local');
mycluster.NumWorkers = n_threads;
mypool = parpool(mycluster,n_threads);

%% Iterate over sampled number of detected-but-uncorrectable error patterns.
parfor j=1:num_sampled_error_patterns % Parallelize loop across separate threads
    error = error_patterns(sampled_error_pattern_indices(j),:);
        
    zero_codeword = repmat('0',1,n);
    received_string_zero_message = my_bitxor(zero_codeword, error);
        
    %% Flip bits on the corrupted codeword, and attempt decoding on each. We should find several bit flip combinations that decode successfully
    %if verbose_recovery == 1
    %    display(['Computing candidate codewords for the zero codeword corrupted by error pattern ' error '...']);
    %end

    [candidate_correct_messages_zero_message, retval] = compute_candidate_correct_messages(received_string_zero_message,H,code_type, hash_mode);
    num_candidate_messages = size(candidate_correct_messages_zero_message,1);

    if retval ~= 0
        display('FATAL! Something went wrong computing candidate-correct messages!');
    else
        for i=1:num_messages   
            %% Get the "message," which is the original instruction, i.e., the ground truth from input file.
            original_message_hex = sampled_trace_hex(i,:);
            original_message_bin = sampled_trace_bin(i,:);
            
            %% Check that the message is actually a valid instruction to begin with.
            %if legal == 0 
            %   display(['WARNING: Found illegal input instruction: ' original_message_hex '. This should not happen. However, we will try heuristic recovery anyway.']);
            %end

            candidate_correct_messages = repmat('X',num_candidate_messages,k);
            for x=1:num_candidate_messages
                candidate_correct_messages(x,:) = my_bitxor(candidate_correct_messages_zero_message(x,:),original_message_bin); 
            end
            candidate_correct_messages = unique(candidate_correct_messages,'rows','sorted'); % Sort feature is important
            
            %% Optional: filter candidates using a hash
            if strcmp(hash_mode, 'none') ~= 1
                if strcmp(hash_mode, '4') == 1
                    hash_size = 4;
                elseif strcmp(hash_mode, '8') == 1
                    hash_size = 8;
                elseif strcmp(hash_mode, '16') == 1
                    hash_size = 16;
                end
                tmp = cacheline_bin{1,1};
                for x=2:size(cacheline_bin,2)
                    tmp(x,:) = cacheline_bin{1,x};
                end
                tmp(sampled_blockpos_indices(i),:) = original_message_bin;
                tmp = reshape(tmp',1,size(tmp,1)*size(tmp,2));
                correct_hash = pearson_hash(tmp-'0',hash_size);
                candidate_correct_messages = hash_filter_candidates(candidate_correct_messages, char(cacheline_bin), sampled_blockpos_indices(i), hash_size, correct_hash);
            end
            
            %% Serialize candidate messages into a string, as data_recovery() requires this instead of cell array.
            serialized_candidate_correct_messages_bin = candidate_correct_messages(1,:); % init
            for x=2:size(candidate_correct_messages,1)
                serialized_candidate_correct_messages_bin = [serialized_candidate_correct_messages_bin ',' candidate_correct_messages(x,:)];
            end

            if verbose_recovery == 1
                original_message_hex
                original_message_bin
                error
                %received_string
                candidate_correct_messages
            end

            %% Attempt to recover the original message. This could actually succeed depending on the code used and how many bits are in the error pattern.
            %if verbose_recovery == 1
            %    display('Attempting to decode the received string...');
            %end

            %if strcmp(code_type, 'hsiao1970') == 1 || strcmp(code_type, 'davydov1991') == 1 % SECDED
            %    [recovered_message, num_error_bits] = secded_decoder(received_string, H, code_type);
            %elseif strcmp(code_type, 'bose1960') == 1 % DECTED
            %    [recovered_message, num_error_bits] = dected_decoder(received_string, H);
            %elseif strcmp(code_type, 'kaneda1982') == 1 % ChipKill
            %    [recovered_message, num_error_bits, num_error_symbols] = chipkill_decoder(received_string, H, 4);
            %end % didn't check bad code type error condition because we should have caught it earlier anyway
            %
            %if verbose_recovery == 1
            %    display(['Sanity check: ECC decoder determined that there are ' num2str(num_error_bits) ' bits in error. The input error pattern had ' num2str(sum(error_pattern=='1')) ' bits flipped.']);

            %    if strcmp(code_type, 'kaneda1982') == 1 % ChipKill
            %        display(['This is a ChipKill code with symbol size of 4 bits. The decoder found ' num2str(num_error_symbols) ' symbols in error.']);
            %    end
            %end
            %    
            %if verbose_recovery == 1 && sum(error_pattern=='1') ~= num_error_bits
            %    display('NOTE: This is a MIS-CORRECTION by the ECC decoder itself.');
            %end
        
            %if strcmp(recovered_message,original_message) == 1
            %    display('ERROR: No error or correctable error. This should not have happened.');
            %    return;
            %end

            [num_valid_messages, recovered_message, estimated_prob_correct, suggest_to_crash, recovered_successfully] = inst_recovery('rv64g', num2str(k), original_message_bin, serialized_candidate_correct_messages_bin, policy, instruction_mnemonic_hotness, instruction_rd_hotness, num2str(crash_threshold), num2str(verbose_recovery));

            %% Store results for this instruction/error pattern pair
            results_candidate_messages(i,j) = num_candidate_messages;
            results_valid_messages(i,j) = num_valid_messages;
            success(i,j) = recovered_successfully;
            could_have_crashed(i,j) = suggest_to_crash;
            results_estimated_prob_correct(i,j) = estimated_prob_correct;
            if suggest_to_crash == 1
                success_with_crash_option(i,j) = ~success(i,j); % If success is 1, then we robbed ourselves of a chance to recover. Otherwise, if success is 0, we saved ourselves from corruption and potential failure!
                results_miscorrect(i,j) = 0;
            else
                success_with_crash_option(i,j) = success(i,j); % If we decide not to crash, success rate is same.
                results_miscorrect(i,j) = ~success(i,j);
            end
        end
    end

    % Progress indicator.
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
