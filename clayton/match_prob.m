function [ result ] = match_prob( matches, total_cc, hash_length )
%Returns the probability that there are 'matches' number of
%candidate codewords out of 'total_cc' that match the correct hash with
%hash length 'hash_length'.
result = binopdf(matches-1,total_cc-1,1/2^(hash_length-1));

end