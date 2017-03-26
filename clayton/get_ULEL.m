function [ G,H ] = get_ULEL( k,r,style )

%k is the number of data bits
%r is the number of redundancy bits
%style should either be "float" or "even",  (if r==1 this doesn't matter,
%so just by convention put "even").


%First make sure input arguments are valid.
if (r~=1) && (r~=2) && (r~=3)
    disp('Not valid redundancy')
    G=[];
    H=[];
    return
end
if (k~=16) && (k~=32)
    disp('Not valid message length')
    G=[];
    H=[];
    return
end
if (~strcmp(style,'float')) && (~strcmp(style,'even'))
    disp('Not valid style')
    G=[];
    H=[];
    return
end


if (r==1) %single redundancy bit
        H = ones(1,k+1);
        G = [eye(k) ones(k,1)];
elseif (r==2) %two redundancy bits
    c=[1 1]';
    a=[0 1]';
    b=[1 0]';
    if (k==16)
        if strcmp(style,'even')
            H = [c c c c c a a a a a b b b b b b eye(2)];
            G = [eye(16) H(:,1:16)']; 
        elseif strcmp(style,'float')
            H = [c a a a a a b b b b b b b b b b eye(2)];
            G = [eye(16) H(:,1:16)'];
        end
    elseif (k==32)
        if strcmp(style,'even')
            H = [c c c c c c c c c c a a a a a a a a a a a b b b b b b b b b b b eye(2)];
            G = [eye(32) H(:,1:32)'];
        elseif strcmp(style,'float')
            H = [c a a a a a a a a b b b b b b b b b b b b b b b b b b b b b b b eye(2)];
            G = [eye(32) H(:,1:32)'];
        end
    end
elseif (r==3) %three redundancy bits
    a=[0 0 1]';
    b=[0 1 0]';
    c=[0 1 1]';
    d=[1 0 0]';
    e=[1 0 1]';
    f=[1 1 0]';
    g=[1 1 1]';
    if (k==16)
        H = [e e c c d d b b a a f f f g g g eye(3)];
        G = [eye(16) H(:,1:16)'];
    elseif (k==32)
        H = [a a a a b b b b d d d d c c c c c e e e e e f f f f f g g g g g eye(3)];
        G = [eye(32) H(:,1:32)'];
    end
end


end

