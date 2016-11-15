% Extract specific parts of data from a giant nested map produced by
% gather_program_stats.m
% 
% Set benchmark variable first.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

%% Init: these are for the benchmark in question
mnemonic_count = overall_instruction_mnemonic_count(benchmark);
codec_count = overall_instruction_codec_count(benchmark);
rd_count = overall_instruction_rd_count(benchmark);
rs1_count = overall_instruction_rs1_count(benchmark);
rs2_count = overall_instruction_rs2_count(benchmark);
rs3_count = overall_instruction_rs3_count(benchmark);
imm_count = overall_instruction_imm_count(benchmark);
arg_count = overall_instruction_arg_count(benchmark);
overall_reg_count = overall_instruction_overall_reg_count(benchmark);
joint_mnemonic_rd_count = overall_joint_mnemonic_rd_count(benchmark);
joint_mnemonic_reg_count = overall_joint_mnemonic_reg_count(benchmark);


%% Loop over results from all benchmarks. We do this to make sure we include keys that were not present in the benchmark under test.
for i=1:size(benchmarks,1)
    bm = benchmarks{i};
    
    % mnemonics
    mnemonics_per_benchmark = overall_instruction_mnemonic_count(bm);
    mnemonics_per_benchmark = mnemonics_per_benchmark.keys();
    for j=1:size(mnemonics_per_benchmark,2)
        mnemonic = mnemonics_per_benchmark{j};
        if ~mnemonic_count.isKey(mnemonic)
            mnemonic_count(mnemonic) = 0;
        end
    end
        
    % codecs
    codecs_per_benchmark = overall_instruction_codec_count(bm);
    codecs_per_benchmark = codecs_per_benchmark.keys();
    for j=1:size(codecs_per_benchmark,2)
        codec = codecs_per_benchmark{j};
        if ~codec_count.isKey(codec)
            codec_count(codec) = 0;
        end
    end
    
    % rds
    rds_per_benchmark = overall_instruction_rd_count(bm);
    rds_per_benchmark = rds_per_benchmark.keys();
    for j=1:size(rds_per_benchmark,2)
        rd = rds_per_benchmark{j};
        if ~rd_count.isKey(rd)
            rd_count(rd) = 0;
        end
    end
    
    % rs1s
    rs1s_per_benchmark = overall_instruction_rs1_count(bm);
    rs1s_per_benchmark = rs1s_per_benchmark.keys();
    for j=1:size(rs1s_per_benchmark,2)
        rs1 = rs1s_per_benchmark{j};
        if ~rs1_count.isKey(rs1)
            rs1_count(rs1) = 0;
        end
    end
    
    % rs2s
    rs2s_per_benchmark = overall_instruction_rs2_count(bm);
    rs2s_per_benchmark = rs2s_per_benchmark.keys();
    for j=1:size(rs2s_per_benchmark,2)
        rs2 = rs2s_per_benchmark{j};
        if ~rs2_count.isKey(rs2)
            rs2_count(rs2) = 0;
        end
    end
    
    % rs3s
    rs3s_per_benchmark = overall_instruction_rs3_count(bm);
    rs3s_per_benchmark = rs3s_per_benchmark.keys();
    for j=1:size(rs3s_per_benchmark,2)
        rs3 = rs3s_per_benchmark{j};
        if ~rs3_count.isKey(rs3)
            rs3_count(rs3) = 0;
        end
    end
    
    % imms
    imms_per_benchmark = overall_instruction_imm_count(bm);
    imms_per_benchmark = imms_per_benchmark.keys();
    for j=1:size(imms_per_benchmark,2)
        imm = imms_per_benchmark{j};
        if ~imm_count.isKey(imm)
            imm_count(imm) = 0;
        end
    end
        
    % args
    args_per_benchmark = overall_instruction_arg_count(bm);
    args_per_benchmark = args_per_benchmark.keys();
    for j=1:size(args_per_benchmark,2)
        arg = args_per_benchmark{j};
        if ~arg_count.isKey(arg)
            arg_count(arg) = 0;
        end
    end
    
    % overall_regs
    overall_regs_per_benchmark = overall_instruction_overall_reg_count(bm);
    overall_regs_per_benchmark = overall_regs_per_benchmark.keys();
    for j=1:size(overall_regs_per_benchmark,2)
        overall_reg = overall_regs_per_benchmark{j};
        if ~overall_reg_count.isKey(overall_reg)
            overall_reg_count(overall_reg) = 0;
        end
    end
    
    % joint_mnemonic_rds
