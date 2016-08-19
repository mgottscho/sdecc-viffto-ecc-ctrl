clear
clc


%% First test no errors
n=144;
k=128;
b=4; %2^4=16 GF(16)

[G,H]=getChipkill(144);

message = randi([0 1],1,k);
codeword = mod(message*G,2);

tic
transmitted = codeword;
[num, decoded]=chipkill_decode(transmitted,H,4);
if num~=0
    disp('Error in num')
end
if ~isequal(decoded,message)
    disp('Error in decoded')
end
toc
%A single run of the decoder takes ~ 0.0001 seconds.

%% Test all single possible errors

%Here we go through all 36*15=540 possible 1-symbol error patterns to make
%sure that we can correct all of them.  %Note that it doesn't matter what
%the message is, only the error pattern.

%This takes a total of 1.2 seconds, and it successfully corrects all
%single-symbol error patterns.

n=144;
k=128;
b=4; %2^4=16 GF(16)

[G,H]=getChipkill(144);

message = randi([0 1],1,k);
codeword = mod(message*G,2);

err_pattern = [0 0 0 1; 0 0 1 0; 0 0 1 1; 0 1 0 0; 0 1 0 1; 0 1 1 0; 0 1 1 1; 1 0 0 0; 1 0 0 1; 1 0 1 0; 1 0 1 1; 1 1 0 0; 1 1 0 1; 1 1 1 0; 1 1 1 1];

tic
for block=1:36 %error symbol location
    for k1=1:15 %error symbol pattern
        err1 = [zeros(1,4*(block-1)) err_pattern(k1,:) zeros(1,4*(36-block))];
        transmitted = mod(codeword+err1,2);
        [num, decoded]=chipkill_decode(transmitted,H,4);
        if num~=1
            disp('Error in num')
        end
        if ~isequal(decoded,message)
            disp('Error in decoded')
        end
    end
end
toc


%% Test all possible 2-symbol error patterns

%Here we have to go through all 2-symbol error-patterns to make sure that
%we can detect all of them.  There are a total of
%(36 choose 2)*15*15=141,750 2-symbol error patterns.

%This successfully detects all 2-symbol error patterns. It takes ~700
%seconds.

n=144;
k=128;
b=4; %2^4=16 GF(16)

[G,H]=getChipkill(144);

message = randi([0 1],1,k);
codeword = mod(message*G,2);

err_pattern = [0 0 0 1; 0 0 1 0; 0 0 1 1; 0 1 0 0; 0 1 0 1; 0 1 1 0; 0 1 1 1; 1 0 0 0; 1 0 0 1; 1 0 1 0; 1 0 1 1; 1 1 0 0; 1 1 0 1; 1 1 1 0; 1 1 1 1];

tic
for block1=1:35 %first error symbol location
    for block2=block1+1:36 %second error symbol location
        for k1=1:15 %error symbol pattern
            err1 = [zeros(1,4*(block1-1)) err_pattern(k1,:) zeros(1,4*(36-block1))];
            for k2=1:15
                err2 = [zeros(1,4*(block2-1)) err_pattern(k2,:) zeros(1,4*(36-block2))];
                transmitted = mod(codeword+err1+err2,2);
                [num, decoded]=chipkill_decode(transmitted,H,4);
                if num~=2
                    disp('Error in num')
                end
            end
        end
    end
end
toc

%% This is how to generate the list of candidate codewords for a given DUE.

%takes about 2.5 seconds to generate the candidate codeword list for a
%2-symbol DUE.

n=144;
k=128;
b=4; %2^4=16 GF(16)

[G,H]=getChipkill(144);

message = randi([0 1],1,k);
codeword = mod(message*G,2);


%First we introduce 2-symbol errors.
channel_errors = zeros(1,n);
%these errors are in the first symbol
channel_errors(1)=1;
channel_errors(3)=1;
%these errors are in the fourth symbol
channel_errors(13)=1;
channel_errors(14)=1;
channel_errors(15)=1;
channel_errors(16)=1;

transmitted = mod(codeword+channel_errors,2);

err_pattern = [0 0 0 1; 0 0 1 0; 0 0 1 1; 0 1 0 0; 0 1 0 1; 0 1 1 0; 0 1 1 1; 1 0 0 0; 1 0 0 1; 1 0 1 0; 1 0 1 1; 1 1 0 0; 1 1 0 1; 1 1 1 0; 1 1 1 1];
%Now we go through and introduce all 36*15=540 possible 1-symbol errors to
%get the list of candidate codewords.
cc_list=[];
tic
for block3=1:36
    for k3=1:15
        err3 = [zeros(1,4*(block3-1)) err_pattern(k3,:) zeros(1,4*(36-block3))];
        test_vec = mod(transmitted+err3,2);
        [num, decoded]=chipkill_decode(test_vec,H,4);
        if num==1
            cc_list = [cc_list; decoded];
        end
    end
end
%Get unorded unique list
cc_list = unique(cc_list,'rows');
toc

%% This is the code to get the average number of CC per DUE
% However, don't run it since it will take ~150 hours or so.
% We need to go through each possibility, which is:
% (36 choose 2)*15*15*36*15 = 7,545,000

n=144;
k=128;
b=4; %2^4=16 GF(16)

[G,H]=getChipkill(144);

message = randi([0 1],1,k);
codeword = mod(message*G,2);

cc_list = zeros(35,36,15,15);

for block1=1:35
    for block2 = block1+1:36
        for k1 = 1:15
            for k2 = 1:15
                err1 = [zeros(1,4*(block1-1)) err_pattern(k1,:) zeros(1,4*(36-block1))];
                err2 = [zeros(1,4*(block2-1)) err_pattern(k2,:) zeros(1,4*(36-block2))];
                %Now that we have our DUE, we need to go through each of
                %the possible 1-symbol bitflip solutions
                cc_tmp=[];
                for block3 = 1:36
                    for k3 = 1:15
                        err3 = [zeros(1,4*(block3-1)) err_pattern(k3,:) zeros(1,4*(36-block3))];
                        transmitted = mod(codeword+err1+err2+err3,2);
                        [num_symbol_err, decoded_codeword] = chipkill_decode(transmitted,H,4);
                        if num_symbol_err == 1
                            cc_tmp = [cc_tmp; decoded_codeword];
                        end
                    end
                end
                [cc_num,tmp] = size(unique(cc_tmp,'rows'));
                cc_list(block1,block2,k1,k2)=cc_num;
            end
        end     
    end
end
avg_cc = sum(sum(sum(sum(cc_list))))/nnz(cc_list);

