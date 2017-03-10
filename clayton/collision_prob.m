function [ result ] = collision_prob( collisions, total_cc, hash_length )
%Returns the probability that there are 'collisions' number of wrong
%candidate codewords out of 'total_cc' that match the correct hash with
%hash length 'hash_length'.
result = binopdf(collisions,total_cc-1,1/2^hash_length);

end