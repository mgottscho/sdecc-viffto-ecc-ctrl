% This script iterates over a series of MIPS1 (R3000) 32-bit instructions that are statically extracted from a compiled program.
% For each instruction, it first checks if it is a valid instruction. If it is, the
% script encodes the instruction/message in a specified SECDED encoder.
% The script then iterates over all possible 2-bit error patterns on the
% resulting codeword. Each of these 2-bit patterns are decoded by our
% SECDED code and should all be "detected but uncorrectable." For each of
% these 2-bit errors, we flip a single bit one at a time and decode again.
% We should obtain X received codewords that are indicated as corrected.
% These X codewords are "candidates" for the original encoded message.
% The script then uses the MIPS instruction decoder to determine which of
% the X candidate messages are valid instructions.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

%% Set parameters for the script

%%%%%% CHANGE THESE AS NEEDED %%%%%%%%
filename = 'mips-bzip2-text-section-inst.txt';
n = 39; % codeword width
k = 32; % instruction width
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r = n-k;

%% Read instructions as bit-strings from file
fid = fopen(filename);
trace_hex = textread(filename, '%8c');
trace_bin = hex2dec(trace);
trace_bin = dec2bin(trace,k);
fclose(fid);

%% Construct a matrix containing all possible 2-bit error patterns as bit-strings.
num_error_patterns = nchoosek(n,2);
error_patterns = repmat('0',num_error_patterns,n);
num_error = 1;
for i=1:n-1
    for j=i+1:n
        error_patterns(num_error, i) = '1';
        error_patterns(num_error, j) = '1';
        num_error = num_error + 1;
    end
end

%% Get our ECC encoder and decoder matrices
[G,H] = getHamCodes(n);

%% Iterate over all instructions in the trace, and do the fun parts.
num_inst = size(trace,1);
%%%%%% FEEL FREE TO OVERRIDE %%%%%%
num_inst = 100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parfor i=1:num_inst % Parallelize loop across separate threads, since this could take a long time. Each instruction is a totally independent procedure to perform.
    %% Progress indicator
    % This will not show accurate progress if the loop is parallelized
    % across threads with parfor, since they can execute out-of-order
    if mod(i,100) == 0
        display(['Inst # ' i ' out of ' num2str(num_inst)]);
    end
    
    %% Get the "message," which is the original instruction, i.e., the ground truth.
    message_hex = trace_hex(i,:);
    message_bin = trace_bin(i,:);
    
    %% Check that the message is actually a valid instruction to begin with.
    % Comment this out to save time if you are absolutely sure that all
    % input values are valid.
    status = unix(['./mipsdecode-mac ' message_hex ' >/dev/null']);
    if status ~= 0
       display(['Instruction #' i ' in the input was found to be ILLEGAL, with value ' message_hex]);
    end
    
    %% Encode the message.
    codeword = hamEnc(message,G);
    
    %% Iterate over all possible 2-bit error patterns.
    for j=1:num_error_patterns
        %% Inject 2-bit error.
        error = error_patterns(j,:);
        received_codeword = dec2bin(bitxor(bin2dec(codeword), bin2dec(error)), n);
        
        
    end
    
end

%This vector will hold the sizes of all the equiprobably codewords for each
%(2-error) combination.
% ThreeD = zeros(72,72);
% size_vec=zeros(nchoosek(n,2),1);
% count=1;
% for i=1:n-1
%     for j=i+1:n
%         % generate an error:
%         err = zeros(1,n);
%         err(i) = 1;
%         err(j) = 1;
% 
%         % encode our codeword
%         cw = hamEnc(mess);
% 
%         % receive an word (poss. in error)
%         reccw = mod(cw+err,2);
% 
%         % decode our received codeword
%         [decCw, e] = hamDec(reccw);
% 
%        
% 
%             % let's run the decoder through every codeword that flips a bit
%             % from the received word.
% 
%         idx = 0;
%         cwList=[];
%         for k=1:n
%            cwmod = reccw;
%            cwmod(k) = mod(cwmod(k)+1,2);
%            [decCwmod, e] = hamDec(cwmod);
%             if (e==1)
%                 idx=idx+1;
%                 cwList(idx,:) = decCwmod;
%             end
%         end
%         [equidistant,tmp] = size(unique(cwList,'rows'));
%         size_vec(count)= equidistant;
%         count=count+1;
%         ThreeD(i,j)=equidistant;
%     end
% end
