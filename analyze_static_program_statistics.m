function analyze_static_program_statistics(architecture, benchmark, input_filename, output_filename)
% Analyze relevant statistics about instructions in a compiled program binary image. The input file should be of the form: TODO
%
% Input arguments:
%   architecture --     String: '[mips|alpha|rv64g]'
%   benchmark --        String
%   input_filename --   String
%   output_filename --  String
%
% Returns:
%   Nothing.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

architecture
benchmark
input_filename
output_filename

if ~isdeployed
    addpath common rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
end

%% Read instructions as bit-strings from file
display('Reading inputs...');
fid = fopen(input_filename);
file_contents = textscan(fid, '%s', 'Delimiter', ':');
fclose(fid);
file_contents = file_contents{1};
file_contents = reshape(file_contents, 3, size(file_contents,1)/3)';
%trace_hex = textread(input_filename, '%8c');
trace_hex = char(file_contents(:,2));
trace_bin = hex2dec(trace_hex);
trace_bin = dec2bin(trace_bin,k);
trace_inst_disassembly = char(file_contents(:,3));

total_num_inst = size(trace_bin,1);

%% Obtain overall static distribution of instructions in the program
display('Computing static instruction distribution...');
instruction_mneumonic_hotness = containers.Map(); % Init
instruction_overall_reg_hotness = containers.Map(); % Init
instruction_rd_hotness = containers.Map(); % Init
instruction_rs1_hotness = containers.Map(); % Init
instruction_rs2_hotness = containers.Map(); % Init

if strcmp(architecture,'alpha') == 1
    total_inst_dealiased = 0;
end

% FIXME 7/29/2016: We are NOT correctly parsing the register addresses/hotnesses
% here! Sometimes rd is a jump address, etc. Also, we are accidentally
% including whitespace as keys
for i=1:total_num_inst
    message_disassembly = trace_inst_disassembly(i,:);
    arg1 = '';
    arg2 = '';
    arg3 = '';
    [mneumonic,message_disassembly] = strtok(message_disassembly);
    if size(message_disassembly,2) > 0
        [arg1,message_disassembly] = strtok(message_disassembly,' ,');
        if size(message_disassembly,2) > 0
            [arg2,message_disassembly] = strtok(message_disassembly,' ,');
            if size(message_disassembly,2) > 0
                [arg3,message_disassembly] = strtok(message_disassembly,' ,');
            end
        end
    end

    % Check for macros/pseudoinstructions/aliases in Alpha ISA
    if strcmp(architecture,'alpha') == 1
        tmp_mneumonic = dealias_alpha_mneumonic(mneumonic);
        if strcmp(tmp_mneumonic, mneumonic) ~= 1
            %display(['Interpreting mneumonic in the input Alpha disassembly: ' mneumonic ' as ' tmp_mneumonic ' (dealiased).']);
            mneumonic = tmp_mneumonic;
            total_inst_dealiased = total_inst_dealiased + 1;
        end
    end

    if ~instruction_mneumonic_hotness.isKey(mneumonic)
        instruction_mneumonic_hotness(mneumonic) = 1;
    else
        instruction_mneumonic_hotness(mneumonic) = instruction_mneumonic_hotness(mneumonic)+1;
    end
   
    if size(arg1,2) > 0
        if ~instruction_overall_reg_hotness.isKey(arg1)
            instruction_overall_reg_hotness(arg1) = 1;
        else
            instruction_overall_reg_hotness(arg1) = instruction_overall_reg_hotness(arg1)+1;
        end
            
        if ~instruction_rd_hotness.isKey(arg1)
            instruction_rd_hotness(arg1) = 1;
        else
            instruction_rd_hotness(arg1) = instruction_rd_hotness(arg1)+1;
        end
    end
    
    if size(arg2,2) > 0 && isstrprop(arg2(1),'alpha') == 1 % alpha is alphabetic, not alpha ISA here. FIXME: This can be wrong when we have something like addi a0,a1,a2 where a2 is not a register address, but actually a hex constant!
        if ~instruction_overall_reg_hotness.isKey(arg2)
            instruction_overall_reg_hotness(arg2) = 1;
        else
            instruction_overall_reg_hotness(arg2) = instruction_overall_reg_hotness(arg2)+1;
        end
            
        if ~instruction_rs1_hotness.isKey(arg1)
            instruction_rs1_hotness(arg1) = 1;
        else
            instruction_rs1_hotness(arg1) = instruction_rs1_hotness(arg1)+1;
        end
    end
    
    if size(arg3,2) > 0 && isstrprop(arg3(1),'alpha') == 1 % alpha is alphabetic, not alpha ISA here. FIXME: This can be wrong when we have something like addi a0,a1,a2 where a2 is not a register address, but actually a hex constant!
        if ~instruction_overall_reg_hotness.isKey(arg3)
            instruction_overall_reg_hotness(arg3) = 1;
        else
            instruction_overall_reg_hotness(arg3) = instruction_overall_reg_hotness(arg3)+1;
        end
            
        if ~instruction_rs2_hotness.isKey(arg1)
            instruction_rs2_hotness(arg1) = 1;
        else
            instruction_rs2_hotness(arg1) = instruction_rs2_hotness(arg1)+1;
        end
    end
