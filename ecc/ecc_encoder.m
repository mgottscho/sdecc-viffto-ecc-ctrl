function [codeword] = ecc_encoder(message,G)
% ECC Encoder
%
% Input arguments:
%   message --         String: 1xk character array, each entry is '0' or '1'
%   G --               Matrix: kxn decimal matrix with 0 or 1 entries that
%   corresponds to an ECC generator matrix (e.g. SECDED, DECTED, etc.)
%
% Returns:
%   codeword --        String: 1xn character array, each entry is '0' or '1' UNLESS encoding fails, in which case it is repeated 'X'
%
% Authors: Clayton Schoeny and Mark Gottscho
% Email: cschoeny@gmail.com, mgottscho@ucla.edu

k = size(G,1);
n = size(G,2);

codeword = repmat('X',1,n);

%% Dimension check
if k > n
    return;
end

%% Check input validity to ensure each character is either '0' or '1' and no other value
if (sum(message == '1')+sum(message == '0')) ~= size(message,2)
    return;
end

%% Check message size is k
if size(message,2) ~= k
    return;
end

% FIXME? Will this code work with k >= 64?
codeword = mod(message*G,2);
codeword = dec2bin(codeword)';

end
