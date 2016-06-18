function [out] = my_bitxor(bin1,bin2)

out = bin1;
for i=1:size(bin1,2)
    if bin1(i) == '0' && bin2(i) == '0'
        out(i) = '0';
    elseif bin1(i) == '1' && bin2(i) == '0'
        out(i) = '1';
    elseif bin1(i) == '0' && bin2(i) == '1'
        out(i) = '1';
    elseif bin1(i) == '1' && bin2(i) == '1'
        out(i) = '0';
    else
        out(i) = 'Z'; % Error
    end
end

end

