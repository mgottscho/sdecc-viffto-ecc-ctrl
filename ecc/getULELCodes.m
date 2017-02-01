function [G, H] = getULELCodes(n,code_type)
% This function returns the generator (G) and parity-check (H) matrices
% for an unequal-length error-locating (ULEL) code with specified length-k message bits, number of redundancy bits, and type of code.
%
% Input arguments:
%   n --                Scalar: [17|18|19|33|34|35]
%   code_type --        String: '[ULEL_float|ULEL_ULEL_even]'. If r == 1 or 3 then this is always treated as 'ULEL_even'
%
% Returns:
%   G --                Matrix: k x n over GF(2)
%   H --                Matrix: (n-k) x n over GF(2)
%
% Authors: Clayton Schoeny and Mark Gottscho
% Email: cschoeny@gmail.com, mgottscho@ucla.edu


%% First, make sure input arguments are valid.
if (n~=17) && (n~=18) && (n~=19) && (n~=33) && (n~=34) && (n~=35)
    G=0;
    H=0;
    return;
end
if (n==17) || (n==18) || (n==19)
    k = 16;
elseif (n==33) || (n==34) || (n==35)   
    k = 32;
end
r = n-k;
if (~strcmp(code_type,'ULEL_float')) && (~strcmp(code_type,'ULEL_even'))
    G=0;
    H=0;
    return;
end

%% Single redundancy bit (parity)
if (r==1)
    H = ones(1,k+1);
    G = [eye(k) ones(k,1)];

%% Two redundancy bits -- 3 segments of arbitary size.
elseif (r==2)
    c=[1 1]';
    a=[0 1]';
    b=[1 0]';
    if (k==16)
        if strcmp(code_type,'ULEL_even')
            H = [c c c c c a a a a a b b b b b b eye(2)];
            G = [eye(16) H(:,1:16)']; 
        elseif strcmp(code_type,'ULEL_float')
            H = [c a a a a a b b b b b b b b b b eye(2)];
            G = [eye(16) H(:,1:16)'];
        end
    elseif (k==32)
        if strcmp(code_type,'ULEL_even')
            H = [c c c c c c c c c c a a a a a a a a a a a b b b b b b b b b b b eye(2)];
            G = [eye(32) H(:,1:32)'];
        elseif strcmp(code_type,'ULEL_float')
            H = [c a a a a a a a a b b b b b b b b b b b b b b b b b b b b b b b eye(2)];
            G = [eye(32) H(:,1:32)'];
        end
    end

%% Three redundancy bits -- 7 segments of arbitrary size.
elseif (r==3)
    a=[0 0 1]';
    b=[0 1 0]';
    c=[0 1 1]';
    d=[1 0 0]';
    e=[1 0 1]';
    f=[1 1 0]';
    g=[1 1 1]';

    % We assume always even sizes
    if (k==16)
        H = [e e c c d d b b a a f f f g g g eye(3)];
        G = [eye(16) H(:,1:16)'];
    elseif (k==32)
        H = [a a a a b b b b d d d d c c c c c e e e e e f f f f f g g g g g eye(3)];
        G = [eye(32) H(:,1:32)'];
    end
end


end
