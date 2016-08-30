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
title(['Rate of Heuristic Recovery for ' code_type ' -- ' benchmark ' -- ' policy], 'FontSize', 12, 'FontName', 'Arial');
