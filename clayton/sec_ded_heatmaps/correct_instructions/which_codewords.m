clear
clc

% Code parameters:
n = 39;
k = 32;
r = n-k;
[G,H]=getHamCodes(n);


%Error vector:
err = zeros(1,n);
   
err(1) = 1;
err(2) = 1;


%Message
mess = zeros(1,k);



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
[equidistant,tmp] = size(unique(cwList,'rows'));
equidistant
final_list = unique(cwList,'rows');
spy(final_list)