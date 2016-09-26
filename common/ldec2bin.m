function l=ldec2bin(x)
% Convert decimal uint64 to binary string representation.
%
% Arguments:
%   x -- Double floating value, representing an integer to convert into
%   binary.
%
% Returns:
%   l -- Binary string representation of x.
%
% Authors: Clayton Schoeny and Mark Gottscho
% Email: cschoeny@gmail.com, mgottscho@ucla.edu

if x>2^52
    head=floor(x/2^52);
    tail=x-head*2^52;
    l=[ldec2bin(head),dec2bin(double(tail),52)];
else
    l=dec2bin(double(x));
end

% Clayton's added code
%l = [repmat('0',1,n-length(l)) l];
end