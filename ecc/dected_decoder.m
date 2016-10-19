function [decoded_message, num_error_bits] = dected_decoder(received_codeword, H)
% DEC-TED Decoder
%
% We assume that the length of the received codeword is n bits (represented
% as char array), and that H is (n-k) x n bits (represented as decimal
% matrix).
%
% If the received codeword was able to be corrected/decoded, it is returned as
% decoded_message (a bit string). num_error_bits is # of errors detected when applicable.
% For a DECTED code, then num_error_bits is accurate at least for up
% to 3 errors. If num_error_bits==3, then
% decoded_message will be set to all 'X'. If num_error_bits==0,1, or 2, then
% decoded_message should match the original encoded message.
%
% Input arguments:
%   received_codeword --      String: 1xn character array, each entry is '0' or '1'
%   H --                      Matrix: (n-k)xn decimal matrix with 0 or 1 entries that corresponds to a DECTED parity-check matrix
%
% Returns:
%   decoded_message --        String: 1xk character array, each entry is '0' or '1' UNLESS decoding fails, in which case it is repeated 'X' and num_error_bits is Inf
%   num_error_bits --         Scalar: [0|1|(2)|(3)|Inf] 
%
% Authors: Clayton Schoeny and Mark Gottscho
% Email: cschoeny@gmail.com, mgottscho@ucla.edu


%% Get some code parameters
r = size(H,1);
n = size(H,2);
k = n-r;

%% Set default return values
num_error_bits = Inf;
%decoded_message = repmat('X',1,k);
decoded_message = 'X';

%% Input validation -- commented out for speed
%input_valid = 0;
%if ((n == 79 && k == 64) || (n == 45 && k == 32))
%   if (sum(size(received_codeword) == [1,n]) == 2)
%       input_valid = 1;
%   end
%end
%
%if input_valid == 0
%   return;
%end

%% Compute syndrome of received codeword
% Note: received_codeword is a string of binary '0' and '1' characters, which have ASCII values 48 and 49, respectively. Thus we can do multiplication of 48 and 49 with a binary H, mod2 to get syndrome s numerically. Fancy.
s = mod(H*received_codeword',2);

%% CASE 0: Syndrome is 0, no errors detected
if nnz(s) == 0
    decoded_message = received_codeword(1:k); % Assume code is systematic, meaning that first k bit positions are the message, and parity bits are glued on the end
    num_error_bits = 0;
    return;
end

%% There exist Errors


%If we get this far, the closest codeword is either 1, 2, or 3 bit flips
%away.  If it is 3, then we can detect that error, because we will not be
%able to correct it with a single or double correction.  Since we will be
%primarily using this when flipping 1-bit from a 3-bit DUE, I will first
%check on the 2-bit error case, for latency purposes.
err = repmat('0',1,n);

% Let's see if there is a single-bit error.
H_plus_syndrome = mod(H+repmat(s,1,size(H,2)),2); % Add the syndrome to each column of H. We do this to memoize the result for later even if there is not a single-bit error found.
a = find(sum(H_plus_syndrome==0)==size(H,1));
if size(a,2) == 1 % Single-bit error found at matching column a
    num_error_bits = 1;
    err(a)='1';
    decoded_codeword = my_bitxor(received_codeword, err);
    decoded_message = decoded_codeword(1:k);
    return;
end

% Let's see if there is a double-bit error.
for a=1:n-1
    col_a_plus_syndrome = H_plus_syndrome(:,a);
    for b=a+1:n
        columns_plus_syndrome = mod(col_a_plus_syndrome+H(:,b),2);
        if nnz(columns_plus_syndrome)==0
            num_error_bits = 2;
            err(a)='1';
            err(b)='1';
            decoded_codeword = my_bitxor(received_codeword, err);
            decoded_message = decoded_codeword(1:k);
            return;
        end
    end
end

%If we get this far, that means we have detected the error, so we assume
%there were 3 errors.
num_error_bits = 3;

end

