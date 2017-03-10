function [bin] = my_hex2bin(hex)
% Convert a string of hexadecimal characters into a string of binary characters.
%
% Arguments:
%   hex --   String of k/4 characters, where each is in set {'0','1',...,'9','a','b','c','d','e','f'}
%
% Returns:
%   bin --   String of k characters, where each is either '0' or '1'. Upon error, bin is set to 'XXXX...XXX' of length k.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

k_by4 = size(hex,2);
k = k_by4*4;

for i=1:k_by4
    index_start = ((i-1)*4)+1;
    index_end = ((i-1)*4)+4;
    switch hex(i)
        case '0'
            bin(index_start:index_end) = '0000';
        case '1'
            bin(index_start:index_end) = '0001';
        case '2'
            bin(index_start:index_end) = '0010';
        case '3'
            bin(index_start:index_end) = '0011';
        case '4'
            bin(index_start:index_end) = '0100';
        case '5'
            bin(index_start:index_end) = '0101';
        case '6'
            bin(index_start:index_end) = '0110';
        case '7'
            bin(index_start:index_end) = '0111';
        case '8'
            bin(index_start:index_end) = '1000';
        case '9'
            bin(index_start:index_end) = '1001';
        case 'a'
            bin(index_start:index_end) = '1010';
        case 'b'
            bin(index_start:index_end) = '1011';
        case 'c'
            bin(index_start:index_end) = '1100';
        case 'd'
            bin(index_start:index_end) = '1101';
        case 'e'
            bin(index_start:index_end) = '1110';
        case 'f'
            bin(index_start:index_end) = '1111';
        otherwise % Error
            bin = repmat('X',1,k);
            return;
    end
end

end

