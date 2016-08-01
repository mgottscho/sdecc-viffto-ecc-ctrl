function [ G,H ] = getDECTEDCodes( n )

if n~=79 && n~=45
    G=0;
    H=0;
    return
end

if n==45
    %First create (63,51,t=2) BCH code:
    g = bchgenpoly(63,51);
    %This comes from inspecting the above result
    g = [1 0 1 0 1 0 0 1 1 1 0 0 1];
    [parmat,genmat,k] = cyclgen(63,g);
    
    %Now add parity bit so that it becomes DECTED
    parmat = [parmat zeros(12,1);
              ones(1,64)];
          
    %Shorten code from (64,51) to (45,32) by deleting 19 columns of H (or just
    %taking the first 45 columns of H.
    H = parmat(:,1:45);
    k=32;
    
    %Make it into systematic form
    H = g2rref(H);
    
    %Want I matrix at end of H
    H = [H(:,n-k+1:45) H(:,1:n-k)];
    
    %Create G
    G = [eye(k) H(:,1:k)'];
end

if n==79
    %First create (63,51,t=2) BCH code:
    g = bchgenpoly(127,113);
    %This comes from inspecting the above result
    g = [1 0 0 0 0 1 1 0 1 1 1 0 1 1 1];
    [parmat,genmat,k] = cyclgen(127,g);


    %Now add parity bit so that it becomes DECTED
    parmat = [parmat zeros(14,1);
              ones(1,128)];


    %Shorten code from (128,114) to (79,64) by deleting 49 columns of H (or just
    %taking the first 79 columns of H.
    H = parmat(:,1:79);
    k=64;
    
    %Make it into systematic form
    H = g2rref(H);
    
    %Want I matrix at end of H
    H = [H(:,n-k+1:79) H(:,1:n-k)];
    
     %Create G
    G = [eye(k) H(:,1:k)'];
end


end

