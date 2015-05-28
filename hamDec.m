% Hamming SEC-DED Denoder:
% xcorr is the corrected word, if possible
% err is # of errors detected. Accurate up to 2 errors
function [xcorr, err] = hamDec(y)
    
  % set codeword parameters: 8/72
    if length(y) == 8 
        n = 8;
        r = 4;
    elseif length(y) == 72
        n = 72;
        r = 8;
    else
       err = -1; 
       return;
    end

    % get parity-check matrix
    [G, H] = getHamCodes(n);
         
    % compute syndrome:
    s = mod(H*y',2);
    
    xcorr = y;
    
    % CASE 1: Syndrome is 0, no errors
    if s == zeros(r,1)
        err = 0;
        return;
    end
           
    % DECODING FOR HSIAO (72, 64) CODE:
    if n == 72
        
       % CASE 2: Syndrome is even, even # of errors: 
       if mod(sum(s),2) == 0
          % double error ocurred;
          err = 2;
       end
       
       % CASE 3: Syndrome is odd, odd # of errors: 
       if mod(sum(s),2) == 1
          % odd number of errors ocurred
          err = 1;
          notfound = 1;
          
           % find single bit error and correct it
           for i=1:n          
              if sum(s == H(:,i)) == r
                 bit = i;
                 notfound = 0;
              end
           end

           if notfound == 1
              err = 3;
           else
               e = zeros(1,n);
               e(bit) = 1;
               xcorr = mod(xcorr + e,2);       
           end

       end
        
    end
    
    % DECODING FOR STANDARD (8, 4) CODE:
    if n == 8
        % CASE 2: Syndrome is non-zero, single error
        if sum(s(1:r-1) ~= zeros(r-1,1)) > 0 && s(r) == 1
           err = 1; 

           % find single bit error and correct it
           for i=1:n           
              if sum(s == H(:,i)) == r
                 bit = i; 
              end
           end

           e = zeros(1,n);
           e(bit) = 1;
           xcorr = mod(xcorr + e,2);

        end

        % CASE 3: Error in sec-ded bit:
        if sum(s(1:r-1) ~= zeros(r-1,1)) == 0 && s(r) == 1
           err = 1; 

           e = zeros(1,n);
           e(n) = 1;
           xcorr = mod(xcorr + e,2);
        end

        % CASE 4: Syndrome is non-zero, double error
        if sum(s(1:r-1) ~= zeros(r-1,1)) > 0 && s(r) == 0
            err = 2;

            % we can't correct this in general
            % but there are special cases we can correct
        end
    end
    
end