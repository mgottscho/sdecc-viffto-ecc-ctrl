function [ num_error_sym, decoded_message ] = chipkill_decode( received_codeword, H, block_size )

%This function assumes that we are using the (144,128) systematic chipkill
%code. (So the input for block_size should be 4) If the received_codeword is already a codeword, then
%num_error_sym=0. If there is a correctable error then we have
%num_error_sym=1 since simply changing a single symbol can lead to a
%codeword. For all else we return num_err_sym=2 meaning it is a detectable
%but uncorrectable error and we don't return any decoded_message (just
%garbage values of 'X').

%% Set default return values
decoded_message = 'X'; % Don't know k yet as we can't trust inputs
num_error_sym = Inf;

%% Get some code parameters
r = size(H,1);
n = size(H,2);
k = n-r;


%% Input validation
input_valid = 0;
if (n == 144 && k == 128)
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
    decoded_message = received_codeword(1:128); % Assume code is systematic, meaning that first k bit positions are the message, and parity bits are glued on the end
    num_error_sym = 0;
    return;
end


%% If we get this far, then there are errors. First we check to see if we can correct any single symbol errors. If not, then we know we detect the error
err = zeros(1,n);

%Single symbol error case
%Need to go through All possible single, double, triple, and quadruple
%bit-error-patterns that can occur within pre-determined b-bit blocks.

%First we check the single bit flips
for a=1:n
    if nnz(mod(H(:,a)+s,2))==0
        num_error_sym = 1;
        err(a)=1;
        decoded_codeword = mod(received_codeword+err,2);
        decoded_message = decoded_codeword(1:128);
        return;
    end
end

%Next we check the double bit flips
for block = 1:n/block_size
    for a=1+block_size*(block-1):block_size*block-1
        for b=a+1:block_size*block
            if nnz(mod(H(:,a)+H(:,b)+s,2))==0
                num_error_sym = 1;
                err(a)=1;
                err(b)=1;
                decoded_codeword = mod(received_codeword+err,2);
                decoded_message = decoded_codeword(1:128);
                return
            end
        end
    end
end

%Next we check for the triple bit flips
for block = 1:n/block_size
    for a=1+block_size*(block-1):block_size*block-2
        for b=a+1:block_size*block-1
            for c=b+1:block_size*block
                if nnz(mod(H(:,a)+H(:,b)+H(:,c)+s,2))==0
                    num_error_sym = 1;
                    err(a)=1;
                    err(b)=1;
                    err(c)=1;
                    decoded_codeword = mod(received_codeword+err,2);
                    decoded_message = decoded_codeword(1:128);
                    return
                end
            end
        end
    end
end

%Lastly we check for the quadruple bit filps
for block = 1:n/block_size
    if nnz(mod(H(:,1+block_size*(block-1))+H(:,2+block_size*(block-1))+H(:,3+block_size*(block-1))+H(:,4+block_size*(block-1))+s,2))==0
        num_error_sym = 1;
        err(1+block_size*(block-1))=1;
        err(2+block_size*(block-1))=1;
        err(3+block_size*(block-1))=1;
        err(4+block_size*(block-1))=1;
        decoded_codeword = mod(received_codeword+err,2);
        decoded_message = decoded_codeword(1:128);
        return
    end
end

%If we get this far, that means we have detected the error, so we assume
%there were 2 errors (it is possible that there were more errors, but the important thing is that we have detected uncorrectable errors).
num_error_sym = 2;


end

