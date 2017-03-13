function [hash_filtered_candidates, retval] = hash_filter_candidates(candidates, cacheline, blockpos, hash_size, correct_hash)
% Arguments:
%    candidates -- Binary string matrix
%    cacheline -- Binary string matrix
%    blockpos -- Scalar
%    hash_size -- Scalar: [4|8|16]
%    correct_hash -- Number
%
% Returns:
%    filtered_candidates
%    retval -- Boolean 1 or 0. 0 on success.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

retval = -1;
num_candidates = size(candidates,1);
k = size(candidates,2); % TODO: should this include parity bits, and hence be n?
hash_filtered_candidates = repmat('X',1,k);
x = 1;
candidate_cacheline = cacheline;
for i=1:num_candidates
    candidate_cacheline(blockpos,:) = candidates(i,:);
    serialized_cc = reshape(candidate_cacheline',1,size(candidate_cacheline,1)*size(candidate_cacheline,2));
    hash = pearson_hash(serialized_cc-'0',hash_size);
    if hash == correct_hash
        hash_filtered_candidates(x,:) = candidates(i,:);
        x = x+1;
    end
end

retval = 0;
