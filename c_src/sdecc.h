/*
 * Author: Mark Gottscho
 * Email: mgottscho@ucla.edu
 */

#include <stdint.h>

//UL-ELC (systematic form, r=3, k=32, n=35)
#define CODEWORD_SIZE 35
#define MESSAGE_SIZE 32
#define PARITY_SIZE (CODEWORD_SIZE - MESSAGE_SIZE)

#define CODEWORD_BITS_MASK (((uint64_t)(1) << CODEWORD_SIZE) - 1)
#define PARITY_BITS_MASK (((uint64_t)(1) << PARITY_SIZE) - 1)
#define MESSAGE_BITS_MASK (CODEWORD_BITS_MASK ^ PARITY_BITS_MASK)

//ULEL_even (35,32) H matrix
/*
    0   0   0   0   0   0   0   0   1   1   1   1   0   0   0   0   0   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   0   0
    0   0   0   0   1   1   1   1   0   0   0   0   1   1   1   1   1   0   0   0   0   0   1   1   1   1   1   1   1   1   1   1   0   1   0
    1   1   1   1   0   0   0   0   0   0   0   0   1   1   1   1   1   1   1   1   1   1   0   0   0   0   0   1   1   1   1   1   0   0   1
*/
uint64_t H_rows[3] = {0x00783fffc, 0x0787c1ffa, 0x7807fe0f9};
uint8_t H_columns[35] = {1,1,1,1,2,2,2,2,4,4,4,4,3,3,3,3,3,5,5,5,5,5,6,6,6,6,6,7,7,7,7,7,4,2,1};

#define SYNDROME_NO_ERROR 0
#define SYNDROME_CHUNK_1 1
#define MASK_CHUNK_1 ((uint64_t)(0x780000001))
#define SYNDROME_CHUNK_2 2
#define MASK_CHUNK_2 ((uint64_t)(0x078000002))
#define SYNDROME_CHUNK_3 4
#define MASK_CHUNK_3 ((uint64_t)(0x007800004))
#define SYNDROME_CHUNK_4 3
#define MASK_CHUNK_4 ((uint64_t)(0x0007c0000))
#define SYNDROME_CHUNK_5 5
#define MASK_CHUNK_5 ((uint64_t)(0x00003e000))
#define SYNDROME_CHUNK_6 6
#define MASK_CHUNK_6 ((uint64_t)(0x000001f00))
#define SYNDROME_CHUNK_7 7
#define MASK_CHUNK_7 ((uint64_t)(0x0000000f8))

typedef union {
   uint64_t val;
   char bytes[8];
} word_t;

int parse_binary_string(const char* s, const size_t len, word_t* w);
int compute_syndrome(const word_t* received_string, uint64_t* syndrome);
uint64_t extract_message(const uint64_t codeword);
int compute_candidate_messages(const word_t received_string, word_t* candidate_messages, const size_t max_messages, size_t* num_messages);
