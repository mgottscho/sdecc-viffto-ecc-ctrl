function [ ent_list ] = entropy_list_col( sym_size, cache_line, cc_list )
%This function receives the following inputs:
%   'sym_size' is the number of cache lines: (39,32) = 16, 64-bit message =
%   8, chipkill = 4.
%   'cache_line' Let this be a single binary vector that includes everything
%       except for the erroneous word in question. So for the (72,64) case, this
%       would be a 1x(7*64) = 1x448 bit vector. 
%   'cc_list' This is a (c x k) matrix, in which there are c candidate
%       codewords of length k.
%The following is the output:
%   'ent_list' is the list of entropies for each corresponding cc_list in
%       the overall cacheline

%Initialize the entropy list
ent_list = zeros(size(cc_list,1),1);

% %First we create the cache_tally vector.
% cache_tally = zeros(1,2^sym_size);

for cc_idx=1:size(cc_list,1)
    % First we add the cc on to the sym_cache
    total_bitline = [cache_line cc_list(cc_idx,:)];
    
    %Then we reshape the matrix so that each word is vertical
    vertical_bitline = reshape(total_bitline,[length(total_bitline)/sym_size,sym_size]);
    
    %Now we put it back together in the proper order
    transformed_bitline = reshape(vertical_bitline',1,length(total_bitline));
    
    %Now convert to symbols
    transformed_sym = zeros(1,length(transformed_bitline)/sym_size);
    for k = 1:length(cache_line)/sym_size
        transformed_sym(k) = my_bi2de(transformed_bitline((k-1)*sym_size+1:k*sym_size));
    end
    
    %Now we make the tally
    values = unique(transformed_sym);
    tmp_tally = zeros(1,length(values));
    for val_idx = 1:length(tmp_tally)
        tmp_tally(val_idx) = nnz(transformed_sym==values(val_idx));
    end
    %Now run entropy function
    ent_list(cc_idx) = entropy_tally(tmp_tally);
    
end




% 
% for cc_idx=1:size(cc_list,1)
%     %First conver to symbols
%     cc_sym = zeros(1,size(cc_list,2)/sym_size);
%     for k = 1:size(cc_list,2)/sym_size
%         cc_sym(k) = bi2de(cc_list(cc_idx,(k-1)*sym_size+1:k*sym_size));
%     end
%     
%     %Now create temporary tally
%     tmp_syms = [sym_cache cc_sym];
% %     for m = 0:2^sym_size-1
% %         tmp_tally(m+1)=tmp_tally(m+1)+sum(cc_sym==m);
% %     end
%     values = unique(tmp_syms);
%     tmp_tally = zeros(1,length(values));
%     for val_idx = 1:length(tmp_tally)
%         tmp_tally(val_idx) = nnz(tmp_syms==values(val_idx));
%     end
%     
%     %Now run entropy function
%     ent_list(cc_idx) = entropy_tally(tmp_tally);
% end

end
   





