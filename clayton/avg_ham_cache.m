function [ result ] = avg_ham_cache( x )
%x (8x1) contains the cache line strings already in hex (cell) form

%First conver the hex to bin
%y = my_hex2bin(x{1});
y = char(x);
for j=1:8
    z(j,:)=my_hex2bin(y(j,:));
end

total=0;
for f=1:7
    for s=f+1:8
        total=total+my_hamming_dist(z(f,:),z(s,:));
    end
end
result = total / 28;

end

