/*
 * Author: Mark Gottscho
 * Email: mgottscho@ucla.edu
 */

#include <stdio.h>
#include <string.h>
//#include <spike_timer.h>
#include "sdecc_chipkill.h"

int parse_binary_string(const char* s, const size_t len, word_t* w) {
    if (!w)
        return 1;
    
    w->val.H = 0;
    w->val.M = 0;
    w->val.L = 0;

    for (size_t i = 0; i < len; i++) {
        if (s[i] != '1' && s[i] != '0')
            return 1;
        
        size_t offset_from_lsb = len-i-1;
        if (offset_from_lsb >= H_OFFSET) //most-significant 64-bit part
            w->val.H |= ((uint64_t)(s[i] == '1')) << (offset_from_lsb - H_OFFSET);
        else if (offset_from_lsb >= M_OFFSET && offset_from_lsb < H_OFFSET) //middle-significant 64-bit part
            w->val.M |= ((uint64_t)(s[i] == '1')) << (offset_from_lsb - M_OFFSET);
        else if (offset_from_lsb >= L_OFFSET && offset_from_lsb < M_OFFSET) //least-significant 64-bit part
            w->val.L |= ((uint64_t)(s[i] == '1')) << (offset_from_lsb - L_OFFSET);
        else
            return 1;
    }

    return 0;
}

int compute_syndrome(const word_t* received_string, uint64_t* syndrome) {
    if (!received_string || !syndrome)
        return 1;

    *syndrome = 0;
    for (int i = 0; i < PARITY_SIZE; i++) {
        uint64_t weight = 0;
        weight += __builtin_parityl(H_rows[i].H & received_string->val.H);
        weight += __builtin_parityl(H_rows[i].M & received_string->val.M);
        weight += __builtin_parityl(H_rows[i].L & received_string->val.L);
        weight = weight % 2;
        *syndrome |= weight << (PARITY_SIZE-i-1);
    }

    return 0;
}

word_t extract_message(const word_t codeword) {
    word_t m;
    m.val.H = codeword.val.H >> PARITY_SIZE;
    m.val.M = (codeword.val.M >> PARITY_SIZE) | ((codeword.val.H & PARITY_BITS_L_MASK) << (sizeof(uint64_t)*8 - PARITY_SIZE));
    m.val.L = (codeword.val.L >> PARITY_SIZE) | ((codeword.val.M & PARITY_BITS_L_MASK) << (sizeof(uint64_t)*8 - PARITY_SIZE));
    return m;
}

word_t flip_bit(const word_t codeword, int pos) {
    word_t w = codeword;
    if (CODEWORD_SIZE-pos-1 >= H_OFFSET)
        w.val.H = w.val.H ^ ((uint64_t)(1) << CODEWORD_SIZE-pos-1 - H_OFFSET);
    else if (CODEWORD_SIZE-pos-1 >= M_OFFSET && CODEWORD_SIZE-pos-1 < H_OFFSET)
        w.val.M = w.val.M ^ ((uint64_t)(1) << CODEWORD_SIZE-pos-1 - M_OFFSET);
    else if (CODEWORD_SIZE-pos-1 >= L_OFFSET && CODEWORD_SIZE-pos-1 < M_OFFSET)
        w.val.L = w.val.L ^ ((uint64_t)(1) << CODEWORD_SIZE-pos-1 - L_OFFSET);
    return w; 
}

