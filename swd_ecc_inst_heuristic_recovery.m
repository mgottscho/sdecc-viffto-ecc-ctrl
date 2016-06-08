function swd_ecc_inst_heuristic_recovery(architecture, benchmark, n, k, num_inst, input_filename, output_filename, n_threads, code_type)
% This function iterates over a series of instructions that are statically extracted from a compiled program.
% For each instruction, it first checks if it is a valid instruction. If it is, the
% script encodes the instruction/message in a specified SECDED encoder.
% The script then iterates over all possible 2-bit error patterns on the
% resulting codeword. Each of these 2-bit patterns are decoded by our
% SECDED code and should all be "detected but uncorrectable." For each of
% these 2-bit errors, we flip a single bit one at a time and decode again.
% We should obtain X received codewords that are indicated as corrected.
% These X codewords are "candidates" for the original encoded message.
% The function then uses the instruction decoder to determine which of
% the X candidate messages are valid instructions.
%
% Input arguments:
%   architecture --     String: '[mips|alpha|riscv]'
%   benchmark --        String
%   n --                String: '[39|72]'
%   k --                String: '[32|64]'
%   num_inst --         String: '[1|2|3|...]'
%   input_filename --   String
%   output_filename --  String
%   n_threads --        String: '[1|2|3|...]'
%   code_type --        String: '[hamming|pi]'
%
% Returns:
%   Nothing.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

architecture
benchmark
n = str2num(n)
k = str2num(k)
num_inst = str2num(num_inst)
input_filename
output_filename
n_threads = str2num(n_threads)
code_type

r = n-k;

%% Set up parallel computing
pctconfig('preservejobs', true);
mypool = parpool(n_threads);

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

%% Construct a matrix containing all possible 2-bit error patterns as bit-strings.
display('Constructing error-pattern matrix...');
num_error_patterns = nchoosek(n,2);
error_patterns = repmat('0',num_error_patterns,n);
num_error = 1;
for i=1:n-1
    for j=i+1:n
        error_patterns(num_error, i) = '1';
        error_patterns(num_error, j) = '1';
        num_error = num_error + 1;
    end
end

%% Get our ECC encoder and decoder matrices
display('Getting ECC encoder and decoder matrices...');
[G,H] = getSECDEDCodes(n,code_type);

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

%% Randomly choose instructions from the trace, and do the fun parts on those
rng('shuffle'); % Seed RNG based on current time
sampled_inst_indices = randperm(total_num_inst, num_inst); % Randomly permute the indices of instructions. We will choose the first num_inst of the permuted list to evaluate
sampled_trace_hex = trace_hex(sampled_inst_indices,:);
sampled_trace_bin = trace_bin(sampled_inst_indices,:);
sampled_trace_inst_disassembly = trace_inst_disassembly(sampled_inst_indices,:);

display(['Number of randomly-sampled instructions to test SWD-ECC: ' num2str(num_inst)]);
display('Evaluating filter-and-rank SWD-ECC...');

results_candidate_messages = NaN(num_inst,num_error_patterns); % Init
results_valid_messages = NaN(num_inst,num_error_patterns); % Init
success = NaN(num_inst, num_error_patterns); % Init
could_have_crashed = NaN(num_inst, num_error_patterns); % Init
success_sans_crashes = NaN(num_inst, num_error_patterns); % Init

parfor i=1:num_inst % Parallelize loop across separate threads, since this could take a long time. Each instruction is a totally independent procedure to perform.
    %% Get the "message," which is the original instruction, i.e., the ground truth from input file. No instruction dealiasing is applied here.
    message_hex = sampled_trace_hex(i,:);
    message_bin = sampled_trace_bin(i,:);
    message_disassembly = sampled_trace_inst_disassembly(i,:);
    
    %% Progress indicator
    % This will not show accurate progress if the loop is parallelized
    % across threads with parfor, since they can execute out-of-order
    display(['Inst # ' num2str(i) ' is index ' num2str(sampled_inst_indices(i)) ' in the program. hex: ' message_hex ' disassembly: ' message_disassembly]);
    
    %% Check that the message is actually a valid instruction to begin with.
    % Comment this out to save time if you are absolutely sure that all
    % input values are valid.
    %if strcmp(computer(), 'PCWIN64') == 1 % Windows version of the decode program
    %    status = dos([architecture 'decode ' message_hex ' >nul']);
    %elseif strcmp(computer(), 'MACI64') == 1 % Mac version of the decode program
    %    status = unix(['./' architecture 'decode-mac ' message_hex ' > /dev/null']); % Mac version of the decode program
    %elseif strcmp(computer(), 'GLNXA64') == 1 % Linux version of the decode program
        %status = unix(['./' architecture 'decode-linux ' message_hex ' > /dev/null']); % Linux version of the decode program
    if strcmp(architecture,'mips') == 1
        [status, decoderOutput] = MyMipsDecoder(message_hex);
    elseif strcmp(architecture,'alpha') == 1
        [status, decoderOutput] = MyAlphaDecoder(message_hex);
    elseif strcmp(architecture,'riscv') == 1
        [status, decoderOutput] = MyRiscvDecoder(message_hex);
    else
        display('ERROR! Supported ISAs are mips, alpha, and riscv');
        status = -1;
        decoderOutput = '';
