%% This script automates the post-processing and plotting of data heuristic recovery rates for each benchmark, and overall trend
% Author: Mark Gottscho <mgottscho@ucla.edu>

%%%%%%%% CHANGE ME AS NEEDED %%%%%%%%%%%%
input_directory = '/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/offline-dynamic/hsiao1970/72,64/hash-none/hamming-pick-longest-run/crash-threshold-0.5/2017-03-18';
output_directory = [input_directory filesep 'postprocessed'];
num_words = 1000;
%num_error_patterns = 741; % For (39,32) SECDED
%num_error_patterns = 2556; % For (72,64) SECDED
%num_error_patterns = 14190; % For (45,32) DECTED
%num_error_patterns = 79079; % For (79,64) DECTED
%num_error_patterns = 141750; % For (144,128) ChipKill
%num_error_patterns = 35; % (18,16) ULELC
num_error_patterns = 1000; % sampled
architecture = 'rv64g';
code_type = 'hsiao1970';
hash_mode = 'hash-none';
policy = 'hamming-pick-longest-run';

mkdir(output_directory);

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
benchmark_successes = NaN(num_words,num_error_patterns,num_benchmarks);
benchmark_could_have_crashed = NaN(num_words,num_error_patterns,num_benchmarks);
benchmark_success_with_crash_option = NaN(num_words,num_error_patterns,num_benchmarks);

for bench=1:num_benchmarks
    benchmark = benchmark_names{bench};
    load([input_directory filesep architecture '-' benchmark '-data-heuristic-recovery.mat'], 'results_candidate_messages', 'results_miscorrect', 'success', 'could_have_crashed', 'success_with_crash_option','n','k','avg_candidate_scores');
    benchmark_successes(:,:,bench) = success;
    benchmark_could_have_crashed(:,:,bench) = could_have_crashed;
    benchmark_success_with_crash_option(:,:,bench) = success_with_crash_option;
    benchmark_miscorrect(:,:,bench) = results_miscorrect;
    data_heuristic_recovery_plot;
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
title(['Average Rate of Heuristic Recovery for ' code_type ' (' num2str(n) ',' num2str(k) ') ' hash_mode ' on ' architecture ': ' policy ' Policy'],  'FontSize', 12, 'FontName', 'Arial');
savefig(gcf, [output_directory filesep 'overall_recovery.fig']);
print(gcf, '-depsc2', [output_directory filesep 'overall_recovery.eps']);

avg_benchmark_successes = reshape(mean(mean(benchmark_successes,1),2), [size(benchmark_successes,3),1]);
figure;
barh(avg_benchmark_successes, 'k');
ylabel('Benchmark', 'FontSize', 12, 'FontName', 'Arial');
set(gca,'YTick', 1:size(benchmark_names,1));
set(gca,'YTickLabel', benchmark_names, 'FontSize', 12, 'FontName', 'Arial');
xlim([0 1]);
xlabel('Average Rate of Heuristic Recovery', 'FontSize', 12, 'FontName', 'Arial');
title(['Overall Average Rate of Heuristic Recovery for ' code_type ' (' num2str(n) ',' num2str(k) ') ' hash_mode ' on ' architecture ': ' policy ' Policy'],  'FontSize', 12, 'FontName', 'Arial');
savefig(gcf, [output_directory filesep 'overall_recovery_avg.fig']);
print(gcf, '-depsc2', [output_directory filesep 'overall_recovery_avg.eps']);

avg_benchmark_could_have_crashed = reshape(mean(mean(benchmark_could_have_crashed,1),2), [size(benchmark_could_have_crashed,3),1]);
figure;
barh(avg_benchmark_could_have_crashed, 'k');
ylabel('Benchmark', 'FontSize', 12, 'FontName', 'Arial');
set(gca,'YTick', 1:size(benchmark_names,1));
set(gca,'YTickLabel', benchmark_names, 'FontSize', 12, 'FontName', 'Arial');
xlim([0 1]);
xlabel('Average Rate of Crash Opt-In', 'FontSize', 12, 'FontName', 'Arial');
title(['Overall Average Rate of Crash Opt-In for ' code_type ' (' num2str(n) ',' num2str(k) ') ' hash_mode ' on ' architecture ': ' policy ' Policy'],  'FontSize', 12, 'FontName', 'Arial');
savefig(gcf, [output_directory filesep 'overall_could_have_crashed_avg.fig']);
print(gcf, '-depsc2', [output_directory filesep 'overall_could_have_crashed_avg.eps']);

avg_benchmark_success_with_crash_option = reshape(mean(mean(benchmark_success_with_crash_option,1),2), [size(benchmark_success_with_crash_option,3),1]);
figure;
barh(avg_benchmark_success_with_crash_option, 'k');
ylabel('Benchmark', 'FontSize', 12, 'FontName', 'Arial');
set(gca,'YTick', 1:size(benchmark_names,1));
set(gca,'YTickLabel', benchmark_names, 'FontSize', 12, 'FontName', 'Arial');
xlim([0 1]);
xlabel('Average Rate of Success With Crash Opt-in', 'FontSize', 12, 'FontName', 'Arial');
title(['Overall Average Rate of Success With Crash Opt-In for ' code_type ' (' num2str(n) ',' num2str(k) ') ' hash_mode ' on ' architecture ': ' policy ' Policy'],  'FontSize', 12, 'FontName', 'Arial');
savefig(gcf, [output_directory filesep 'overall_recovery_with_crash_option_avg.fig']);
print(gcf, '-depsc2', [output_directory filesep 'overall_recovery_with_crash_option_avg.eps']);

