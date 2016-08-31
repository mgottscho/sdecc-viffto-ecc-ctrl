function [candidate_correct_messages, retval] = compute_candidate_correct_messages(received_string, H, code_type)
% Compute a list of candidate-correct messages upon receiving a detected-but-uncorrectable error.
%
% Arguments:
%    received_string -- String of length n binary characters, where each is either '0' or '1'.
%    H -- Binary matrix of dimension (n-k) x n, where each is either 0 or 1. This is the parity-check matrix.
%    code_type -- String: '[hsiao1970|davydov1991|bose1960]' SECDED and DECTED-only for now.
%
% Returns:
%    candidate_correct_messages -- Character matrix of dimension c x k. Each row corresponds to a message that, when encoded and corrupted with a detected-but-uncorrectable error, could have resulted in the given received_string. Upon error in this function, candidate_correct_messages will be set to an n x k matrix of 'X'.
%    retval -- Boolean 1 or 0. 0 on success.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

r = size(H,1);
n = size(H,2);
k = n-r;

%if ~isdeployed
%    addpath(['..' filesep 'common']); % Add sub-folders to MATLAB search paths for calling other functions we wrote
%end

x = 1;
candidate_correct_messages = repmat('X',n,k); % Pre-allocate for worst-case capacity. X is placeholder. If something goes wrong, we expect this variable to not change and be returned as-is.
retval = 1;

for pos=1:n
   %% Flip the bit
   error = repmat('0',1,n);
   error(pos) = '1';
   trial_string = my_bitxor(received_string, error);

   %% Attempt to decode
   if strcmp(code_type, 'hsiao1970') == 1 || strcmp(code_type, 'davydov1991') == 1 % SECDED version
        [decoded_message, num_error_bits] = secded_decoder(trial_string, H, code_type);
   elseif strcmp(code_type, 'bose1960') == 1 % DECTED version
        [decoded_message, num_error_bits] = dected_decoder(trial_string, H);
   else
       display(['FATAL! Unsupported code type: ' code_type]);
       return;
   end

   if sum(size(strfind(decoded_message,'X'))) == 0
       % This is a candidate codeword.
       candidate_correct_messages(x,:) = decoded_message;
       x = x+1;
   end
end

% Uniquify the candidate messages
if x > 1
    candidate_correct_messages = candidate_correct_messages(1:x-1, :);
    candidate_correct_messages = unique(candidate_correct_messages,'rows','sorted'); % Sort feature is important
    retval = 0;
end
