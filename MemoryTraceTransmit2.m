% Memory Trace Tranmission

% Code parameters:
n = 72;
k = 64;
r = n-k;

% read the file:
fid = fopen('bzip2_mem_trace_snip.txt');
C = textscan(fid,'%u64 %u64 %u64 %u64 %u64 %s %u64 %u64 %u64 %u64 %u64 %u64 %u64 %u64','Delimiter',',','EmptyValue',0);
fclose(fid);

% the data words are in C{7} to C{14}:
ln = length(C{7});
%ln=1; %delete this line later
for i=1:ln
   for j=1:8
      messageList(i,j) =  C{6+j}(i);
   end
end

% transmit our messages:
for i=1:ln
    for j=1:8
        mess = dec2bin(messageList(i,j),64);
        mess=mess-'0';
        
        % generate an error:
        err = zeros(1,n);
        err(40) = 1;
        err(32) = 1;
        
        % encode our codeword
        cw = hamEnc(mess);
            
        % receive an word (poss. in error)
        reccw = mod(cw+err,2);
        
        % decode our received codeword
        [decCw, e] = hamDec(reccw);

        % check for errors. if e==2, we 
        if e==2
           disp('We are in the 2 error case.');
           
           % let's run the decoder through every codeword that flips a bit
           % from the received word.
           
           idx = 0;
           cwList=[];
           for k=1:n
               cwmod = reccw;
               cwmod(k) = mod(cwmod(k)+1,2);   
               [decCwmod, e] = hamDec(cwmod);
                if (e==1)
                    idx=idx+1;
                    cwList(idx,:) = decCwmod;
                end
           end
           size(unique(cwList,'rows'))
        end
    end
    
 %   cw
 %   cwList
   
end