%     joint_mnemonic_rds_per_benchmark = overall_joint_mnemonic_rd_count(bm);
%     joint_mnemonic_rds_per_benchmark = joint_mnemonic_rds_per_benchmark.keys();
%     for j=1:size(joint_mnemonic_rds_per_benchmark,2)
%         joint_mnemonic_rd = joint_mnemonic_rds_per_benchmark{j};
%         if ~joint_mnemonic_rd_count.isKey(joint_mnemonic_rd)
%             joint_mnemonic_rd_count(joint_mnemonic_rd) = 0;
%         end
%     end  
end

%% Export all these maps for the benchmark to arrays suitable for Excel or plotting here in Matlab

% mnemonic
tmp = mnemonic_count;
mnemonic_count = cell(size(tmp.keys(),2),2);
mnemonic_count(:,1) = tmp.keys()';
mnemonic_count(:,2) = tmp.values()';

% codec
tmp = codec_count;
codec_count = cell(size(tmp.keys(),2),2);
codec_count(:,1) = tmp.keys()';
codec_count(:,2) = tmp.values()';

% rd
tmp = rd_count;
rd_count = cell(size(tmp.keys(),2),2);
rd_count(:,1) = tmp.keys()';
rd_count(:,2) = tmp.values()';

% rs1
tmp = rs1_count;
rs1_count = cell(size(tmp.keys(),2),2);
rs1_count(:,1) = tmp.keys()';
rs1_count(:,2) = tmp.values()';

% rs2
tmp = rs2_count;
rs2_count = cell(size(tmp.keys(),2),2);
rs2_count(:,1) = tmp.keys()';
rs2_count(:,2) = tmp.values()';

% rs3
tmp = rs3_count;
rs3_count = cell(size(tmp.keys(),2),2);
rs3_count(:,1) = tmp.keys()';
rs3_count(:,2) = tmp.values()';

% imm
tmp = imm_count;
imm_count = cell(size(tmp.keys(),2),2);
imm_count(:,1) = tmp.keys()';
imm_count(:,2) = tmp.values()';

% arg
tmp = arg_count;
arg_count = cell(size(tmp.keys(),2),2);
arg_count(:,1) = tmp.keys()';
arg_count(:,2) = tmp.values()';

% overall_reg
tmp = overall_reg_count;
overall_reg_count = cell(size(tmp.keys(),2),2);
overall_reg_count(:,1) = tmp.keys()';
overall_reg_count(:,2) = tmp.values()';

% joint mnemonic-rd prep
for i=1:size(mnemonic_count,1)
    if ~joint_mnemonic_rd_count.isKey(mnemonic_count{i,1})
        joint_mnemonic_rd_count(mnemonic_count{i,1}) = containers.Map();
    end
end

for i=1:size(mnemonic_count,1)
    colmap = joint_mnemonic_rd_count(mnemonic_count{i,1});
    for j=1:size(rd_count,1)
        if ~colmap.isKey(rd_count{j,1})
            colmap(rd_count{j,1}) = 0;
        end
    end
    joint_mnemonic_rd_count(mnemonic_count{i,1}) = colmap;
end

% joint mnemonic-reg prep
for i=1:size(mnemonic_count,1)
    if ~joint_mnemonic_reg_count.isKey(mnemonic_count{i,1})
        joint_mnemonic_reg_count(mnemonic_count{i,1}) = containers.Map();
    end
end

for i=1:size(mnemonic_count,1)
    colmap = joint_mnemonic_reg_count(mnemonic_count{i,1});
    for j=1:size(overall_reg_count,1)
        if ~colmap.isKey(overall_reg_count{j,1})
            colmap(overall_reg_count{j,1}) = 0;
        end
    end
    joint_mnemonic_reg_count(mnemonic_count{i,1}) = colmap;
end
        


