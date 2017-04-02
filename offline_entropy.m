function [entropies] = offline_entropy(num_cachelines, k, words_per_block, input_filename, output_filename, n_threads, file_version, symbol_size)
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
%   num_cachelines --        String
%   k --                String: '[16|32|64|128]'
%   words_per_block --  String: '[1|2|3|...]'
%   input_filename --   String
%   output_filename --  String
%   n_threads --        String: '[1|2|3|...]'
%   file_version --     String: '[micro17|cases17]'
%   symbol_size --      String: '[4|8|16]'
%
% Returns:
%   entropies --        num_cachelines X 2 matrix. First column is
%       cacheline sampled index, second column is measured cacheline entropy.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

num_cachelines = str2num(num_cachelines)
k = str2num(k)
words_per_block = str2num(words_per_block)
input_filename
output_filename
n_threads = str2num(n_threads)
file_version
symbol_size = str2num(symbol_size)

if ~isdeployed
    addpath ecc common rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
end

%% Read data as hex-strings from file.

% Because the file may have a LOT of data, we don't want to read it into a buffer, as it may fail and use too much memory.
% Instead, we get the number of instructions by using the 'wc' command, with the assumption that each line in the file will
% contain a cache line.
display('Reading inputs...');
[wc_return_code, wc_output] = system(['wc -l "' input_filename '"']);
if wc_return_code ~= 0
    display(['FATAL! Could not get line count (# cache lines) from ' input_filename '.']);
    return;
end
total_num_cachelines = str2num(strtok(wc_output));
display(['Number of words: ' num2str(num_cachelines) '. Total cache lines in trace: ' num2str(total_num_cachelines) '.']);

if total_num_cachelines < num_cachelines || num_cachelines < 1
    num_cachelines = total_num_cachelines;
    display('Overriding num_cachelines');
    num_cachelines
end

%% Randomly choose cache lines from the trace, and load them
sampled_cacheline_indices = sortrows(randperm(total_num_cachelines, num_cachelines)'); % Randomly permute the indices of cachelines. We will choose the first num_cachelines of the permuted list to evaluate. Then, from each of these cachelines, we randomly pick one word from within it.

fid = fopen(input_filename);
if fid == -1
    display(['FATAL! Could not open file ' input_filename '.']);
    return;
end

% Loop over each line in the file and read it.
% Only save data from the line if it matches one of our sampled indices.
sampled_trace_raw = cell(num_cachelines,1);
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

%% Parse the raw trace (cases17 format shown)
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
sampled_trace_step = cell(num_cachelines,1);
sampled_trace_operation = cell(num_cachelines,1);
if strcmp(file_version, 'micro17') ~= 1
    sampled_trace_reg_type = cell(num_cachelines,1);
end
sampled_trace_seq_num = cell(num_cachelines,1);
sampled_trace_vaddr = cell(num_cachelines,1);
sampled_trace_paddr = cell(num_cachelines,1);
sampled_trace_user_perm = cell(num_cachelines,1);
sampled_trace_supervisor_perm = cell(num_cachelines,1);
sampled_trace_payload_size = cell(num_cachelines,1);
sampled_trace_payload = cell(num_cachelines,1);
sampled_trace_demand_blockpos = cell(num_cachelines,1);
sampled_trace_cachelines_hex = cell(num_cachelines,words_per_block);
sampled_trace_cachelines_bin = cell(num_cachelines,words_per_block);
for i=1:num_cachelines
    remain = sampled_trace_raw{i,1};
    [sampled_trace_step{i,1}, remain] = strtok(remain,',');
    [sampled_trace_operation{i,1}, remain] = strtok(remain,',');
    if strcmp(file_version, 'micro17') ~= 1
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

%% Set up parallel computing
pctconfig('preservejobs', true);
mycluster = parcluster('local');
mycluster.NumWorkers = n_threads;
mypool = parpool(mycluster,n_threads);

entropy_indices = NaN(num_cachelines,1);
entropy = NaN(num_cachelines,1);
%% Iterate over cachelines
parfor i=1:num_cachelines
    cacheline_clayton = zeros(1,(words_per_block-1)*k);
    for blockpos=2:words_per_block
        cacheline_clayton(1,1+(blockpos-1)*k:blockpos*k) = sampled_trace_cachelines_bin{i,blockpos} - '0';
    end

    entropy_indices(i) = sampled_cacheline_indices(i);
    entropy(i) = entropy_list(symbol_size, cacheline_clayton, sampled_trace_cachelines_bin{i,1} - '0');
end

entropies = NaN(num_cachelines,2);
entropies(:,1) = entropy_indices;
entropies(:,2) = entropy;

%% Save all variables
display('Saving outputs...');
save(output_filename);
display('Done!');

%% Shut down parallel computing pool
delete(mypool);

end