%        exit(1);
    end 
    %else % Error
    %    display('Non-supported operating system detected!');
    %    status = 1;
    %end
   
    %decoderOutput
    if status ~= 0
       display(['Instruction #' num2str(i) ' in the input was found to be ILLEGAL, with value ' message_hex '. This probably should not happen.']);
    %   decoderOutput
    end
    
    %% Encode the message.
    codeword = secded_encoder(message_bin,G);
    
    %% Iterate over all possible 2-bit error patterns.
    for j=1:num_error_patterns
        %% Inject 2-bit error.
        error = error_patterns(j,:);
        received_codeword = dec2bin(bitxor(bin2dec(codeword), bin2dec(error)), n);
        
        %% Attempt to decode the corrupted codeword, check that num_error_bits is 2
        [decoded_message, num_error_bits] = secded_decoder(received_codeword, H, code_type);
        
        % Sanity check
        if num_error_bits ~= 2
           display(['OOPS! Problem with error pattern #' num2str(j) ' on codeword #' num2str(i) '. Got ' num2str(num_error_bits) ' error bits in error.']);
           continue;
        end
        
        %% Flip 1 bit at a time on the received codeword, and attempt decoding on each. We should find several bit positions that decode successfully with just a single-bit error.
        x = 1;
        candidate_correct_messages = repmat('X',n,k); % Pre-allocate for worst-case capacity. X is placeholder
        for pos=1:n
           %% Flip the bit
           error = repmat('0',1,n);
           error(pos) = '1';
           candidate_codeword = dec2bin(bitxor(bin2dec(received_codeword), bin2dec(error)), n);
           
           %% Attempt to decode
           [decoded_message, num_error_bits] = secded_decoder(candidate_codeword, H, code_type);
           
           if num_error_bits == 1           
               % We now know that num_error_bits == 1 if we got this far. This
               % is a candidate codeword.
               candidate_correct_messages(x,:) = decoded_message;
               x = x+1;
           end
        end
        
        %% Uniquify the candidate messages
        if x > 1
            candidate_correct_messages = candidate_correct_messages(1:x-1, :);
            candidate_correct_messages = unique(candidate_correct_messages,'rows');
        else
            display(['Something went wrong! x = ' num2str(x)]);
        end
        
        
        %% Now check each of the candidate codewords to see which are valid instructions :)
        num_candidate_messages = size(candidate_correct_messages,1);
        num_valid_messages = 0;
        candidate_valid_messages = repmat('0',1,k); % Init
        valid_messages_mneumonic = cell(1,1);
        valid_messages_rd = cell(1,1);
        for x=1:num_candidate_messages
            %% Convert message to hex string representation
            message = candidate_correct_messages(x,:);
            message_hex = dec2hex(bin2dec(message),8);
            
            %% Test the candidate message to see if it is a valid instruction and extract disassembly of the message hex
            %if strcmp(computer(), 'PCWIN64') == 1 % Windows version of the decode program
            %    status = dos([architecture 'decode ' message_hex ' >tmp_disassembly_' architecture '_' benchmark '_' num2str(i) '.txt']);
            %elseif strcmp(computer(), 'MACI64') == 1 % Mac version of the decode program
            %    status = unix(['./' architecture 'decode-mac ' message_hex ' >tmp_disassembly_' architecture '_' benchmark '_' num2str(i) '.txt']); % Mac version of the decode program
            %elseif strcmp(computer(), 'GLNXA64') == 1 % Linux version of the decode program
                %status = unix(['./' architecture 'decode-linux ' message_hex ' >tmp_disassembly_' architecture '_' benchmark '_' num2str(i) '.txt']); % Linux version of the decode program
                if strcmp(architecture,'mips') == 1
                    [status, decoderOutput] = MyMipsDecoder(message_hex);
                elseif strcmp(architecture,'alpha') == 1
                    [status, decoderOutput] = MyAlphaDecoder(message_hex);
                elseif strcmp(architecture,'riscv') == 1
                    [status, decoderOutput] = MyRiscvDecoder(message_hex);
                else
                    display('ERROR! Supported ISAs are mips, alpha, and riscv');
                    status = -1;
                    decoderOutput = '';
            %        exit(1);
                end 
            %else % Error
            %    display('Non-supported operating system detected!');
            %    status = 1;
            %end
            
            if status == 0 % It is valid!
               num_valid_messages = num_valid_messages+1;
               candidate_valid_messages(num_valid_messages,:) = message;
               
               % Read disassembly of instruction from file
               %tmpfid = fopen(['tmp_disassembly_' architecture '_' benchmark '_' num2str(i) '.txt']);
               %tmp_file_contents = textscan(tmpfid, '%s', 'Delimiter', ':');
               output_contents = textscan(decoderOutput, '%s', 'Delimiter', ':');
               %fclose(tmpfid);

               %tmp_file_contents = tmp_file_contents{1};
               output_contents = output_contents{1};
               %tmp_file_contents = reshape(tmp_file_contents, 2, size(tmp_file_contents,1)/2)';
               output_contents = reshape(output_contents, 2, size(output_contents,1)/2)';

               % Store disassembly in the list
               mneumonic = output_contents{4,2};
               rd = output_contents{6,2};
               valid_messages_mneumonic{num_valid_messages,1} = mneumonic;
               valid_messages_rd{num_valid_messages,1} = rd;
            end
        end
        
        %% Choose decode target
        highest_rel_freq_mneumonic = 0;
        target_mneumonic = '';
        for x=1:num_valid_messages
            mneumonic = valid_messages_mneumonic{x,1};
            if instruction_mneumonic_hotness.isKey(mneumonic)
                rel_freq_mneumonic = instruction_mneumonic_hotness(mneumonic);
            else % This could happen legally
                rel_freq_mneumonic = 0;
            end
            
            % Find highest frequency mneumonic
            if rel_freq_mneumonic > highest_rel_freq_mneumonic
               highest_rel_freq_mneumonic = rel_freq_mneumonic;
               target_mneumonic = mneumonic;
            end
        end

        % Find indices matching highest frequency mneumonic
        mneumonic_inst_indices = zeros(1,1);
        y=1;
        for x=1:num_valid_messages
            mneumonic = valid_messages_mneumonic{x,1};
            if strcmp(mneumonic,target_mneumonic) == 1
                mneumonic_inst_indices(y,1) = x;
                y = y+1;
            end
        end
    
        highest_rel_freq_rd = 0;
        target_rd = '';
        for y=1:size(mneumonic_inst_indices,1)
            rd = valid_messages_rd{mneumonic_inst_indices(y,1),1};
            
            if instruction_rd_hotness.isKey(rd)
                rel_freq_rd = instruction_rd_hotness(rd);
            else % This can happen when rd is not used in an instr (NA)
                rel_freq_rd = 0;
            end
            
            % Find highest frequency rd
            if rel_freq_rd > highest_rel_freq_rd
               highest_rel_freq_rd = rel_freq_rd;
               target_rd = rd;
            end
        end
        
        % Find indices matching both highest frequency mneumonic and highest frequency rd
        target_inst_indices = zeros(1,1);
        z=1;
        for y=1:size(mneumonic_inst_indices,1)
            rd = valid_messages_rd{mneumonic_inst_indices(y,1),1};
            if strcmp(rd,target_rd) == 1
                target_inst_indices(z,1) = mneumonic_inst_indices(y,1);
                z = z+1;
            end
        end

        if target_inst_indices(1) == 0 % This is OK when rd is not used anywhere in the checked candidates
            target_inst_indices = mneumonic_inst_indices;
        end

        crash = 0;
        if target_inst_indices(1) == 0 % sanity check
            display('Error! No valid target instruction for recovery found.');
            target_inst_index = -2;
        elseif size(target_inst_indices,1) == 1 % have one recovery target
            target_inst_index = target_inst_indices(1); 
        else % multiple recovery targets: let it crash
            crash = 1;
            target_inst_index = target_inst_indices(1); % Pick first of remaining targets as a guess
        end
        
        %% Store results of the number of candidate and valid messages for this instruction/error pattern pair
        results_candidate_messages(i,j) = num_candidate_messages;
        results_valid_messages(i,j) = num_valid_messages;

        %% Compute whether we got the correct answer or not for this instruction/error pattern pairing
        if target_inst_index > 0 && strcmp(candidate_valid_messages(target_inst_index,:), message_bin) == 1 % Successfully corrected error!
            success(i,j) = 1;
        else % Failed to correct error -- corrupted recovery
            success(i,j) = 0;
        end

        %% Compute whether we would have crashed instead
        if crash == 1
            could_have_crashed(i,j) = 1;
            success_sans_crashes(i,j) = NaN;
        else
            could_have_crashed(i,j) = 0;
            success_sans_crashes(i,j) = success(i,j);
        end
    end
end

%% Save all variables
display('Saving outputs...');
save(output_filename);
display('Done!');

%% Shut down parallel computing pool
delete(mypool);
