function [ ent_list ] = entropy_list( sym_size, cache_line, cc_list )
%This function receives the following inputs:
%   'sym_size' is the size of the symbols in bits for the entropy calculation. Make
%       sure that the candidate codeword is divisibly by this number. Good
%       choices include 1, 2, 4, 8.
%   'cache_line' Let this be a single binary vector that includes everything
%       except for the erroneous word in question. So for the (72,64) case, this
%       would be a 1x(7*64) = 1x448 bit vector. 
%   'cc_list' This is a (c x k) matrix, in which there are c candidate
%       codewords of length k.
%The following is the output:
%   'ent_list' is the list of entropies for each corresponding cc_list in
%       the overall cacheline
%
% Author: Clayton Schoeny <cschoeny@gmail.com>

%Initialize the entropy list
ent_list = zeros(size(cc_list,1),1);

% %First we create the cache_tally vector.
% cache_tally = zeros(1,2^sym_size);


%Now we convert cache_line to symbols
sym_cache = zeros(1,length(cache_line)/sym_size);
for k = 1:length(cache_line)/sym_size
    sym_cache(k) = my_bi2de(cache_line((k-1)*sym_size+1:k*sym_size));
end


%Now we fill out the cache_tally
% for m = 0:2^sym_size-1
%     cache_tally(m+1)=sum(sym_cache==m);
% end


%For each candidate codeword, we convert to symbols, create a temporary tally, and then run the
%entorpy function on it.


for cc_idx=1:size(cc_list,1)
    %First conver to symbols
    cc_sym = zeros(1,size(cc_list,2)/sym_size);
    for k = 1:size(cc_list,2)/sym_size
        cc_sym(k) = my_bi2de(cc_list(cc_idx,(k-1)*sym_size+1:k*sym_size));
    end
    
    %Now create temporary tally
    tmp_syms = [sym_cache cc_sym];
%     for m = 0:2^sym_size-1
%         tmp_tally(m+1)=tmp_tally(m+1)+sum(cc_sym==m);
%     end
    values = unique(tmp_syms);
    tmp_tally = zeros(1,length(values));
    for val_idx = 1:length(tmp_tally)
        tmp_tally(val_idx) = nnz(tmp_syms==values(val_idx));
    end
    
    %Now run entropy function
    ent_list(cc_idx) = entropy(tmp_tally);
end

end
   





