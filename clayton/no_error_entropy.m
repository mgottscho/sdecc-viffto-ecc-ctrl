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

% Choose the symbol size for the entropy
sym_size=8;
cache_words = size(cache_line,1); %this should usually just be 8
n=72;
k=64;

%% run test
tic
trials=length(input_filename); %this is all of them
entropy_vals = zeros(1,trials);

for cache_idx=1:trials %1:trials %this loops over all of our caches
    %For a specific cache line, let us first convert to binary vector format
    cache_bin = zeros(cache_words,k); %assume 64-bits per word for now
    for word_idx=1:cache_words
        cache_bin(word_idx,:) = my_hex2bin(cache_line{word_idx,cache_idx}) - '0';
    end
    entropy_vals(cache_idx) = entropy_list(sym_size,cache_concat(cache_bin,1),cache_bin(1,:));
end
toc
%% plot