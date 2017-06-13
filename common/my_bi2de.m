function [dec] = my_bi2de(bin)
% Convert a binary vector of 0 and 1 numbers into a decimal numeric value.
%
% Arguments:
%   bin --   Vector of k scalars, where each is either 0 or 1.
%
% Returns:
%   dec --   unsigned integer value (uint32)
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

bin_str = bin + '0';
dec = my_bin2dec(bin_str, 32);
