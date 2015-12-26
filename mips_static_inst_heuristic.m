% This script iterates over a series of MIPS1 (R3000) 32-bit instructions that are statically extracted from a compiled program.
% For each instruction, it first checks if it is a valid instruction. If it is, the
% script encodes the instruction/message in a specified SECDED encoder.
% The script then iterates over all possible 2-bit error patterns on the
% resulting codeword. Each of these 2-bit patterns are decoded by our
% SECDED code and should all be "detected but uncorrectable." For each of
% these 2-bit errors, we flip a single bit one at a time and decode again.
% We should obtain X received codewords that are indicated as corrected.
% These X codewords are "candidates" for the original encoded message.
% The script then uses the MIPS instruction decoder to determine which of
% the X candidate messages are valid instructions.
%
% Authors: Mark Gottscho and Clayton Schoeny
% Email: mgottscho@ucla.edu, cschoeny@gmail.com

%% Set parameters for the script

%%%%%% CHANGE THESE AS NEEDED %%%%%%%%
filename = 'mips-mcf-disassembly-text-section-inst.txt';
n = 39; % codeword width
k = 32; % instruction width
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r = n-k;

%% Read instructions as bit-strings from file
fid = fopen(filename);
file_contents = textscan(fid, '%s', 'Delimiter', ':');
fclose(fid);
file_contents = file_contents{1};
file_contents = reshape(file_contents, 3, size(file_contents,1)/3)';
%trace_hex = textread(filename, '%8c');
trace_hex = char(file_contents(:,2));
trace_bin = hex2dec(trace_hex);
trace_bin = dec2bin(trace_bin,k);
trace_inst_disassembly = char(file_contents(:,3));

%% Construct a matrix containing all possible 2-bit error patterns as bit-strings.
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
[G,H] = getHamCodes(n);

num_inst = size(trace_bin,1);

%% Obtain overall static distribution of instructions in the program
instruction_opcode_hotness = containers.Map(); % Init
for i=1:num_inst
    message_disassembly = trace_inst_disassembly(i,:);
    opcode = strtok(message_disassembly);
    if ~instruction_opcode_hotness.isKey(opcode)
        instruction_opcode_hotness(opcode) = 1;
    else
        instruction_opcode_hotness(opcode) = instruction_opcode_hotness(opcode)+1;
    end
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
    results_instruction_opcode_hotness{i,2} = results_instruction_opcode_hotness{i,2} ./ num_inst;
end
results_instruction_opcode_hotness = sortrows(results_instruction_opcode_hotness, 2);

%% Iterate over all instructions in the trace, and do the fun parts.

%%%%%% FEEL FREE TO OVERRIDE %%%%%%
if num_inst > 1000
    num_inst = 1000;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

results_candidate_messages = NaN(num_inst,num_error_patterns); % Init
results_valid_messages = NaN(num_inst,num_error_patterns); % Init

parfor i=1:num_inst % Parallelize loop across separate threads, since this could take a long time. Each instruction is a totally independent procedure to perform.
    %% Progress indicator
    % This will not show accurate progress if the loop is parallelized
    % across threads with parfor, since they can execute out-of-order
    if mod(i,100) == 0
        display(['Inst # ' num2str(i) ' out of ' num2str(num_inst)]);
    end
    
    %% Get the "message," which is the original instruction, i.e., the ground truth.
    message_hex = trace_hex(i,:);
    message_bin = trace_bin(i,:);
    message_disassembly = trace_inst_disassembly(i,:);
    
    %% Check that the message is actually a valid instruction to begin with.
    % Comment this out to save time if you are absolutely sure that all
    % input values are valid.
    status = dos(['mipsdecode ' message_hex ' >nul']);
    %status = unix(['./mipsdecode-mac ' message_hex ' > /dev/null']);
    if status ~= 0
       display(['Instruction #' num2str(i) ' in the input was found to be ILLEGAL, with value ' message_hex]);
    end
    
    %% Encode the message.
    codeword = hamEnc(message_bin,G);
    
    %% Iterate over all possible 2-bit error patterns.
    for j=1:num_error_patterns
        %% Inject 2-bit error.
        error = error_patterns(j,:);
        received_codeword = dec2bin(bitxor(bin2dec(codeword), bin2dec(error)), n);
        
        %% Attempt to decode the corrupted codeword, check that num_error_bits is 2
        [decoded_message, num_error_bits] = hamDec(received_codeword, H);
        
        % Sanity check
        if num_error_bits ~= 2
           display(['OOPS! Problem with error pattern #' num2str(j) ' on codeword #' num2str(i) '. Got ' num2str(num_error_bits) ' error bits in error.']);
           continue;
        end
        
        %% Flip 1 bit at a time on the received codeword, and attempt decoding on each. We should find several bit positions that decode successfully with just a single-bit error.
        %candidate_correct_messages = repmat('0',1,k); % Init
        x = 1;
        candidate_correct_messages = repmat('0',n,k); % Pre-allocate for worst-case capacity
        for pos=1:n
           %% Flip the bit
           error = repmat('0',1,n);
           error(pos) = '1';
           candidate_codeword = dec2bin(bitxor(bin2dec(received_codeword), bin2dec(error)), n);
           
           %% Attempt to decode
           [decoded_message, num_error_bits] = hamDec(candidate_codeword, H);
           
           if num_error_bits == 1           
               % We now know that num_error_bits == 1 if we got this far. This
               % is a candidate codeword.
               candidate_correct_messages(x,:) = decoded_message;
               x = x+1;
           end
        end
        
        %% Uniquify the candidate messages
        candidate_correct_messages = unique(candidate_correct_messages,'rows');
        
        %% Now check each of the candidate codewords to see which are valid instructions :)
        num_candidate_messages = size(candidate_correct_messages,1);
        num_valid_messages = 0;
        for x=1:num_candidate_messages
            %% Convert message to hex string representation
            message = candidate_correct_messages(x,:);
            message_hex = dec2hex(bin2dec(message));
            
            %% Test the candidate message to see if it is a valid instruction
            %status = unix(['./mipsdecode-mac ' message_hex ' >/dev/null']);
            status = dos(['mipsdecode ' message_hex ' >nul']);
            if status == 0 % It is valid!
               num_valid_messages = num_valid_messages+1;
            end
        end
        results_candidate_messages(i,j) = num_candidate_messages;
        results_valid_messages(i,j) = num_valid_messages;
    end
end
