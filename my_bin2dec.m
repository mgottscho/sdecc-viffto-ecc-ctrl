function [dec] = my_bin2dec(bin)
% From http://stackoverflow.com/questions/32334748/convert-64-bit-numbers-from-binary-to-decimal-using-uint64

v = uint64(length(bin)-1:-1:0);
base = uint64(2).^v;
dec = sum(uint64(base.*(uint64(bin-'0'))), 'native');

end

