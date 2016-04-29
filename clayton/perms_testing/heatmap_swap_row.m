clear
clc

% Code parameters:
n = 39;
k = 32;
r = n-k;
[G,H]=getHamCodes(n);

%% Permutation of H and G matrices
%Going to swap row 1 and 2 of H matrix (same as swapping cols on P in G)
col_perm = [1:32 34 33 35:n];
%col_perm = [1:4 10 6:9 5 11:n];
%col_perm = [1:4 15 6:9 5 11:14 10 16:n];

tmpG = G(:,col_perm);
G = tmpG;

H = [G(:,33:n)' eye(r)];




%% Run all errors
%All zeros message -> codeword.
mess = zeros(1,k);

%This vector will hold the sizes of all the equiprobably codewords for each
%(2-error) combination.
ThreeD = zeros(n,n);
size_vec=zeros(1,nchoosek(n,2));
count=1;
for i=1:n-1
    for j=i+1:n
        % generate an error:
        err = zeros(1,n);
        err(i) = 1;
        err(j) = 1;

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
        for k=1:n
           cwmod = reccw;
           cwmod(k) = mod(cwmod(k)+1,2);
           [decCwmod, e] = hamDec(cwmod,H);
            if (e==1)
                idx=idx+1;
                cwList(idx,:) = decCwmod;
            end
        end
        [equidistant,tmp] = size(unique(cwList,'rows'));
        size_vec(count)= equidistant;
        count=count+1;
        ThreeD(i,j)=equidistant;
    end
end

%% Generate Plot
figure()
pcolor(ThreeD+ThreeD')

