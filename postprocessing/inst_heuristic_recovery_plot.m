% This script plots the rate of heuristic recovery for a given benchmark/code/instruction sample.
% Each point in the resulting plot is the arithmetic mean rate of recovery for each error pattern, averaged over all instructions that were sampled.
% The colors represent the bit(s) that were in error. If a point has errors in multiple subfields, the last of them in the legend takes color predence.
% The appropriate variables are assumed to already have been loaded in the
% workspace.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

addpath ../common % Add sub-folders to MATLAB search paths for calling other functions we wrote

x = mean(results_valid_messages);
y = mean(success);

% Assume 2 bits in error -- secded plot only
first_error_mask = repmat('0',size(error_patterns,1),32);
first_error_bitpos = NaN(size(error_patterns,1),1);
second_error_bitpos = NaN(size(error_patterns,1),1);
second_error_mask = repmat('0',size(error_patterns,1),32);

parity_mask = repmat('0',1,n);
parity_mask(k+1:n) = '1';

opcodes_affected_first_error = logical(zeros(size(error_patterns,1),1));
rd_affected_first_error = logical(zeros(size(error_patterns,1),1));
funct3_affected_first_error = logical(zeros(size(error_patterns,1),1));
rs1_affected_first_error = logical(zeros(size(error_patterns,1),1));
rs2_affected_first_error = logical(zeros(size(error_patterns,1),1));
funct7_affected_first_error = logical(zeros(size(error_patterns,1),1));
parity_affected_first_error = logical(zeros(size(error_patterns,1),1));

opcodes_affected_second_error = logical(zeros(size(error_patterns,1),1));
rd_affected_second_error = logical(zeros(size(error_patterns,1),1));
funct3_affected_second_error = logical(zeros(size(error_patterns,1),1));
rs1_affected_second_error = logical(zeros(size(error_patterns,1),1));
rs2_affected_second_error = logical(zeros(size(error_patterns,1),1));
funct7_affected_second_error = logical(zeros(size(error_patterns,1),1));
parity_affected_second_error = logical(zeros(size(error_patterns,1),1));

for i=1:size(error_patterns,1)
    tmp = strfind(error_patterns(i,:),'1');
    first_error_bitpos(i) = tmp(1);
    second_error_bitpos(i) = tmp(2);
    first_error_mask(i,first_error_bitpos(i)) = '1';
    second_error_mask(i,second_error_bitpos(i)) = '1';
    
    if sum(my_bitand(first_error_mask(i,1:32),opcode_mask)=='1') > 0
        opcodes_affected_first_error(i) = true;
    end
    if sum(my_bitand(second_error_mask(i,1:32),opcode_mask)=='1') > 0
        opcodes_affected_second_error(i) = true;
    end
    
    if sum(my_bitand(first_error_mask(i,1:32),rd_mask)=='1') > 0
        rd_affected_first_error(i) = true;
    end
    if sum(my_bitand(second_error_mask(i,1:32),rd_mask)=='1') > 0
        rd_affected_second_error(i) = true;
    end
    
    if sum(my_bitand(first_error_mask(i,1:32),funct3_mask)=='1') > 0
        funct3_affected_first_error(i) = true;
    end
    if sum(my_bitand(second_error_mask(i,1:32),funct3_mask)=='1') > 0
        funct3_affected_second_error(i) = true;
    end
    
    if sum(my_bitand(first_error_mask(i,1:32),rs1_mask)=='1') > 0
        rs1_affected_first_error(i) = true;
    end
    if sum(my_bitand(second_error_mask(i,1:32),rs1_mask)=='1') > 0
        rs1_affected_second_error(i) = true;
    end
    
    if sum(my_bitand(first_error_mask(i,1:32),rs2_mask)=='1') > 0
        rs2_affected_first_error(i) = true;
    end
    if sum(my_bitand(second_error_mask(i,1:32),rs2_mask)=='1') > 0
        rs2_affected_second_error(i) = true;
    end
    
    if sum(my_bitand(first_error_mask(i,1:32),funct7_mask)=='1') > 0
        funct7_affected_first_error(i) = true;
    end
    if sum(my_bitand(second_error_mask(i,1:32),funct7_mask)=='1') > 0
        funct7_affected_second_error(i) = true;
    end
    
    if sum(first_error_mask(i,1:32)=='1') == 0
        parity_affected_first_error(i) = true;
    end
    if sum(second_error_mask(i,1:32)=='1') == 0
        parity_affected_second_error(i) = true;
    end
end

figure;
scatter(x(opcodes_affected_first_error),y(opcodes_affected_first_error),'ro');
hold on;
scatter(x(rd_affected_first_error),y(rd_affected_first_error),'bo');
scatter(x(funct3_affected_first_error),y(funct3_affected_first_error),'go');
scatter(x(rs1_affected_first_error),y(rs1_affected_first_error),'mo');
scatter(x(rs2_affected_first_error),y(rs2_affected_first_error),'yo');
scatter(x(funct7_affected_first_error),y(funct7_affected_first_error),'co');
scatter(x(parity_affected_first_error),y(parity_affected_first_error),'ko');

scatter(x(opcodes_affected_second_error),y(opcodes_affected_second_error),40,'r.');
scatter(x(rd_affected_second_error),y(rd_affected_second_error),40,'b.');
scatter(x(funct3_affected_second_error),y(funct3_affected_second_error),40,'g.');
scatter(x(rs1_affected_second_error),y(rs1_affected_second_error),40,'m.');
scatter(x(rs2_affected_second_error),y(rs2_affected_second_error),40,'y.');
scatter(x(funct7_affected_second_error),y(funct7_affected_second_error),40,'c.');
scatter(x(parity_affected_second_error),y(parity_affected_second_error),40,'k.');

xlim([0 20]);
ylim([0 1]);

legend('opcode (bit 1)','rd (bit 1)','funct3 (bit 1)','rs1 (bit 1)','rs2 (bit 1)','funct7 (bit 1)','parity (bit 1)', 'opcode (bit 2)','rd (bit 2)','funct3 (bit 2)','rs1 (bit 2)','rs2 (bit 2)','funct7 (bit 2)','parity (bit 2)');
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