end

if strcmp(architecture,'alpha') == 1
    total_inst_dealiased
end

unique_inst = instruction_mneumonic_hotness.keys()';
unique_inst_counts = zeros(size(unique_inst,1),1);
for i=1:size(unique_inst,1)
   unique_inst_counts(i) = instruction_mneumonic_hotness(unique_inst{i}); 
   results_instruction_mneumonic_hotness{i,1} = unique_inst{i};
   results_instruction_mneumonic_hotness{i,2} = unique_inst_counts(i);
end

% Normalize
for i=1:size(unique_inst,1)
    results_instruction_mneumonic_hotness{i,2} = results_instruction_mneumonic_hotness{i,2} ./ total_num_inst;
end
results_instruction_mneumonic_hotness = sortrows(results_instruction_mneumonic_hotness, 2);



unique_overall_reg = instruction_overall_reg_hotness.keys()';
unique_overall_reg_counts = zeros(size(unique_overall_reg,1),1);
for i=1:size(unique_overall_reg,1)
   unique_overall_reg_counts(i) = instruction_overall_reg_hotness(unique_overall_reg{i}); 
   results_instruction_overall_reg_hotness{i,1} = unique_overall_reg{i};
   results_instruction_overall_reg_hotness{i,2} = unique_overall_reg_counts(i);
end

% Normalize
for i=1:size(unique_overall_reg,1)
    results_instruction_overall_reg_hotness{i,2} = results_instruction_overall_reg_hotness{i,2} ./ total_num_inst;
end
results_instruction_overall_reg_hotness = sortrows(results_instruction_overall_reg_hotness, 2);



unique_rd = instruction_rd_hotness.keys()';
unique_rd_counts = zeros(size(unique_rd,1),1);
for i=1:size(unique_rd,1)
   unique_rd_counts(i) = instruction_rd_hotness(unique_rd{i}); 
   results_instruction_rd_hotness{i,1} = unique_rd{i};
   results_instruction_rd_hotness{i,2} = unique_rd_counts(i);
end

% Normalize
for i=1:size(unique_rd,1)
    results_instruction_rd_hotness{i,2} = results_instruction_rd_hotness{i,2} ./ total_num_inst;
end
results_instruction_rd_hotness = sortrows(results_instruction_rd_hotness, 2);


unique_rs1 = instruction_rs1_hotness.keys()';
unique_rs1_counts = zeros(size(unique_rs1,1),1);
for i=1:size(unique_rs1,1)
   unique_rs1_counts(i) = instruction_rs1_hotness(unique_rs1{i}); 
   results_instruction_rs1_hotness{i,1} = unique_rs1{i};
   results_instruction_rs1_hotness{i,2} = unique_rs1_counts(i);
end

% Normalize
for i=1:size(unique_rs1,1)
    results_instruction_rs1_hotness{i,2} = results_instruction_rs1_hotness{i,2} ./ total_num_inst;
end
results_instruction_rs1_hotness = sortrows(results_instruction_rs1_hotness, 2);


unique_rs2 = instruction_rs2_hotness.keys()';
unique_rs2_counts = zeros(size(unique_rs2,1),1);
for i=1:size(unique_rs2,1)
   unique_rs2_counts(i) = instruction_rs2_hotness(unique_rs2{i}); 
   results_instruction_rs2_hotness{i,1} = unique_rs2{i};
   results_instruction_rs2_hotness{i,2} = unique_rs2_counts(i);
end

% Normalize
for i=1:size(unique_rs2,1)
    results_instruction_rs2_hotness{i,2} = results_instruction_rs2_hotness{i,2} ./ total_num_inst;
end
results_instruction_rs2_hotness = sortrows(results_instruction_rs2_hotness, 2);

%% Save all variables
display('Saving outputs...');
save(output_filename);
display('Done!');
