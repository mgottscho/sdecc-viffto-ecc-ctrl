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
instruction_opcode_hotness = containers.Map(); % Init
if strcmp(architecture,'alpha') == 1
    total_inst_dealiased = 0;
end

for i=1:total_num_inst
    message_disassembly = trace_inst_disassembly(i,:);
    opcode = strtok(message_disassembly);
    % Check for macros/pseudoinstructions/aliases in Alpha ISA
    if strcmp(architecture,'alpha') == 1
        tmp_opcode = dealias_alpha_mneumonic(opcode);
        if strcmp(tmp_opcode, opcode) ~= 1
            %display(['Interpreting mneumonic in the input Alpha disassembly: ' opcode ' as ' tmp_opcode ' (dealiased).']);
            opcode = tmp_opcode;
            total_inst_dealiased = total_inst_dealiased + 1;
        end
    end
    if ~instruction_opcode_hotness.isKey(opcode)
        instruction_opcode_hotness(opcode) = 1;
    else
        instruction_opcode_hotness(opcode) = instruction_opcode_hotness(opcode)+1;
    end
end
if strcmp(architecture,'alpha') == 1
    total_inst_dealiased
end

unique_inst = instruction_opcode_hotness.keys()';
unique_inst_counts = zeros(size(unique_inst,1),1);
for i=1:size(unique_inst,1)
   unique_inst_counts(i) = instruction_opcode_hotness(unique_inst{i}); 
   results_instruction_opcode_hotness{i,1} = unique_inst{i};
   results_instruction_opcode_hotness{i,2} = unique_inst_counts(i);
end

% Normalize
for i=1:size(unique_inst,1)
    results_instruction_opcode_hotness{i,2} = results_instruction_opcode_hotness{i,2} ./ total_num_inst;
end
results_instruction_opcode_hotness = sortrows(results_instruction_opcode_hotness, 2);

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
achieved_correct_decoding = NaN(num_inst, num_error_patterns); % Init

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
        valid_messages_disassembly = cell(1,1);
        target_inst_index = -1;
        highest_rel_freq = 0;
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
               %instruction = tmp_file_contents{3,2};
               instruction = output_contents{3,2};
               valid_messages_disassembly{num_valid_messages,1} = instruction;
               
               % Decide whether this valid candidate instruction should be
               % the decode target
               if instruction_opcode_hotness.isKey(instruction)
                   rel_freq = instruction_opcode_hotness(instruction);
               else
                   rel_freq = 0;
               end

               if rel_freq >= highest_rel_freq
                  highest_rel_freq = rel_freq;
                  target_inst_index = num_valid_messages;
               end
            end
        end
        
        if target_inst_index < 1 % Sanity check
            display(['Error! target_inst_index = ' num2str(target_inst_index)]);
        end
        
        %% Store results of the number of candidate and valid messages for this instruction/error pattern pair
        results_candidate_messages(i,j) = num_candidate_messages;
        results_valid_messages(i,j) = num_valid_messages;

        %% Compute whether we got the correct answer or not for this instruction/error pattern pairing
        if strcmp(candidate_valid_messages(target_inst_index,:), message_bin) == 1 % Successfully corrected error!
            achieved_correct_decoding(i,j) = 1;
        else % Failed to correct error
            achieved_correct_decoding(i,j) = 0;
        end
    end
end

%% Save all variables
display('Saving outputs...');
save(output_filename);
display('Done!');

%% Shut down parallel computing pool
delete(mypool);
