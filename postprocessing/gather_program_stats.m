% Extract results in a useful form from program statistics data structures.
%
% Author: Mark Gottscho <mgottscho@ucla.edu>

%%%%%%% FEEL FREE TO CHANGE THIS %%%%%%%%%
input_directory = 'D:\Dropbox\ECCGroup\data\instruction-mixes\rv64g\post-processed\hsiao-code\random-sampling\2016-7-25 rv64g 1000inst filter-rank pick_first';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Read in names of benchmarks to process as subdirectories
dir_contents = dir(input_directory);
j=1;
for i=1:size(dir_contents,1)
    if ~dir_contents(i).isdir || strcmp(dir_contents(i).name, '.') == 1 || strcmp(dir_contents(i).name, '..') == 1
        continue;
    end
    
    benchmarks{j,1} = dir_contents(i).name;
    j = j+1;
end

%% Construct monster nested maps. 
% At the top level, the map is keyed by benchmark. 
% Then the next level(s) are keyed by what is produced by analyze_static_rv64g_program_statistics output files.
overall_instruction_mnemonic_count = containers.Map(); % Init
overall_instruction_codec_count = containers.Map(); % Init
overall_instruction_rd_count = containers.Map(); % Init
overall_instruction_rs1_count = containers.Map(); % Init
overall_instruction_rs2_count = containers.Map(); % Init
overall_instruction_rs3_count = containers.Map(); % Init
overall_instruction_imm_count = containers.Map(); % Init
overall_instruction_arg_count = containers.Map(); % Init
overall_instruction_overall_reg_count = containers.Map(); % Init
overall_joint_mnemonic_rd_count = containers.Map(); % Init


for i=1:size(benchmarks,1)
    % Load the right .mat file for this benchmark
    load([input_directory filesep benchmarks{i} filesep 'rv64g-' benchmarks{i} '-program-statistics.mat']);
    
    overall_instruction_mnemonic_count(benchmark) = instruction_mnemonic_count;
    overall_instruction_codec_count(benchmark) = instruction_codec_count;
    overall_instruction_rd_count(benchmark) = instruction_rd_count;
    overall_instruction_rs1_count(benchmark) = instruction_rs1_count;
    overall_instruction_rs2_count(benchmark) = instruction_rs2_count;
    overall_instruction_rs3_count(benchmark) = instruction_rs3_count;
    overall_instruction_imm_count(benchmark) = instruction_imm_count;
    overall_instruction_arg_count(benchmark) = instruction_arg_count;
    overall_instruction_overall_reg_count(benchmark) = instruction_overall_reg_count;
    overall_joint_mnemonic_rd_count(benchmark) = joint_mnemonic_rd_count;

    display(['Finished ' benchmark]);
end

display('Now try running extract_program_stats.m for a given benchmark.');
