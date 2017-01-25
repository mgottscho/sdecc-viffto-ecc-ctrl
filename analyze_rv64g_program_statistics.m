function analyze_static_rv64g_program_statistics(benchmark, k, input_filename, output_filename)
% Analyze relevant statistics about instructions in a rv64g compiled program binary image.
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

%% Get total number of instructions
% Because the file may have a LOT of data, we don't want to read it into a buffer, as it may fail and use too much memory.
% Instead, we get the number of instructions by using the 'wc' command, with the assumption that each line in the file will
% contain an instruction.
display('Reading inputs...');
[wc_return_code, wc_output] = system(['wc -l ' input_filename]);
if wc_return_code ~= 0
    display(['FATAL! Could not get line count (# inst) from ' input_filename '.']);
    return;
end
total_num_inst = str2num(strtok(wc_output));

instruction_mnemonic_count = containers.Map(); % Init
instruction_codec_count = containers.Map(); % Init
instruction_overall_reg_count = containers.Map(); % Init
instruction_rd_count = containers.Map(); % Init
instruction_rs1_count = containers.Map(); % Init
instruction_rs2_count = containers.Map(); % Init
instruction_rs3_count = containers.Map(); % Init
instruction_imm_count = containers.Map(); % Init
instruction_arg_count = containers.Map(); % Init

%if strcmp(architecture,'alpha') == 1
%    total_inst_dealiased = 0;
%end

%% Obtain overall static distribution of instructions in the program
display('Computing instruction distribution...');
fid = fopen(input_filename);
if fid == -1
    display(['FATAL! Could not open file ' input_filename '.']);
    return;
end

rng('shuffle'); % Seed RNG based on current time
line = fgetl(fid);
if size(strfind(line, ',')) ~= 0 % Dynamic trace mode
    trace_mode = 'dynamic';
    display('Detected dynamic trace, parsing...');
else
    trace_mode = 'static';
    display('Detected static trace, parsing...');
end
fclose(fid);

fid = fopen(input_filename);
if fid == -1
    display(['FATAL! Could not open file ' input_filename '.']);
    return;
end

for i=1:total_num_inst
    %% Read line from file
    line = fgetl(fid);

    %% Parse the line depending on its format to get the instruction of interest.
    % If it is hexadecimal instructions in big-endian format, one instruction per line of the form
    % 00000000
    % deadbeef
    % 01234567
    % 0000abcd
    % ...
    %
    %
    % If it is in CSV format, as output by our memdatatrace version of RISCV Spike simulator of the form
    % STEP,OPERATION,REG_TYPE,MEM_ACCESS_SEQ_NUM,VADDR,PADDR,USER_PERM,SUPER_PERM,ACCESS_SIZE,PAYLOAD,CACHE_BLOCKPOS,CACHE_BLOCK0,CACHE_BLOCK1,...,
    % like so:
    % 1805000,I$ RD fr MEM,INT,1898719,VADDR 0x0000000000001718,PADDR 0x0000000000001718,u---,sRWX,4B,PAYLOAD 0x63900706,BLKPOS 3,0x33d424011374f41f,0x1314340033848700,0x0335040093771500,0x63900706638e0908,0xeff09ff21355c500,0x1315a50013651500,0x2330a4001355a500,0x1b0979ff9317c500,
    % ...
    %
    % NOTE: memdatatrace payloads and cache blocks are in NATIVE byte order for
    % the simulated architecture. For RV64G this is LITTLE-ENDIAN!
    % NOTE: we only expect instruction cache lines to be in this file!
    % NOTE: addresses and decimal values in these traces are in BIG-ENDIAN
    % format.
    remain = line;
    if strcmp(trace_mode, 'dynamic') == 1 % Dynamic trace mode
        for j=1:10 % 10 iterations because payload is 10th entry in a row of the above format
            [token,remain] = strtok(remain,',');
        end
        [token, remain] = strtok(token,'x'); % Find the part of "PAYLOAD 0xDEADBEEF" after the "0x" part.
        message_hex = reverse_byte_order(remain(2:end)); % Put the instruction in big-endian format.
    else
        message_hex = remain;
    end

    %% Decode the instruction
    message_bin = my_hex2bin(message_hex);
    [disassembly, legal, mnemonic, codec, rd, rs1, rs2, rs3, imm, arg] = parse_rv64g_decoder_output(message_hex);
    
    if legal == 0 % Illegal instruction
       display(['Found illegal instruction: ' message_hex '. Ignoring.']);
       continue;
    end
    
    % Check for macros/pseudoinstructions/aliases in Alpha ISA
