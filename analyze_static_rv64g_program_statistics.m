function analyze_static_rv64g_program_statistics(benchmark, k, input_filename, output_filename)
% Analyze relevant statistics about instructions in a rv64g compiled program binary image. The input file should be of the form: TODO
%
% Input arguments:
%   benchmark --        String
%   k --                String: '[32|64]'
%   input_filename --   String
%   output_filename --  String
%
% Returns:
%   Nothing.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

benchmark
architecture = 'rv64g';
k = str2num(k)
input_filename
output_filename

if ~isdeployed
    addpath common rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
end

%% Read instructions as hex-strings from file
display('Reading inputs...');
fid = fopen(input_filename);
file_contents = textscan(fid, '%s');
fclose(fid);
file_contents = file_contents{1};
total_num_inst = size(file_contents,1);
trace_hex = char(file_contents(:,1));
trace_bin = dec2bin(hex2dec(trace_hex),k);

%% Obtain overall static distribution of instructions in the program
display('Computing static instruction distribution...');
instruction_mnemonic_hotness = containers.Map(); % Init
instruction_codec_hotness = containers.Map(); % Init
instruction_overall_reg_hotness = containers.Map(); % Init
instruction_rd_hotness = containers.Map(); % Init
instruction_rs1_hotness = containers.Map(); % Init
instruction_rs2_hotness = containers.Map(); % Init
instruction_rs3_hotness = containers.Map(); % Init
instruction_imm_hotness = containers.Map(); % Init
instruction_arg_hotness = containers.Map(); % Init

%if strcmp(architecture,'alpha') == 1
%    total_inst_dealiased = 0;
%end

for i=1:total_num_inst
    %% Decode the instruction
    message_hex = trace_hex(i,:);
    [status, decoderOutput] = MyRv64gDecoder(message_hex); % NOTE: this will only work if the decoder MEX file is properly compiled for your platform!
    
    if status == 1 % Illegal instruction
       display(['Found illegal instruction: ' message_hex '. Ignoring.']);
       continue;
    end

    % Parse disassembly of instruction from string spit back by the instruction decoder
    disassembly = textscan(decoderOutput, '%s', 'Delimiter', ':');
    disassembly = disassembly{1};
    disassembly = reshape(disassembly, 2, size(disassembly,1)/2)';
    mnemonic = disassembly{4,2};
    codec = disassembly{5,2};
    rd = disassembly{6,2};
    rs1 = disassembly{7,2};
    rs2 = disassembly{8,2};
    rs3 = disassembly{9,2};
    imm = disassembly{10,2};
    arg = disassembly{11,2};
    
    % Check for macros/pseudoinstructions/aliases in Alpha ISA
%     if strcmp(architecture,'alpha') == 1
%         tmp_mnemonic = dealias_alpha_mnemonic(mnemonic);
%         if strcmp(tmp_mnemonic, mnemonic) ~= 1
%             %display(['Interpreting mnemonic in the input Alpha disassembly: ' mnemonic ' as ' tmp_mnemonic ' (dealiased).']);
%             mnemonic = tmp_mnemonic;
%             total_inst_dealiased = total_inst_dealiased + 1;
%         end
%     end

    %% mnemonic hotness
    if ~instruction_mnemonic_hotness.isKey(mnemonic)
        instruction_mnemonic_hotness(mnemonic) = 1;
    else
        instruction_mnemonic_hotness(mnemonic) = instruction_mnemonic_hotness(mnemonic)+1;
    end
    
    %% codec hotness
    if strcmp(rd,'unknown') ~= 1
        if ~instruction_codec_hotness.isKey(codec)
            instruction_codec_hotness(codec) = 1;
        else
            instruction_codec_hotness(codec) = instruction_codec_hotness(codec)+1;
        end
    end
    
    %% rd hotness
    if strcmp(rd,'NA') ~= 1
        if ~instruction_rd_hotness.isKey(rd)
            instruction_rd_hotness(rd) = 1;
        else
            instruction_rd_hotness(rd) = instruction_rd_hotness(rd)+1;
        end
    end
    
    %% rs1 hotness
    if strcmp(rs1,'NA') ~= 1
        if ~instruction_rs1_hotness.isKey(rs1)
            instruction_rs1_hotness(rs1) = 1;
        else
            instruction_rs1_hotness(rs1) = instruction_rs1_hotness(rs1)+1;
        end
    end
    
    %% rs2 hotness
    if strcmp(rs2,'NA') ~= 1
        if ~instruction_rs2_hotness.isKey(rs2)
            instruction_rs2_hotness(rs2) = 1;
        else
            instruction_rs2_hotness(rs2) = instruction_rs2_hotness(rs2)+1;
        end
    end
    
    %% rs3 hotness
    if strcmp(rs3,'NA') ~= 1
        if ~instruction_rs3_hotness.isKey(rs3)
            instruction_rs3_hotness(rs3) = 1;
        else
            instruction_rs3_hotness(rs3) = instruction_rs3_hotness(rs3)+1;
        end
    end
    
    %% imm hotness
    if strcmp(imm,'NA') ~= 1
        if ~instruction_imm_hotness.isKey(imm)
            instruction_imm_hotness(imm) = 1;
        else
            instruction_imm_hotness(imm) = instruction_imm_hotness(imm)+1;
        end
    end
    
    %% arg hotness
    if strcmp(arg,'NA') ~= 1
        if ~instruction_arg_hotness.isKey(arg)
            instruction_arg_hotness(arg) = 1;
        else
            instruction_arg_hotness(arg) = instruction_arg_hotness(arg)+1;
        end
    end
    
