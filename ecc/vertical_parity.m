function [parity] = vertical_parity(cacheline)
% Author: Mark Gottscho <mgottscho@ucla.edu>

words_per_block = size(cacheline,1);
k = size(cacheline,2);
parity = cacheline(1,:);
for i=2:words_per_block
   parity = my_bitxor(parity, cacheline(i,:));
end
