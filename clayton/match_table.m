%In this scrpit we create a table for a specific code.
%Each column is for a different size hash, (in powers of 2)
%Each row represents the number of candidate codewords that have match the
%original hash.
%The entry itself is the probability.

%% Load (72,64) Hsiao Code
total_cc = nchoosek(72,2); %2556
num_cc = [8 14 17 20 24 27];
prob_cc = [8 168 272 1400 384 324]./total_cc;

%% Load (72,64) Davydov Code
% total_cc = nchoosek(72,2); %2556
% num_cc = (15:27);
% prob_cc = [15 80 272 252 380 400 399 198 161 168 125 52 54]./total_cc;

%% Load (79, 64) DECTED (my own creation)
% total_cc = nchoosek(79,3); %79079
% num_cc = (1:12);
% prob_cc = [148 1648 6255 15548 20095 16938 10885 4800 1773 800 165 24]./total_cc;

%% Load Chipkill
% total_cc = nchoosek(36,2)*15*15; %161280
% num_cc = (1:9);
% prob_cc = [18120 28440 32940 28860 18750 8640 3780 1680 540]./total_cc;

%% Create table
table = zeros(8,5); %so this is 1:8 down and 1,2,4,8,16 across

hash_size = [1 2 4 8 16];

for c=1:length(hash_size);
    for r=1:size(table,1)
        for m=1:length(num_cc)
            table(r,c) = table(r,c)+match_prob(r,num_cc(m),hash_size(c))*prob_cc(m);
        end
    end
end