%     if size(arg2,2) > 0 && isstrprop(arg2(1),'alpha') == 1 % alpha is alphabetic, not alpha ISA here. FIXME: This can be wrong when we have something like addi a0,a1,a2 where a2 is not a register address, but actually a hex constant!
%         if ~instruction_overall_reg_hotness.isKey(arg2)
%             instruction_overall_reg_hotness(arg2) = 1;
%         else
%             instruction_overall_reg_hotness(arg2) = instruction_overall_reg_hotness(arg2)+1;
%         end
%             
%         if ~instruction_rs1_hotness.isKey(arg1)
%             instruction_rs1_hotness(arg1) = 1;
%         else
%             instruction_rs1_hotness(arg1) = instruction_rs1_hotness(arg1)+1;
%         end
%     end
    
%     if size(arg3,2) > 0 && isstrprop(arg3(1),'alpha') == 1 % alpha is alphabetic, not alpha ISA here. FIXME: This can be wrong when we have something like addi a0,a1,a2 where a2 is not a register address, but actually a hex constant!
%         if ~instruction_overall_reg_hotness.isKey(arg3)
%             instruction_overall_reg_hotness(arg3) = 1;
%         else
%             instruction_overall_reg_hotness(arg3) = instruction_overall_reg_hotness(arg3)+1;
%         end
%             
%         if ~instruction_rs2_hotness.isKey(arg1)
%             instruction_rs2_hotness(arg1) = 1;
%         else
%             instruction_rs2_hotness(arg1) = instruction_rs2_hotness(arg1)+1;
%         end
%     end
end

% if strcmp(architecture,'alpha') == 1
%     total_inst_dealiased
% end

% unique_inst = instruction_mnemonic_hotness.keys()';
% unique_inst_counts = zeros(size(unique_inst,1),1);
% for i=1:size(unique_inst,1)
%    unique_inst_counts(i) = instruction_mnemonic_hotness(unique_inst{i}); 
%    results_instruction_mnemonic_hotness{i,1} = unique_inst{i};
%    results_instruction_mnemonic_hotness{i,2} = unique_inst_counts(i);
% end
% 
% % Normalize
% for i=1:size(unique_inst,1)
%     results_instruction_mnemonic_hotness{i,2} = results_instruction_mnemonic_hotness{i,2} ./ total_num_inst;
% end
% results_instruction_mnemonic_hotness = sortrows(results_instruction_mnemonic_hotness, 2);
% 
% 
% 
% unique_overall_reg = instruction_overall_reg_hotness.keys()';
% unique_overall_reg_counts = zeros(size(unique_overall_reg,1),1);
% for i=1:size(unique_overall_reg,1)
%    unique_overall_reg_counts(i) = instruction_overall_reg_hotness(unique_overall_reg{i}); 
%    results_instruction_overall_reg_hotness{i,1} = unique_overall_reg{i};
%    results_instruction_overall_reg_hotness{i,2} = unique_overall_reg_counts(i);
% end
% 
% % Normalize
% for i=1:size(unique_overall_reg,1)
%     results_instruction_overall_reg_hotness{i,2} = results_instruction_overall_reg_hotness{i,2} ./ total_num_inst;
% end
% results_instruction_overall_reg_hotness = sortrows(results_instruction_overall_reg_hotness, 2);
% 
% 
% 
% unique_rd = instruction_rd_hotness.keys()';
% unique_rd_counts = zeros(size(unique_rd,1),1);
% for i=1:size(unique_rd,1)
%    unique_rd_counts(i) = instruction_rd_hotness(unique_rd{i}); 
%    results_instruction_rd_hotness{i,1} = unique_rd{i};
%    results_instruction_rd_hotness{i,2} = unique_rd_counts(i);
% end
% 
% % Normalize
% for i=1:size(unique_rd,1)
%     results_instruction_rd_hotness{i,2} = results_instruction_rd_hotness{i,2} ./ total_num_inst;
% end
% results_instruction_rd_hotness = sortrows(results_instruction_rd_hotness, 2);
% 
% 
% unique_rs1 = instruction_rs1_hotness.keys()';
% unique_rs1_counts = zeros(size(unique_rs1,1),1);
% for i=1:size(unique_rs1,1)
%    unique_rs1_counts(i) = instruction_rs1_hotness(unique_rs1{i}); 
%    results_instruction_rs1_hotness{i,1} = unique_rs1{i};
%    results_instruction_rs1_hotness{i,2} = unique_rs1_counts(i);
% end
% 
% % Normalize
% for i=1:size(unique_rs1,1)
%     results_instruction_rs1_hotness{i,2} = results_instruction_rs1_hotness{i,2} ./ total_num_inst;
% end
% results_instruction_rs1_hotness = sortrows(results_instruction_rs1_hotness, 2);
% 
% 
% unique_rs2 = instruction_rs2_hotness.keys()';
% unique_rs2_counts = zeros(size(unique_rs2,1),1);
% for i=1:size(unique_rs2,1)
%    unique_rs2_counts(i) = instruction_rs2_hotness(unique_rs2{i}); 
%    results_instruction_rs2_hotness{i,1} = unique_rs2{i};
%    results_instruction_rs2_hotness{i,2} = unique_rs2_counts(i);
% end
% 
% % Normalize
% for i=1:size(unique_rs2,1)
%     results_instruction_rs2_hotness{i,2} = results_instruction_rs2_hotness{i,2} ./ total_num_inst;
% end
% results_instruction_rs2_hotness = sortrows(results_instruction_rs2_hotness, 2);

%% Save all variables
display('Saving outputs...');
save(output_filename);
display('Done!');
