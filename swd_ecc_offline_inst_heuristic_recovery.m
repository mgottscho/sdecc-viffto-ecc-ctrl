function swd_ecc_offline_inst_heuristic_recovery(architecture, benchmark, n, k, num_messages, input_filename, output_filename, n_threads, code_type, policy, mnemonic_hotness_filename, rd_hotness_filename, verbose_recovery)
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
%   n --                String: '[39|45|72|79|144]'
%   k --                String: '[32|64|128]'
%   num_messages --     String: '[1|2|3|...]'
%   input_filename --   String
%   output_filename --  String
%   n_threads --        String: '[1|2|3|...]'
%   code_type --        String: '[hsiao|davydov1991|bose1960|fujiwara1982]'
%   policy --           String: '[baseline-pick-random | filter-rank-pick-random | filter-rank-sort-pick-first | filter-rank-rank-sort-pick-first | filter-frequency-pick-random | filter-frequency-sort-pick-first | filter-frequency-sort-pick-longest-pad]'
%   mnemonic_hotness_filename -- String: full path to CSV file containing the relative frequency of each instruction to use for ranking
%   rd_hotness_filename -- String: full path to CSV file containing the relative frequency of each destination register address to use for ranking
%   verbose_recovery -- String: '[0|1]'
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
num_messages = str2num(num_messages)
input_filename
output_filename
n_threads = str2num(n_threads)
code_type
policy
mnemonic_hotness_filename
rd_hotness_filename
verbose_recovery

if ~isdeployed
    addpath ecc common rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
end

%% Read instructions as hex-strings from file.

% Because the file may have a LOT of data, we don't want to read it into a buffer, as it may fail and use too much memory.
% Instead, we get the number of instructions by using the 'wc' command, with the assumption that each line in the file will
% contain an instruction.
display('Reading inputs...');
[wc_return_code, wc_output] = system(['wc -l ' input_filename]);
if wc_return_code ~= 0
    display(['FATAL! Could not get line count (# inst) from ' input_filename '.']);
    return;
end
total_num_inst = str2num(strtok(wc_output));
num_packed_inst = k/32; % We assume 32-bits per instruction. For k as a multiple of 32, we have packed instructions per message. FIXME: this is only true for RV64G
display(['Number of randomly-sampled messages to test SWD-ECC: ' num2str(num_messages) '. Total instructions in trace: ' num2str(total_num_inst) '. Since k = ' num2str(k) ', we have ' num2str(num_packed_inst) ' packed instructions per ECC message.']);

