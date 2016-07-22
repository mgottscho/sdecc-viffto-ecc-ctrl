%% This script automates the post-processing and plotting of instruction heuristic recovery rates for each benchmark, and overall trend
% Author: Mark Gottscho <mgottscho@ucla.edu>

input_directory = '/Users/Mark/Dropbox/ECCGroup/data/instruction-mixes/rv64g/post-processed/davydov-code/random-sampling/2016-7-18 to 2016-7-21 rv64g 1000inst';
output_directory = input_directory;
inst_fields_file = '/Users/Mark/Dropbox/ECCGroup/data/instruction-mixes/rv64g/post-processed/rv64g_inst_field_bitmasks.mat';
num_inst = 1000;
num_error_patterns = 741;
architecture = 'rv64g';
code_type = 'davydov1991';
policy = 'Filter-Rank-Filter-Rank';
benchmark_names = {
    'bzip2',
    'gobmk',
    'h264ref',
    'lbm',
    'libquantum',
    'mcf',
    'milc',
    'namd',
    'omnetpp',
    'perlbench',
    'povray',
    'sjeng',
    'soplex',
    'specrand998',
    'specrand999'
};

num_benchmarks = size(benchmark_names,1);
benchmark_successes = NaN(num_inst,num_error_patterns,num_benchmarks);

load(inst_fields_file);

for bench=1:num_benchmarks
    benchmark = benchmark_names{bench};
    load([input_directory filesep benchmark filesep architecture '-' benchmark '-inst-heuristic-recovery.mat'], 'results_valid_messages', 'success');
    benchmark_successes(:,:,bench) = success;
    heuristic_recovery_plot;
    print(gcf, '-depsc2', [output_directory filesep benchmark filesep architecture '-' benchmark '-inst-heuristic-recovery.eps']);
    close(gcf);
end

figure;
hold on;
mycolors = copper(num_benchmarks);
for bench=1:num_benchmarks
    plot(mean(benchmark_successes(:,:,bench),1), 'Color', mycolors(bench,:));
end
legend(benchmark_names, 'FontSize', 10, 'FontName', 'Arial');
xlabel('Index of 2-bit Error Pattern', 'FontSize', 12, 'FontName', 'Arial');
set(gca, 'FontSize', 12, 'FontName', 'Arial');
ylabel('Average Rate of Heuristic Recovery', 'FontSize', 12, 'FontName', 'Arial');
set(gca, 'FontSize', 12, 'FontName', 'Arial');
title(['Average Rate of Heuristic Recovery for ' code_type ' (39,32) SECDED on ' architecture ': ' policy ' Policy'],  'FontSize', 12, 'FontName', 'Arial');


avg_benchmark_successes = reshape(mean(mean(benchmark_successes,1),2), [size(benchmark_successes,3),1]);
figure;
barh(avg_benchmark_successes, 'k');
ylabel('Benchmark', 'FontSize', 12, 'FontName', 'Arial');
set(gca,'YTickLabel', benchmark_names, 'FontSize', 12, 'FontName', 'Arial');
xlim([0 1]);
xlabel('Average Rate of Heuristic Recovery', 'FontSize', 12, 'FontName', 'Arial');
title(['Overall Average Rate of Heuristic Recovery for ' code_type ' (39,32) SECDED on ' architecture ': ' policy ' Policy'],  'FontSize', 12, 'FontName', 'Arial');