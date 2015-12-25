% Hamming SEC-DED Decoder
% We assume that the length of the received codeword is n bits (represented
% as char array), and that H is (n-k) x n bits (represented as decimal
% matrix).
% If the received codeword was able to be corrected/decoded, it is returned as
% decoded_message (a bit string). err is # of errors detected, which is accurate for up
% to 2 errors. Since this is a SEC-DED decoder, if err=2, then
% decoded_message will be set to 'FAIL'. If err=0 or 1, then
% decoded_message should match the original encoded message.
%
% Authors: Clayton Schoeny and Mark Gottscho
% Email: cschoeny@gmail.com, mgottscho@ucla.edu
function [decoded_message, num_error_bits] = hamDec(received_codeword, H)
    %% Set default return values
    decoded_message = 'FAILED TO RECOVER MESSAGE';
    num_error_bits = Inf;
    
    %% Get some code parameters
    r = size(H,1);
    n = size(H,2);
    k = n-r;
         
    %% Compute syndrome of received codeword
    s = mod(H*received_codeword',2);
    
    %% CASE 0: Syndrome is 0, no errors detected
    if s == zeros(r,1)
        decoded_message = received_codeword(1:k); % Assume code is systematic, meaning that first k bit positions are the message, and parity bits are glued on the end
        num_error_bits = 0;
        return;
    end
           
    %% DECODING FOR HSIAO (72, 64) CODE:
    if n == 72
       %% CASE 1: Syndrome is even, so there are an even # of errors. Maximum likelihood decoding means we interpret as 2-bit error.
       if mod(sum(s),2) == 0
          num_error_bits = 2;
       end
       
       %% CASE 2: Syndrome is odd, so there are an odd # of errors. Usually this is a single bit error, but in some cases SECDED can detect 3-bit errors.
       if mod(sum(s),2) == 1         
          %% Now we need to locate the actual bit position of the error so it can be corrected
          notfound = 1;
          for i=1:n          
             if sum(s==H(:,i)) == r
                bit = i;
                notfound = 0;
                break;
             end
          end

          if notfound == 1
             num_error_bits = 3;
          else % Correct the error
             num_error_bits = 1;
             error = repmat('0',num_error_patterns,n);
             error(bit) = '1';
             decoded_codeword = dec2bin(bitxor(bin2dec(received_codeword), bin2dec(error)), n);
             decoded_message = decoded_codeword(1:k);       
          end
       end
       
       return;
    end
    
    %% DECODING FOR STANDARD (8, 4) CODE:
    if n == 8
        %% CASE 1: Syndrome is non-zero, single error
        if sum(s(1:r-1) ~= zeros(r-1,1)) > 0 && s(r) == 1
           num_error_bits = 1; 

           %% Find the single bit error
           for i=1:n           
              if sum(s == H(:,i)) == r
                 bit = i; 
              end
           end

           %% Correct it
           error = repmat('0',num_error_patterns,n);
           error(bit) = '1';
           decoded_codeword = dec2bin(bitxor(bin2dec(received_codeword), bin2dec(error)), n);
           decoded_message = decoded_codeword(1:k);
        end

        %% CASE 2: Error in SECDED bit. Is this correct??
        if sum(s(1:r-1) ~= zeros(r-1,1)) == 0 && s(r) == 1
           num_error_bits = 1; 

           %% Correct it
           error = repmat('0',num_error_patterns,n);
           error(bit) = '1';
           decoded_codeword = dec2bin(bitxor(bin2dec(received_codeword), bin2dec(error)), n);
           decoded_message = decoded_codeword(1:k); 
        end

        %% CASE 3: Syndrome is non-zero, double error. This is uncorrectable
        if sum(s(1:r-1) ~= zeros(r-1,1)) > 0 && s(r) == 0
            num_error_bits = 2;        
        end
        
        return;
    end
end