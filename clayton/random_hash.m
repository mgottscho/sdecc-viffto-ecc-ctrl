function [ hash ] = random_hash( word )
%This produces a hash in which each data bit is involved in exactly 2 check
%equations, and each check equation is size 16.

idx = [randperm(64) randperm(64)];
%idx = [36,34,33,37,46,64,26,23,22,29,54,51,43,1,3,53,44,39,25,42,16,20,48,55,52,63,24,17,8,4,30,58,6,57,2,40,15,19,12,9,27,38,61,41,35,56,18,47,60,28,11,14,59,5,10,49,7,62,32,45,31,13,50,21,38,2,64,21,47,46,51,19,17,13,25,26,57,48,24,7,45,1,4,28,54,6,32,58,11,42,14,37,36,10,43,16,22,62,33,34,8,27,60,50,41,63,12,29,20,9,18,40,53,49,3,5,56,31,35,61,39,23,52,44,59,15,30,55];

%time to build our H-matrix
H = zeros(8,64);
for k=1:8
        H(k,idx((k-1)*16+1:k*16)) = 1; 
end

hash = mod(word*H',2);

end