%% joint_mnemonic_rd tabular
rowmap = joint_mnemonic_rd_count;
mnemonics = rowmap.keys()';
tmp = rowmap.values();
rds = tmp{1}.keys();
joint_mnemonic_rd_count_matrix = cell(size(mnemonics,1)+1,size(rds,2)+1);
joint_mnemonic_rd_count_matrix(2:end,1) = mnemonics;
joint_mnemonic_rd_count_matrix(1,2:end) = rds;
for i=2:size(joint_mnemonic_rd_count_matrix,1)
    colmap = rowmap(mnemonics{i-1});
    for j=2:size(joint_mnemonic_rd_count_matrix,2)
        if colmap == 0
            joint_mnemonic_rd_count_matrix{i,j} = 0; 
        else
            entry = colmap(rds{j-1});
            joint_mnemonic_rd_count_matrix{i,j} = entry;
        end
    end
end

%% joint_mnemonic_regs tabular
rowmap = joint_mnemonic_reg_count;
mnemonics = rowmap.keys()';
tmp = rowmap.values();
regs = tmp{1}.keys();
joint_mnemonic_reg_count_matrix = cell(size(mnemonics,1)+1,size(regs,2)+1);
joint_mnemonic_reg_count_matrix(2:end,1) = mnemonics;
joint_mnemonic_reg_count_matrix(1,2:end) = regs;
for i=2:size(joint_mnemonic_reg_count_matrix,1)
    colmap = rowmap(mnemonics{i-1});
    for j=2:size(joint_mnemonic_reg_count_matrix,2)
        if colmap == 0
            joint_mnemonic_reg_count_matrix{i,j} = 0; 
        else
            entry = colmap(regs{j-1});
            joint_mnemonic_reg_count_matrix{i,j} = entry;
        end
    end
end

% Change table to relative frequencies
joint_mnemonic_reg_freq_matrix = cell(size(joint_mnemonic_reg_count_matrix));
joint_mnemonic_reg_freq_matrix(:,1) = joint_mnemonic_reg_count_matrix(:,1);
joint_mnemonic_reg_freq_matrix(1,:) = joint_mnemonic_reg_count_matrix(1,:);
total_count = sum(sum(cell2mat(joint_mnemonic_reg_count_matrix(2:end,2:end))));
for r=2:size(joint_mnemonic_reg_freq_matrix,1)
    for c=2:size(joint_mnemonic_reg_freq_matrix,2)
        joint_mnemonic_reg_freq_matrix{r,c} = joint_mnemonic_reg_count_matrix{r,c} / total_count;
    end
end

% plot normalized
total = sum(sum(cell2mat(joint_mnemonic_rd_count_matrix(2:end,2:end))));
figure;
surf(cell2mat(joint_mnemonic_rd_count_matrix(2:end,2:end)));
xlabel('Destination Register');
set(gca,'XTick',[1:2:size(rds,2)]','XTickLabel',rds(1,1:2:end)');
ylabel('Mnemonic');
set(gca,'YTick',[1:5:size(mnemonics,1)]','YTickLabel',mnemonics(1:5:end)');
zlabel('Count');
title(['Joint Relative Frequency of Mnemonic-Destination Register Pairs: ' architecture ', ' benchmark]);
%savefig(gcf, [output_directory filesep architecture '-' benchmark '-joint-mnemonic-rd-freq.fig']);
close(gcf);

figure;
surf(cell2mat(joint_mnemonic_reg_count_matrix(2:end,2:end)));
xlabel('Register');
set(gca,'XTick',[1:2:size(regs,2)]','XTickLabel',regs(1,1:2:end)');
ylabel('Mnemonic');
set(gca,'YTick',[1:5:size(mnemonics,1)]','YTickLabel',mnemonics(1:5:end)');
zlabel('Count');
title(['Joint Relative Frequency of Mnemonic-Register Pairs: ' architecture ', ' benchmark]);
%savefig(gcf, [output_directory filesep architecture '-' benchmark '-joint-mnemonic-reg-freq.fig']);
close(gcf);

%% Save progress
save([output_directory filesep architecture '-' benchmark '-program-statistics-tabular.mat'],...
    'mnemonic_count',...
    'codec_count',...
    'rd_count',...
    'rs1_count',...
    'rs2_count',...
    'rs3_count',...
    'imm_count',...
    'arg_count',...
    'overall_reg_count',...
    'joint_mnemonic_rd_count_matrix',...
    'joint_mnemonic_reg_count_matrix',...
    'joint_mnemonic_reg_freq_matrix');

display(['Done tabularizing ' benchmark]);
