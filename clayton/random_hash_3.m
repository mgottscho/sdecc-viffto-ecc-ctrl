function [ hash ] = random_hash_3( word )
%random hash idea but make sure the column weight is 3.

% H = zeros(8,64);
% for k=1:64
%     H(randperm(8,3),k)=1;
% end

H = [0,1,0,0,0,0,1,0,0,1,1,0,0,1,1,1,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,1,1,1,1,0,0,1,0,0,0,0,0,1,1,1,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0;1,0,1,0,1,1,0,0,0,1,0,0,0,0,0,0,1,1,1,0,1,1,0,0,1,0,0,0,1,1,0,1,0,0,0,0,1,0,0,1,0,1,0,0,1,0,0,0,1,0,1,0,1,0,0,1,1,1,0,1,0,0,0,1;0,1,0,0,0,0,0,1,1,0,0,1,1,0,1,1,0,0,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,0,0,0,1,0,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,1,0,1,0,0;1,0,1,1,1,1,0,0,0,1,0,0,0,1,1,0,0,1,0,1,0,0,1,0,1,0,0,1,1,0,1,0,0,0,1,1,0,0,1,0,0,0,1,1,0,0,1,0,1,0,0,0,0,0,1,0,0,1,1,0,1,0,1,1;0,1,0,1,0,0,0,1,0,0,1,1,0,0,0,0,1,1,0,0,1,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,1,1,1,0;1,0,0,0,0,0,1,0,1,0,1,1,0,1,0,0,0,0,1,1,0,0,1,1,0,1,1,1,1,0,0,1,1,0,0,0,1,0,0,0,1,1,0,0,1,1,0,1,0,0,1,1,0,1,0,1,0,0,0,0,0,0,0,0;0,0,0,0,0,1,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,1,0,0,1,0,0,1,0,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,1,0,1,1,0,0,0,0;0,0,1,1,1,0,1,0,1,0,0,0,1,0,0,1,1,0,0,1,1,0,0,0,1,1,1,1,0,1,0,0,0,1,1,0,0,1,0,1,0,1,1,1,0,1,1,1,0,0,0,1,1,1,0,0,0,0,0,0,1,1,0,1];

hash = mod(word*H',2);

end

