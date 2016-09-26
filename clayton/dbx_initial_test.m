clear
clc


%Assume that here the 8 64-bit words are in hex from a cache line.
%The following is just an example, in the real function we would read these
%in.

cache_line=['0000000000000000';
        '0300000000000000';
        '58b1c03f00000000';
        '00c0820000000000';
        '00d09c1100000000';
        'a000c03f00000000';
        '00c00c0000000000';
        '4c1c000000000000'];
    
orig_hex = cellstr(cache_line);

%First convert everthing to binary
%The orig_bin cell is essentially the transpose of the 'Data block' in
%Fig 1.c
orig_bin=[];
for k=1:8
    orig_bin{k,1}=my_hex2bin(orig_hex{k});
end

%Also get orig in decimal
orig_dec=[];
for k=1:8
    orig_dec{k,1}=my_bin2dec(orig_bin{k});
end

%Now we get the delta matrix in decimal and convert to binary
%delta_bin is the transpose of 'Delta' in Fig 1.c
%In the following for loop, special care is taken care of in the delta
%function since the result can be negative.
delta_dec=[];
delta_bin=[];
delta_dec{1}=orig_dec{1};
delta_bin{1}=orig_bin{1};
for k=2:8
    if orig_dec{k}==orig_dec{k-1} %If they are equal then delta=0
        delta_dec{k,1}=0;
        delta_bin{k,1}=ldec2bin(delta_dec{k});
        delta_bin{k,1} = [repmat('0',1,65-length(delta_bin{k,1})) delta_bin{k,1}];
    elseif orig_dec{k}>orig_dec{k-1} %In this case we can subtract normally and add a 0 to the initial digit
        delta_dec{k,1}=orig_dec{k}-orig_dec{k-1};
        delta_bin{k,1}=ldec2bin(delta_dec{k});
        delta_bin{k,1} = [repmat('0',1,65-length(delta_bin{k,1})) delta_bin{k,1}];
    else %In this case we need to subtract the other way, but then convert to 2's compliment
        delta_dec{k,1}=orig_dec{k-1}-orig_dec{k}-1;
        %Now convert to 64-bit binary and flip all the bits
        delta_bin{k,1}=ldec2bin(delta_dec{k});
        delta_bin{k,1} = [repmat('0',1,64-length(delta_bin{k,1})) delta_bin{k,1}];
        delta_bin{k,1}=my_bitxor(delta_bin{k},repmat('1',1,64));
        %Now add the 1 in front
        delta_bin{k,1}=['1' delta_bin{k}];
    end
end


%Now we will perform the XOR function.  Note that the top row doesn't
%change since it's the base symbol. We also transform the cell of strings
%to a binary matrix for ease of analysis

DBX_bin=[];
%First convert the base symbol
for m=1:64
    DBX_bin{1,1}(m)=str2num(delta_bin{1}(m));
end


%Now we XOR through the other rows
for row=2:8
    DBX_bin{row,1}(1)=str2num(delta_bin{row}(1));
    for idx=2:65
        DBX_bin{row,1}(idx)=mod(str2num(delta_bin{row}(idx-1))+str2num(delta_bin{row}(idx)),2);
    end
end

%This DBX_bin represents the final 'Delta-BP-XOR' matrix, where the top row
%of our cell represents the base symbol.

%Now we convert the cell to a matrix
%We need the sizes to be consistent so we add this zero.
DBX_bin{1,1}(65)=0;

DBX_array = cell2mat(DBX_bin);

%Now that we have the final array, there are different ways to analyze it.
%For example, we can see the total number of zeros:
total_zeros = nnz(DBX_array);






