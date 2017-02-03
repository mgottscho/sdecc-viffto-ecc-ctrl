function [dec] = my_bin2dec(bin,k)
% Convert a binary string of '0' and '1' characters into a decimal numeric value.
%
% Arguments:
%   bin --   String of k characters, where each is either '0' or '1'.
%   k --     Scalar: [32|64]
%
% Returns:
%   dec --   unsigned integer value (uint64 if k = 64, uint32 if k = 32) represented by the binary input string. NaN on error or if k is invalid
%
% Code based on that from http://stackoverflow.com/questions/32334748/convert-64-bit-numbers-from-binary-to-decimal-using-uint64
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

%dec = NaN; 
% commented out for speed

%% Check input validity to ensure each character is either '0' or '1' and no other value
% commented out for speed
%if (sum(bin == '1')+sum(bin == '0')) ~= size(bin,2)
%    return;
%end

%% Check input validity to ensure k is OK
% commented out for speed
%if size(bin,2) ~= k || k ~= 32 || k ~= 64
%    return;
%end

if k == 32
    v = uint32(length(bin)-1:-1:0);
    base = uint32(2).^v;
    dec = sum(uint32(base.*(uint32(bin-'0'))), 'native');
elseif k == 64
    v = uint64(length(bin)-1:-1:0);
    base = uint64(2).^v;
    dec = sum(uint64(base.*(uint64(bin-'0'))), 'native');
end

end

