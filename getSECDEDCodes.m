function [G, H] = getSECDEDCodes(n,code_type)
% This function returns the generator (G) and parity-check (H) matrices
% for a SECDED ECC code with specified length-n bits and type of code.
%
% Input arguments:
%   n --                Scalar: [39|72]
%   code_type --        String: '[hsiao1970|davydov1991]'
%
% Returns:
%   G --                Matrix: k x n over GF(2)
%   H --                Matrix: (n-k) x n over GF(2)
%
% Authors: Clayton Schoeny and Mark Gottscho
% Email: cschoeny@gmail.com, mgottscho@ucla.edu

    %% We support (8,4), (39,32), and (72, 64) SECDED codes
    if n ~= 8 && n~= 39 && n ~= 72
       G=0;
       H=0;
       return;
    end

    %% We support Hamming (Hsiao) and Pi codes
    if strcmp(code_type,'hsiao1970') ~= 1 && strcmp(code_type,'davydov1991') ~= 1
       G=0;
       H=0;
       return;
    end
    
    %% n == 8 setup
    if n == 8
        if strcmp(code_type,'hsiao1970') == 1
            % Hsiao code (Hsiao1970)
            % generator matrix
            G = [1 1 1 0 0 0 0 1
                 1 0 0 1 1 0 0 1
                 0 1 0 1 0 1 0 1
                 1 1 0 1 0 0 1 0];

            % parity-check matrix
            H = [1 0 1 0 1 0 1 0
                 0 1 1 0 0 1 1 0
                 0 0 0 1 1 1 1 0
                 1 1 1 1 1 1 1 1];       

        else % Pi code
            G = 0; % TODO
            H = 0; % TODO
        end
    end
    
    %% n == 39 setup
    if n == 39
        if strcmp(code_type,'hsiao1970') == 1
            % Hsiao code (Hsiao1970)
            Gp39 = [
                1 0 0 0 0 1 1
                1 0 0 0 1 0 1
                1 0 0 1 1 0 0
                1 0 1 0 0 0 1
                1 1 0 0 0 0 1
                1 0 0 0 1 1 0
                1 0 0 1 0 1 0
                1 1 0 0 1 0 0
                0 1 0 0 0 1 1
                0 1 0 0 1 0 1
                0 1 0 1 0 0 1
                0 1 1 0 0 0 1
                0 1 0 0 1 1 0
                0 1 0 1 0 1 0
                1 1 0 0 0 1 0
                0 1 0 1 1 0 0
                0 0 1 1 0 1 0
                0 0 1 0 0 1 1
                0 1 1 0 0 1 0
                1 0 1 0 0 1 0
                0 0 1 0 1 1 0
                0 1 1 0 1 0 0
                1 0 1 0 1 0 0
                0 0 1 0 1 0 1
                1 1 0 1 0 0 0
                0 0 0 1 1 0 1
                0 0 1 1 1 0 0
                0 0 1 1 0 0 1
                0 0 0 1 1 1 0
                0 1 1 1 0 0 0
                1 0 1 1 0 0 0
                1 0 0 1 0 0 1
        %        1 0 0 0 0 0 0
        %        0 1 0 0 0 0 0
        %        0 0 1 0 0 0 0
        %        0 0 0 1 0 0 0
        %        0 0 0 0 1 0 0
        %        0 0 0 0 0 1 0
        %        0 0 0 0 0 0 1
                ];
            
