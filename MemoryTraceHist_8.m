clear
clc

% Code parameters:
n = 8;
k = 4;
r = n-k;

%All zeroes message
mess = zeros(1,k);

%This vector will hold the sizes of all the equiprobably codewords for each
%(2-error) combination.
size_vec=zeros(1,nchoosek(n,2));
count=1;
for i=1:n-1
    for j=i+1:n
        % generate an error:
        err = zeros(1,n);
        err(i) = 1;
        err(j) = 1;

        % encode our codeword
        cw = hamEnc(mess);

        % receive an word (poss. in error)
        reccw = mod(cw+err,2);

        % decode our received codeword
        [decCw, e] = hamDec(reccw);

       

            % let's run the decoder through every codeword that flips a bit
            % from the received word.

        idx = 0;
        cwList=[];
        for k=1:n
           cwmod = reccw;
           cwmod(k) = mod(cwmod(k)+1,2);
           [decCwmod, e] = hamDec(cwmod);
            if (e==1)
                idx=idx+1;
                cwList(idx,:) = decCwmod;
            end
        end
        [equidistant,tmp] = size(unique(cwList,'rows'));
        size_vec(count)= equidistant;
        count=count+1
    end
end