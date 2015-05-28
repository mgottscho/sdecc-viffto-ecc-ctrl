% Hamming SEC-DED Encoder:
% out is the codeword
function out = hamEnc(in)
 
    % set codeword length: 8/72
    if length(in) == 4 
        n=8;
    elseif length(in) == 64
        n=72;
    else
       out = -1; 
       return;
    end
    
    % get generator matrix
    [G, H] = getHamCodes(n);

    % encode
    out = mod(in*G,2);
    
end