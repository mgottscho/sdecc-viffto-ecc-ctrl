function [ decoded_message, num_error_bits ] = dected_decoder( received_codeword, H )

%% Set default return values
decoded_message = 'X'; % Don't know k yet as we can't trust inputs
num_error_bits = Inf;

%% Get some code parameters
r = size(H,1);
n = size(H,2);
k = n-r;

%% Input validation
input_valid = 0;
if ((n == 79 && k == 64) || (n == 45 && k == 32))
   if (sum(size(received_codeword) == [1,n]) == 2)
       input_valid = 1;
   end
end

if input_valid == 0
   return;
end

%% Compute syndrome of received codeword
s = mod(H*received_codeword',2);

%% CASE 0: Syndrome is 0, no errors detected
if s == zeros(r,1)
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
err = zeros(1,n);

%2-Bit error case (hypothesis)
%Here we go through and see if any codeword is 2-bit flips away from the
%received word.

for a=1:n-1
    for b=a+1:n
        if nnz(mod(H(:,a)+H(:,b)+s,2))==0
            num_error_bits = 2;
            err(a)=1;
            err(b)=1;
            decoded_codeword = mod(received_codeword+err,2);
            decoded_message = decoded_codeword(1:k);
            return
        end
    end
end

%If we got this far, then either we have either exactly 1 error, or more
%than 2 errors. Let's see if there is a single error.
for a=1:n
    if nnz(mod(H(:,a)+s,2))==0
        num_error_bits = 1;
        err(a)=1;
        decoded_codeword = mod(received_codeword+err,2);
        decoded_message = decoded_codeword(1:k);
        return
    end
end

%If we get this far, that means we have detected the error, so we assume
%there were 3 errors.
num_error_bits = 3;


   




end

