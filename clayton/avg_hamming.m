
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

%% Now we call calculate the average Hamming distance of all (8 choose 2)=28 pairs in a cacheline

ham_vec=zeros(1,total_num_cache);

for m=1:total_num_cache
    ham_vec(m)=avg_ham_cache(cache_line(:,m));
end


