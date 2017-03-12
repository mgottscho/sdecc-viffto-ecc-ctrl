function [bin] = my_de2bi(dec,k)
% Convert a decimal numeric value into a vector of numeric 1 and 0
%
% Arguments:
%   dec --   unsigned integer value (uint32)
%
% Returns:
%   bin --   Vector of k scalars, where each is either 0 or 1.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

bin = my_dec2bin(dec,k) - '0';
