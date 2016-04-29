clear
clc
%% Generate ThreeD
% Code parameters:
n = 39;
k = 32;
r = n-k;

[G,H] = getHamCodes(n);

%All zeroes message
mess = zeros(1,k);

%This vector will hold the sizes of all the equiprobably codewords for each
%(2-error) combination.
ThreeD = zeros(72,72);
size_vec=zeros(1,nchoosek(n,2));
count=1;
for i=1:n-1
    for j=i+1:n
        % generate an error:
        err = repmat('0',1,n);
        err(i) = '1';
        err(j) = '1';

        % encode our codeword
        cw = hamEnc(mess,G);

        % receive an word (poss. in error)
        reccw = dec2bin(bitxor(bin2dec(cw), bin2dec(err)), n);
        %reccw = mod(cw+err,2);

        % decode our received codeword
        [decCw, e] = hamDec(reccw,H);

       

            % let's run the decoder through every codeword that flips a bit
            % from the received word.

        idx = 0;
        cwList=[];
        for k=1:n
           cwmod = reccw;
           %cwmod(k) = mod(cwmod(k)+1,2);
           cwmod(k) = dec2bin(bitxor(bin2dec(cwmod(k)), bin2dec('1')), 1);
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
surf(ThreeD)

figure()
eight=ThreeD==8;
eight=double(eight);
spy(eight)
title('8')

figure()
fourteen=ThreeD==14;
fourteen=double(fourteen);
spy(fourteen)
title('14')

figure()
seventeen=ThreeD==17;
seventeen=double(seventeen);
spy(seventeen)
title('17')

figure()
twenty=ThreeD==20;
twenty=double(twenty);
spy(twenty)
title('20')

figure()
twentyfour=ThreeD==24;
twentyfour=double(twentyfour);
spy(twentyfour)
title('24')

figure()
twentyseven=ThreeD==27;
twentyseven=double(twentyseven);
spy(twentyseven)
title('27')


%% Adding up rows

%Fill up ThreeD to ThreeD2
ThreeD2=ThreeD;
for row=1:72
    for col=1:row
        ThreeD2(row,col)=ThreeD(col,row);
    end
end
surf(ThreeD2)


total_row = zeros(1,72);
for row=1:72
    total_row(row) = sum(ThreeD2(row,:));
end

bar(total_row/72)


