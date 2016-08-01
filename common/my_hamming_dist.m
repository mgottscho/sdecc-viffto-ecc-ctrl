function [dist] = my_hamming_dist(bin1,bin2)
% Compute the Hamming distance between two binary strings comprised of '0' and '1' characters. Argument sizes must be matched.
%
% Arguments:
%   bin1 --   String of k characters, where each is either '0' or '1'.
%   bin2 --   String of k characters, where each is either '0' or '1'.
%
% Returns:
%   dist --   Scalar representing the Hamming distance between bin1 and bin2. Upon error, dist is set to -1.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

%% Input dimension check
if size(bin1) ~= size(bin2)
    dist = -1;
    return;
end

%% Check input validity to ensure each character is either '0' or '1' and no other value
if (sum(bin == '1')+sum(bin == '0')) ~= size(bin,2)
    dist = -1;
    return;
end

%% Compute Hamming distance
dist = size(bin1,2); % Init to max distance
for i=1:size(bin1,2)
    if bin1(i) == bin2(i)
        dist = dist-1;
    end
end

end
