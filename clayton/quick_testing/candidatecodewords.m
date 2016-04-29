clear
clc

% Code parameters:
n = 39;
k = 32;
r = n-k;
[G,H]=getHamCodes(n);

for i=1:n-1
    for j=i:n
iter=100;
count=1;
size_vec=zeros(1,iter);

%Error vector:
err = zeros(1,n);
% i=randi([1 n]);
% j=randi([1 n]);
% assert(i~=j)
    
err(i) = 1;
err(j) = 1;

for m=1:iter
%Message
mess = randi([0 1],1,k);



% encode our codeword
cw = hamEnc(mess,G);

% receive an word (poss. in error)
reccw = mod(cw+err,2);

% decode our received codeword
[decCw, e] = hamDec(reccw,H);        

        
% let's run the decoder through every codeword that flips a bit
% from the received word.

idx = 0;
cwList=[];
for p=1:n
   cwmod = reccw;
   cwmod(p) = mod(cwmod(p)+1,2);
   [decCwmod, e] = hamDec(cwmod,H);
    if (e==1)
        idx=idx+1;
        cwList(idx,:) = decCwmod;
    end
end
by_two=size(cwList)/2;
[equidistant,tmp] = size(unique(cwList,'rows'));
equidistant;
size_vec(count)= equidistant;
count=count+1;
end
assert(max(size_vec)==min(size_vec))
i
    end
end