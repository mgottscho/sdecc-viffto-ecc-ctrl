function [hex] = my_bin2hex(bin)
% Convert a string of binary characters into a string of hexadecimal characters.
%
% Arguments:
%   bin --   String of k characters, where each is either '0' or '1'. Upon error, bin is set to 'XXXX...XXX' of length k.
%
% Returns:
%   hex --   String of k/4 characters, where each is in set {'0','1',...,'9','a','b','c','d','e','f'}
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

k = size(bin,2);
k_by4 = k/4;

for i=1:k_by4
    index_start = ((i-1)*4)+1;
    index_end = ((i-1)*4)+4;
    nibble = bin(index_start:index_end);
    switch nibble
        case '0000'
            hex(i) = '0';
        case '0001'
            hex(i) = '1';
        case '0010'
            hex(i) = '2';
        case '0011'
            hex(i) = '3';
        case '0100'
            hex(i) = '4';
        case '0101'
            hex(i) = '5';
        case '0110'
            hex(i) = '6';
        case '0111'
            hex(i) = '7';
        case '1000'
            hex(i) = '8';
        case '1001'
            hex(i) = '9';
        case '1010'
            hex(i) = 'a';
        case '1011'
            hex(i) = 'b';
        case '1100'
            hex(i) = 'c';
        case '1101'
            hex(i) = 'd';
        case '1110'
            hex(i) = 'e';
        case '1111'
            hex(i) = 'f';
        otherwise % Error
            hex = repmat('X',1,k_by4);
            return;
    end
end

end

