function [reversed_word] = reverse_byte_order(word)
% Convert a character string representing a hexadecimal value from big
% endian to little endian or vice versa.
%
% Arguments:
%    word -- String of hexadecimal characters, e.g. 'deadbeef'.
%
% Returns:
%    reversed_word -- String of hexadecimal characters, e.g.
%    'efbeadde'. On error, set to string of Xes, e.g. 'XXXX....XXXX'.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

%reversed_word = repmat('X',1,size(word,2));
% commented out for speed
num_chars = size(word,2);
% commented out for speed
%if mod(num_chars,2) ~= 0 % Check for even number of chars
%    return;
%end

for i=1:2:num_chars
    reversed_word(i) = word(num_chars-i);
    reversed_word(i+1) = word(num_chars-i+1);
end

end