%             Gp39alt = [ % Clayton's minimal W(4) construction with odd-weight columns
%          1     1     0     0     1     1     1
%          0     1     1     1     1     1     0
%          1     1     0     1     1     1     0
%          1     1     1     0     1     1     0
%          1     1     1     1     0     0     1
%          1     0     1     0     1     1     1
%          1     1     0     1     0     1     1
%          1     1     1     0     1     0     1
%          0     1     1     0     1     1     1
%          0     0     1     1     1     1     1
%          1     0     1     1     0     1     1
%          1     1     1     0     0     1     1
%          1     1     1     1     0     1     0
%          1     1     0     1     1     0     1
%          0     1     1     1     1     0     1
%          0     1     1     1     0     1     1
%          1     0     1     1     1     1     0
%          1     0     1     1     1     0     1
%          0     1     0     1     1     1     1
%          1     0     0     1     1     1     1
%          1     1     1     1     1     0     0
%          0     0     1     0     1     1     0
%          0     1     0     1     1     0     0
%          1     0     0     1     0     0     1
%          1     1     0     0     0     1     0
%          1     0     0     0     1     0     1
%          1     0     0     1     0     1     0
%          0     1     1     0     0     0     1
%          0     1     1     0     0     1     0
%          0     0     1     1     0     0     1
%          0     0     1     1     0     1     0
%          1     1     1     1     1     1     1
%          ];

        else % Pi code -- Constructed using Ravydov1991
           Gp39 = [0,0,1,0,1,1,1,1,1,0,0,1,1,1,1,1,0,0,0,1,0,1,1,1,0,1,1,0,0,1,1,0
                   0,0,1,0,1,0,1,0,0,1,1,0,1,1,1,1,0,1,1,0,1,0,1,1,0,1,0,1,1,0,0,1
                   0,1,0,1,1,0,0,1,0,1,1,1,0,1,1,1,1,0,1,0,0,0,1,0,1,0,1,1,0,1,1,1
                   1,0,0,1,1,1,0,0,1,1,1,1,1,0,1,1,1,1,0,0,0,0,0,1,1,0,0,0,1,1,1,1
                   1,1,1,1,0,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,1,1
                   1,1,1,0,0,0,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1
                   1,1,1,1,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1]';
             
