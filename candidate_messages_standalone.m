function [] = candidate_messages_standalone(original_message_bin, n, k, code_type, verbose, hash_mode)
% This function serves as a wrapper for compute_candidate_correct_messages() to external applications. It is meant to be compiled with mcc and invoked through a shell.
% Relevant arguments are passed through. Those which are not are described below. Function output is text to stdout.
%
% Returns:
%   Nothing.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

n = str2num(n);
k = str2num(k);
verbose = str2num(verbose);

rng('shuffle'); % Seed RNG based on current time

if ~isdeployed
    addpath ecc common rv64g % Add sub-folders to MATLAB search paths for calling other functions we wrote
end

[G,H] = getECCConstruction(n,code_type);

if verbose == 1
    G
    H
    n
    k
    hash_mode
end

original_codeword_bin = ecc_encoder(original_message_bin,G);
error_patterns = construct_error_pattern_matrix(n, code_type);
error_pattern_bin = error_patterns(randi(size(error_patterns,1),1),:);
received_string_bin = my_bitxor(original_codeword_bin, error_pattern_bin);

if verbose == 1
    original_codeword_bin 
    error_pattern_bin
    received_string_bin
end

[candidate_correct_messages_bin, retval] = compute_candidate_correct_messages(received_string_bin, H, code_type);
            
%% Optional: filter candidates using a hash
if strcmp(hash_mode, 'none') ~= 1
    if strcmp(hash_mode, '4') == 1
        hash_size = 4;
    elseif strcmp(hash_mode, '8') == 1
        hash_size = 8;
    elseif strcmp(hash_mode, '16') == 1
        hash_size = 16;
    end

    %correct_hash = pearson_hash(original_message_bin-'0',hash_size);
    correct_hash = parity_hash_uneven(original_message_bin-'0',hash_size);
    if verbose == 1
        hash_size
        correct_hash
        candidate_correct_messages_bin
    end
    x=1;
    hash_filtered_candidates = repmat('X',1,k);
    for i=1:size(candidate_correct_messages_bin,1)
        %hash = pearson_hash(candidate_correct_messages_bin(i,:)-'0',hash_size);
        hash = parity_hash_uneven(candidate_correct_messages_bin(i,:)-'0',hash_size);
        if hash == correct_hash
            hash_filtered_candidates(x,:) = candidate_correct_messages_bin(i,:);
            x=x+1;
        end
    end
    if verbose == 1
        hash_filtered_candidates
    end
    candidate_correct_messages_bin = hash_filtered_candidates;
end

for i=1:size(candidate_correct_messages_bin)
    fprintf(1, '%s\n', candidate_correct_messages_bin(i,:));
end
