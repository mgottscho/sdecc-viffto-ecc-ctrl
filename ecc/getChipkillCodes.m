function [ G, H ] = getChipkill( n )
%This function returns the G and H matrices for ChipKill.  There is only
%current support for the (144,128) SSCDSD, which symbol size 4-bits.  We
%start with the matrix from "Single Byte Error Correcting-Double Byte Error
%Detecting Codes for Memory Systems" -- Kaneda, Fujiwara -- IEEE Trans. on
%Computers 1982.  We start with the matrix in Fig. 4 which is the "optimal"
%S4EC-D4ED in terms on 1's in H (reduces implementation logic).
%Then we convert it to systematic form. 
% 
% Author: Clayton Schoeny
% Email: cschoeny@gmail.com

% so far we only support the (144,128) codes:
if n ~= 144
   G=0;
   H=0;
   return;
end

%Primitive polynomial is g(x)=x^4+x+1
T = [0 0 0 1;
    1 0 0 1;
    0 1 0 0;
    0 0 1 0];

Z = zeros(4,4);
I = eye(4);

%Matrix in Fig. 4 from Kaneda1982
H = [I I I I     I I I I    I    Z Z Z Z    Z Z Z Z    Z    mod(T^3,2) mod(T^2,2) T I    mod(T^14,2) mod(T^13,2) mod(T^12,2) mod(T^11,2)    Z    mod(T^11,2) mod(T^12,2) mod(T^13,2) mod(T^14,2)    I T mod(T^2,2) mod(T^3,2)    Z;
    mod(T^11,2) mod(T^12,2) mod(T^13,2) mod(T^14,2)    I T mod(T^2,2) mod(T^3,2)    Z    I I I I     I I I I    I    Z Z Z Z    Z Z Z Z    Z    mod(T^3,2) mod(T^2,2) T I    mod(T^14,2) mod(T^13,2) mod(T^12,2) mod(T^11,2)    Z;
    mod(T^3,2) mod(T^2,2) T I     mod(T^14,2) mod(T^13,2) mod(T^12,2) mod(T^11,2)    Z    mod(T^11,2) mod(T^12,2) mod(T^13,2) mod(T^14,2)    I T mod(T^2,2) mod(T^3,2)    Z    I I I I     I I I I    I    Z Z Z Z    Z Z Z Z    Z;
    Z Z Z Z    Z Z Z Z    Z    mod(T^3,2) mod(T^2,2) T I     mod(T^14,2) mod(T^13,2) mod(T^12,2) mod(T^11,2)    Z    mod(T^11,2) mod(T^12,2) mod(T^13,2) mod(T^14,2)    I T mod(T^2,2) mod(T^3,2)    Z    I I I I     I I I I    I];

%Convert to systematic form
%The final eye matrix is in 4 parts.  The last part is alread in the final
%position.
%First, swap columns 105:108 with 137:140
H(:,[105:108 137:140]) = H(:,[137:140 105:108]);
%Second, swap columns 69:72 with 133:136
H(:,[69:72 133:136]) = H(:,[133:136 69:72]);
%Last, swap columns 33:36 with 129:132
H(:,[33:36 129:132]) = H(:,[129:132 33:36]);
%Our H is now in systematic form. Also note that all we did was permute
%columns, so this is still optimal in the "Hsaio" sense of having the
%minimum number of 1's in the H-matrix.

%Now, since H is in the form [P,I], we can simply get G=[I,P^T];
G=[eye(128) H(:,1:128)'];

end