%            H =  [0,0,1,0,1,1,1,1,1,0,0,1,1,1,1,1,0,0,0,1,0,1,1,1,0,1,1,0,0,1,1,0,1,0,0,0,0,0,0
%                  0,0,1,0,1,0,1,0,0,1,1,0,1,1,1,1,0,1,1,0,1,0,1,1,0,1,0,1,1,0,0,1,0,1,0,0,0,0,0
%                  0,1,0,1,1,0,0,1,0,1,1,1,0,1,1,1,1,0,1,0,0,0,1,0,1,0,1,1,0,1,1,1,0,0,1,0,0,0,0
%                  1,0,0,1,1,1,0,0,1,1,1,1,1,0,1,1,1,1,0,0,0,0,0,1,1,0,0,0,1,1,1,1,0,0,0,1,0,0,0
%                  1,1,1,1,0,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,1,1,0,0,0,0,1,0,0
%                  1,1,1,0,0,0,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,0
%                  1,1,1,1,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1];
        end
        G = [eye(32), Gp39];
        H = [Gp39' eye(7)];
    end
    
    %% n == 72 setup
    if n == 72
        if strcmp(code_type,'hsiao1970') % Hsiao1970
             Gp72 = [
             1     1     0     1     0     0     0     0
             1     1     0     1     1     1     0     0
             1     1     1     0     1     1     0     0
             1     1     1     0     0     0     0     0
             1     0     0     1     1     0     0     0
             1     0     0     1     0     1     0     0
             1     0     0     1     0     0     1     0
             1     0     0     1     0     0     0     1
             0     1     1     0     1     0     0     0
             0     1     1     0     0     1     0     0
             0     1     1     0     0     0     1     0
             0     1     1     0     0     0     0     1
             1     1     0     0     1     0     0     0
             1     1     0     0     0     1     0     0
             1     1     0     0     0     0     1     0
             1     1     0     0     0     0     0     1
             0     0     1     1     1     0     0     0
             0     0     1     1     0     1     0     0
             0     0     1     1     0     0     1     0
             0     0     1     1     0     0     0     1
             1     0     1     0     1     0     0     0
             1     0     1     0     0     1     0     0
             1     0     1     0     0     0     1     0
             1     0     1     0     0     0     0     1
             0     1     0     1     1     0     0     0
             0     1     0     1     0     1     0     0
             0     1     0     1     0     0     1     0
             0     1     0     1     0     0     0     1
             1     0     1     1     0     0     0     0
             1     0     1     1     0     0     1     1
             0     1     1     1     0     0     1     1
             0     1     1     1     0     0     0     0
             0     0     0     0     1     1     1     0
             1     1     0     0     1     1     1     0
             1     1     0     0     1     1     0     1
             0     0     0     0     1     1     0     1
             1     0     0     0     1     0     1     0
             0     1     0     0     1     0     1     0
             0     0     1     0     1     0     1     0
             0     0     0     1     1     0     1     0
             1     0     0     0     0     1     0     1
             0     1     0     0     0     1     0     1
             0     0     1     0     0     1     0     1
             0     0     0     1     0     1     0     1
             1     0     0     0     1     1     0     0
             0     1     0     0     1     1     0     0
             0     0     1     0     1     1     0     0
             0     0     0     1     1     1     0     0
             1     0     0     0     0     0     1     1
             0     1     0     0     0     0     1     1
             0     0     1     0     0     0     1     1
             0     0     0     1     0     0     1     1
             1     0     0     0     0     1     1     0
             0     1     0     0     0     1     1     0
             0     0     1     0     0     1     1     0
             0     0     0     1     0     1     1     0
             1     0     0     0     1     0     0     1
             0     1     0     0     1     0     0     1
             0     0     1     0     1     0     0     1
             0     0     0     1     1     0     0     1
             0     0     0     0     0     1     1     1
             0     0     1     1     0     1     1     1
             0     0     1     1     1     0     1     1
             0     0     0     0     1     0     1     1
             ];
        else % Pi code
            % Davydov1991
%             H =     [0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0,     1,1,1,1,1, 1,1,1,1,1, 1,1,1,1,1, 1,1,1,1,1, 1,1, 1,1, 1,1,1, 1, 1,1,1,1
%                      0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 1,1,1,1,1, 1,1,1,1,1, 1,1,1,1,1, 1,1,1,1,1,     0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 1,1, 1,1, 1,1,1, 1, 1,1,1,1
%                      0,0,0,0,0, 0,0,0,0,0, 1,1,1,1,1, 1,1,1,1,1, 0,0,0,0,0, 0,0,0,0,0, 1,1,1,1,1, 1,1,1,1,1,     0,0,0,0,0, 0,0,0,0,0, 1,1,1,1,1, 1,1,1,1,1, 0,0, 0,0, 0,0,0, 0, 1,1,1,1
%                      0,0,0,0,0, 1,1,1,1,1, 0,0,0,0,0, 1,1,1,1,1, 0,0,0,0,0, 1,1,1,1,1, 0,0,0,0,0, 1,1,1,1,1,     0,0,0,0,0, 1,1,1,1,1, 0,0,0,0,0, 1,1,1,1,1, 0,0, 0,0, 1,1,1, 1, 0,0,0,0
% 
%                      1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1,     1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0, 0,1, 1,0,0, 1, 1,0,0,0
%                      0,1,0,0,1, 0,1,0,0,1, 0,1,0,0,1, 0,1,0,0,1, 0,1,0,0,1, 0,1,0,0,1, 0,1,0,0,1, 0,1,0,0,1,     0,1,0,0,1, 0,1,0,0,1, 0,1,0,0,1, 0,1,0,0,1, 0,1, 0,1, 0,1,0, 1, 0,1,0,0
%                      0,0,1,0,1, 0,0,1,0,1, 0,0,1,0,1, 0,0,1,0,1, 0,0,1,0,1, 0,0,1,0,1, 0,0,1,0,1, 0,0,1,0,1,     0,0,1,0,1, 0,0,1,0,1, 0,0,1,0,1, 0,0,1,0,1, 0,0, 0,1, 0,0,1, 1, 0,0,1,0
%                      0,0,0,1,1, 0,0,0,1,1, 0,0,0,1,1, 0,0,0,1,1, 0,0,0,1,1, 0,0,0,1,1, 0,0,0,1,1, 0,0,0,1,1,     0,0,0,1,1, 0,0,0,1,1, 0,0,0,1,1, 0,0,0,1,1, 0,0, 1,1, 0,0,0, 1, 0,0,0,1];
%             H_rref = [1,0,0,0,1,0,1,1,1,0,0,1,1,1,0,1,0,0,0,1,0,1,1,1,0,1,0,0,0,1,1,0,0,0,1,0,1,1,1,0,0,1,1,1,0,1,0,0,0,1,1,0,0,0,1,0,1,1,1,0,1,0,0,1,0,1,1,0,0,1,1,1
%                       0,1,0,0,1,0,1,0,0,1,1,0,1,1,0,1,0,1,1,0,0,1,0,0,1,0,1,0,0,1,1,0,1,1,0,1,0,1,1,0,1,0,1,1,0,1,0,1,1,0,0,1,0,0,1,0,1,0,0,1,1,0,1,0,1,0,1,0,0,1,0,0
%                       0,0,1,0,1,0,0,1,0,1,0,0,1,0,1,0,0,1,0,1,1,1,0,1,0,1,1,0,1,0,1,1,0,1,0,1,1,0,1,0,1,1,0,1,0,1,1,0,1,0,1,1,0,1,0,1,1,0,1,0,0,0,0,1,0,0,1,1,0,0,1,0
%                       0,0,0,1,1,0,0,0,1,1,0,0,0,1,1,0,0,0,1,1,0,0,0,1,1,0,0,0,1,1,0,0,0,1,1,0,0,0,1,1,1,1,1,0,0,1,1,1,0,0,1,1,1,0,0,1,1,1,0,0,1,1,0,0,1,1,1,0,1,1,1,0
%                       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
%                       0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0
%                       0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1
%                       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1];
%               H_rref_standard_form = [1,1,1,1,0,0,1,1,1,0,1,0,0,1,0,1,1,1,0,1,0,0,1,1,0,0,0,1,0,1,1,1,0,0,1,1,1,1,0,0,0,1,1,0,0,0,1,0,1,1,1,0,1,0,0,1,0,1,1,0,0,1,1,1, 1,0,0,0,0,0,0,0 
%                                       1,1,0,0,1,1,0,1,1,0,1,1,1,0,0,1,0,0,1,0,1,0,1,1,0,1,1,0,1,0,1,1,0,1,0,1,1,1,0,1,1,0,0,1,0,0,1,0,1,0,0,1,1,0,1,0,1,0,1,0,0,1,0,0, 0,1,0,0,0,0,0,0
%                                       1,0,1,0,1,0,0,1,0,1,0,1,0,1,1,1,0,1,0,1,1,1,0,1,1,0,1,0,1,1,0,1,0,1,1,0,1,1,1,0,1,0,1,1,0,1,0,1,1,0,1,0,0,0,0,1,0,0,1,1,0,0,1,0, 0,0,1,0,0,0,0,0
%                                       1,0,0,1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1,0,0,0,1,1,1,1,1,0,1,1,1,0,0,1,1,1,0,0,1,1,1,0,0,1,1,0,0,1,1,1,0,1,1,1,0, 0,0,0,1,0,0,0,0
%                                       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 0,0,0,0,1,0,0,0
%                                       0,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0, 0,0,0,0,0,1,0,0
%                                       0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1, 0,0,0,0,0,0,1,0
%                                       0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1, 0,0,0,0,0,0,0,1
%                                       
%                                       ];

             Gp72 =  [1,1,1,1,0,0,1,1,1,0,1,0,0,1,0,1,1,1,0,1,0,0,1,1,0,0,0,1,0,1,1,1,0,0,1,1,1,1,0,0,0,1,1,0,0,0,1,0,1,1,1,0,1,0,0,1,0,1,1,0,0,1,1,1 
                      1,1,0,0,1,1,0,1,1,0,1,1,1,0,0,1,0,0,1,0,1,0,1,1,0,1,1,0,1,0,1,1,0,1,0,1,1,1,0,1,1,0,0,1,0,0,1,0,1,0,0,1,1,0,1,0,1,0,1,0,0,1,0,0
                      1,0,1,0,1,0,0,1,0,1,0,1,0,1,1,1,0,1,0,1,1,1,0,1,1,0,1,0,1,1,0,1,0,1,1,0,1,1,1,0,1,0,1,1,0,1,0,1,1,0,1,0,0,0,0,1,0,0,1,1,0,0,1,0
                      1,0,0,1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1,0,0,0,1,1,1,1,1,0,1,1,1,0,0,1,1,1,0,0,1,1,1,0,0,1,1,0,0,1,1,1,0,1,1,1,0
                      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                      0,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0
                      0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1
                      0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1]';
        end
 
        G = [eye(64), Gp72];
        H = [Gp72' eye(8)];
    end
end
