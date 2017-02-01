function [G,H] = getECCConstruction(n,code_type)
% Get the generator and parity-check matrices for the specified code.
% The message size k is inferred by the value of n. It can either be 16, 32, 64, or 128.
% Upon error, G and H are set to 0.
%
% Arguments:
%   n --                Scalar: [17|18|19|33|34|35|39|45|72|79|144]
%   code_type --        String: '[hsiao|davydov1991|bose1960|kaneda1982|ULEL_float|ULEL_even]'
%
% Returns:
%   G --                Matrix: k x n over GF(2)
%   H --                Matrix: (n-k) x n over GF(2)
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

if strcmp(code_type, 'hsiao1970') == 1 || strcmp(code_type, 'davydov1991') == 1 % SECDED
    [G,H] = getSECDEDCodes(n,code_type);
elseif strcmp(code_type, 'bose1960') == 1 % DECTED
    [G,H] = getDECTEDCodes(n);
elseif strcmp(code_type, 'kaneda1982') == 1 % ChipKill
    [G,H] = getChipkillCodes(n);
elseif strcmp(code_type, 'ULEL_float') == 1 || strcmp(code_type, 'ULEL_even') == 1 % ULEL
    [G,H] = getULELCodes(n,code_type);
else
    G=0;
    H=0;
end
