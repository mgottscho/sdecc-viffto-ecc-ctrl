#ifndef __DECODER_HH__
#define __DECODER_HH__

#include <stdint.h>

//total hack to compile on Hoffman2...
/*#ifndef _WIN32
typedef unsigned long uint64_t;
#else
#include <cstdint>
#endif*/

inline uint64_t
mask(int nbits)
{
    return (nbits == 64) ? (uint64_t)-1LL : (1ULL << nbits) - 1;
}

template <class T>
inline
T
mbits(T val, int first, int last)
{
    return val & (mask(first+1) & ~mask(last));
}

inline uint64_t
mask (int first, int last)
{
    return mbits((uint64_t)-1LL, first, last);
}

template <class T>
inline
T
bits(T val, int first, int last)
{
    int nbits = first - last + 1;
    return (val >> last) & mask(nbits);
}

template <class T>
inline
T
bits(T val, int bit)
{
    return bits (val, bit, bit);
}

namespace MipsISAInst {

#undef OPCODE
#define OPCODE	bits(machInst, 31, 26)
#undef OPCODE_HI
#define OPCODE_HI	bits(machInst, 31, 29)
#undef OPCODE_LO
#define OPCODE_LO	bits(machInst, 28, 26)
#undef REGIMM
#define REGIMM	bits(machInst, 20, 16)
#undef REGIMM_HI
#define REGIMM_HI	bits(machInst, 20, 19)
#undef REGIMM_LO
#define REGIMM_LO	bits(machInst, 18, 16)
#undef FUNCTION
#define FUNCTION	bits(machInst,  5,  0)
#undef FUNCTION_HI
#define FUNCTION_HI	bits(machInst,  5,  3)
#undef FUNCTION_LO
#define FUNCTION_LO	bits(machInst,  2,  0)
#undef RS
#define RS	bits(machInst, 25, 21)
#undef RS_MSB
#define RS_MSB	bits(machInst, 25, 25)
#undef RS_HI
#define RS_HI	bits(machInst, 25, 24)
#undef RS_LO
#define RS_LO	bits(machInst, 23, 21)
#undef RS_SRL
#define RS_SRL	bits(machInst, 25, 22)
#undef RS_RT
#define RS_RT	bits(machInst, 25, 16)
#undef RT
#define RT	bits(machInst, 20, 16)
#undef RT_HI
#define RT_HI	bits(machInst, 20, 19)
#undef RT_LO
#define RT_LO	bits(machInst, 18, 16)
#undef RT_RD
#define RT_RD	bits(machInst, 20, 11)
#undef RD
#define RD	bits(machInst, 15, 11)
#undef INTIMM
#define INTIMM	bits(machInst, 15,  0)
#undef RS_RT_INTIMM
#define RS_RT_INTIMM	bits(machInst, 25,  0)
#undef FMT
#define FMT	bits(machInst, 25, 21)
#undef FR
#define FR	bits(machInst, 25, 21)
#undef FT
#define FT	bits(machInst, 20, 16)
#undef FS
#define FS	bits(machInst, 15, 11)
#undef FD
#define FD	bits(machInst, 10,  6)
#undef ND
#define ND	bits(machInst, 17, 17)
#undef TF
#define TF	bits(machInst, 16, 16)
#undef MOVCI
#define MOVCI	bits(machInst, 16, 16)
#undef MOVCF
#define MOVCF	bits(machInst, 16, 16)
#undef SRL
#define SRL	bits(machInst, 21, 21)
#undef SRLV
#define SRLV	bits(machInst,  6,  6)
#undef SA
#define SA	bits(machInst, 10,  6)
#undef CC
#define CC	bits(machInst, 10,  8)
#undef BRANCH_CC
#define BRANCH_CC	bits(machInst, 20, 18)
#undef SEL
#define SEL	bits(machInst,  2,  0)
#undef SC
#define SC	bits(machInst,  5,  5)
#undef OFFSET
#define OFFSET	bits(machInst, 15,  0)
#undef JMPTARG
#define JMPTARG	bits(machInst, 25,  0)
#undef HINT
#define HINT	bits(machInst, 10,  6)
#undef SYSCALLCODE
#define SYSCALLCODE	bits(machInst, 25,  6)
#undef TRAPCODE
#define TRAPCODE	bits(machInst, 15, 13)
#undef MSB
#define MSB	bits(machInst, 15, 11)
#undef LSB
#define LSB	bits(machInst, 10,  6)
#undef M5FUNC
#define M5FUNC	bits(machInst,  7,  0)
#undef OP
#define OP	bits(machInst, 10,  6)
#undef OP_HI
#define OP_HI	bits(machInst, 10,  9)
#undef OP_LO
#define OP_LO	bits(machInst,  8,  6)
#undef DSPSA
#define DSPSA	bits(machInst, 23, 21)
#undef HILOSA
#define HILOSA	bits(machInst, 25, 20)
#undef RDDSPMASK
#define RDDSPMASK	bits(machInst, 21, 16)
#undef WRDSPMASK
#define WRDSPMASK	bits(machInst, 16, 11)
#undef ACSRC
#define ACSRC	bits(machInst, 22, 21)
#undef ACDST
#define ACDST	bits(machInst, 12, 11)
#undef BP
#define BP	bits(machInst, 12, 11)
#undef POS
#define POS	bits(machInst, 10,  6)
#undef MT_U
#define MT_U	bits(machInst,  5,  5)
#undef MT_H
#define MT_H	bits(machInst,  4,  4)
#undef CACHE_OP
#define CACHE_OP	bits(machInst, 20, 16)

}

#endif
