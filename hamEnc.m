% Hamming SEC-DED Encoder
% We assume that the length of message is k bits represented as char. G must be k x n bits (represented as decimal numerics).
% The output is the generated codeword represented as n-bit char array.
%
% Author: Clayton Schoeny and Mark Gottshco
% Email: cschoeny@gmail.com, mgottscho@ucla.edu

function codeword = hamEnc(message,G)
    codeword = mod(message*G,2);
    codeword = dec2bin(codeword)';
end