function A = swap_rows(A,i,j)
assert( i > 0 && i < size(A,2) && j > 0 && j < size(A,2) );
A([i j],:) = A([j i],:);