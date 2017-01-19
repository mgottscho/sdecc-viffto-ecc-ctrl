% ULEL Decoder
%
% We assume that the length of the received codeword is n bits (represented
% as char array), and that H is (n-k) x n bits (represented as decimal
% matrix).
%
% In our ULEL, we can never correct an error in the general case, only localize them. So handling here is quite different than traditional (t)EC(t+1)ED code flavors. 
%
% Input arguments:
%   received_string --      String: 1xn character array, each entry is '0' or '1'
%   H --                      Matrix: (n-k)xn decimal matrix with 0 or 1 entries that corresponds to a ULEL parity-check matrix
%
% Returns:
%   segment_locator_mask --  String: 1xn character array, each entry is '0' or '1'. In positions with '1', this is a candidate location for the error. Essentially, this array is a mask of possible error locations, and they should fall within one segment as defined by our ULEL code. If no errors are detected, the mask should be all '0'.
%
% Authors: Clayton Schoeny and Mark Gottscho
% Email: cschoeny@gmail.com, mgottscho@ucla.edu

function [segment_locator_mask] = ULEL_decoder(received_string, H)
   %% Set default return values
   segment_locator_mask = 'X'; % Don't know k yet as we can't trust inputs
   
   %% Get some code parameters
   r = size(H,1);
   n = size(H,2);
   k = n-r;

   %% Input validation
   % commented out for speed
   %input_valid = 0;
   %if (sum(size(received_string) == [1,n]) == 2)
   %    input_valid = 1;
   %end

   %if input_valid == 0
   %    return;
   %end

   segment_locator_mask = repmat('0',1,n);
   
   %% Compute syndrome of received codeword
   s = mod(H*received_string',2);
   
   %% CASE 0: Syndrome is 0, no errors detected
   if s == zeros(r,1)
       return; 
           
   %% CASE 1: Syndrome is not 0, so there is an error somewhere.
   else
       % Find columns of H that match the syndrome.
       candidate_locs = ismember(H',s','rows')';
       for i=1:size(segment_locator_mask,2)
           if candidate_locs(i) == 1
               segment_locator_mask(i) = '1';
           end
       end
       return;
   end
end
