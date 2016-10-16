%% This script automates the post-processing and plotting of static program analysis for each benchmark
% Author: Mark Gottscho <mgottscho@ucla.edu>

%%%%%%%% CHANGE ME AS NEEDED %%%%%%%%%%%%
input_directory = '/Users/Mark/Dropbox/SoftwareDefinedECC/data/rv64g/program-statistics/2016-10-13 dynamic';
output_directory = [input_directory filesep 'postprocessed'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Read in names of benchmarks to process
dir_contents = dir(input_directory);
j=1;
benchmark_filenames = cell(1,1);
benchmarks = cell(1,1);
for i=1:size(dir_contents,1)
    if dir_contents(i).isdir || strcmp(dir_contents(i).name, '.') == 1 || strcmp(dir_contents(i).name, '..') == 1 || strcmp(dir_contents(i).name, '.DS_Store') == 1
        continue;
    end
    
    % Skip all files except those containing '.mat'
    if dir_contents(i).isdir || size(strfind(dir_contents(i).name,'.mat'),1) <= 0
        continue;
    end
    
    benchmark_filenames{j,1} = dir_contents(i).name;
    benchmark_name = benchmark_filenames{j,1};
    [~, remain] = strtok(benchmark_name, '-');
    [benchmark_name, remain] = strtok(remain, '-');
    benchmarks{j,1} = benchmark_name;
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
overall_joint_mnemonic_reg_count = containers.Map(); % Init


for i=1:size(benchmarks,1)
    % Load the right .mat file for this benchmark
    benchmark = benchmarks{i};
    load([input_directory filesep benchmark_filenames{i}]);
    
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
    overall_joint_mnemonic_reg_count(benchmark) = joint_mnemonic_reg_count;

    display(['Finished ' benchmark]);
end

%% Save progress
mkdir(output_directory);
save([output_directory filesep 'overall_program_results.mat'],...
    'overall_instruction_mnemonic_count',...
    'overall_instruction_codec_count',...
    'overall_instruction_rd_count',...
    'overall_instruction_rs1_count',...
    'overall_instruction_rs2_count',...
    'overall_instruction_rs3_count',...
    'overall_instruction_imm_count',...
    'overall_instruction_arg_count',...
    'overall_instruction_overall_reg_count',...
    'overall_joint_mnemonic_rd_count',...
    'overall_joint_mnemonic_reg_count',...
    'benchmarks',...
    'architecture');

%% Extract results for each benchmark, save, and plot them
for i=1:size(benchmarks,1)
   benchmark = benchmarks{i};
   extract_program_stats;
end












