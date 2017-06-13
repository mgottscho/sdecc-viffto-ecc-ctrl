function [num_valid_messages, recovered_message, estimated_prob_correct, suggest_to_crash, recovered_successfully] = inst_recovery_endian_wrapper(architecture, k, original_message, candidate_correct_messages_bin, policy, instruction_mnemonic_hotness_filename, instruction_rd_hotness_filename, crash_threshold, verbose)

k = str2num(k);
verbose = str2num(verbose);

if ~isdeployed
    addpath ecc common rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
end

num_packed_inst = k/32; % We assume 32-bits per instruction. For k as a multiple of 32, we have packed instructions per message. FIXME: this is only true for RV64G

original_message_hex = my_bin2hex(original_message);

if verbose == 1
    original_message_hex
end

original_message_endianswap = repmat('X',1,k/4);
for packed_inst=1:num_packed_inst
    original_message_endianswap((packed_inst-1)*8+1:(packed_inst-1)*8+8) = reverse_byte_order(original_message_hex((packed_inst-1)*8+1:(packed_inst-1)*8+8)); % Put the packed instruction in big-endian format.
end
original_message_endianswap_bin = my_hex2bin(original_message_endianswap);

if verbose == 1
    original_message_endianswap_bin
end

%% Parse candidate_correct_messages_bin to convert into char matrix
candidate_correct_messages = repmat('X',1,k);
done_parsing = 0;
i = 1;
remain = candidate_correct_messages_bin;
while done_parsing == 0
   [token,remain] = strtok(remain,',');

   % Check input validity of token to ensure k-bits of '0' or '1' and no other value
   if (sum(token == '1')+sum(token == '0')) ~= size(token,2)
       display(['FATAL! Candidate entry ' num2str(i) ' has non-binary character: ' token]);
       return;
   end
   if size(token,2) ~= k
       display(['FATAL! Candidate entry ' num2str(i) ' has ' num2str(size(token,2)) ' bits, but ' num2str(k) ' bits are needed.']);
       return;
   end

   candidate_correct_messages(i,:) = token;
   i = i+1;

   if size(remain,2) == 0
       done_parsing = 1;
   end
end

if verbose == 1
    candidate_correct_messages
end

candidate_correct_messages_endianswap = repmat('X',size(candidate_correct_messages,1),k/4);
for i=1:size(candidate_correct_messages,1)
    tmp = my_bin2hex(candidate_correct_messages(i,:));
    for packed_inst=1:num_packed_inst
        candidate_correct_messages_endianswap(i,(packed_inst-1)*8+1:(packed_inst-1)*8+8) = reverse_byte_order(tmp((packed_inst-1)*8+1:(packed_inst-1)*8+8)); % Put the packed instruction in big-endian format.
    end
end

if verbose == 1
    candidate_correct_messages_endianswap
end

% hex to bin
candidate_correct_messages_endianswap_bin = repmat('X',size(candidate_correct_messages,1),k);
for i=1:size(candidate_correct_messages,1)
    candidate_correct_messages_endianswap_bin(i,:) = my_hex2bin(candidate_correct_messages_endianswap(i,:));
end

if verbose == 1
    candidate_correct_messages_endianswap_bin
end

%%Stringize endian-swapped insts
serialized_candidate_correct_messages_endianswap_bin = '';
for i=1:size(candidate_correct_messages_endianswap,1)
   serialized_candidate_correct_messages_endianswap_bin = [serialized_candidate_correct_messages_endianswap_bin candidate_correct_messages_endianswap_bin(i,:)];
   if i < size(candidate_correct_messages_endianswap_bin,1)
       serialized_candidate_correct_messages_endianswap_bin = [serialized_candidate_correct_messages_endianswap_bin ','];
   end
end

if verbose == 1
    serialized_candidate_correct_messages_endianswap_bin
end

% mnemonic frequency
fid = fopen(instruction_mnemonic_hotness_filename);
instruction_mnemonic_hotness_file = textscan(fid, '%s', 'Delimiter', ',');
fclose(fid);
instruction_mnemonic_hotness_file = instruction_mnemonic_hotness_file{1};
%instruction_mnemonic_hotness_file = reshape(instruction_mnemonic_hotness_file, 2, size(instruction_mnemonic_hotness_file,1)/2)';
instruction_mnemonic_hotness_file = reshape(instruction_mnemonic_hotness_file, 67, size(instruction_mnemonic_hotness_file,1)/67)'; % FIXME: 67 is hardcoded number of registers (64) + 'NA' + 'TOTAL' + mnemonic column
instruction_mnemonic_hotness = containers.Map(); % Init
if strcmp(policy, 'filter-joint-frequency-sort-pick-longest-pad') == 1
    for r=2:size(instruction_mnemonic_hotness_file,1)
        reg_in_mnemonic_hotness = containers.Map();
        for c=3:size(instruction_mnemonic_hotness_file,2)
            reg_in_mnemonic_hotness(instruction_mnemonic_hotness_file{1,c}) = str2double(instruction_mnemonic_hotness_file{r,c});
        end
        instruction_mnemonic_hotness(instruction_mnemonic_hotness_file{r,1}) = reg_in_mnemonic_hotness;
    end
else
    for r=2:size(instruction_mnemonic_hotness_file,1)
        instruction_mnemonic_hotness(instruction_mnemonic_hotness_file{r,1}) = str2double(instruction_mnemonic_hotness_file{r,2});
    end
end

% rd frequency
fid = fopen(instruction_rd_hotness_filename);
instruction_rd_hotness_file = textscan(fid, '%s', 'Delimiter', ',');
fclose(fid);
instruction_rd_hotness_file = instruction_rd_hotness_file{1};
instruction_rd_hotness_file = reshape(instruction_rd_hotness_file, 2, size(instruction_rd_hotness_file,1)/2)';
instruction_rd_hotness = containers.Map(); % Init
for r=2:size(instruction_rd_hotness_file,1)
    instruction_rd_hotness(instruction_rd_hotness_file{r,1}) = str2double(instruction_rd_hotness_file{r,2});
end

[num_valid_messages, recovered_message_endianswap_bin, estimated_prob_correct, suggest_to_crash, recovered_successfully] = inst_recovery(architecture, num2str(k), original_message_endianswap_bin, serialized_candidate_correct_messages_endianswap_bin, policy, instruction_mnemonic_hotness, instruction_rd_hotness, crash_threshold, num2str(verbose));

if verbose == 1
    recovered_message_endianswap_bin
end
    
tmp = my_bin2hex(recovered_message_endianswap_bin);
tmp2 = repmat('X',1,k/4);
for packed_inst=1:num_packed_inst
     tmp2((packed_inst-1)*8+1:(packed_inst-1)*8+8) = reverse_byte_order(tmp((packed_inst-1)*8+1:(packed_inst-1)*8+8));
end
recovered_message = my_hex2bin(tmp2);

fprintf(1, '%s\n', recovered_message);
