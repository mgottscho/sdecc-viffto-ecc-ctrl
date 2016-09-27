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
title(['Rate of Heuristic Recovery for ' code_type ' (' num2str(n) ',' num2str(k) ') -- ' benchmark ' -- ' policy], 'FontSize', 12, 'FontName', 'Arial');

print(gcf, '-depsc2', [output_directory filesep architecture '-' benchmark '-inst-heuristic-recovery.eps']);
close(gcf);

if strcmp(code_type,'hsiao1970') == 1 || strcmp(code_type,'davydov1991') == 1
    z=1;
    success_2d = NaN(n+1,n+1);
    mean_success = mean(success);
    for err_bitpos_1=1:n-1
        for err_bitpos_2=err_bitpos_1+1:n
            success_2d(err_bitpos_1,err_bitpos_2) = mean_success(z);
            z=z+1;
        end
    end
    success_2d(end,:) = NaN;
    success_2d(:,end) = NaN;

    figure;
    pcolor(success_2d);
    xlim([0 n]);
    ylim([0 n]);

    xlabel('Index of 1st bit in error', 'FontSize', 12, 'FontName', 'Arial');
    ylabel('Index of 2nd bit in error', 'FontSize', 12, 'FontName', 'Arial');
    title(['Rate of Heuristic Recovery for ' code_type ' (' num2str(n) ',' num2str(k) ') -- ' benchmark ' -- ' policy], 'FontSize', 12, 'FontName', 'Arial');

    print(gcf, '-depsc2', [output_directory filesep architecture '-' benchmark '-inst-heuristic-recovery-heatmap.eps']);
    close(gcf);
end