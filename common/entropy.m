function [ H ] = entropy(p)
% p is the tally of number of items. i.e. [5 1 0 0 3 11 0]. This function
% automatically normalizes it to a probability distribution and then
% returns the entropy in bits. 
% Author: Clayton Schoeny <cschoeny@gmail.com>

%First we normalize to a pdf:
p=p./sum(p);

H = sum(-(p(p>0).*(log2(p(p>0)))));


end

