%First attempt at calculating MTTF for ISCA, 10/16/16


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SET PARAMETERS HERE

%beta is the error rate per bit, iid, no memory in system. For now
%log-scale seems to make sense. Change the min and max to better fit what
%other papers and studies do. This is the x-axis
error = linspace(1e-10,1e-3);

%This is the length for the secded codes
n1=72;
%This is our correction rate in the DUE case.
cor1=.8;

% Mark: Length for DECTED
n2=79; 
cor2=0.8;


%This is the length for the sscdsd codes (in bits).
n3=144;
%This is the symbol size in bits of the sscdsd codes.
b=4;
%This is our correction rate in the DUE case.
cor3=.8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%We treat a DUE or a miscorrect as a failure. We can calculate the probability of error for
%SECDED fairly easily. It is 1 minus the probability that we have 0
%bit-errors or 1-bit error. This is a function of n (the code length) and
%e (error rate per bit).
secded = @(n,e) 1 -(1-e).^n -n.*e.*(1-e).^(n-1);

% Mark: DECTED is same as secded except we add on probability of 2-bit errors.
dected = @(n,e) 1 -(1-e).^n -n.*e.*(1-e).^(n-1) -nchoosek(n,2).*e.^2.*(1-e).^(n-2);

%The SSCDSD formula is a lot more complicated. Basically, its 1-prob(0
%errors)-prob(1 error)-prob(2 bit errors in 1 block, 0 elsewhere)-prob(3
%bit errors in 1 block, 0 elsewhere)-(4 bit errors in 1 block, 0
%elsewhere) We have an additional parameter: b is the number of bits in a
%symbol.
sscdsd = @(n,b,e)   1-(1-e).^n...
                    -n.*e.*(1-e).^(n-1)...
                    -(n/b)^2*nchoosek(b,2)*e.^2.*(1-e).^(2*b-2)...
                    -(n/b)^2*nchoosek(b,3)*e.^3.*(1-e).^(2*b-3)...
                    -(n/b)^2*nchoosek(b,4)*e.^4.*(1-e).^(2*b-4);
                
   
                
                
%Create the secded cases:
secded_normal = secded(n1,error);
secded_swdecc = secded(n1,error)*(1-cor1);

%Create the dected cases:
dected_normal = dected(n2,error);
dected_swdecc = dected(n2,error)*(1-cor2);

%Create the sscdsd cases:
sscdsd_normal = sscdsd(n3,b,error);
sscdsd_swdecc = sscdsd(n3,b,error)*(1-cor3);


%Create the plot
loglog(error,1./secded_normal,error,1./secded_swdecc,error,1./dected_normal,error,1./dected_swdecc,error,1./sscdsd_normal,error,1./sscdsd_swdecc)
xlabel('Bit Error Rate')
ylabel('MTTF')
legend('SECDED','SECDED-SWDECC','DECTED','DECTED-SWDECC','SSCDSD','SSCDSD-SWDECC')
