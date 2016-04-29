clear
clc
n = 8;
k = 4;

%Parity-check matrix from http://users.ece.utexas.edu/~touba/research/vts07a.pdf
%-----Single Error Correcting
%-----Double Error Detecting
%-----Double Adjacent Error Correcting
H = [1     0     1     0     0     1     0     1;
     1     1     0     1     0     0     0     1;
     1     0     1     1     1     0     0     0;
     1     1     1     1     1     1     1     1];
 
 %Message (all zeros since the relevant stats are only dependent on the
 %error locations, not the message itself.
 m = zeros(1,n);
 %This holds the number of equiprobable codewords in each of the 2556
 %possible double error patterns.
size_vec=zeros(1,nchoosek(n,2));
count=1;
ThreeD = zeros(8,8);
 
 for i=1:n-1
     for j=i+1:n
        %generate a double error
        err = zeros(1,n);
        err(i) = 1;
        err(j) = 1;
        %reset the number of equiprobable codewords for each error pattern.
        equidistant=0;
        %Now we go through each possible double flip to see all the
        %codewords that are 2 away.
        for a=1:n-1
            for b=a+1:n
                r=err;
                r(a)=mod(r(a)+1,2);
                r(b)=mod(r(b)+1,2);
                s=mod(r*H',2);
                if nnz(s)==0
                    equidistant=equidistant+1;
                end
            end
        end
        size_vec(count)=equidistant;
        count=count+1;
        ThreeD(i,j)=equidistant;
     end
 end
 
G=null2(H)';

%% list codewords
for d=0:15
    mod(de2bi(d,4)*G,2)
end

