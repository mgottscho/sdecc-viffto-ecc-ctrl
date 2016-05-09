clear
clc

% Code parameters:
n = 39;
k = 32;
r = n-k;
[G,H]=getHamCodes(n);

%All zeroes message
mess = zeros(1,k);

%This vector will hold the sizes of all the equiprobably codewords for each
%(2-error) combination.
ThreeD = zeros(n,n);
size_vec=zeros(1,nchoosek(n,2));
count=1;
for i=1:n-1
    for j=i+1:n
        equidistant=0;
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
        tmp_row = (unique(cwList,'rows'));
        dist_instr = tmp_row(:,1:6);
        for pp=1:size(dist_instr)
            if (nnz(dist_instr(pp,:))==0)
                equidistant=equidistant+1;
            end
        end
        %[equidistant,tmp] = size(unique(dist_instr,'rows'));
        size_vec(count)= equidistant;
        count=count+1;
        ThreeD(i,j)=equidistant;
    end
end

%% Generate Plot
figure()
%surf(ThreeD)
%pcolor(ThreeD)
%imagesc(ThreeD)
pcolor([zeros(1,40); ThreeD, zeros(39,1)]);
