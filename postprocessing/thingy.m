joint_mnemonic_reg_freq_matrix = cell(125,66);
joint_mnemonic_reg_freq_matrix(:,1) = joint_mnemonic_reg_count_matrix(:,1);
joint_mnemonic_reg_freq_matrix(1,:) = joint_mnemonic_reg_count_matrix(1,:);
for r=2:125
    for c=2:66
        joint_mnemonic_reg_freq_matrix{r,c} = 1;
    end
end
for i=1:size(benchmarks,1)
    benchmark = benchmarks{i};
    load([input_directory filesep benchmark_filenames{i}]);
    total_per_bm = sum(sum(cell2mat(joint_mnemonic_reg_count_matrix(2:end,2:end))));
    for r=2:125
        for c=2:66
            joint_mnemonic_reg_freq_matrix{r,c} = joint_mnemonic_reg_freq_matrix{r,c} * (joint_mnemonic_reg_count_matrix{r,c} / total_per_bm);
        end
    end
end

surf(cell2mat(joint_mnemonic_reg_freq_matrix(2:end,2:end)));
xlabel('Register');
set(gca,'XTick',[1:2:size(regs,2)]','XTickLabel',regs(1,1:2:end)');
ylabel('Mnemonic');
set(gca,'YTick',[1:5:size(mnemonics,1)]','YTickLabel',mnemonics(1:5:end)');
zlabel('Relative Frequency');
%title(['Joint Relative Frequency of Mnemonic-Register Pairs: ' architecture ', ' benchmark]);