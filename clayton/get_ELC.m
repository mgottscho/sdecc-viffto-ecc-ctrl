function [ G,H ] = get_ELC(r)
%ELC code for RISC-V.
%r is the number of redundancy bits
%For r=1, it is just a single parity-bit.
%For r=2, the error-segments are the Type-U type
%For r=3, the error-segments are the Type-R4 type
%For r=2, only the opcode is 'unshared' with the parity bits, and for r=3,
%its the least significant 4 regions.

if (r~=1) && (r~=2) && (r~=3)
    disp('Not valid redundancy')
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
    H = [a a a a a a a a a a a a a a a a a a a a b b b b b c c c c c c c eye(2)];
    G = [eye(32) H(:,1:32)'];
elseif (r==3) %three redundancy bits
    a=[0 0 1]';
    b=[0 1 0]';
    c=[0 1 1]';
    d=[1 0 0]';
    e=[1 0 1]';
    f=[1 1 0]';
    g=[1 1 1]';
    H = [a a a a a b b d d d d d c c c c c e e e f f f f f g g g g g g g eye(3)];
    G = [eye(32) H(:,1:32)'];
end

end

