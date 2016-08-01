function [ codeword ] = dected_encoder( message, G )
    codeword = mod(message*G,2);
    codeword = dec2bin(codeword)';
end

