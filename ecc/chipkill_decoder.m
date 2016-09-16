function [ decoded_message, num_error_bits, num_error_symbols ] = chipkill_decoder( received_codeword, H, symbol_size )

%This function assumes that we are using the (144,128) systematic chipkill
%code. (So the input for symbol_size should be 4) If the received_codeword is already a codeword, then
%num_error_symbols=0. If there is a correctable error then we have
%num_error_symbols=1 since simply changing a single symbol can lead to a
%codeword. For all else we return num_err_sym=2 meaning it is a detectable
%but uncorrectable error and we don't return any decoded_message (just
%garbage values of 'X').

    %% Set default return values
    decoded_message = 'X'; % Don't know k yet as we can't trust inputs
    num_error_bits = Inf;
    num_error_symbols = Inf;

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
   
   %% Set default message
   decoded_message = repmat('X',1,k);

   %% Compute syndrome of received codeword
   s = mod(H*received_codeword',2);

   %% CASE 0: Syndrome is 0, no errors detected
   if s == zeros(r,1)
       decoded_message = received_codeword(1:k); % Assume code is systematic, meaning that first k bit positions are the message, and parity bits are glued on the end
       num_error_symbols = 0;
       num_error_bits = 0;
       return;
   end

   %% If we get this far, then there are errors. First we check to see if we can correct any single symbol errors. If not, then we know we detect the error
   err = zeros(1,n);

   %Single symbol error case
   %Need to go through All possible single, double, triple, and quadruple
   %bit-error-patterns that can occur within pre-determined b-bit symbols.

   %First we check the single bit flips (all possible single bit flips within a symbol)
   for a=1:n
       if nnz(mod(H(:,a)+s,2))==0 % Column of H at bit position a matches syndrome. This means there is one bit error.
           num_error_symbols = 1;
           num_error_bits = 1;
           err(a)=1;
           decoded_codeword = mod(received_codeword+err,2);
           decoded_message = decoded_codeword(1:k);
           return;
       end
   end

   %Next we check all possible double bit flips within a symbol
   for symbol = 1:n/symbol_size
       for a=1+symbol_size*(symbol-1):symbol_size*symbol-1 % a is the first bit position of each symbol
           for b=a+1:symbol_size*symbol % b iterates over the 2nd possible bit positions within each symbol
               if nnz(mod(H(:,a)+H(:,b)+s,2))==0 % sum of columns a and b in H are syndrome, meaning we found double-bit error within a symbol.
                   num_error_symbols = 1;
                   num_error_bits = 2;
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
   for symbol = 1:n/symbol_size
       for a=1+symbol_size*(symbol-1):symbol_size*symbol-2 % a is the first bit position of each symbol
           for b=a+1:symbol_size*symbol-1 % b iterates over the 2nd possible bit positions within each symbol
               for c=b+1:symbol_size*symbol % c iterates over the 3rd possible bit positions within each symbol
                   if nnz(mod(H(:,a)+H(:,b)+H(:,c)+s,2))==0 % sum of columns a, b, and c in H are syndrome, meaning we found triple-bit error within a symbol.
                       num_error_symbols = 1;
                       num_error_bits = 3;
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

   %Lastly we check for the quadruple bit flips
   for symbol = 1:n/symbol_size
       if nnz(mod(H(:,1+symbol_size*(symbol-1))+H(:,2+symbol_size*(symbol-1))+H(:,3+symbol_size*(symbol-1))+H(:,4+symbol_size*(symbol-1))+s,2))==0 % Only one way this happens for symbol size of 4 bits: all four columns within a symbol of H sum to syndrome.
           num_error_symbols = 1;
           num_error_bits = 4;
           err(1+symbol_size*(symbol-1))=1;
           err(2+symbol_size*(symbol-1))=1;
           err(3+symbol_size*(symbol-1))=1;
           err(4+symbol_size*(symbol-1))=1;
           decoded_codeword = mod(received_codeword+err,2);
           decoded_message = decoded_codeword(1:128);
           return
       end
   end

   %If we get this far, that means we have detected the error, so we assume
   %there were 2 symbol errors (it is possible that there were more errors, but the important thing is that we have detected uncorrectable errors).
   % We also don't know how many bits in error. So we assume NaN bits in error. FIXME: is this correct?
   num_error_symbols = 2;
   num_error_bits = NaN;

end

