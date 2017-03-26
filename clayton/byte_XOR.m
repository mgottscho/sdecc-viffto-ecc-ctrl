function [ hash ] = byte_XOR( word )
%Takes in a word (normally 64-bits or 128-bits) and outputs an 8-bit hash
%that is just the XOR of the first bit of every byte, etc.

hash = zeros(1,8);

for k=1:8
    hash(k) = mod(sum(word(k:8:length(word))),2);
end

end

