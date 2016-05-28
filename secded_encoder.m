% SEC-DED Encoder
%
% Input arguments:
%   G --                      Matrix: kxn decimal matrix with 0 or 1 entries that corresponds to a SECDED generator matrix
%
% Returns:
%   codeword --        String: 1xn character array, each entry is '0' or '1' UNLESS encoding fails, in which case it is repeated 'X'
%
% Authors: Clayton Schoeny and Mark Gottscho
% Email: cschoeny@gmail.com, mgottscho@ucla.edu

function [codeword] = secded_encoder(message,G)
    codeword = mod(message*G,2);
    codeword = dec2bin(codeword)';
end
