% Random seed
rng('shuffle')

%% First parse the file to get the cache lines
input_filename = 'astar.reads';
display('Reading inputs...');
fid = fopen(input_filename);
file_contents = textscan(fid, '%s', 'Delimiter', ',');
fclose(fid);
file_contents = file_contents{1};
total_num_cache = size(file_contents,1)/18;
%Reshape matrix
file_contents = reshape(file_contents,[18,total_num_cache]);
cache_line = file_contents(11:18,:);
%This is to get rid of the 0x at the beginning of the hex
for m=1:total_num_cache
    for k =1:8
        cellContents = cache_line{k,m};
        % Truncate and stick back into the cell
        cache_line{k,m} = cellContents(3:end);
    end
end
display('Done Reading inputs...');
%At this point, the cache_line is in hex format

%% Let us load the G and H matrices
%% First we load H and G (let's do 72,64 Hsiao Code)
n = 72;
k = 64;
r = n-k;
[G,H]=getHamCodes(n);



%% Now we calculate the entropy per cache line
tic
% Choose the symbol size for the entropy
sym_size=4;

% Initialize counts
crash=0;
recover=0;
MCE=0;


cache_words = size(cache_line,1); %this should usually just be 8

trials=1000;
for cache_idx=1:trials %this loops over all of our caches
    %For a specific cache line, let us first convert to binary vector format
    cache_bin = zeros(cache_words,k); %assume 64-bits per word for now
    for word_idx=1:cache_words
        cache_bin(word_idx,:) = my_hex2bin(cache_line{word_idx,cache_idx}) - '0';
    end
    
    %Now we randomly choose a word to have a DUE
    DUE_idx = randi([1 8]);
    original_mess = cache_bin(DUE_idx,:);
    %Let us calculate the entropy of the cacheline before any errors
    original_entropy = entropy_list(sym_size,cache_concat(cache_bin,DUE_idx),original_mess);
    
    %Now we need to create the error and then get the list of candidate
    %codewords.
    err1=randi([1 n]);
    err2=randi([1 n]);
    while (err2 == err1)
        err2=randi([1 n]);
    end
    err_vec = zeros(1,n);
    err_vec(err1)=1;
    err_vec(err2)=1;
    cw = mod(original_mess*G,2);
    DUE_cw = mod(cw + err_vec,2);
   
    % Find candidate codewords
    idx = 0;
    cwList=[];
    for kk=1:n
       cwmod = DUE_cw;
       cwmod(kk) = mod(cwmod(kk)+1,2);
       [decCwmod, e] = hamDec(cwmod,H);
        if (e==1)
            idx=idx+1;
            cwList(idx,:) = decCwmod;
        end
    end
    cwList = unique(cwList,'rows');
    num_cc = size(cwList,1);
    
    %Now cwList contains all of our candidate codewords. Time to get the
    %list of entropies:
    cur_entropies = entropy_list(sym_size,cache_concat(cache_bin,DUE_idx),cwList);
    
    %find the index of the original_mess in the cwList
    [q, original_pos_cwList] = ismember(cwList, original_mess, 'rows');
    %Now its time to count if we got it right or wrong
    %First, if there are more than 1 tied for minimum then we crash.
    if nnz(cur_entropies==min(cur_entropies))>1
        crash=crash+1;
    elseif find(original_pos_cwList==1) == find(cur_entropies==min(cur_entropies))
        recover = recover+1;
    else
        MCE=MCE+1;
    end
end

%Final percentages:
crash_per = crash/trials
recover_per = recover/trials
MCE_per = MCE/trials

toc
