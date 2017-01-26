[] = inst_recovery_standalone(architecture, n, k, original_message_bin, error_pattern_bin, policy, instruction_mnemonic_hotness, instruction_rd_hotness, crash_threshold, verbose, code_type)
% This function serves as a wrapper for inst_recovery() to external applications. It is meant to be compiled with mcc and invoked through a shell.
% Relevant arguments are passed through to inst_recovery. Those which are not are described below. Function output is text to stdout.
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

if ~isdeployed
    addpath ecc common rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
end

[G,H] = getECCConstruction(n,code_type);

original_codeword_bin = ecc_encoder(original_message_bin,G);
received_string_bin = my_bitxor(original_codeword_bin, error_pattern_bin);
[candidate_correct_messages_bin, retval] = compute_candidate_correct_messages(received_string_bin, H, code_type);

% TODO and FIXME: worry about byte ordering for specific policies like delta-pick-random and fdelta-pick-random

inst_recovery('rv64g', num2str(n), num2str(k), original_message_bin, candidate_correct_messages_bin, policy, instruction_mnemonic_hotness, instruction_rd_hotness, crash_threshold, num2str(verbose_recovery)); % Don't need return values.
