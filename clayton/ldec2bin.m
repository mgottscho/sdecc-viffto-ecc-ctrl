function l=ldec2bin(x)
if x>2^52
    head=floor(x/2^52);
    tail=x-head*2^52;
    l=[ldec2bin(head),dec2bin(double(tail),52)];
else
    l=dec2bin(double(x));
end

%my added code
%l = [repmat('0',1,n-length(l)) l];
end