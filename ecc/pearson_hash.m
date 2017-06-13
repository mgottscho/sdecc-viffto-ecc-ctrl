function [h] = pearson_hash(cc,hash_size)
%We input a binary candidate codeword. For now let it consist of a whole
%number of symbols.
%The output is a single-symbollength binary hash (h).
% Authors: Clayton Schoeny <cschoeny@gmail.com> and Mark Gottscho <mgottscho@ucla.edu>


%First find the number of symbols in the cc.
total_symbols = length(cc)/hash_size;

%Initialize the hash table. This is just 0-255 in a random order.
%T = randperm(256)-1;
if hash_size == 16
    T=importdata('T16.mat','T');
elseif hash_size == 8
    T=[112,88,163,233,21,29,11,250,164,23,141,81,159,80,135,108,179,101,116,230,154,24,254,110,217,149,225,44,137,85,155,125,57,5,129,124,58,104,0,90,43,94,165,207,19,122,175,138,213,34,173,205,66,200,224,49,206,208,102,203,243,160,238,136,139,152,63,67,61,51,59,218,118,255,221,231,96,123,40,22,75,171,226,201,185,210,92,27,227,89,146,47,65,194,132,70,161,248,176,148,191,78,31,151,17,247,117,134,153,219,140,6,228,212,120,209,183,30,216,109,36,184,100,169,239,87,202,69,3,182,236,244,145,35,144,45,52,229,186,187,133,242,93,82,193,106,241,170,56,73,128,197,79,86,158,237,127,72,48,199,220,95,222,68,131,198,245,177,190,37,168,166,97,42,18,10,14,246,41,174,98,26,53,20,38,223,235,167,16,172,99,50,77,39,76,15,32,113,181,83,178,150,8,91,189,33,253,119,4,232,192,62,114,188,162,25,105,71,60,204,12,130,115,126,196,251,54,147,142,214,121,252,103,7,74,211,234,64,180,13,84,195,156,143,28,157,2,55,9,46,111,240,1,215,249,107];
elseif hash_size == 4
    T=[11,3,1,12,5,10,7,13,0,14,8,4,6,2,15,9];
else
    display(['Bad hash size = ' num2str(hash_size)]);
    return;
end

%Initialize the hash value
h = 0;

%Go through hash function
for cur_symbol = 1:total_symbols
    h = my_de2bi(h,hash_size); %convert h to binary vector
    idx = my_bitxor(cc(hash_size*(cur_symbol-1)+1:hash_size*(cur_symbol))+'0',h+'0')-'0'; %this is just bit-wise xor of binary vectors
    h = T(my_bi2de(idx)+1);
end

h = my_de2bi(h,hash_size);

end

