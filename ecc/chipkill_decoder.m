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


    %% Input validation -- commented out for speed
    %input_valid = 0;
    %if (n == 144 && k == 128)
    %   if (sum(size(received_codeword) == [1,n]) == 2)
    %       input_valid = 1;
    %   end
    %end

    %if input_valid == 0
    %   return;
    %end
   
   %% Set default message
   % commented out for speed
   %decoded_message = repmat('X',1,k);

   %% Compute syndrome of received codeword
   % Note: received_codeword is a string of binary '0' and '1' characters, which have ASCII values 48 and 49, respectively. Thus we can do multiplication of 48 and 49 with a binary H, mod2 to get syndrome s numerically. Fancy.
   s = mod(H*received_codeword',2);

   %% CASE 0: Syndrome is 0, no errors detected
   if nnz(s) == 0
       decoded_message = received_codeword(1:k); % Assume code is systematic, meaning that first k bit positions are the message, and parity bits are glued on the end
       num_error_symbols = 0;
       num_error_bits = 0;
       return;
   end

   %% If we get this far, then there are errors. First we check to see if we can correct any single symbol errors. If not, then we know we detect the error
   error = repmat('0',1,n);

   %Single symbol error case
   %Need to go through All possible single, double, triple, and quadruple
   %bit-error-patterns that can occur within pre-determined b-bit symbols.

   % First we check the single bit flips (all possible single bit flips within a symbol), as this is the simplest and fast case
   for a=1:n
       if nnz(mod(H(:,a)+s,2))==0 % Column of H at bit position a matches syndrome. This means there is one bit error.
           num_error_symbols = 1;
           num_error_bits = 1;
           error(a)='1';
           decoded_codeword = my_bitxor(received_codeword,error);
           decoded_message = decoded_codeword(1:k);
           return;
       end
   end
   
   % Next we check for the quadruple bit flips, as this is a fast and simple case
   for symbol = 1:n/symbol_size
       % Only one way this happens for symbol size of 4 bits: all four columns within a symbol of H sum to syndrome.
       idx = symbol_size*(symbol-1)+1;
       cols = H(:,idx:idx+3);
       columns_plus_syndrome = mod(sum(cols,2)+s,2);
       %if nnz(mod(H(:,1+symbol_size*(symbol-1))+H(:,2+symbol_size*(symbol-1))+H(:,3+symbol_size*(symbol-1))+H(:,4+symbol_size*(symbol-1))+s,2))==0  
       if nnz(columns_plus_syndrome) == 0 
           num_error_symbols = 1;
           num_error_bits = 4;
           error(idx:idx+3) = '1111';
           decoded_codeword = my_bitxor(received_codeword,error);
           decoded_message = decoded_codeword(1:k);
           return;
       end
   end
   
   % Next we check for the triple bit flips, as this is almost the exact same as checking for single bit flips, only '0' and '1' are reversed! This looks ugly but is faster than it seems.
   for symbol = 1:n/symbol_size
       idx = symbol_size*(symbol-1)+1;
       cols = H(:,idx:idx+3);
       % This looks like an ugly triple for loop and it is. However, when symbol size is 4 bits, there are only 4 ways to have three-bit error. This loop structure merely memoizes shared parts of 3-column sums.
       for a=1:2 % a is the first bit flip position in the symbol
           col_a_plus_syndrome = mod(cols(:,a)+s,2);
           for b=a+1:3 % b is the second bit flip position in the symbol
               col_a_b_plus_syndrome = mod(col_a_plus_syndrome+cols(:,b),2);
               for c=b+1:4 % c is the third bit flip position in the symbol
                   columns_plus_syndrome = mod(col_a_b_plus_syndrome+cols(:,c),2);
                   if nnz(columns_plus_syndrome)==0 % sum of columns a, b, and c in H are syndrome, meaning we found triple-bit error within a symbol.
                       num_error_symbols = 1;
                       num_error_bits = 3;
                       error(idx+a-1)='1';
                       error(idx+b-1)='1';
                       error(idx+c-1)='1';
                       decoded_codeword = my_bitxor(received_codeword,error);
                       decoded_message = decoded_codeword(1:k);
                       return;
                   end
               end
           end
       end
   end

   % Next we check all possible double bit flips within a symbol. There are 6 ways to do this. This is the slowest case.
   for symbol = 1:n/symbol_size
       idx = symbol_size*(symbol-1)+1;
       cols = H(:,idx:idx+3);
       for a=1:3 % a is the first bit flip position in the symbol
           col_a_plus_syndrome = mod(cols(:,a)+s,2);
           for b=a+1:4 % b is the second bit flip position in the symbol
               columns_plus_syndrome = mod(col_a_plus_syndrome+cols(:,b),2);
               if nnz(columns_plus_syndrome)==0 % sum of columns a and b in H are syndrome, meaning we found double-bit error within a symbol.
                   num_error_symbols = 1;
                   num_error_bits = 2;
                   error(idx+a-1)='1';
                   error(idx+b-1)='1';
                   decoded_codeword = my_bitxor(received_codeword,error);
                   decoded_message = decoded_codeword(1:k);
                   return;
               end
           end
       end
   end

   %If we get this far, that means we have detected the error, so we assume
   %there were 2 symbol errors (it is possible that there were more errors, but the important thing is that we have detected uncorrectable errors).
   % We also don't know how many bits in error. So we assume NaN bits in error. FIXME: is this correct?
   num_error_symbols = 2;
   num_error_bits = NaN;

end

