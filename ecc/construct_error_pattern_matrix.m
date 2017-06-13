function [error_patterns] = construct_error_pattern_matrix(n, code_type)
%% Construct a matrix containing all possible DUE error patterns as bit-strings.
%
% Input arguments:
%
%   n --                String: '[17|18|19|33|34|35|39|45|72|79|144]'
%   code_type --        String: '[hsiao|davydov1991|bose1960|kaneda1982|ULEL_float|ULEL_even|ULEL_riscv]'
%
% Returns:
%   error_patterns --   num_error_patterns list of n-char binary patterns 
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

if strcmp(code_type,'hsiao1970') == 1 || strcmp(code_type,'davydov1991') == 1 % SECDED: DUE is t+1 bit error
    num_error_patterns = nchoosek(n,2);
    error_patterns = repmat('0',num_error_patterns,n);
    num_error = 1;
    for i=1:n-1
        for j=i+1:n
            error_patterns(num_error, i) = '1';
            error_patterns(num_error, j) = '1';
            num_error = num_error + 1;
        end
    end
elseif strcmp(code_type,'bose1960') == 1 % DECTED: DUE is t+1 bit error
    num_error_patterns = nchoosek(n,3);
    error_patterns = repmat('0',num_error_patterns,n);
    num_error = 1;
    for i=1:n-2
        for j=i+1:n-1
            for l=j+1:n
                error_patterns(num_error, i) = '1';
                error_patterns(num_error, j) = '1';
                error_patterns(num_error, l) = '1';
                num_error = num_error + 1;
            end
        end
    end
elseif strcmp(code_type,'kaneda1982') == 1 % ChipKill: DUE is t+1 symbol error
    num_error_patterns = nchoosek(n/4,2) * 15^2;
    error_patterns = repmat('0',num_error_patterns,n);
    sym_error_patterns = dec2bin(1:15);
    num_error = 1;
    for sym1=1:n/4-1
        for sym2=sym1:n/4
            for sym1_error_index=1:size(sym_error_patterns,1)
                for sym2_error_index=1:size(sym_error_patterns,1)
                    error_patterns(num_error,(sym1-1)*4+1:(sym1-1)*4+4) = sym_error_patterns(sym1_error_index,:);
                    error_patterns(num_error,(sym2-1)*4+1:(sym2-1)*4+4) = sym_error_patterns(sym2_error_index,:);
                    num_error = num_error+1;
                end
            end
        end
    end
elseif strcmp(code_type,'ULEL_float') == 1 || strcmp(code_type,'ULEL_even') == 1 || strcmp(code_type,'ULEL_riscv') == 1 % ULEL: DUE is 1-bit error
    % Identity matrix
    error_patterns = repmat('0',n,n);
    for i=1:n
        error_patterns(i,i) = '1';
    end
    num_error_patterns = n;
else
    display(['FATAL! Unsupported code type: ' code_type]);
    return;
end

