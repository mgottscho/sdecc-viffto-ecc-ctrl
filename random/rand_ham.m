clear
clc

n=8;
k=4;

size=2000;
vec=zeros(1,size);
weight_4=zeros(n-k,n,1);
count=0;
for i=1:size
    H = randi([0 1],n-k,n);
    vec(i)=gfweight(H,'par');
    if vec(i)==4
        count=count+1;
         weight_4(:,:,count)=H;  
    end
end