%     if strcmp(architecture,'alpha') == 1
%         tmp_mnemonic = dealias_alpha_mnemonic(mnemonic);
%         if strcmp(tmp_mnemonic, mnemonic) ~= 1
%             %display(['Interpreting mnemonic in the input Alpha disassembly: ' mnemonic ' as ' tmp_mnemonic ' (dealiased).']);
%             mnemonic = tmp_mnemonic;
%             total_inst_dealiased = total_inst_dealiased + 1;
%         end
%     end

    %% mnemonic count
    if ~instruction_mnemonic_count.isKey(mnemonic)
        instruction_mnemonic_count(mnemonic) = 1;
    else
        instruction_mnemonic_count(mnemonic) = instruction_mnemonic_count(mnemonic)+1;
    end
    
    %% codec count
    %if strcmp(rd,'unknown') ~= 1
    if ~instruction_codec_count.isKey(codec)
        instruction_codec_count(codec) = 1;
    else
        instruction_codec_count(codec) = instruction_codec_count(codec)+1;
    end
    %end
    
    %% rd count
    %if strcmp(rd,'NA') ~= 1
    if ~instruction_rd_count.isKey(rd)
        instruction_rd_count(rd) = 1;
    else
        instruction_rd_count(rd) = instruction_rd_count(rd)+1;
    end
    
    % Also count rd in overall reg count
    if ~instruction_overall_reg_count.isKey(rd)
        instruction_overall_reg_count(rd) = 1;
    else
        instruction_overall_reg_count(rd) = instruction_overall_reg_count(rd)+1;
    end
    %end
    
    %% rs1 count
    %if strcmp(rs1,'NA') ~= 1
    if ~instruction_rs1_count.isKey(rs1)
        instruction_rs1_count(rs1) = 1;
    else
        instruction_rs1_count(rs1) = instruction_rs1_count(rs1)+1;
    end
    
    % Also count rs1 in overall reg count
    if ~instruction_overall_reg_count.isKey(rs1)
        instruction_overall_reg_count(rs1) = 1;
    else
        instruction_overall_reg_count(rs1) = instruction_overall_reg_count(rs1)+1;
    end
    %end
    
    %% rs2 count
    %if strcmp(rs2,'NA') ~= 1
    if ~instruction_rs2_count.isKey(rs2)
        instruction_rs2_count(rs2) = 1;
    else
        instruction_rs2_count(rs2) = instruction_rs2_count(rs2)+1;
    end
    
    % Also count rs2 in overall reg count
    if ~instruction_overall_reg_count.isKey(rs2)
        instruction_overall_reg_count(rs2) = 1;
    else
        instruction_overall_reg_count(rs2) = instruction_overall_reg_count(rs2)+1;
    end
    %end
    
    %% rs3 count
    %if strcmp(rs3,'NA') ~= 1
    if ~instruction_rs3_count.isKey(rs3)
        instruction_rs3_count(rs3) = 1;
    else
        instruction_rs3_count(rs3) = instruction_rs3_count(rs3)+1;
    end
    
    % Also count rs3 in overall reg count
    if ~instruction_overall_reg_count.isKey(rs3)
        instruction_overall_reg_count(rs3) = 1;
    else
        instruction_overall_reg_count(rs3) = instruction_overall_reg_count(rs3)+1;
    end
    %end
    
    %% imm count
    %if strcmp(imm,'NA') ~= 1
    if ~instruction_imm_count.isKey(imm)
        instruction_imm_count(imm) = 1;
    else
        instruction_imm_count(imm) = instruction_imm_count(imm)+1;
    end
    %end
    
    %% arg count
    %if strcmp(arg,'NA') ~= 1
    if ~instruction_arg_count.isKey(arg)
        instruction_arg_count(arg) = 1;
    else
        instruction_arg_count(arg) = instruction_arg_count(arg)+1;
    end
    %end
    
