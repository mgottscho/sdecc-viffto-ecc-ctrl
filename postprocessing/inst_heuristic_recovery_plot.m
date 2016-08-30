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
scatter(x(opcodes_affected),y(opcodes_affected),'r');
hold on;
scatter(x(rd_affected),y(rd_affected),'b');
scatter(x(funct3_affected),y(funct3_affected),'g');
scatter(x(rs1_affected),y(rs1_affected),'k');
scatter(x(rs2_affected),y(rs2_affected),'y');
scatter(x(funct7_affected),y(funct7_affected),'c');
scatter(x(parity_affected),y(parity_affected),'k.');
xlim([0 20]);
ylim([0 1]);

legend('opcode','rd','funct3','rs1','rs2','funct7','parity');
xlabel('Average Number of Valid (Filtered) Candidate Messages', 'FontSize', 12, 'FontName', 'Arial');
ylabel('Average Rate of Recovery', 'FontSize', 12, 'FontName', 'Arial');
title(['Rate of Heuristic Recovery for ' code_type ' -- ' benchmark ' -- ' policy], 'FontSize', 12, 'FontName', 'Arial');