int chipkill_decoder(const word_t received_string, const uint64_t syndrome, int* outcome, word_t* corrected_codeword) {
    if (!outcome || !corrected_codeword)
        return 1;

    if (syndrome == 0) { //No error
        *corrected_codeword = received_string;
        *outcome = 0;
        return 0;
    }

    //First check for single-bit errors within a symbol
    *corrected_codeword = received_string;
    for (int i = 0; i < CODEWORD_SIZE; i++) {
        if (syndrome == H_columns[i]) {
            *corrected_codeword = flip_bit(received_string, i);
            *outcome = 1; //corrected
            return 0;
        }
    }

    //Next check for quadruple-bit errors within a symbol, as this is a fast and simple case
    for (int s = 0; s < CODEWORD_SIZE/SYMBOL_SIZE; s++) {
        //Four-bit error if all columns in a symbol sum to the syndrome
        uint64_t col_sum = 0;
        for (int c = 0; c < SYMBOL_SIZE; c++)
            col_sum += H_columns[s*SYMBOL_SIZE+c]; 
        if (col_sum == syndrome) { //found it
            *corrected_codeword = flip_bit(received_string, s*SYMBOL_SIZE);
            *corrected_codeword = flip_bit(*corrected_codeword, s*SYMBOL_SIZE+1);
            *corrected_codeword = flip_bit(*corrected_codeword, s*SYMBOL_SIZE+2);
            *corrected_codeword = flip_bit(*corrected_codeword, s*SYMBOL_SIZE+3);
            *outcome = 1; //corrected
            return 0;
        }
    }

    //Next we check for the triple bit flips. This is almost the same as checking for single-bit flips, only '0' and '1' are reversed. It looks ugly but is actually fast.
    for (int s = 0; s < CODEWORD_SIZE/SYMBOL_SIZE; s++) {
        int idx = s*SYMBOL_SIZE;
        //This looks like an ugly triple for loop and it is. However, when symbol size is 4 bits, there are only 4 ways to have a three-bit error. This loop structure merely memoizes shared parts of 3-column sums.
        for (int a = 0; a < 2; a++) { //a is the first bit flip position in the symbol
            uint64_t col_a_plus_syndrome = H_columns[idx+a] ^ syndrome;
            for (int b = a+1; b < 3; b++) { //b is the second bit flip position in the symbol
                uint64_t col_a_b_plus_syndrome = H_columns[idx+b] ^ col_a_plus_syndrome;
                for (int c = b+1; c < 4; c++) { //c is the third bit flip position in the symbol
                    uint64_t cols_plus_syndrome = H_columns[idx+c] ^ col_a_b_plus_syndrome;
                    //if sum of cols a, b, c in H are syndrome, then we found a three-bit error
                    if (cols_plus_syndrome == 0) {
                        *corrected_codeword = flip_bit(received_string, idx+a);
                        *corrected_codeword = flip_bit(*corrected_codeword, idx+b);
                        *corrected_codeword = flip_bit(*corrected_codeword, idx+c);
                        *outcome = 1; //corrected
                        return 0;
                    }
                }
            }
        }
    }

    //Next we check for all possible double bit flips. There are 6 ways to do this and this is the slowest case.
    for (int s = 0; s < CODEWORD_SIZE/SYMBOL_SIZE; s++) {
        int idx = s*SYMBOL_SIZE;
        for (int a = 0; a < 3; a++) { //a is the first bit flip position in the symbol
            uint64_t col_a_plus_syndrome = H_columns[idx+a] ^ syndrome;
            for (int b = a+1; b < 4; b++) { //b is the second bit flip position in the symbol
                uint64_t cols_plus_syndrome = H_columns[idx+b] ^ col_a_plus_syndrome;
                //if sum of cols a, b, c in H are syndrome, then we found a three-bit error
                if (cols_plus_syndrome == 0) {
                    *corrected_codeword = flip_bit(received_string, idx+a);
                    *corrected_codeword = flip_bit(*corrected_codeword, idx+b);
                    *outcome = 1; //corrected
                    return 0;
                }
            }
        }
    }

    //If we got this far, it is a DUE
    *corrected_codeword = received_string;
    *outcome = 2; //DUE

    return 0;
}

int compute_candidate_messages(const word_t received_string, word_t* candidate_messages, const size_t max_messages, size_t* num_messages) {
    if (!candidate_messages || max_messages < 1)
        return 1;

    uint64_t syndrome = SYNDROME_NO_ERROR;
    compute_syndrome(&received_string, &syndrome);

    if (syndrome == SYNDROME_NO_ERROR) { //No error
        candidate_messages[0] = extract_message(received_string);
        *num_messages = 1;
        printf("no error\n");
        return 1;
    } else {
        *num_messages = 0;

        //Check for correctable error
        int outcome = 0;
        word_t corrected_codeword;
        if (chipkill_decoder(received_string, syndrome, &outcome, &corrected_codeword))
            return 1;

        if (outcome == 1) { //CE
            candidate_messages[0] = extract_message(corrected_codeword);
            *num_messages = 1;
            printf("ce\n");
            return 0;
        }
        
        if (outcome == 2) { //DUE, generate candidates
            //For codes that correct t-sym errors and detect t+1-sym errors, we only need to iterate over a linear number of symbol "flip" positions.
            uint64_t checksums[max_messages];
            for (int s = 0; s < CODEWORD_SIZE/SYMBOL_SIZE; s++) { //Over all symbols
                int idx = s*SYMBOL_SIZE;
                for (uint8_t pat = 0; pat < 16; pat++) { //Over all symbol patterns
                    uint8_t err = pat;
                    word_t trial_string = received_string;
                    for (int i = 0; i < SYMBOL_SIZE; i++) {
                        if (err & 1)
                            trial_string = flip_bit(trial_string, idx+3-i);
                        err = err >> 1;
                    }
                    
                    //Attempt to decode
                    uint64_t trial_syndrome = 0;
                    compute_syndrome(&trial_string, &trial_syndrome);
                    if (chipkill_decoder(trial_string, trial_syndrome, &outcome, &corrected_codeword))
                        return 1;

                    if (outcome == 1) { //trial was a CE, found candidate
                        //Make sure only unique candidates are committed
                        uint64_t checksum = corrected_codeword.val.H + corrected_codeword.val.M + corrected_codeword.val.L;
                        int duplicate = 0;
                        for (int i = 0; i < *num_messages; i++) {
                            if (checksum == checksums[i]) {
                                duplicate = 1;
                                break;
                            }
                        }

                        if (!duplicate) {
                            if (*num_messages == max_messages)
                                return 1;
                            
                            checksums[*num_messages] = checksum;
                            candidate_messages[(*num_messages)++] = extract_message(corrected_codeword);
                        }
                    }
                }
            }
            printf("due\n");
        }


        if (*num_messages == 0)
            return 1;
    }

    return 0;
}