avg_benchmark_miscorrect = reshape(mean(mean(benchmark_miscorrect,1),2), [size(benchmark_miscorrect,3),1]);
figure;
barh(avg_benchmark_miscorrect, 'k');
ylabel('Benchmark', 'FontSize', 12, 'FontName', 'Arial');
set(gca,'YTick', 1:size(benchmark_names,1));
set(gca,'YTickLabel', benchmark_names, 'FontSize', 12, 'FontName', 'Arial');
%xlim([0 1]);
xlabel('Average Rate of Miscorrection', 'FontSize', 12, 'FontName', 'Arial');
title(['Overall Average Rate of Miscorrection With Crash Opt-In for ' code_type ' (' num2str(n) ',' num2str(k) ') ' hash_mode ' on ' architecture ': ' policy ' Policy'],  'FontSize', 12, 'FontName', 'Arial');
savefig(gcf, [output_directory filesep 'overall_miscorrect_with_crash_option_avg.fig']);
print(gcf, '-depsc2', [output_directory filesep 'overall_miscorrect_with_crash_option_avg.eps']);

figure;
barh([avg_benchmark_successes 1-avg_benchmark_successes],'stacked');
ylabel('Benchmark', 'FontSize', 12, 'FontName', 'Arial');
set(gca,'YTick', 1:size(benchmark_names,1));
set(gca,'YTickLabel', benchmark_names, 'FontSize', 12, 'FontName', 'Arial');
xlim([0 1]);
xlabel('Fraction of DUEs', 'FontSize', 12, 'FontName', 'Arial');
title(['Breakdown of Successful Recovery and Miscorrections with No Crash Policy for ' code_type ' (' num2str(n) ',' num2str(k) ') ' hash_mode ' on ' architecture ': ' policy ' Policy'],  'FontSize', 12, 'FontName', 'Arial');
savefig(gcf, [output_directory filesep 'overall_miscorrect_no_crash_policy_breakdown.fig']);
print(gcf, '-depsc2', [output_directory filesep 'overall_miscorrect_no_crash_policy_breakdown.eps']);

stackData = NaN(num_benchmarks, 2, 3);
for bench=1:num_benchmarks
   % No crash policy
   stackData(bench,1,1) = avg_benchmark_successes(bench);
   stackData(bench,1,2) = 0;
   stackData(bench,1,3) = 1-avg_benchmark_successes(bench);

   % Crash policy
   stackData(bench,2,1) = 1-(avg_benchmark_could_have_crashed(bench)+avg_benchmark_miscorrect(bench));
   stackData(bench,2,2) = avg_benchmark_could_have_crashed(bench);
   stackData(bench,2,3) = avg_benchmark_miscorrect(bench);
end
plotBarStackGroups(stackData,benchmark_names);
xlim([0 21]);
xticklabel_rotate([],45,[],'fontsize',14);
ylabel('Fraction of DUEs', 'FontSize', 12, 'FontName', 'Arial');
colormap(flipud(prism));
legend({'Successful Recovery', 'Forced Crash', 'Failed Recovery (MCE)'});
title(['Breakdown of DUEs for ' code_type ' (' num2str(n) ',' num2str(k) ') ' hash_mode ' on ' architecture ': ' policy ' Policy'],  'FontSize', 12, 'FontName', 'Arial');
savefig(gcf, [output_directory filesep 'due_breakdown.fig']);
print(gcf, '-depsc2', [output_directory filesep 'due_breakdown.eps']);


figure;
subplot(1,2,1);
avg_benchmark_successes_mean = mean(avg_benchmark_successes);
avg_benchmark_could_have_crashed_mean = mean(avg_benchmark_could_have_crashed);
avg_benchmark_miscorrect_mean = mean(avg_benchmark_miscorrect);
pie([avg_benchmark_successes_mean 1-avg_benchmark_successes_mean]);
subplot(1,2,2);
pie([1-(avg_benchmark_could_have_crashed_mean+avg_benchmark_miscorrect_mean) avg_benchmark_could_have_crashed_mean avg_benchmark_miscorrect_mean]);
colormap(flipud(prism));
legend({'Successful Recovery', 'Forced Crash', 'Failed Recovery (MCE)'});
title(['Breakdown of DUEs for ' code_type ' (' num2str(n) ',' num2str(k) ') ' hash_mode ' on ' architecture ': ' policy ' Policy'],  'FontSize', 12, 'FontName', 'Arial');
savefig(gcf, [output_directory filesep 'due_breakdown.fig']);
print(gcf, '-depsc2', [output_directory filesep 'due_breakdown.eps']);


if (strcmp(code_type,'hsiao1970') == 1 || strcmp(code_type,'davydov1991') == 1) && ((n == 72 && num_error_patterns == 2556) || (n == 39 && num_error_patterns == 741))    
    secded_heatmap(results_candidate_messages,n);
    savefig(gcf, [output_directory filesep code_type '-' num2str(n) '-' num2str(k) '-cc-heatmap.fig']);
    print(gcf, '-depsc2', [output_directory filesep code_type '-' num2str(n) '-' num2str(k) '-cc-heatmap.eps']);
end

save([output_directory filesep 'postprocessed.mat'], '-v7.3');
