function [num_valid_messages, recovered_message, estimated_prob_correct, suggest_to_crash, recovered_successfully] = inst_recovery_endian_wrapper(architecture, k, original_message, candidate_correct_messages_bin, policy, instruction_mnemonic_hotness, instruction_rd_hotness, crash_threshold, verbose)
           
if ~isdeployed
    addpath ecc common rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
end

num_packed_inst = k/32; % We assume 32-bits per instruction. For k as a multiple of 32, we have packed instructions per message. FIXME: this is only true for RV64G

original_message_endianswapped = my_bin2hex(original_message);
for packed_inst=1:num_packed_inst
    original_message_endianswapped((packed_inst-1)*8+1:(packed_inst-1)*8+8) = reverse_byte_order(original_message_endianswapped((packed_inst-1)*8+1:(packed_inst-1)*8+8)); % Put the packed instruction in big-endian format.
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

candidate_correct_messages_endianswap = repmat('X',size(candidate_correct_messages,1),k);
for i=1:size(candidate_correct_messages,1)
    for packed_inst=1:num_packed_inst
        candidate_correct_messages_endianswapped((packed_inst-1)*8+1:(packed_inst-1)*8+8,i) = reverse_byte_order(candidate_correct_messages((packed_inst-1)*8+1:(packed_inst-1)*8+8),i); % Put the packed instruction in big-endian format.
    end
end

%%Stringize endian-swapped insts
candidate_correct_messages_endianswapped_bin = '';
for i=1:size(candidate_correct_messages_endianswapped,1)
   candidate_correct_messages_endianswapped_bin = [candidate_correct_messages_endianswapped_bin candidate_correct_messages_endianswapped(i,:)];
   if i < size(candidate_correct_messages_endianswapped,1)-1
       candidate_correct_messages_endianswapped_bin = [candidate_correct_messages_endianswapped_bin ','];
   end
end

[num_valid_messages, recovered_message_endianswap_bin, estimated_prob_correct, suggest_to_crash, recovered_successfully] = inst_recovery(architecture, k, original_message_endianswapped, candidate_correct_messages_endianswap, policy, instruction_mnemonic_hotness, instruction_rd_hotness, crash_threshold, verbose);

recovered_message = repmat('X',1,k);
for packed_inst=1:num_packed_inst
    recovered_message((packed_inst-1)*8+1:(packed_inst-1)*8+8,i) = reverse_byte_order(recovered_message_endianswap_bin((packed_inst-1)*8+1:(packed_inst-1)*8+8),i); % Put the packed instruction in little-endian format.
end

fprintf(1, '%s\n', recovered_message);