%     if size(arg2,2) > 0 && isstrprop(arg2(1),'alpha') == 1 % alpha is alphabetic, not alpha ISA here. FIXME: This can be wrong when we have something like addi a0,a1,a2 where a2 is not a register address, but actually a hex constant!
%         if ~instruction_overall_reg_count.isKey(arg2)
%             instruction_overall_reg_count(arg2) = 1;
%         else
%             instruction_overall_reg_count(arg2) = instruction_overall_reg_count(arg2)+1;
%         end
%             
%         if ~instruction_rs1_count.isKey(arg1)
%             instruction_rs1_count(arg1) = 1;
%         else
%             instruction_rs1_count(arg1) = instruction_rs1_count(arg1)+1;
%         end
%     end
    
%     if size(arg3,2) > 0 && isstrprop(arg3(1),'alpha') == 1 % alpha is alphabetic, not alpha ISA here. FIXME: This can be wrong when we have something like addi a0,a1,a2 where a2 is not a register address, but actually a hex constant!
%         if ~instruction_overall_reg_count.isKey(arg3)
%             instruction_overall_reg_count(arg3) = 1;
%         else
%             instruction_overall_reg_count(arg3) = instruction_overall_reg_count(arg3)+1;
%         end
%             
%         if ~instruction_rs2_count.isKey(arg1)
%             instruction_rs2_count(arg1) = 1;
%         else
%             instruction_rs2_count(arg1) = instruction_rs2_count(arg1)+1;
%         end
%     end
end
    
fclose(fid);

% if strcmp(architecture,'alpha') == 1
%     total_inst_dealiased
% end

%% Joint occurrences of mnemonic and rd
joint_mnemonic_rd_count = containers.Map();
all_mnemonics = instruction_mnemonic_count.keys()';
all_rds = instruction_rd_count.keys()';

% Init 2D nested map
for i=1:size(all_mnemonics,1)
   mnemonic = all_mnemonics{i,1};
   inner_map = containers.Map();
   joint_mnemonic_rd_count(mnemonic) = inner_map;
   for j=1:size(all_rds,1)
      rd = all_rds{j,1};
      inner_map(rd) = 0;
   end
end

fid = fopen(input_filename);
if fid == -1
    display(['FATAL! Could not open file ' input_filename '.']);
    return;
end
for i=1:total_num_inst
    %% Read line from file
    line = fgetl(fid);

    %% Parse the line depending on its format to get the instruction of interest.
    % If it is hexadecimal instructions in big-endian format, one instruction per line of the form
    % 00000000
    % deadbeef
    % 01234567
    % 0000abcd
    % ...
    % then we do this.

    % If it is in CSV format, as output by our memdatatrace version of RISCV Spike simulator of the form
    % STEP,OPERATION,REG_TYPE,MEM_ACCESS_SEQ_NUM,VADDR,PADDR,USER_PERM,SUPER_PERM,ACCESS_SIZE,PAYLOAD,CACHE_BLOCKPOS,CACHE_BLOCK0,CACHE_BLOCK1,...,
    % like so:
    % 1805000,I$ RD fr MEM,INT,1898719,VADDR 0x0000000000001718,PADDR 0x0000000000001718,u---,sRWX,4B,PAYLOAD 0x63900706,BLKPOS 3,0x33d424011374f41f,0x1314340033848700,0x0335040093771500,0x63900706638e0908,0xeff09ff21355c500,0x1315a50013651500,0x2330a4001355a500,0x1b0979ff9317c500,
    % ...
    % then we do this.
    % NOTE: memdatatrace payloads and cache blocks are in NATIVE byte order for
    % the simulated architecture. For RV64G this is LITTLE-ENDIAN!
    % NOTE: we only expect instruction cache lines to be in this file!
    % NOTE: addresses and decimal values in these traces are in BIG-ENDIAN
    % format.
    remain = line;
    if strcmp(trace_mode, 'dynamic') == 1 % Dynamic trace mode
        for j=1:10 % 10 iterations because payload is 10th entry in a row of the above format
            [token,remain] = strtok(remain,',');
        end
        [token, remain] = strtok(token,'x'); % Find the part of "PAYLOAD 0xDEADBEEF" after the "0x" part.
        message_hex = reverse_byte_order(remain(2:end)); % Put the instruction in big-endian format.
    else
        message_hex = remain;
    end

    [disassembly, legal, mnemonic, codec, rd, rs1, rs2, rs3, imm, arg] = parse_rv64g_decoder_output(message_hex);
    if legal == 1
        inner_map = joint_mnemonic_rd_count(mnemonic);
        if inner_map.isKey(rd) % Account for NA cases
            inner_map(rd) = inner_map(rd)+1;
        end
    end
