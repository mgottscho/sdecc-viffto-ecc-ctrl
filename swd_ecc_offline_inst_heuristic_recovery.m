function swd_ecc_offline_inst_heuristic_recovery(architecture, benchmark, n, k, num_inst, input_filename, output_filename, n_threads, code_type, policy, tiebreak_policy, mnemonic_hotness_filename, rd_hotness_filename)
% This function evaluates heuristic recovery from corrupted instructions in an offline manner.
%
% It iterates over a series of instructions that are statically extracted from a compiled program.
% For each instruction, it first checks if it is a valid instruction. If it is, the
% script encodes the instruction/message in a specified SECDED encoder.
% The script then iterates over all possible 2-bit error patterns on the
% resulting codeword. Each of these 2-bit patterns are decoded by our
% SECDED code and should all be "detected but uncorrectable." For each of
% these 2-bit errors, we flip a single bit one at a time and decode again.
% We should obtain X received codewords that are indicated as corrected.
% These X codewords are "candidates" for the original encoded message.
% The function then uses the instruction decoder to determine which of
% the X candidate messages are valid instructions.
%
% Input arguments:
%   architecture --     String: '[rv64g]'
%   benchmark --        String
%   n --                String: '[39|72]'
%   k --                String: '[32|64]'
%   num_inst --         String: '[1|2|3|...]'
%   input_filename --   String
%   output_filename --  String
%   n_threads --        String: '[1|2|3|...]'
%   code_type --        String: '[hsiao|davydov1991]'
%   policy --           String: '[filter-rank|filter-rank-filter-rank]'
%   tiebreak_policy --  String: '[pick_first|pick_last|pick_random]'
%   mnemonic_hotness_filename -- String: full path to CSV file containing the relative frequency of each instruction to use for ranking
%   rd_hotness_filename -- String: full path to CSV file containing the relative frequency of each destination register address to use for ranking
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
num_inst = str2num(num_inst)
input_filename
output_filename
n_threads = str2num(n_threads)
code_type
policy
tiebreak_policy
mnemonic_hotness_filename
rd_hotness_filename

if ~isdeployed
    addpath ecc common rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
end

%% Set up parallel computing
pctconfig('preservejobs', true);
mypool = parpool(n_threads);

%% Read instructions as hex-strings from file
display('Reading inputs...');
fid = fopen(input_filename);
file_contents = textscan(fid, '%s');
fclose(fid);
file_contents = file_contents{1};
total_num_inst = size(file_contents,1);
trace_hex = char(file_contents(:,1));
trace_bin = dec2bin(hex2dec(trace_hex),k);
total_num_inst = size(trace_hex,1);

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

%% Randomly choose instructions from the trace, and do the fun parts on those
rng('shuffle'); % Seed RNG based on current time
sampled_inst_indices = randperm(total_num_inst, num_inst); 
sampled_trace_hex = trace_hex(sampled_inst_indices,:);
sampled_trace_bin = trace_bin(sampled_inst_indices,:);
sampled_trace_inst_disassembly = cell(num_inst,1);
for i=1:num_inst
    [legal, mnemonic, codec, rd, rs1, rs2, rs3, imm, arg] = parse_rv64g_decoder_output(sampled_trace_hex(i,:));
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
    sampled_trace_inst_disassembly{i} = map;
end

display(['Number of randomly-sampled instructions to test SWD-ECC: ' num2str(num_inst)]);
display('Evaluating SWD-ECC...');

results_candidate_messages = NaN(num_inst,num_error_patterns); % Init
results_valid_messages = NaN(num_inst,num_error_patterns); % Init
success = NaN(num_inst, num_error_patterns); % Init
could_have_crashed = NaN(num_inst, num_error_patterns); % Init
success_with_crash_option = NaN(num_inst, num_error_patterns); % Init
verbose_recovery = '0';

parfor i=1:num_inst % Parallelize loop across separate threads, since this could take a long time. Each instruction is a totally independent procedure to perform.
    %% Get the "message," which is the original instruction, i.e., the ground truth from input file.
    message_hex = sampled_trace_hex(i,:);
    message_bin = sampled_trace_bin(i,:);
    [legal, mnemonic, codec, rd, rs1, rs2, rs3, imm, arg] = parse_rv64g_decoder_output(message_hex);
    
    %% Check that the message is actually a valid instruction to begin with.
    if legal == 0 
       display(['WARNING: Found illegal input instruction: ' message_hex '. This should not happen!']);
    end

    %% Iterate over all possible 2-bit error patterns.
    for j=1:num_error_patterns
        error = error_patterns(j,:);
        [original_codeword, received_string, num_candidate_messages, num_valid_messages, recovered_message, suggest_to_crash, recovered_successfully] = inst_recovery('rv64g', num2str(n), num2str(k), message_bin, error, code_type, policy, tiebreak_policy, mnemonic_hotness_filename, rd_hotness_filename, verbose_recovery);

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

