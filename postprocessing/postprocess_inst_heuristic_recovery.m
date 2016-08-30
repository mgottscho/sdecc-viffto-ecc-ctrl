%% This script automates the post-processing and plotting of instruction heuristic recovery rates for each benchmark, and overall trend
% Author: Mark Gottscho <mgottscho@ucla.edu>

%%%%%%%% CHANGE ME AS NEEDED %%%%%%%%%%%%
input_directory = '/Users/Mark/Dropbox/SoftwareDefinedECC/data/rv64g/heuristic-recovery/instructions/hsiao-code/offline-static-random-sampling/2016-8-26 rv64g 1000inst filter-frequency-sort-pick-longest-pad';
output_directory = input_directory;
inst_fields_file = '/Users/Mark/Dropbox/SoftwareDefinedECC/data/rv64g/rv64g_inst_field_bitmasks.mat';
num_inst = 1000;
num_error_patterns = 741; % For (39,32) SECDED
architecture = 'rv64g';
code_type = 'hsiao1970 (39,32) SECDED';
policy = 'Filter-Frequency-Sort-Pick-Longest-Pad';

%% Read in names of benchmarks to process
dir_contents = dir(input_directory);
j=1;
benchmark_filenames = cell(1,1);
benchmark_names = cell(1,1);
for i=1:size(dir_contents,1)
    %if dir_contents(i).isdir || strcmp(dir_contents(i).name, '.') == 1 || strcmp(dir_contents(i).name, '..') == 1 || strcmp(dir_contents(i).name, '.DS_Store') == 1 || size(strfind(dir_contents(i).name,'.log'),1) > 0
    %    continue;
    %end
    
    % Skip all files except those containing '.mat'
    if dir_contents(i).isdir || size(strfind(dir_contents(i).name,'.mat'),1) <= 0
        continue;
    end
    
    benchmark_filenames{j,1} = dir_contents(i).name;
    benchmark_name = benchmark_filenames{j,1};
    [~, remain] = strtok(benchmark_name, '-');
    [benchmark_name, remain] = strtok(remain, '-');
    benchmark_names{j,1} = benchmark_name;
    j = j+1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num_benchmarks = size(benchmark_names,1);
benchmark_successes = NaN(num_inst,num_error_patterns,num_benchmarks);
benchmark_could_have_crashed = NaN(num_inst,num_error_patterns,num_benchmarks);
benchmark_success_with_crash_option = NaN(num_inst,num_error_patterns,num_benchmarks);
load(inst_fields_file);

for bench=1:num_benchmarks
    benchmark = benchmark_names{bench};
    load([input_directory filesep architecture '-' benchmark '-inst-heuristic-recovery.mat'], 'results_valid_messages', 'success', 'could_have_crashed', 'success_with_crash_option');
    benchmark_successes(:,:,bench) = success;
    benchmark_could_have_crashed(:,:,bench) = could_have_crashed;
    benchmark_success_with_crash_option(:,:,bench) = success_with_crash_option;
    inst_heuristic_recovery_plot;
end

figure;
hold on;
mycolors = copper(num_benchmarks);
for bench=1:num_benchmarks
    plot(mean(benchmark_successes(:,:,bench),1), 'Color', mycolors(bench,:));
end
legend(benchmark_names, 'FontSize', 10, 'FontName', 'Arial');
xlabel('Error Pattern ID', 'FontSize', 12, 'FontName', 'Arial');
set(gca, 'FontSize', 12, 'FontName', 'Arial');
ylabel('Average Rate of Heuristic Recovery', 'FontSize', 12, 'FontName', 'Arial');
set(gca, 'FontSize', 12, 'FontName', 'Arial');
title(['Average Rate of Heuristic Recovery for ' code_type ' on ' architecture ': ' policy ' Policy'],  'FontSize', 12, 'FontName', 'Arial');
print(gcf, '-depsc2', [output_directory filesep 'overall_recovery.eps']);

avg_benchmark_successes = reshape(mean(mean(benchmark_successes,1),2), [size(benchmark_successes,3),1]);
figure;
barh(avg_benchmark_successes, 'k');
ylabel('Benchmark', 'FontSize', 12, 'FontName', 'Arial');
set(gca,'YTick', 1:size(benchmark_names,1));
set(gca,'YTickLabel', benchmark_names, 'FontSize', 12, 'FontName', 'Arial');
xlim([0 1]);
xlabel('Average Rate of Heuristic Recovery', 'FontSize', 12, 'FontName', 'Arial');
title(['Overall Average Rate of Heuristic Recovery for ' code_type ' on ' architecture ': ' policy ' Policy'],  'FontSize', 12, 'FontName', 'Arial');
print(gcf, '-depsc2', [output_directory filesep 'overall_recovery_avg.eps']);

avg_benchmark_could_have_crashed = reshape(mean(mean(benchmark_could_have_crashed,1),2), [size(benchmark_could_have_crashed,3),1]);
figure;
barh(avg_benchmark_could_have_crashed, 'k');
ylabel('Benchmark', 'FontSize', 12, 'FontName', 'Arial');
set(gca,'YTick', 1:size(benchmark_names,1));
set(gca,'YTickLabel', benchmark_names, 'FontSize', 12, 'FontName', 'Arial');
xlim([0 1]);
xlabel('Average Rate of Crash Opt-In', 'FontSize', 12, 'FontName', 'Arial');
title(['Overall Average Rate of Crash Opt-In for ' code_type ' on ' architecture ': ' policy ' Policy'],  'FontSize', 12, 'FontName', 'Arial');
print(gcf, '-depsc2', [output_directory filesep 'overall_could_have_crashed_avg.eps']);

avg_benchmark_success_with_crash_option = reshape(mean(mean(benchmark_success_with_crash_option,1),2), [size(benchmark_success_with_crash_option,3),1]);
figure;
barh(avg_benchmark_success_with_crash_option, 'k');
ylabel('Benchmark', 'FontSize', 12, 'FontName', 'Arial');
set(gca,'YTick', 1:size(benchmark_names,1));
set(gca,'YTickLabel', benchmark_names, 'FontSize', 12, 'FontName', 'Arial');
xlim([0 1]);
xlabel('Average Rate of Success With Crash Opt-in', 'FontSize', 12, 'FontName', 'Arial');
title(['Overall Average Rate of Success With Crash Opt-In for ' code_type ' on ' architecture ': ' policy ' Policy'],  'FontSize', 12, 'FontName', 'Arial');
print(gcf, '-depsc2', [output_directory filesep 'overall_recovery_with_crash_option_avg.eps']);