end

%% Joint occurrences of mnemonic and ALL registers in aggregate (rd, rs1, rs2, rs3) -- NA entries are OK and should be counted to be unbiased.
joint_mnemonic_reg_count = containers.Map();
all_mnemonics = instruction_mnemonic_count.keys()';
all_regs = instruction_overall_reg_count.keys()';

% Init 2D nested map
for i=1:size(all_mnemonics,1)
   mnemonic = all_mnemonics{i,1};
   inner_map = containers.Map();
   joint_mnemonic_reg_count(mnemonic) = inner_map;
   for j=1:size(all_regs,1)
      reg = all_regs{j,1};
      inner_map(reg) = 0;
   end
end

fid = fopen(input_filename);
if fid == -1
    display(['FATAL! Could not open file ' input_filename '.']);
    return;
end
for i=1:total_num_inst
    %% Read line from file
    line = fgetl(fid);

    %% Parse the line depending on its format to get the instruction of interest.
    % If it is hexadecimal instructions in big-endian format, one instruction per line of the form
    % 00000000
    % deadbeef
    % 01234567
    % 0000abcd
    % ...
    % then we do this.

    % If it is in CSV format, as output by our memdatatrace version of RISCV Spike simulator of the form
    % STEP,OPERATION,MEM_ACCESS_SEQ_NUM,VADDR,PADDR,USER_PERM,SUPER_PERM,ACCESS_SIZE,PAYLOAD,CACHE_BLOCKPOS,CACHE_BLOCK0,CACHE_BLOCK1,...,
    % like so:
    % 1805000,I$ RD fr MEM,1898719,VADDR 0x0000000000001718,PADDR 0x0000000000001718,u---,sRWX,4B,PAYLOAD 0x63900706,BLKPOS 3,0x33d424011374f41f,0x1314340033848700,0x0335040093771500,0x63900706638e0908,0xeff09ff21355c500,0x1315a50013651500,0x2330a4001355a500,0x1b0979ff9317c500,
    % ...
    % then we do this.
    % NOTE: memdatatrace payloads and cache blocks are in NATIVE byte order for
    % the simulated architecture. For RV64G this is LITTLE-ENDIAN!
    % NOTE: we only expect instruction cache lines to be in this file!
    % NOTE: addresses and decimal values in these traces are in BIG-ENDIAN
    % format.
    remain = line;
    if strcmp(trace_mode, 'dynamic') == 1 % Dynamic trace mode
        for j=1:9 % 9 iterations because payload is 9th entry in a row of the above format
            [token,remain] = strtok(remain,',');
        end
        [token, remain] = strtok(token,'x'); % Find the part of "PAYLOAD 0xDEADBEEF" after the "0x" part.
        message_hex = reverse_byte_order(remain(2:end)); % Put the instruction in big-endian format.
    else
        message_hex = remain;
    end

    [disassembly, legal, mnemonic, codec, rd, rs1, rs2, rs3, imm, arg] = parse_rv64g_decoder_output(message_hex);
    if legal == 1
        % Count each register exactly once for every possible mnemonic to avoid bias, since some instructions have different registers and numbers of them.
        % For this to be fair, we consider 'NA' as a register.
        % Thus, every instruction should get 4 counts equally.
        inner_map = joint_mnemonic_reg_count(mnemonic);
        inner_map(rd) = inner_map(rd)+1;
        inner_map(rs1) = inner_map(rs1)+1;
        inner_map(rs2) = inner_map(rs2)+1;
        inner_map(rs3) = inner_map(rs3)+1;
    end
end

%% Save all variables
display('Saving outputs...');
save(output_filename, ...
    'benchmark', ...
    'architecture', ...
    'input_filename', ...
    'output_filename', ...
    'total_num_inst', ...
    'instruction_mnemonic_count', ...
    'instruction_codec_count', ...
    'instruction_rd_count', ...
    'instruction_rs1_count', ...
    'instruction_rs2_count', ...
    'instruction_rs3_count', ...
    'instruction_imm_count', ...
    'instruction_arg_count', ...
    'instruction_overall_reg_count', ...
    'joint_mnemonic_rd_count', ...
    'joint_mnemonic_reg_count');

display('Done!');
