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
        error = zeros(1,n);

        % encode our codeword
        cw = hamEnc(mess);
        
        % decode our received codeword
        [decCw, e] = hamDec(mod(cw+error,2));
        
        % check for errors:
        if e~=0
           disp('Something bad happened!'); 
        end
    end
   
end
