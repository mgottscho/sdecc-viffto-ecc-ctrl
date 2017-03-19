% This script plots the rate of heuristic recovery for a given benchmark/code/instruction sample.
% Each point in the resulting plot is the arithmetic mean rate of recovery for each error pattern, averaged over all instructions that were sampled.
% The colors represent the bit(s) that were in error. If a point has errors in multiple subfields, the last of them in the legend takes color predence.
% The appropriate variables are assumed to already have been loaded in the
% workspace.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

x = mean(results_candidate_messages);
y = mean(success);

figure;
scatter(x,y,'k');

xlim([0 30]);
ylim([0 1]);

xlabel('Average Number of Candidate Messages', 'FontSize', 12, 'FontName', 'Arial');
ylabel('Average Rate of Recovery', 'FontSize', 12, 'FontName', 'Arial');
title(['Rate of Heuristic Recovery for ' code_type ' (' num2str(n) ',' num2str(k) ') -- ' benchmark ' -- ' policy], 'FontSize', 12, 'FontName', 'Arial');

print(gcf, '-depsc2', [output_directory filesep architecture '-' benchmark '-data-heuristic-recovery.eps']);
savefig(gcf, [output_directory filesep architecture '-' benchmark '-data-heuristic-recovery.fig']);
close(gcf);

figure;
histogram(avg_candidate_scores,[0:0.05:max(avg_candidate_scores)]); % Change range for different policies
hold on;
tmp = avg_candidate_scores.*success;
tmp((avg_candidate_scores ~= 0) & (success == 0)) = NaN;
histogram(tmp,[0:0.05:6]);
xlabel('Mean Candidate Score', 'FontSize', 12, 'FontName', 'Arial');
ylabel('Count', 'FontSize', 12, 'FontName', 'Arial');
set(gca,'YTick',[]);
title(['Rate of Heuristic Recovery vs. Mean Candidate Score for ' code_type ' (' num2str(n) ',' num2str(k) ') -- ' benchmark ' -- ' policy], 'FontSize', 12, 'FontName', 'Arial');
legend({'Mean Candidate Score', 'Successful Recovery'});
print(gcf, '-depsc2', [output_directory filesep architecture '-' benchmark '-success-vs-score-histogram.eps']);
savefig(gcf, [output_directory filesep architecture '-' benchmark '-success-vs-score-histogram.fig']);
%close(gcf);

if (strcmp(code_type,'hsiao1970') == 1 || strcmp(code_type,'davydov1991') == 1) && ((n == 72 && num_error_patterns == 2556) || (n == 39 && num_error_patterns == 741))
    secded_heatmap(success,n);
    savefig(gcf, [output_directory filesep architecture '-' benchmark '-data-heuristic-recovery-heatmap.fig']);
    print(gcf, '-depsc2', [output_directory filesep architecture '-' benchmark '-data-heuristic-recovery-heatmap.eps']);
    close(gcf);

    secded_surf(success,n);
    savefig(gcf,[output_directory filesep architecture '-' benchmark '-data-heuristic-recovery-surf.fig']);
    print(gcf, '-depsc2', [output_directory filesep architecture '-' benchmark '-data-heuristic-recovery-surf.eps']);
    close(gcf);
end