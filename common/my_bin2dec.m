function [dec] = my_bin2dec(bin)
% Convert a binary string of '0' and '1' characters into a decimal numeric value.
%
% Arguments:
%   bin --   String of k characters, where each is either '0' or '1'.
%
% Returns:
%   dec --   unsigned integer value represented by the binary input string. NaN on error or if k > 64.
%
% Code based on that from http://stackoverflow.com/questions/32334748/convert-64-bit-numbers-from-binary-to-decimal-using-uint64
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

dec = NaN; 

%% Check input validity to ensure each character is either '0' or '1' and no other value
if (sum(bin == '1')+sum(bin == '0')) ~= size(bin,2)
    return;
end

%% Check input validity to ensure k <= 64
if size(bin,2) > 64
    return;
end

v = uint64(length(bin)-1:-1:0);
base = uint64(2).^v;
dec = sum(uint64(base.*(uint64(bin-'0'))), 'native');

end

