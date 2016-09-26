function [DBX_bin, delta_bin] = dbx_transform(cacheline)
% Perform the Delta-Bitplane-XOR transform from Kim et al. ISCA 2016:
% "Bit-Plane Compression: Transforming Data for Better Compression in Many-core Architectures"
%
% Arguments:
%   cache_line -- Nxk matrix of characters. Each character is either '0' or '1'. Cache line size is thus N
%       * k bits in total.
%
% Returns:
%   DBX_bin -- Nx(k+1) matrix of characters. Each character is either '0' or
%       '1'. The first row corresponds to the "base" k-bit value in DBX
%       transform, with an extra 0 added to pad the MSB. After the first row,
%       each column corresponds to the BP-XOR symbols after the DBX transform.
%
%   delta_bin -- Nx(k+1) matrix of characters. Each character is either '0'
%       or '1'. The first row corresponds to the "base" k-bit value in delta
%       transform, with an extra 0 added to pad the MSB. After the first row,
%       each row corresponds to a delta symbol.
%
% Authors: Clayton Schoeny and Mark Gottscho
% Email: cschoeny@gmail.com, mgottscho@ucla.edu

N = size(cacheline,1);
k = size(cacheline,2);

%% Convert each cacheline entry to decimal uint64 form
cacheline_dec=cell(N,1);
for blockpos=1:N
    cacheline_dec{blockpos,1}=my_bin2dec(cacheline(blockpos,:));
end

%% Now we get the delta matrix in decimal and convert to binary
% In the following for loop, special care is taken care of in the delta
% function since the result can be negative.
delta_dec=[];
delta_bin=[];
delta_dec{1}=cacheline_dec{1};
delta_bin{1}=['0' cacheline(1,:)];
for blockpos=2:N
    if cacheline_dec{blockpos}==cacheline_dec{blockpos-1} %If they are equal then delta=0
        delta_dec{blockpos,1}=0;
        delta_bin{blockpos,1}=ldec2bin(delta_dec{blockpos});
        delta_bin{blockpos,1} = [repmat('0',1,(k+1)-length(delta_bin{blockpos,1})) delta_bin{blockpos,1}];
    elseif cacheline_dec{blockpos}>cacheline_dec{blockpos-1} %In this case we can subtract normally and add a 0 to the initial digit
        delta_dec{blockpos,1}=cacheline_dec{blockpos}-cacheline_dec{blockpos-1};
        delta_bin{blockpos,1}=ldec2bin(delta_dec{blockpos});
        delta_bin{blockpos,1} = [repmat('0',1,(k+1)-length(delta_bin{blockpos,1})) delta_bin{blockpos,1}];
    else %In this case we need to subtract the other way, but then convert to 2's compliment
        delta_dec{blockpos,1}=cacheline_dec{blockpos-1}-cacheline_dec{blockpos}-1;
        %Now convert to 64-bit binary and flip all the bits
        delta_bin{blockpos,1}=ldec2bin(delta_dec{blockpos});
        delta_bin{blockpos,1} = [repmat('0',1,k-length(delta_bin{blockpos,1})) delta_bin{blockpos,1}];
        delta_bin{blockpos,1}=my_bitxor(delta_bin{blockpos},repmat('1',1,k));
        %Now add the 1 in front
        delta_bin{blockpos,1}=['1' delta_bin{blockpos}];
    end
end

delta_bin = cell2mat(delta_bin);

%% Now we will perform the XOR function. Note that the top row doesn't
% change since it's the base symbol. We also transform the cell of strings
% to a binary matrix for ease of analysis

DBX_bin=repmat('X',N,k+1);
DBX_bin(1,:) = delta_bin(1,:);

%% Now we XOR the columns below row 1
DBX_bin(2:end,1) = delta_bin(2:end,1); % First bits are always copied over
for column=2:k+1
   DBX_bin(2:end,column) = my_bitxor(delta_bin(2:end,column-1)', delta_bin(2:end,column)');
end

% This DBX_bin represents the final 'Delta-BP-XOR' matrix, where the top row
% of our cell represents the base symbol.






