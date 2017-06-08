/*
 * Author: Mark Gottscho
 * Email: mgottscho@ucla.edu
 */

#include <stdio.h>
#include <string.h>
#include "sdecc.h"

int parse_binary_string(const char* s, const size_t len, word_t* w) {
    if (!w)
        return 1;
    
    w->val = 0;

    for (size_t i = 0; i < len; i++) {
        if (s[i] != '1' && s[i] != '0')
            return 1;

        w->val |= ((uint64_t)(s[i] == '1')) << len-i-1;
    }

    return 0;
}

int compute_syndrome(const word_t* received_string, uint64_t* syndrome) {
    if (!received_string || !syndrome)
        return 1;

    *syndrome = 0;
    for (int i = 0; i < PARITY_SIZE; i++)
        *syndrome |= __builtin_popcountl(H_rows[i] & received_string->val) << PARITY_SIZE-i-1;

    return 0;
}

uint64_t extract_message(const uint64_t codeword) {
    return (codeword & MESSAGE_BITS_MASK) >> PARITY_SIZE;
}


int compute_candidate_messages(const word_t received_string, word_t* candidate_messages, const size_t max_messages, size_t* num_messages) {
    if (!candidate_messages || max_messages < 1)
        return 1;

    uint64_t syndrome = SYNDROME_NO_ERROR;
    compute_syndrome(&received_string, &syndrome);

    if (syndrome == SYNDROME_NO_ERROR) { //No error
        candidate_messages[0].val = extract_message(received_string.val);
        *num_messages = 1;
    } else {
        //Generate candidates
        *num_messages = 0;
        for (int i = 0; i < CODEWORD_SIZE; i++) {
            if (syndrome == H_columns[i])
                candidate_messages[(*num_messages)++].val = received_string.val ^ ((uint64_t)(1) << CODEWORD_SIZE-i-1);
        }

    }

    return 0;
}


int main(int argc, char** argv) {
    if (argc != 3) {
        printf("Usage: sdecc <RECEIVED_STRING_BIN> <SIDE_INFORMATION_BIN>\n");
        printf("\n");
        printf("Codeword size (n): %d\n", CODEWORD_SIZE);
        printf("Message size (k): %d\n", MESSAGE_SIZE);
        printf("Parity size (r=n-k): %d\n", PARITY_SIZE);
        printf("Codeword mask: %016lx\n", CODEWORD_BITS_MASK);
        printf("Message mask: %016lx\n", MESSAGE_BITS_MASK);
        printf("Parity mask: %016lx\n", PARITY_BITS_MASK);
        return 1; 
    }

    //Parse input
    word_t received_string;
    word_t si[8];

    int fail = 0;

    fail = parse_binary_string(argv[1], strlen(argv[1]), &received_string);
    char* curr = strtok(argv[2], ",");
    for (int i = 0; i < 7; i++) {
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

    printf("Received string: %016lx\n", received_string.val);
    for (int i = 0; i < 7; i++)
        printf("SI[%d]: %016lx\n", i, si[i].val); 

    //Compute candidate codewords
    word_t candidate_messages[6];
    size_t num_messages = 0;
    if (compute_candidate_messages(received_string, candidate_messages, 6, &num_messages)) {
        printf("failed to compute candidates\n");
        return 1;
    }

    for (int i = 0; i < num_messages; i++)
        printf("candidate_message[%d]: %016lx\n", i, candidate_messages[i].val); 

    return 0;
}
