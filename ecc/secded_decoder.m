% SEC-DED Decoder
%
% We assume that the length of the received codeword is n bits (represented
% as char array), and that H is (n-k) x n bits (represented as decimal
% matrix).
%
% If the received codeword was able to be corrected/decoded, it is returned as
% decoded_message (a bit string). num_error_bits is # of errors detected when applicable.
% For a Hsiao SECDED code, which is odd-weight, then num_error_bits is accurate for up
% to 2 errors. Since this is a SEC-DED decoder, if num_error_bits==2, then
% decoded_message will be set to all 'X'. If num_error_bits==0 or 1, then
% decoded_message should match the original encoded message. In some cases, a triple-bit error
% (num_error_bits==3) will be detectable and reported for Hsiao code only. In other cases,
% triple-bit errors will be mis-corrected as a single-bit error.
%
% Input arguments:
%   received_codeword --      String: 1xn character array, each entry is '0' or '1'
%   H --                      Matrix: (n-k)xn decimal matrix with 0 or 1 entries that corresponds to a SECDED parity-check matrix
%   code_type --              String: '[hsiao1970|davydov1991]'
%
% Returns:
%   decoded_message --        String: 1xk character array, each entry is '0' or '1' UNLESS decoding fails, in which case it is repeated 'X' and num_error_bits is Inf
%   num_error_bits --         Scalar: [0|1|(2)|(3)|Inf] 
%
% Authors: Clayton Schoeny and Mark Gottscho
% Email: cschoeny@gmail.com, mgottscho@ucla.edu

function [decoded_message, num_error_bits] = secded_decoder(received_codeword, H, code_type)
   %% Set default return values
   decoded_message = 'X'; % Don't know k yet as we can't trust inputs
   num_error_bits = Inf;
   
   %% Get some code parameters
   r = size(H,1);
   n = size(H,2);
   k = n-r;

   %% Input validation
   input_valid = 0;
   if ((n == 39 && k == 32) || (n == 72 && k == 64) || (n == 8 && k == 4)) && (strcmp(code_type,'hsiao1970') == 1 || strcmp(code_type,'davydov1991') == 1) && (sum(size(received_codeword) == [1,n]) == 2)
           input_valid = 1;
   end

   if input_valid == 0
       return;
   end
   
   %% Set default message
   decoded_message = repmat('X',1,k);
         
   %% Compute syndrome of received codeword
   s = mod(H*received_codeword',2);
   
   %% CASE 0: Syndrome is 0, no errors detected (or it was an ultra-rare 4-bit error that was mis-corrected)
   if s == zeros(r,1)
      decoded_message = received_codeword(1:k); % Assume code is systematic, meaning that first k bit positions are the message, and parity bits are glued on the end
      num_error_bits = 0;
           
   %% CASE 1: HSIAO ONLY: Syndrome is even, so there are an even # of errors. Maximum likelihood decoding means we interpret as 2-bit error.
   elseif strcmp(code_type,'hsiao1970') == 1 && mod(sum(s),2) == 0
      num_error_bits = 2;
   
   %% CASE 2: Pi code OR Hsiao code when syndrome is odd, so there are an odd # of errors. Usually this is a single bit error, but in some cases SECDED can detect 3-bit errors.
   elseif strcmp(code_type,'davydov1991') == 1 || mod(sum(s),2) == 1         
      %% Attempt to find bit position of the error so it can be corrected
      notfound = 1;
      for i=1:n          
         if sum(s==H(:,i)) == r
            bit = i;
            notfound = 0;
            break;
         end
      end

      if notfound == 1 % Detected but not corrected error
         if strcmp(code_type,'hsiao1970') == 1 % In Hsiao code, this means detected triple-bit error
             num_error_bits = 3;
         else % In Pi code, this could be either 2-bit or 3-bit detected error but we can't tell the difference since it isn't strictly odd-weight code. We default to assuming 2-bit error.
             num_error_bits = 2; 
         end
      else % Correct a single-bit or mis-interpreted triple-bit error
         num_error_bits = 1;
         
         error = repmat('0',1,n);
         error(bit) = '1';
         decoded_codeword = my_bitxor(received_codeword, error);
         decoded_message = decoded_codeword(1:k);       
      end
   end
end