%% Randomly choose instructions from the trace, and load them
rng('shuffle'); % Seed RNG based on current time
sampled_message_indices = sortrows(randperm(total_num_inst-(num_packed_inst-1), num_messages)'); % Increasing order of indices. This does not affect experiment correctness.

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
% If it is in CSV format, as output by our memdatatrace version of RISCV Spike simulator of the form
% STEP,OPERATION,MEM_ACCESS_SEQ_NUM,VADDR,PADDR,USER_PERM,SUPER_PERM,ACCESS_SIZE,PAYLOAD,CACHE_BLOCKPOS,CACHE_BLOCK0,CACHE_BLOCK1,...,
% like so:
% 1805000,I$ RD fr MEM,1898719,VADDR 0x0000000000001718,PADDR 0x0000000000001718,u---,sRWX,4B,PAYLOAD 0x63900706,BLKPOS 3,0x33d424011374f41f,0x1314340033848700,0x0335040093771500,0x63900706638e0908,0xeff09ff21355c500,0x1315a50013651500,0x2330a4001355a500,0x1b0979ff9317c500,
% ...
% NOTE: memdatatrace payloads and cache blocks are in NATIVE byte order for
% the simulated architecture. For RV64G this is LITTLE-ENDIAN!
% NOTE: we only expect instruction cache lines to be in this file!
% NOTE: addresses and decimal values in these traces are in BIG-ENDIAN
% format.
line = fgets(fid);
line = line(1:end-1); % Throw away newline character
if size(strfind(line, ',')) ~= 0 % Dynamic trace mode
    trace_mode = 'dynamic';
    display('Detected dynamic trace, parsing...');
else
    trace_mode = 'static';
    display('Detected static trace, parsing...');
end
fclose(fid);
fid = fopen(input_filename);
if fid == -1
    display(['FATAL! Could not open file ' input_filename '.']);
    return;
end

num_messages_in_cacheline = 512 / k;
sampled_trace_raw = cell(num_messages,1);
j = 1;
for i=1:total_num_inst
    line = fgets(fid);
    line = line(1:end-1); % Throw away newline character
    if strcmp(line,'') == 1 || j > size(sampled_message_indices,1)
        break;
    end
    if i == sampled_message_indices(j)
        if strcmp(trace_mode, 'static') == 1 % Static trace mode
            packed_message = line;
            for packed_inst=2:num_packed_inst
                line = fgets(fid);
                line = line(1:end-1); % Throw away newline character
                packed_message = [packed_message line];
            end
        elseif strcmp(trace_mode, 'dynamic') == 1 % Dynamic trace mode
            for x=1:9 % 9 iterations because payload is 9th entry in a row of the above format
                [token,remain] = strtok(remain,',');
            end
            [payload_token, payload_remain] = strtok(token,'x'); % Find the part of "PAYLOAD 0xDEADBEEF" after the "0x" part.
            payload = payload_remain(2:end);
            % Now we have target instruction of interest, but have to find its packed message representation.
            [token, remain] = strtok(remain,','); % Throw away blockpos
            cacheline = repmat('X',1,128);
            for x=1:8 % 8 iterations, one per word in cacheline. Assume 64 bits per word. This is 128 hex symbols per cacheline
                [token, remain] = strtok(remain,',');
                [word_token, word_remain] = strtok(token,'x'); % Find the part of "0x000000000DEADBEEF" after the "0x" part.
                cacheline(1,(x-1)*16+1:(x-1)*16+16) = word_remain(2:end);
            end

            % Find starting hexpos of payload in cacheline
            payload_start_hexpos = strfind(cacheline,payload);
            payload_start_hexpos = payload_start_hexpos(1); % If multiple payloads appear, choose the first one FIXME
            payload_offset_in_message = mod(payload_start_hexpos,k/4);
            packed_message = cacheline(1,payload_start_hexpos-payload_offset_in_message+1:payload_start_hexpos-payload_offset_in_message+k/4);

            for packed_inst=1:num_packed_inst
                packed_message((packed_inst-1)*8+1:(packed_inst-1)*8+8) = reverse_byte_order((packed_inst-1)*8+1:(packed_inst-1)*8+8); % Put the packed instruction in big-endian format.
            end
        else
            display(['FATAL! Unsupported trace mode: ' trace_mode]);
            return;
        end
        sampled_trace_raw{j,1} = packed_message;
        j = j+1;
    end
end
fclose(fid);

sampled_trace_packed_inst_disassembly = cell(1,num_packed_inst);
x = 1;
for i=1:num_messages
   packed_message = sampled_trace_raw{i,1};
   for packed_inst=1:num_packed_inst
       %% Disassemble each instruction that we sampled.
       inst_hex = packed_message((packed_inst-1)*8+1:(packed_inst-1)*8+8);

       [legal, mnemonic, codec, rd, rs1, rs2, rs3, imm, arg] = parse_rv64g_decoder_output(inst_hex);
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
sampled_trace_bin = dec2bin(hex2dec(sampled_trace_hex),k);

%% Construct a matrix containing all possible (t+1)-bit error patterns as bit-strings.
display('Constructing error-pattern matrix...');
if strcmp(code_type,'hsiao1970') == 1 || strcmp(code_type,'davydov1991') == 1 % SECDED
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
elseif strcmp(code_type,'bose1960') == 1 % DECTED
    num_error_patterns = nchoosek(n,3);
    error_patterns = repmat('0',num_error_patterns,n);
    num_error = 1;
    for i=1:n-2
        for j=i+1:n-1
            for l=j+1:n
                error_patterns(num_error, i) = '1';
                error_patterns(num_error, j) = '1';
                error_patterns(num_error, l) = '1';
                num_error = num_error + 1;
            end
        end
    end
elseif strcmp(code_type,'fujiwara1982') == 1 % ChipKill
    num_error_patterns = nchoosek(n/4,2) * 15^2;
    error_patterns = repmat('0',num_error_patterns,n);
    sym_error_patterns = dec2bin(1:15);
    num_error = 1;
    for sym1=1:n/4-1
        for sym2=sym1:n/4
            for sym1_error_index=1:size(sym_error_patterns,1)
                for sym2_error_index=1:size(sym_error_patterns,1)
                    error_patterns(num_error,(sym1-1)*4+1:(sym1-1)*4+4) = sym_error_patterns(sym1_error_index,:);
                    error_patterns(num_error,(sym2-1)*4+1:(sym2-1)*4+4) = sym_error_patterns(sym2_error_index,:);
                end
            end
        end
    end
else
    display(['FATAL! Unsupported code type: ' code_type]);
    return;
end

display('Evaluating SWD-ECC...');

results_candidate_messages = NaN(num_inst,num_error_patterns); % Init
results_valid_messages = NaN(num_inst,num_error_patterns); % Init
success = NaN(num_inst, num_error_patterns); % Init
could_have_crashed = NaN(num_inst, num_error_patterns); % Init
success_with_crash_option = NaN(num_inst, num_error_patterns); % Init

%% Set up parallel computing
pctconfig('preservejobs', true);
mycluster = parcluster('local');
mycluster.NumWorkers = n_threads;
mypool = parpool(mycluster,n_threads);

parfor i=1:num_messages % Parallelize loop across separate threads, since this could take a long time. Each instruction is a totally independent procedure to perform.
    %% Get the "message," which is the original instruction, i.e., the ground truth from input file.
    message_hex = sampled_trace_hex(i,:);
    message_bin = sampled_trace_bin(i,:);
    [legal, mnemonic, codec, rd, rs1, rs2, rs3, imm, arg] = parse_rv64g_decoder_output(message_hex);
    
    %% Check that the message is actually a valid instruction to begin with.
    if legal == 0 
       display(['WARNING: Found illegal input instruction: ' message_hex '. This should not happen. However, we will try heuristic recovery anyway.']);
    end

    %% Iterate over all possible detected-but-uncorrectable error patterns.
    for j=1:num_error_patterns
        error = error_patterns(j,:);
        [original_codeword, received_string, num_candidate_messages, num_valid_messages, recovered_message, suggest_to_crash, recovered_successfully] = inst_recovery('rv64g', num2str(n), num2str(k), message_bin, error, code_type, policy, mnemonic_hotness_filename, rd_hotness_filename, verbose_recovery);

        %% Store results for this instruction/error pattern pair
        results_candidate_messages(i,j) = num_candidate_messages;
        results_valid_messages(i,j) = num_valid_messages;
        success(i,j) = recovered_successfully;
        could_have_crashed(i,j) = suggest_to_crash;
        if suggest_to_crash == 1
            success_with_crash_option(i,j) = ~success(i,j); % If success is 1, then we robbed ourselves of a chance to recover. Otherwise, if success is 0, we saved ourselves from corruption and potential failure!
        else
            success_with_crash_option(i,j) = success(i,j); % If we decide not to crash, success rate is same.
        end
    end
    
    % Progress indicator.
    % This will not show accurate progress if the loop is parallelized
    % across threads with parfor, since they can execute out-of-order
    display(['Completed inst # ' num2str(i) ' is index ' num2str(sampled_inst_indices(i)) ' in the program. hex: ' message_hex '. legal = ' num2str(legal) ', mnemonic = ' mnemonic ', codec = ' codec ',rd = ' rd ', rs1 = ' rs1 ', rs2 = ' rs2 ', rs3 = ' rs3 ', imm = ' imm ', arg = ' arg]);
    %'. avg_success = ' num2str(sum(success(i,:))) ', avg_could_have_crashed = ' num2str(sum(could_have_crashed(i,:))) ', avg_success_with_crash_option = ' num2str(sum(success_with_crash_option(i,:)))]);
end

%% Save all variables
display('Saving outputs...');
save(output_filename);
display('Done!');

%% Shut down parallel computing pool
delete(mypool);

