function cache_stream = cache_concat(cache_line,DUE_word)
%we take a 8x64 binary vector and return a single vector of the entire
%thing without the DUE_word.  just the side_information.
cache_stream=[];
for k=1:8
    if k==DUE_word
        continue
    end
    cache_stream = [cache_stream cache_line(k,:)];
end

end