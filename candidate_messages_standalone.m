function [] = candidate_messages_standalone(original_message_bin, error_pattern_bin, n, k, code_type, verbose)
% This function serves as a wrapper for compute_candidate_correct_messages() to external applications. It is meant to be compiled with mcc and invoked through a shell.
% Relevant arguments are passed through. Those which are not are described below. Function output is text to stdout.
%
% Arguments:
%   error_pattern_bin --    1xn string of '0' and '1'. Please be sure this is a DUE pattern for the specified code_type.
%   code_type --        String: '[hsiao|davydov1991|bose1960|kaneda1982|ULEL_float|ULEL_even]'
%
% Returns:
%   Nothing.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

n = str2num(n);
k = str2num(k);
verbose = str2num(verbose);

if ~isdeployed
    addpath ecc common rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
end

[G,H] = getECCConstruction(n,code_type);

if verbose == 1
    G
    H
end

original_codeword_bin = ecc_encoder(original_message_bin,G);
received_string_bin = my_bitxor(original_codeword_bin, error_pattern_bin);

if verbose == 1
    original_codeword_bin 
    error_pattern_bin
    received_string_bin
end

[candidate_correct_messages_bin, retval] = compute_candidate_correct_messages(received_string_bin, H, code_type);

for i=1:size(candidate_correct_messages_bin)
    fprintf(1, '%s\n', candidate_correct_messages_bin(i,:));
end
