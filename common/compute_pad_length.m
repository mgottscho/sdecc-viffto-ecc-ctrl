function [padLength] = count_pad_length(bin)
% Find the length of a sequential run of either 0s or 1s starting only from the most-significant bit position (pad) in a string of binary characters.
% 
% Arguments:
%   bin --   String of k characters, where each is either '0' or '1'.
%
% Returns:
%   padLength -- Scalar, longest pad of either 0s or 1s, whichever is greater. On error, longestPad is set to -1.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

padLength = size(bin,2); % Init to max

%% Check input validity to ensure each character is either '0' or '1' and no other value
if (sum(bin == '1')+sum(bin == '0')) ~= size(bin,2)
    padLength = -1;
    return;
end

%% Find length of the pad
msb = bin(1);
padLength = 1;
for i=1:size(bin,2)
   if bin(i) ~= msb
       break;
   end
   padLength = padLength+1;
end

end
