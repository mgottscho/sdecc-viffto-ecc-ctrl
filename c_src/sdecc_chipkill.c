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
        w.val.H = w.val.H ^ ((uint64_t)(1) << pos - H_OFFSET);
    else if (CODEWORD_SIZE-pos-1 >= M_OFFSET && CODEWORD_SIZE-pos-1 < H_OFFSET)
        w.val.M = w.val.M ^ ((uint64_t)(1) << pos - M_OFFSET);
    else if (CODEWORD_SIZE-pos-1 >= L_OFFSET && CODEWORD_SIZE-pos-1 < M_OFFSET)
        w.val.L = w.val.L ^ ((uint64_t)(1) << pos - L_OFFSET);
    return w; 
}

int chipkill_decoder(const word_t received_string, const uint64_t syndrome, int* corrected, word_t* corrected_codeword) {
    if (!num_errors || !corrected_codeword)
        return 1;

    //First check for single-bit errors within a symbol
    *corrected_codeword = received_string;
    for (int i = 0; i < CODEWORD_SIZE; i++) {
        if (syndrome == H_columns[i]) {
            *corrected_codeword = flip_bit(received_string, i);
            return 0;
        }
    }
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
        return 1;
    } else {
        //Generate candidates
        *num_messages = 0;

        //Check for correctable error
        int corrected = 0;
        word_t corrected_codeword;
        if (chipkill_decoder(received_string, syndrome, &corrected, &corrected_codeword))
            return 1;

        if (corrected)
            return 1;

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
    double avg_hamming_dist[num_si];
    double min_avg_hamming_dist = sizeof(word_t)*8;
    int chosen_index = -1;
    for (int i = 0; i < num_messages; i++) {
        avg_hamming_dist[i] = 0;
        for (int j = 0; j < num_si; j++) {
            avg_hamming_dist[i] += (double)(__builtin_popcountl(candidate_messages[i].val.H ^ si[j].val.H));
            avg_hamming_dist[i] += (double)(__builtin_popcountl(candidate_messages[i].val.M ^ si[j].val.M));
            avg_hamming_dist[i] += (double)(__builtin_popcountl(candidate_messages[i].val.L ^ si[j].val.L));
        }
        avg_hamming_dist[i] /= num_si;
        if (avg_hamming_dist[i] <= min_avg_hamming_dist) {
            min_avg_hamming_dist = avg_hamming_dist[i];
            chosen_index = i;
        }
        //printf("avg_hamming_dist[%d]: %f\n", i, avg_hamming_dist[i]);
        //printf("chosen_index: %d\n", chosen_index);
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

    printf("Received string: %016lx %016lx %016lx\n", received_string.val.H, received_string.val.M, received_string.val.L);
    for (int i = 0; i < 7; i++)
        printf("SI[%d]: %016lx %016lx %016lx\n", i, si[i].val.H, si[i].val.M, si[i].val.L); 

    //Compute candidate codewords

    //starttick();

    word_t candidate_messages[10];
    size_t num_messages = 0;
    if (compute_candidate_messages(received_string, candidate_messages, 10, &num_messages)) {
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
        if (hamming_distance_recovery(candidate_messages, num_messages, si, 7, &chosen_message)) {
            printf("bad recovery\n");
            return 1;
        }
    }

    //stoptick();
    //printtick();

    printf("chosen message: %016lx %016lx %016lx\n", chosen_message.val.H, chosen_message.val.M, chosen_message.val.L);

    return 0;
}

