joint_mnemonic_reg_freq_matrix_mean = cell(125,66);
joint_mnemonic_reg_freq_matrix_mean(:,1) = joint_mnemonic_reg_count_matrix(:,1);
joint_mnemonic_reg_freq_matrix_mean(1,:) = joint_mnemonic_reg_count_matrix(1,:);
for r=2:125
    for c=2:66
         joint_mnemonic_reg_freq_matrix_mean{r,c} = 0; % Arith mean
        %joint_mnemonic_reg_freq_matrix_mean{r,c} = 1; % Geo mean
%         joint_mnemonic_reg_freq_matrix_mean{r,c} = 0; % Harmonic mean
    end
end
for i=1:size(benchmarks,1)
    benchmark = benchmarks{i};
    load([output_directory filesep 'rv64g-' benchmark '-program-statistics-tabular.mat']);
    total_per_bm = sum(sum(cell2mat(joint_mnemonic_reg_count_matrix(2:end,2:end))));
    for r=2:125
        for c=2:66
            %% Geo mean
            %joint_mnemonic_reg_freq_matrix_mean{r,c} = nthroot((joint_mnemonic_reg_freq_matrix_mean{r,c}^(i-1)) * (joint_mnemonic_reg_count_matrix{r,c} / total_per_bm),i);
            %% Arith mean
             if i == 1
                 joint_mnemonic_reg_freq_matrix_mean{r,c} = joint_mnemonic_reg_count_matrix{r,c} / total_per_bm;
             else
                 joint_mnemonic_reg_freq_matrix_mean{r,c} = (joint_mnemonic_reg_freq_matrix_mean{r,c} * (i-1) + (joint_mnemonic_reg_count_matrix{r,c} / total_per_bm)) / i;
             end
            %% Harmonic mean (ignore 0 entries) -- probably wrong
%             if i == 1
%                joint_mnemonic_reg_freq_matrix_mean{r,c} = 1/(1/joint_mnemonic_reg_freq_matrix{r,c});
%             elseif joint_mnemonic_reg_count_matrix{r,c} > 0
%                joint_mnemonic_reg_freq_matrix_mean{r,c} = 1/(1/(joint_mnemonic_reg_freq_matrix_mean{r,c}/(i-1)) + (1/(joint_mnemonic_reg_count_matrix{r,c}/total_per_bm)))*i;
%             end
        end
    end
end

figure;
surf(cell2mat(joint_mnemonic_reg_freq_matrix_mean(2:end,2:end)));
xlabel('Register');
set(gca,'XTick',[1:2:size(regs,2)]','XTickLabel',regs(1,1:2:end)');
ylabel('Mnemonic');
set(gca,'YTick',[1:5:size(mnemonics,1)]','YTickLabel',mnemonics(1:5:end)');
zlabel('Relative Frequency');