int hamming_distance_recovery(const word_t* candidate_messages, const size_t num_messages, const word_t* si, const size_t num_si, word_t* chosen_message) {
    //Error checks
    if (num_messages < 1 || !candidate_messages || !si || !chosen_message)
        return 1;

    //If one candidate or no SI, just choose first candidate
    if (num_messages == 1 || num_si < 1) {
        *chosen_message = candidate_messages[0];
        return 0;
    }

    //Compute average hamming distance of each candidate to all SI
    double avg_hamming_dist[num_messages];
    double min_avg_hamming_dist = (double)(CODEWORD_SIZE);
    int chosen_index = -1;
    for (int i = 0; i < num_messages; i++) {
        int dist = 0;
        for (int j = 0; j < num_si; j++) {
            dist += __builtin_popcountl((candidate_messages[i].val.H) ^ (si[j].val.H));
            dist += __builtin_popcountl((candidate_messages[i].val.M) ^ (si[j].val.M));
            dist += __builtin_popcountl((candidate_messages[i].val.L) ^ (si[j].val.L));
        }
        avg_hamming_dist[i] = (double)(dist) / (double)(num_si);
        if (avg_hamming_dist[i] <= min_avg_hamming_dist) {
            min_avg_hamming_dist = avg_hamming_dist[i];
            chosen_index = i;
        }
    }

    if (chosen_index >= 0 && chosen_index < num_messages)
        *chosen_message = candidate_messages[chosen_index];
    else
        return 1;

    return 0;
}


int main(int argc, char** argv) {
    if (argc != 3) {
        printf("Usage: sdecc <RECEIVED_STRING_BIN> <SIDE_INFORMATION_BIN>\n");
        printf("\n");
        printf("Codeword size (n): %d\n", CODEWORD_SIZE);
        printf("Message size (k): %d\n", MESSAGE_SIZE);
        printf("Parity size (r=n-k): %d\n", PARITY_SIZE);
        printf("Codeword mask: %016lx %016lx %016lx\n", CODEWORD_BITS_H_MASK, CODEWORD_BITS_M_MASK, CODEWORD_BITS_L_MASK);
        printf("Message mask: %016lx %016lx %016lx\n", MESSAGE_BITS_H_MASK, MESSAGE_BITS_M_MASK, MESSAGE_BITS_L_MASK);
        printf("Parity mask: %016lx %016lx %016lx\n", PARITY_BITS_H_MASK, PARITY_BITS_M_MASK, PARITY_BITS_L_MASK);
        return 1; 
    }

    //Parse input
    word_t received_string;
    word_t si[4];

    int fail = 0;

    fail = parse_binary_string(argv[1], strlen(argv[1]), &received_string);
    char* curr = strtok(argv[2], ",");
    for (int i = 0; i < 3; i++) {
        if (!curr) {
            fail = 1;
            break;
        }
        fail = parse_binary_string(curr, strlen(curr), si+i);
        if (fail)
            break;

        curr = strtok(NULL, ",");
    }
    if (curr)
        fail = 1;

    if (fail) {
        printf("Bad input\n");
        return 1;
    }

    printf("Received string: %016lx %016lx %016lx\n", received_string.val.H, received_string.val.M, received_string.val.L);
    for (int i = 0; i < 3; i++)
        printf("SI[%d]: %016lx %016lx %016lx\n", i, si[i].val.H, si[i].val.M, si[i].val.L); 

    //Compute candidate codewords

    //starttick();

    word_t candidate_messages[20];
    size_t num_messages = 0;
    if (compute_candidate_messages(received_string, candidate_messages, 20, &num_messages)) {
        printf("failed to compute candidates\n");
        return 1;
    }

    for (int i = 0; i < num_messages; i++)
        printf("candidate_message[%d]: %016lx %016lx %016lx\n", i, candidate_messages[i].val.H, candidate_messages[i].val.M, candidate_messages[i].val.L); 

    //Choose a recovery target
    word_t chosen_message;
    if (num_messages == 1)
        chosen_message = candidate_messages[0];
    else {
        if (hamming_distance_recovery(candidate_messages, num_messages, si, 3, &chosen_message)) {
            printf("bad recovery\n");
            return 1;
        }
    }

    //stoptick();
    //printtick();

    printf("chosen message: %016lx %016lx %016lx\n", chosen_message.val.H, chosen_message.val.M, chosen_message.val.L);

    return 0;
}

