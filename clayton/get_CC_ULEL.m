function [ CC_list ] = get_CC_ULEL( H, y )

%This function returns the candidate codewords given an H-matrix and a
%received vector y.

%First we calculate syndrome:
s = mod(H*y',2);

if s==0 %Then no error detected
    CC_list = y;
    return
end

%Now we find columns of H that are the syndrome:
cols = ismember(H',s','rows')';

%The size of our CC_list is the number of 1s in cols.
cc_size = nnz(cols);

%Now we create the error vectors that we will add to the original received
%message to get all of the candidate codewords.
ev = zeros(cc_size,length(y));
one_locs = find(cols==1); %these are the corresponding columns of H that equal the syndrome
for i=1:cc_size
    ev(i,one_locs(i))=1;
end

CC_list = repmat(y,cc_size,1);
CC_list = mod(CC_list+ev,2);

end

