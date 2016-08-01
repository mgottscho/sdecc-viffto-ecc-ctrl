function [dist] = my_hamming_dist(bin1,bin2)

dist = size(bin1,2); % Init to max distance
for i=1:size(bin1,2)
    if bin1(i) == bin2(i)
        dist = dist-1;
    end
end

end
