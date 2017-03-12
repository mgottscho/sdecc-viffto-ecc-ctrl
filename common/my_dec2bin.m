function [bin] = my_dec2bin(dec,k)
% Convert a decimal numeric value into a binary string of '0' and '1' characters.
%
% Arguments:
%   dec --   unsigned integer value (uint64 if k = 64, uint32 if k = 32 or 16) represented by the binary input string. NaN on error or if k is invalid
%   k --     Scalar: [16|32|64]
%
% Returns:
%   bin --   String of k characters, where each is either '0' or '1'.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

bin = repmat('X',1,k);
if k <= 32
    mask = uint32(1);
elseif k <= 64
    mask = uint64(1);
else
    display(['Bad k = ' num2str(k)]);
    return;
end

for i=1:k
    bin(k-(i-1)) = bitand(bitshift(dec,-(i-1)), mask) + '0';
end

end

