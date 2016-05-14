#include "decoder.hh"
#include "MyDecoder.hh"
#include <iostream>

//#include <cmath>

//#if defined(linux)
//#include <fenv.h>
//#endif

using namespace MipsISA;


bool
Decoder::decodeInst(ExtMachInst machInst)
{
    using namespace MipsISAInst;
  switch (OPCODE_HI) {
    
    case 0x0:
      switch (OPCODE_LO) {
        
        case 0x0:
          switch (FUNCTION_HI) {
            
            case 0x0:
              switch (FUNCTION_LO) {
                
                case 0x1:
                  switch (MOVCI) {
                    
                    case 0x0:  
                      // BasicOp::movf(['\n                            Rd = (getCondCode(FCSR, CC) == 0) ? Rd : Rs;\n                        '],{})
                      
                              std::cout << "movf" << std::endl;
                              return 0;// Movf(machInst);
                      break;
                    
                    case 0x1:  
                      // BasicOp::movt(['\n                            Rd = (getCondCode(FCSR, CC) == 1) ? Rd : Rs;\n                        '],{})
                      
                              std::cout << "movt" << std::endl;
                              return 0;// Movt(machInst);
                      break;
                    
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                case 0x0:
                  switch (RS) {
                    
                    case 0x0:
                      switch (RT_RD) {
                        
                        case 0x0:
                          switch (SA) {
                            
                            case 0x1:  
                              // BasicOp::ssnop([';'],{})
                              
                                      std::cout << "ssnop" << std::endl;
                                      return 0;// Ssnop(machInst);
                              break;
                            
                            case 0x3:  
                              // BasicOp::ehb([';'],{})
                              
                                      std::cout << "ehb" << std::endl;
                                      return 0;// Ehb(machInst);
                              break;
                            
                            default:
                              
                              // Nop::nop(([], {}))
                              std::cout << "nop" << std::endl;
                              return 0;// Nop("",machInst);
                              break;
                            }
                          
                        default:  
                          // BasicOp::sll([' Rd = Rt_uw << SA; '],{})
                          
                                  std::cout << "sll" << std::endl;
                                  return 0;// Sll(machInst);
                          break;
                        }
                      
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                case 0x2:
                  switch (RS_SRL) {
                    
                    case 0x0:
                      switch (SRL) {
                        
                        case 0x0:  
                          // BasicOp::srl([' Rd = Rt_uw >> SA; '],{})
                          
                                  std::cout << "srl" << std::endl;
                                  return 0;// Srl(machInst);
                          break;
                        
                        case 0x1:  
                          // BasicOp::rotr(['\n                                Rd = (Rt_uw << (32 - SA)) | (Rt_uw >> SA);\n                            '],{})
                          
                                  std::cout << "rotr" << std::endl;
                                  return 0;// Rotr(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                case 0x3:
                  switch (RS) {
                    
                    case 0x0:  
                      // BasicOp::sra(['\n                            uint32_t temp = Rt >> SA;\n                            if ( (Rt & 0x80000000) > 0 ) {\n                                uint32_t mask = 0x80000000;\n                                for(int i=0; i < SA; i++) {\n                                    temp |= mask;\n                                    mask = mask >> 1;\n                                }\n                            }\n                            Rd = temp;\n                        '],{})
                      
                              std::cout << "sra" << std::endl;
                              return 0;// Sra(machInst);
                      break;
                    
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                case 0x4:  
                  // BasicOp::sllv([' Rd = Rt_uw << Rs<4:0>; '],{})
                  
                          std::cout << "sllv" << std::endl;
return 0;// Sllv(machInst);
                  break;
                
                case 0x6:
                  switch (SRLV) {
                    
                    case 0x0:  
                      // BasicOp::srlv([' Rd = Rt_uw >> Rs<4:0>; '],{})
                      
                              std::cout << "srlv" << std::endl;
return 0;// Srlv(machInst);
                      break;
                    
                    case 0x1:  
                      // BasicOp::rotrv(['\n                            Rd = (Rt_uw << (32 - Rs<4:0>)) |\n                                 (Rt_uw >> Rs<4:0>);\n                        '],{})
                      
                              std::cout << "rotrv" << std::endl;
return 0;// Rotrv(machInst);
                      break;
                    
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                case 0x7:  
                  // BasicOp::srav(['\n                        int shift_amt = Rs<4:0>;\n\n                        uint32_t temp = Rt >> shift_amt;\n\n                        if ((Rt & 0x80000000) > 0) {\n                            uint32_t mask = 0x80000000;\n                            for (int i = 0; i < shift_amt; i++) {\n                                temp |= mask;\n                                mask = mask >> 1;\n                            }\n                        }\n                        Rd = temp;\n                    '],{})
                  
                          std::cout << "srav" << std::endl;
return 0;// Srav(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x1:
              switch (FUNCTION_LO) {
                
                case 0x0:
                  switch (HINT) {
                    
                    case 0x1:  
                      // Jump::jr_hb(['\n                            Config1Reg config1 = Config1;\n                            if (config1.ca == 0) {\n                                NNPC = Rs;\n                            } else {\n                                panic("MIPS16e not supported\\n");\n                            }\n                        ', 'IsReturn', 'ClearHazards'],{})
                      
                              std::cout << "jr_hb" << std::endl;
return 0;// Jr_hb(machInst);
                      break;
                    
                    default:  
                      // Jump::jr(['\n                            Config1Reg config1 = Config1;\n                            if (config1.ca == 0) {\n                                NNPC = Rs;\n                            } else {\n                                panic("MIPS16e not supported\\n");\n                            }\n                        ', 'IsReturn'],{})
                      
                              std::cout << "jr" << std::endl;
return 0;// Jr(machInst);
                      break;
                    }
                  
                case 0x1:
                  switch (HINT) {
                    
                    case 0x1:  
                      // Jump::jalr_hb(['\n                            Rd = NNPC;\n                            NNPC = Rs;\n                        ', 'IsCall', 'ClearHazards'],{})
                      
                              std::cout << "jalr_hb" << std::endl;
return 0;// Jalr_hb(machInst);
                      break;
                    
                    default:  
                      // Jump::jalr(['\n                            Rd = NNPC;\n                            NNPC = Rs;\n                        ', 'IsCall'],{})
                      
                              std::cout << "jalr" << std::endl;
return 0;// Jalr(machInst);
                      break;
                    }
                  
                case 0x2:  
                  // BasicOp::movz([' Rd = (Rt == 0) ? Rs : Rd; '],{})
                  
                          std::cout << "movz" << std::endl;
return 0;// Movz(machInst);
                  break;
                
                case 0x3:  
                  // BasicOp::movn([' Rd = (Rt != 0) ? Rs : Rd; '],{})
                  
                          std::cout << "movn" << std::endl;
return 0;// Movn(machInst);
                  break;
                
                case 0x4:
                  //switch (FullSystemInt) {
                    
                   // case 0x0:  
                      // BasicOp::syscall_se([' xc->syscall(R2); ', 'IsSerializeAfter', 'IsNonSpeculative'],{})
                      
                              std::cout << "syscall_se" << std::endl;
return 0;// Syscall_se(machInst);
                    //  break;
                    
                    //default:  
                      // BasicOp::syscall([' fault = new SystemCallFault(); '],{})
                      
                              //std::cout << "syscall" << std::endl;
return 0;// Syscall(machInst);
                      break;
                    //}
                  
                case 0x7:  
                  // BasicOp::sync([' ; ', 'IsMemBarrier'],{})
                  
                          std::cout << "sync" << std::endl;
return 0;// Sync(machInst);
                  break;
                
                case 0x5:  
                  // BasicOp::break(['fault = new BreakpointFault();'],{})
                  
                          std::cout << "break" << std::endl;
return 0;// Break(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x2:
              switch (FUNCTION_LO) {
                
                case 0x0:  
                  // HiLoRsSelOp::mfhi(([' Rd = HI_RS_SEL; ', 'IntMultOp', 'IsIprAccess'], {}))
                  
                          std::cout << "mfhi" << std::endl;
return 0;// Mfhi(machInst);
                  break;
                
                case 0x1:  
                  // HiLoRdSelOp::mthi(([' HI_RD_SEL = Rs; '], {}))
                  
                          std::cout << "mthi" << std::endl;
return 0;// Mthi(machInst);
                  break;
                
                case 0x2:  
                  // HiLoRsSelOp::mflo(([' Rd = LO_RS_SEL; ', 'IntMultOp', 'IsIprAccess'], {}))
                  
                          std::cout << "mflo" << std::endl;
return 0;// Mflo(machInst);
                  break;
                
                case 0x3:  
                  // HiLoRdSelOp::mtlo(([' LO_RD_SEL = Rs; '], {}))
                  
                          std::cout << "mtlo" << std::endl;
return 0;// Mtlo(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x3:
              switch (FUNCTION_LO) {
                
                case 0x0:  
                  // HiLoRdSelValOp::mult([' val = Rs_sd * Rt_sd; ', 'IntMultOp'],{})
                  
                          std::cout << "mult" << std::endl;
return 0;// Mult(machInst);
                  break;
                
                case 0x1:  
                  // HiLoRdSelValOp::multu([' val = Rs_ud * Rt_ud; ', 'IntMultOp'],{})
                  
                          std::cout << "multu" << std::endl;
return 0;// Multu(machInst);
                  break;
                
                case 0x2:  
                  // HiLoOp::div(['\n                        if (Rt_sd != 0) {\n                            HI0 = Rs_sd % Rt_sd;\n                            LO0 = Rs_sd / Rt_sd;\n                        }\n                    ', 'IntDivOp'],{})
                  
                          std::cout << "div" << std::endl;
return 0;// Div(machInst);
                  break;
                
                case 0x3:  
                  // HiLoOp::divu(['\n                        if (Rt_ud != 0) {\n                            HI0 = Rs_ud % Rt_ud;\n                            LO0 = Rs_ud / Rt_ud;\n                        }\n                    ', 'IntDivOp'],{})
                  
                          std::cout << "divu" << std::endl;
return 0;// Divu(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x4:
              switch (HINT) {
                
                case 0x0:
                  switch (FUNCTION_LO) {
                    
                    case 0x0:  
                      // IntOp::add(['\n                            IntReg result;\n                            Rd = result = Rs + Rt;\n                            if (FullSystem &&\n                                    findOverflow(32, result, Rs, Rt)) {\n                                fault = new IntegerOverflowFault();\n                            }\n                        '],{})
                      
                       /*{
                           MipsStaticInst *i = new Add(machInst);
                           //if (RD == 0) {
                               //i = makeNop(i);
                               //}
                           return i;
                       }*/
                       std::cout << "add" << std::endl;
                       return 0;
                      break;
                    
                    case 0x1:  
                      // IntOp::addu([' Rd_sw = Rs_sw + Rt_sw;'],{})
                      
                       /*{
                           MipsStaticInst *i = new Addu(machInst);
                           //if (RD == 0) {
                               //i = makeNop(i);
                               //}
                           return i;
                       }*/
                       std::cout << "addu" << std::endl;
                       return 0;
                      break;
                    
                    case 0x2:  
                      // IntOp::sub(['\n                            IntReg result;\n                            Rd = result = Rs - Rt;\n                            if (FullSystem &&\n                                    findOverflow(32, result, Rs, ~Rt)) {\n                                fault = new IntegerOverflowFault();\n                            }\n                        '],{})
                      
                       /*{
                           MipsStaticInst *i = new Sub(machInst);
                           //if (RD == 0) {
                               //i = makeNop(i);
                               //}
                           return i;
                       }*/
                       std::cout << "sub" << std::endl;
                       return 0;
                      break;
                    
                    case 0x3:  
                      // IntOp::subu([' Rd_sw = Rs_sw - Rt_sw; '],{})
                      
                       /*{
                           MipsStaticInst *i = new Subu(machInst);
                           //if (RD == 0) {
                               //i = makeNop(i);
                               //}
                           return i;
                       }*/
                       std::cout << "subu" << std::endl;
                       return 0;
                      break;
                    
                    case 0x4:  
                      // IntOp::and([' Rd = Rs & Rt; '],{})
                      
                       /*{
                           MipsStaticInst *i = new And(machInst);
                           //if (RD == 0) {
                               //i = makeNop(i);
                               //}
                           return i;
                       }*/
                       std::cout << "and" << std::endl;
                       return 0;
                      break;
                    
                    case 0x5:  
                      // IntOp::or([' Rd = Rs | Rt; '],{})
                      
                       /*{
                           MipsStaticInst *i = new Or(machInst);
                           //if (RD == 0) {
                               //i = makeNop(i);
                               //}
                           return i;
                       }*/
                       std::cout << "or" << std::endl;
                       return 0;
                      break;
                    
                    case 0x6:  
                      // IntOp::xor([' Rd = Rs ^ Rt; '],{})
                      
                       /*{
                           MipsStaticInst *i = new Xor(machInst);
                           //if (RD == 0) {
                               //i = makeNop(i);
                               //}
                           return i;
                       }*/
                       std::cout << "xor" << std::endl;
                       return 0;
                      break;
                    
                    case 0x7:  
                      // IntOp::nor([' Rd = ~(Rs | Rt); '],{})
                      
                       /*{
                           MipsStaticInst *i = new Nor(machInst);
                           //if (RD == 0) {
                               //i = makeNop(i);
                               //}
                           return i;
                       }*/
                       std::cout << "nor" << std::endl;
                       return 0;
                      break;
                    
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x5:
              switch (HINT) {
                
                case 0x0:
                  switch (FUNCTION_LO) {
                    
                    case 0x2:  
                      // IntOp::slt(['  Rd_sw = (Rs_sw < Rt_sw) ? 1 : 0 '],{})
                      
                       /*{
                           MipsStaticInst *i = new Slt(machInst);
                           //if (RD == 0) {
                               //i = makeNop(i);
                               //}
                           return i;
                       }*/
                       std::cout << "slt" << std::endl;
                       return 0;
                      break;
                    
                    case 0x3:  
                      // IntOp::sltu([' Rd_uw = (Rs_uw < Rt_uw) ? 1 : 0 '],{})
                      
                       /*{
                           MipsStaticInst *i = new Sltu(machInst);
                           //if (RD == 0) {
                               //i = makeNop(i);
                               //}
                           return i;
                       }*/
                       std::cout << "sltu" << std::endl;
                       return 0;
                      break;
                    
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x6:
              switch (FUNCTION_LO) {
                
                case 0x0:  
                  // Trap::tge(['  cond = (Rs_sw >= Rt_sw); '],{})
                  
                          std::cout << "tge" << std::endl;
return 0;// Tge(machInst);
                  break;
                
                case 0x1:  
                  // Trap::tgeu([' cond = (Rs_uw >= Rt_uw); '],{})
                  
                          std::cout << "tgeu" << std::endl;
return 0;// Tgeu(machInst);
                  break;
                
                case 0x2:  
                  // Trap::tlt([' cond = (Rs_sw < Rt_sw); '],{})
                  
                          std::cout << "tlt" << std::endl;
return 0;// Tlt(machInst);
                  break;
                
                case 0x3:  
                  // Trap::tltu([' cond = (Rs_uw < Rt_uw); '],{})
                  
                          std::cout << "tltu" << std::endl;
return 0;// Tltu(machInst);
                  break;
                
                case 0x4:  
                  // Trap::teq([' cond = (Rs_sw == Rt_sw); '],{})
                  
                          std::cout << "teq" << std::endl;
return 0;// Teq(machInst);
                  break;
                
                case 0x6:  
                  // Trap::tne([' cond = (Rs_sw != Rt_sw); '],{})
                  
                          std::cout << "tne" << std::endl;
return 0;// Tne(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            default:
              
              // Unknown::unknown(([], {}))
              std::cout << "UNKNOWN" << std::endl;
              return 1;//Unknown(machInst);
              break;
            }
          
        case 0x1:
          switch (REGIMM_HI) {
            
            case 0x0:
              switch (REGIMM_LO) {
                
                case 0x0:  
                  // Branch::bltz([' cond = (Rs_sw < 0); '],{})
                  
                          std::cout << "bltz" << std::endl;
return 0;// Bltz(machInst);
                  break;
                
                case 0x1:  
                  // Branch::bgez([' cond = (Rs_sw >= 0); '],{})
                  
                          std::cout << "bgez" << std::endl;
return 0;// Bgez(machInst);
                  break;
                
                case 0x2:  
                  // Branch::bltzl([' cond = (Rs_sw < 0); ', 'Likely'],{})
                  
                          std::cout << "bltzl" << std::endl;
return 0;// Bltzl(machInst);
                  break;
                
                case 0x3:  
                  // Branch::bgezl([' cond = (Rs_sw >= 0); ', 'Likely'],{})
                  
                          std::cout << "bgezl" << std::endl;
return 0;// Bgezl(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x1:
              switch (REGIMM_LO) {
                
                case 0x0:  
                  // TrapImm::tgei([' cond = (Rs_sw >= (int16_t)INTIMM); '],{})
                  
                          std::cout << "tgei" << std::endl;
return 0;// Tgei(machInst);
                  break;
                
                case 0x1:  
                  // TrapImm::tgeiu(['\n                        cond = (Rs_uw >= (uint32_t)(int32_t)(int16_t)INTIMM);\n                    '],{})
                  
                          std::cout << "tgeiu" << std::endl;
return 0;// Tgeiu(machInst);
                  break;
                
                case 0x2:  
                  // TrapImm::tlti([' cond = (Rs_sw < (int16_t)INTIMM); '],{})
                  
                          std::cout << "tlti" << std::endl;
return 0;// Tlti(machInst);
                  break;
                
                case 0x3:  
                  // TrapImm::tltiu(['\n                        cond = (Rs_uw < (uint32_t)(int32_t)(int16_t)INTIMM);\n                    '],{})
                  
                          std::cout << "tltiu" << std::endl;
return 0;// Tltiu(machInst);
                  break;
                
                case 0x4:  
                  // TrapImm::teqi([' cond = (Rs_sw == (int16_t)INTIMM); '],{})
                  
                          std::cout << "teqi" << std::endl;
return 0;// Teqi(machInst);
                  break;
                
                case 0x6:  
                  // TrapImm::tnei([' cond = (Rs_sw != (int16_t)INTIMM); '],{})
                  
                          std::cout << "tnei" << std::endl;
return 0;// Tnei(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x2:
              switch (REGIMM_LO) {
                
                case 0x0:  
                  // Branch::bltzal([' cond = (Rs_sw < 0); ', 'Link'],{})
                  
                          std::cout << "bltzal" << std::endl;
return 0;// Bltzal(machInst);
                  break;
                
                case 0x1:
                  switch (RS) {
                    
                    case 0x0:  
                      // Branch::bal([' cond = 1; ', 'IsCall', 'Link'],{})
                      
                              std::cout << "bal" << std::endl;
return 0;// Bal(machInst);
                      break;
                    
                    default:  
                      // Branch::bgezal([' cond = (Rs_sw >= 0); ', 'Link'],{})
                      
                              std::cout << "bgezal" << std::endl;
return 0;// Bgezal(machInst);
                      break;
                    }
                  
                case 0x2:  
                  // Branch::bltzall([' cond = (Rs_sw < 0); ', 'Link', 'Likely'],{})
                  
                          std::cout << "bltzall" << std::endl;
return 0;// Bltzall(machInst);
                  break;
                
                case 0x3:  
                  // Branch::bgezall([' cond = (Rs_sw >= 0); ', 'Link', 'Likely'],{})
                  
                          std::cout << "bgezall" << std::endl;
return 0;// Bgezall(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x3:
              switch (REGIMM_LO) {
                
                case 0x4:  
                  // DspBranch::bposge32(([' cond = (dspctl<5:0> >= 32); '], {}))
                  
                          std::cout << "bposge32" << std::endl;
return 0;// Bposge32(machInst);
                  break;
                
                case 0x7:  
                  // WarnUnimpl::synci([],{})
                  
                          std::cout << "synci" << std::endl;
return 0;// WarnUnimplemented("synci", machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            default:
              
              // Unknown::unknown(([], {}))
              std::cout << "UNKNOWN" << std::endl;
              return 1;//Unknown(machInst);
              break;
            }
          
        case 0x2:  
          // Jump::j([' NNPC = (NPC & 0xF0000000) | (JMPTARG << 2); '],{})
          
                  std::cout << "j" << std::endl;
return 0;// J(machInst);
          break;
        
        case 0x3:  
          // Jump::jal([' NNPC = (NPC & 0xF0000000) | (JMPTARG << 2); ', 'IsCall', 'Link'],{})
          
                  std::cout << "jal" << std::endl;
return 0;// Jal(machInst);
          break;
        
        case 0x4:
          switch (RS_RT) {
            
            case 0x0:  
              // Branch::b([' cond = 1; '],{})
              
                      std::cout << "b" << std::endl;
return 0;// B(machInst);
              break;
            
            default:  
              // Branch::beq([' cond = (Rs_sw == Rt_sw); '],{})
              
                      std::cout << "beq" << std::endl;
return 0;// Beq(machInst);
              break;
            }
          
        case 0x5:  
          // Branch::bne([' cond = (Rs_sw != Rt_sw); '],{})
          
                  std::cout << "bne" << std::endl;
return 0;// Bne(machInst);
          break;
        
        case 0x6:  
          // Branch::blez([' cond = (Rs_sw <= 0); '],{})
          
                  std::cout << "blez" << std::endl;
return 0;// Blez(machInst);
          break;
        
        case 0x7:  
          // Branch::bgtz([' cond = (Rs_sw > 0); '],{})
          
                  std::cout << "bgtz" << std::endl;
return 0;// Bgtz(machInst);
          break;
        
        default:
          
          // Unknown::unknown(([], {}))
          std::cout << "UNKNOWN" << std::endl;
          return 1;//Unknown(machInst);
          break;
        }
      
    case 0x1:
      switch (OPCODE_LO) {
        
        case 0x0:  
          // IntImmOp::addi(['\n                IntReg result;\n                Rt = result = Rs + imm;\n                if (FullSystem &&\n                        findOverflow(32, result, Rs, imm)) {\n                    fault = new IntegerOverflowFault();\n                }\n            '],{})
          
           /*{
               MipsStaticInst *i = new Addi(machInst);
               //if (RT == 0) {
               // i = makeNop(i);
               // }
               return i;
           }*/
           std::cout << "addi" << std::endl;
           return 0;
          break;
        
        case 0x1:  
          // IntImmOp::addiu([' Rt_sw = Rs_sw + imm; '],{})
          
           /*{
               MipsStaticInst *i = new Addiu(machInst);
               //if (RT == 0) {
               // i = makeNop(i);
               // }
               return i;
           }*/
           std::cout << "addiu" << std::endl;
           return 0;
          break;
        
        case 0x2:  
          // IntImmOp::slti([' Rt_sw = (Rs_sw < imm) ? 1 : 0 '],{})
          
           /*{
               MipsStaticInst *i = new Slti(machInst);
               //if (RT == 0) {
               // i = makeNop(i);
               // }
               return i;
           }*/
           std::cout << "slti" << std::endl;
           return 0;
          break;
        
        case 0x3:  
          // IntImmOp::sltiu([' Rt_uw = (Rs_uw < (uint32_t)sextImm) ? 1 : 0;'],{})
          
           /*{
               MipsStaticInst *i = new Sltiu(machInst);
               //if (RT == 0) {
               // i = makeNop(i);
               // }
               return i;
           }*/
           std::cout << "sltiu" << std::endl;
           return 0;
          break;
        
        case 0x4:  
          // IntImmOp::andi([' Rt_sw = Rs_sw & zextImm; '],{})
          
           /*{
               MipsStaticInst *i = new Andi(machInst);
               //if (RT == 0) {
               // i = makeNop(i);
               // }
               return i;
           }*/
           std::cout << "andi" << std::endl;
           return 0;
          break;
        
        case 0x5:  
          // IntImmOp::ori([' Rt_sw = Rs_sw | zextImm; '],{})
          
           /*{
               MipsStaticInst *i = new Ori(machInst);
               //if (RT == 0) {
               // i = makeNop(i);
               // }
               return i;
           }*/
           std::cout << "ori" << std::endl;
           return 0;
          break;
        
        case 0x6:  
          // IntImmOp::xori([' Rt_sw = Rs_sw ^ zextImm; '],{})
          
           /*{
               MipsStaticInst *i = new Xori(machInst);
               //if (RT == 0) {
               // i = makeNop(i);
               // }
               return i;
           }*/
           std::cout << "xori" << std::endl;
           return 0;
          break;
        
        case 0x7:
          switch (RS) {
            
            case 0x0:  
              // IntImmOp::lui([' Rt = imm << 16; '],{})
              
               /*{
                   MipsStaticInst *i = new Lui(machInst);
                   //if (RT == 0) {
                   // i = makeNop(i);
                   // }
                   return i;
               }*/
               std::cout << "lui" << std::endl;
               return 0;
              break;
            
            default:
              
              // Unknown::unknown(([], {}))
              std::cout << "UNKNOWN" << std::endl;
              return 1;//Unknown(machInst);
              break;
            }
          
        default:
          
          // Unknown::unknown(([], {}))
          std::cout << "UNKNOWN" << std::endl;
          return 1;//Unknown(machInst);
          break;
        }
      
    case 0x2:
      switch (OPCODE_LO) {
        
        case 0x0:
          switch (RS_MSB) {
            
            case 0x0:
              switch (RS) {
                
                case 0x0:  
                  // CP0Control::mfc0(['\n                        Config3Reg config3 = Config3;\n                        PageGrainReg pageGrain = PageGrain;\n                        Rt = CP0_RD_SEL;\n                        /* Hack for PageMask */\n                        if (RD == 5) {\n                            // PageMask\n                            if (config3.sp == 0 || pageGrain.esp == 0)\n                                Rt &= 0xFFFFE7FF;\n                        }\n                    '],{})
                  
                          std::cout << "mfc0" << std::endl;
return 0;// Mfc0(machInst);
                  break;
                
                case 0x4:  
                  // CP0Control::mtc0([' \n                        CP0_RD_SEL = Rt;\n                        CauseReg cause = Cause;\n                        IntCtlReg intCtl = IntCtl;\n                        if (RD == 11) {\n                            // Compare\n                            if (cause.ti == 1) {\n                                cause.ti = 0;\n                                int offset = 10; // corresponding to cause.ip0\n                                offset += intCtl.ipti - 2;\n                                replaceBits(cause, offset, offset, 0);\n                            }\n                        }\n                        Cause = cause;\n                    '],{})
                  
                          std::cout << "mtc0" << std::endl;
return 0;// Mtc0(machInst);
                  break;
                
                case 0x1:  
                  // CP0Unimpl::dmfc0([],{})
                  
                          std::cout << "dmfc0" << std::endl;
return 0;// CP0Unimplemented("dmfc0", machInst);
                  break;
                
                case 0x5:  
                  // CP0Unimpl::dmtc0([],{})
                  
                          std::cout << "dmtc0" << std::endl;
return 0;// CP0Unimplemented("dmtc0", machInst);
                  break;
                
                default:  
                  // CP0Unimpl::unknown([],{})
                  
                          std::cout << "UNKNOWN" << std::endl;
return 1;// CP0Unimplemented("unknown", machInst);
                  break;
                
                case 0x8:
                  switch (MT_U) {
                    
                    case 0x0:  
                      // MT_MFTR::mftc0(['\n                            data = xc->readRegOtherThread((RT << 3 | SEL) +\n                                                          Misc_Reg_Base);\n                        '],{})
                      
                              std::cout << "mftc0" << std::endl;
return 0;// Mftc0(machInst);
                      break;
                    
                    case 0x1:
                      switch (SEL) {
                        
                        case 0x0:  
                          // MT_MFTR::mftgpr(['\n                                data = xc->readRegOtherThread(RT);\n                            '],{})
                          
                                  std::cout << "mftgpr" << std::endl;
return 0;// Mftgpr(machInst);
                          break;
                        
                        case 0x1:
                          switch (RT) {
                            
                            case 0x0:  
                              // MT_MFTR::mftlo_dsp0([' data = xc->readRegOtherThread(INTREG_DSP_LO0); '],{})
                              
                                      std::cout << "mftlo_dsp0" << std::endl;
return 0;// Mftlo_dsp0(machInst);
                              break;
                            
                            case 0x1:  
                              // MT_MFTR::mfthi_dsp0([' data = xc->readRegOtherThread(INTREG_DSP_HI0); '],{})
                              
                                      std::cout << "mfthi_dsp0" << std::endl;
return 0;// Mfthi_dsp0(machInst);
                              break;
                            
                            case 0x2:  
                              // MT_MFTR::mftacx_dsp0([' data = xc->readRegOtherThread(INTREG_DSP_ACX0); '],{})
                              
                                      std::cout << "mftacx_dsp0" << std::endl;
return 0;// Mftacx_dsp0(machInst);
                              break;
                            
                            case 0x4:  
                              // MT_MFTR::mftlo_dsp1([' data = xc->readRegOtherThread(INTREG_DSP_LO1); '],{})
                              
                                      std::cout << "mftlo_dsp1" << std::endl;
return 0;// Mftlo_dsp1(machInst);
                              break;
                            
                            case 0x5:  
                              // MT_MFTR::mfthi_dsp1([' data = xc->readRegOtherThread(INTREG_DSP_HI1); '],{})
                              
                                      std::cout << "mfthi_dsp1" << std::endl;
return 0;// Mfthi_dsp1(machInst);
                              break;
                            
                            case 0x6:  
                              // MT_MFTR::mftacx_dsp1([' data = xc->readRegOtherThread(INTREG_DSP_ACX1); '],{})
                              
                                      std::cout << "mftacx_dsp1" << std::endl;
return 0;// Mftacx_dsp1(machInst);
                              break;
                            
                            case 0x8:  
                              // MT_MFTR::mftlo_dsp2([' data = xc->readRegOtherThread(INTREG_DSP_LO2); '],{})
                              
                                      std::cout << "mftlo_dsp2" << std::endl;
return 0;// Mftlo_dsp2(machInst);
                              break;
                            
                            case 0x9:  
                              // MT_MFTR::mfthi_dsp2([' data = xc->readRegOtherThread(INTREG_DSP_HI2); '],{})
                              
                                      std::cout << "mfthi_dsp2" << std::endl;
return 0;// Mfthi_dsp2(machInst);
                              break;
                            
                            case 0x10:  
                              // MT_MFTR::mftacx_dsp2([' data = xc->readRegOtherThread(INTREG_DSP_ACX2); '],{})
                              
                                      std::cout << "mftacx_dsp2" << std::endl;
return 0;// Mftacx_dsp2(machInst);
                              break;
                            
                            case 0x12:  
                              // MT_MFTR::mftlo_dsp3([' data = xc->readRegOtherThread(INTREG_DSP_LO3); '],{})
                              
                                      std::cout << "mftlo_dsp3" << std::endl;
return 0;// Mftlo_dsp3(machInst);
                              break;
                            
                            case 0x13:  
                              // MT_MFTR::mfthi_dsp3([' data = xc->readRegOtherThread(INTREG_DSP_HI3); '],{})
                              
                                      std::cout << "mfthi_dsp3" << std::endl;
return 0;// Mfthi_dsp3(machInst);
                              break;
                            
                            case 0x14:  
                              // MT_MFTR::mftacx_dsp3([' data = xc->readRegOtherThread(INTREG_DSP_ACX3); '],{})
                              
                                      std::cout << "mftacx_dsp3" << std::endl;
return 0;// Mftacx_dsp3(machInst);
                              break;
                            
                            case 0x16:  
                              // MT_MFTR::mftdsp([' data = xc->readRegOtherThread(INTREG_DSP_CONTROL); '],{})
                              
                                      std::cout << "mftdsp" << std::endl;
return 0;// Mftdsp(machInst);
                              break;
                            
                            default:  
                              // CP0Unimpl::unknown(([], {}))
                              
                                      std::cout << "unknown" << std::endl;
return 0;// CP0Unimplemented("unknown", machInst);
                              break;
                            }
                          
                        case 0x2:
                          switch (MT_H) {
                            
                            case 0x0:  
                              // MT_MFTR::mftc1([' data = xc->readRegOtherThread(RT +\n                                                                            FP_Reg_Base);\n                                '],{})
                              
                                      std::cout << "mftc1" << std::endl;
return 0;// Mftc1(machInst);
                              break;
                            
                            case 0x1:  
                              // MT_MFTR::mfthc1([' data = xc->readRegOtherThread(RT +\n                                                                             FP_Reg_Base);\n                                '],{})
                              
                                      std::cout << "mfthc1" << std::endl;
return 0;// Mfthc1(machInst);
                              break;
                            
                            default:
                              
                              // Unknown::unknown(([], {}))
                              std::cout << "UNKNOWN" << std::endl;
                              return 1;//Unknown(machInst);
                              break;
                            }
                          
                        case 0x3:  
                          // MT_MFTR::cftc1(['\n                                uint32_t fcsr_val = xc->readRegOtherThread(FLOATREG_FCSR +\n                                                                            FP_Reg_Base);\n                                switch (RT) {\n                                  case 0:\n                                    data = xc->readRegOtherThread(FLOATREG_FIR +\n                                                                  Misc_Reg_Base);\n                                    break;\n                                  case 25:\n                                    data = (fcsr_val & 0xFE000000 >> 24) |\n                                           (fcsr_val & 0x00800000 >> 23);\n                                    break;\n                                  case 26:\n                                    data = fcsr_val & 0x0003F07C;\n                                    break;\n                                  case 28:\n                                    data = (fcsr_val & 0x00000F80) |\n                                           (fcsr_val & 0x01000000 >> 21) |\n                                           (fcsr_val & 0x00000003);\n                                    break;\n                                  case 31:\n                                    data = fcsr_val;\n                                    break;\n                                  default:\n                                    fatal("FP Control Value (%d) Not Valid");\n                                }\n                            '],{})
                          
                                  std::cout << "cftc1" << std::endl;
return 0;// Cftc1(machInst);
                          break;
                        
                        default:  
                          // CP0Unimpl::unknown(([], {}))
                          
                                  std::cout << "UNKNOWN" << std::endl;
return 1;// CP0Unimplemented("unknown", machInst);
                          break;
                        }
                      
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                case 0xc:
                  switch (MT_U) {
                    
                    case 0x0:  
                      // MT_MTTR::mttc0([' xc->setRegOtherThread((RD << 3 | SEL) + Misc_Reg_Base,\n                                                            Rt);\n                                   '],{})
                      
                              std::cout << "mttc0" << std::endl;
return 0;// Mttc0(machInst);
                      break;
                    
                    case 0x1:
                      switch (SEL) {
                        
                        case 0x0:  
                          // MT_MTTR::mttgpr([' xc->setRegOtherThread(RD, Rt); '],{})
                          
                                  std::cout << "mttgpr" << std::endl;
return 0;// Mttgpr(machInst);
                          break;
                        
                        case 0x1:
                          switch (RT) {
                            
                            case 0x0:  
                              // MT_MTTR::mttlo_dsp0([' xc->setRegOtherThread(INTREG_DSP_LO0, Rt);\n                                                '],{})
                              
                                      std::cout << "mttlo_dsp0" << std::endl;
return 0;// Mttlo_dsp0(machInst);
                              break;
                            
                            case 0x1:  
                              // MT_MTTR::mtthi_dsp0([' xc->setRegOtherThread(INTREG_DSP_HI0,\n                                                                         Rt);\n                                                '],{})
                              
                                      std::cout << "mtthi_dsp0" << std::endl;
return 0;// Mtthi_dsp0(machInst);
                              break;
                            
                            case 0x2:  
                              // MT_MTTR::mttacx_dsp0([' xc->setRegOtherThread(INTREG_DSP_ACX0,\n                                                                          Rt);\n                                                 '],{})
                              
                                      std::cout << "mttacx_dsp0" << std::endl;
return 0;// Mttacx_dsp0(machInst);
                              break;
                            
                            case 0x4:  
                              // MT_MTTR::mttlo_dsp1([' xc->setRegOtherThread(INTREG_DSP_LO1,\n                                                                         Rt);\n                                                '],{})
                              
                                      std::cout << "mttlo_dsp1" << std::endl;
return 0;// Mttlo_dsp1(machInst);
                              break;
                            
                            case 0x5:  
                              // MT_MTTR::mtthi_dsp1([' xc->setRegOtherThread(INTREG_DSP_HI1,\n                                                                         Rt);\n                                                '],{})
                              
                                      std::cout << "mtthi_dsp1" << std::endl;
return 0;// Mtthi_dsp1(machInst);
                              break;
                            
                            case 0x6:  
                              // MT_MTTR::mttacx_dsp1([' xc->setRegOtherThread(INTREG_DSP_ACX1,\n                                                                          Rt);\n                                                 '],{})
                              
                                      std::cout << "mttacx_dsp1" << std::endl;
return 0;// Mttacx_dsp1(machInst);
                              break;
                            
                            case 0x8:  
                              // MT_MTTR::mttlo_dsp2([' xc->setRegOtherThread(INTREG_DSP_LO2,\n                                                                         Rt);\n                                                '],{})
                              
                                      std::cout << "mttlo_dsp2" << std::endl;
return 0;// Mttlo_dsp2(machInst);
                              break;
                            
                            case 0x9:  
                              // MT_MTTR::mtthi_dsp2([' xc->setRegOtherThread(INTREG_DSP_HI2,\n                                                                         Rt);\n                                                '],{})
                              
                                      std::cout << "mtthi_dsp2" << std::endl;
return 0;// Mtthi_dsp2(machInst);
                              break;
                            
                            case 0x10:  
                              // MT_MTTR::mttacx_dsp2([' xc->setRegOtherThread(INTREG_DSP_ACX2,\n                                                                           Rt);\n                                                  '],{})
                              
                                      std::cout << "mttacx_dsp2" << std::endl;
return 0;// Mttacx_dsp2(machInst);
                              break;
                            
                            case 0x12:  
                              // MT_MTTR::mttlo_dsp3([' xc->setRegOtherThread(INTREG_DSP_LO3,\n                                                                          Rt);\n                                                 '],{})
                              
                                      std::cout << "mttlo_dsp3" << std::endl;
return 0;// Mttlo_dsp3(machInst);
                              break;
                            
                            case 0x13:  
                              // MT_MTTR::mtthi_dsp3([' xc->setRegOtherThread(INTREG_DSP_HI3,\n                                                                          Rt);\n                                                 '],{})
                              
                                      std::cout << "mtthi_dsp3" << std::endl;
return 0;// Mtthi_dsp3(machInst);
                              break;
                            
                            case 0x14:  
                              // MT_MTTR::mttacx_dsp3([' xc->setRegOtherThread(INTREG_DSP_ACX3, Rt);\n                                                  '],{})
                              
                                      std::cout << "mttacx_dsp3" << std::endl;
return 0;// Mttacx_dsp3(machInst);
                              break;
                            
                            case 0x16:  
                              // MT_MTTR::mttdsp([' xc->setRegOtherThread(INTREG_DSP_CONTROL, Rt); '],{})
                              
                                      std::cout << "mttdsp" << std::endl;
return 0;// Mttdsp(machInst);
                              break;
                            
                            default:  
                              // CP0Unimpl::unknown(([], {}))
                              
                                      std::cout << "UNKNOWN" << std::endl;
return 1;// CP0Unimplemented("unknown", machInst);
                              break;
                            }
                          
                        case 0x2:  
                          // MT_MTTR::mttc1(['\n                                uint64_t data = xc->readRegOtherThread(RD +\n                                                                       FP_Reg_Base);\n                                data = insertBits(data, MT_H ? 63 : 31,\n                                                  MT_H ? 32 : 0, Rt);\n                                xc->setRegOtherThread(RD + FP_Reg_Base,\n                                                      data);\n                            '],{})
                          
                                  std::cout << "mttc1" << std::endl;
return 0;// Mttc1(machInst);
                          break;
                        
                        case 0x3:  
                          // MT_MTTR::cttc1(['\n                                uint32_t data;\n                                switch (RD) {\n                                  case 25:\n                                    data = (Rt_uw<7:1> << 25) |  // move 31-25\n                                           (FCSR & 0x01000000) | // bit 24\n                                           (FCSR & 0x004FFFFF);  // bit 22-0\n                                    break;\n                                  case 26:\n                                    data = (FCSR & 0xFFFC0000) | // move 31-18\n                                           Rt_uw<17:12> << 12 |  // bit 17-12\n                                           (FCSR & 0x00000F80) << 7 | // bit 11-7\n                                           Rt_uw<6:2> << 2 |     // bit 6-2\n                                           (FCSR & 0x00000002);  // bit 1...0\n                                    break;\n                                  case 28:\n                                    data = (FCSR & 0xFE000000) | // move 31-25\n                                           Rt_uw<2:2> << 24 |    // bit 24\n                                           (FCSR & 0x00FFF000) << 23 | // bit 23-12\n                                           Rt_uw<11:7> << 7 |    // bit 24\n                                           (FCSR & 0x000007E) |\n                                           Rt_uw<1:0>;           // bit 22-0\n                                    break;\n                                  case 31:\n                                    data = Rt_uw;\n                                    break;\n                                  default:\n                                    panic("FP Control Value (%d) "\n                                            "Not Available. Ignoring "\n                                            "Access to Floating Control "\n                                            "S""tatus Register", FS);\n                                }\n                                xc->setRegOtherThread(FLOATREG_FCSR + FP_Reg_Base, data);\n                            '],{})
                          
                                  std::cout << "cttc1" << std::endl;
return 0;// Cttc1(machInst);
                          break;
                        
                        default:  
                          // CP0Unimpl::unknown(([], {}))
                          
                                  std::cout << "UNKNOWN" << std::endl;
return 1;// CP0Unimplemented("unknown", machInst);
                          break;
                        }
                      
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                case 0xb:
                  switch (RD) {
                    
                    case 0x0:
                      switch (POS) {
                        
                        case 0x0:
                          switch (SEL) {
                            
                            case 0x1:
                              switch (SC) {
                                
                                case 0x0:  
                                  // MT_Control::dvpe(['\n                                        MVPControlReg mvpControl = MVPControl;\n                                        VPEConf0Reg vpeConf0 = VPEConf0;\n                                        Rt = MVPControl;\n                                        if (vpeConf0.mvp == 1)\n                                            mvpControl.evp = 0;\n                                        MVPControl = mvpControl;\n                                    '],{})
                                  
                                          std::cout << "dvpe" << std::endl;
return 0;// Dvpe(machInst);
                                  break;
                                
                                case 0x1:  
                                  // MT_Control::evpe(['\n                                        MVPControlReg mvpControl = MVPControl;\n                                        VPEConf0Reg vpeConf0 = VPEConf0;\n                                        Rt = MVPControl;\n                                        if (vpeConf0.mvp == 1)\n                                            mvpControl.evp = 1;\n                                        MVPControl = mvpControl;\n                                    '],{})
                                  
                                          std::cout << "evpe" << std::endl;
return 0;// Evpe(machInst);
                                  break;
                                
                                default:  
                                  // CP0Unimpl::unknown(([], {}))
                                  
                                          std::cout << "UNKNOWN" << std::endl;
return 1;// CP0Unimplemented("unknown", machInst);
                                  break;
                                }
                              
                            default:  
                              // CP0Unimpl::unknown(([], {}))
                              
                                      std::cout << "UNKNOWN" << std::endl;
return 1;// CP0Unimplemented("unknown", machInst);
                              break;
                            }
                          
                        default:  
                          // CP0Unimpl::unknown(([], {}))
                          
                                  std::cout << "UNKNOWN" << std::endl;
return 1;// CP0Unimplemented("unknown", machInst);
                          break;
                        }
                      
                    case 0x1:
                      switch (POS) {
                        
                        case 0xf:
                          switch (SEL) {
                            
                            case 0x1:
                              switch (SC) {
                                
                                case 0x0:  
                                  // MT_Control::dmt(['\n                                        VPEControlReg vpeControl = VPEControl;\n                                        Rt = vpeControl;\n                                        vpeControl.te = 0;\n                                        VPEControl = vpeControl;\n                                    '],{})
                                  
                                          std::cout << "dmt" << std::endl;
return 0;// Dmt(machInst);
                                  break;
                                
                                case 0x1:  
                                  // MT_Control::emt(['\n                                        VPEControlReg vpeControl = VPEControl;\n                                        Rt = vpeControl;\n                                        vpeControl.te = 1;\n                                        VPEControl = vpeControl;\n                                    '],{})
                                  
                                          std::cout << "emt" << std::endl;
return 0;// Emt(machInst);
                                  break;
                                
                                default:  
                                  // CP0Unimpl::unknown(([], {}))
                                  
                                          std::cout << "UNKNOWN" << std::endl;
return 1;// CP0Unimplemented("unknown", machInst);
                                  break;
                                }
                              
                            default:  
                              // CP0Unimpl::unknown(([], {}))
                              
                                      std::cout << "UNKNOWN" << std::endl;
return 1;// CP0Unimplemented("unknown", machInst);
                              break;
                            }
                          
                        default:  
                          // CP0Unimpl::unknown(([], {}))
                          
                                  std::cout << "UNKNOWN" << std::endl;
return 1;// CP0Unimplemented("unknown", machInst);
                          break;
                        }
                      
                    case 0xc:
                      switch (POS) {
                        
                        case 0x0:
                          switch (SC) {
                            
                            case 0x0:  
                              // CP0Control::di((['\n                                StatusReg status = Status;\n                                ConfigReg config = Config;\n                                // Rev 2.0 or beyond?\n                                if (config.ar >= 1) {\n                                    Rt = status;\n                                    status.ie = 0;\n                                } else {\n                                    // Enable this else branch once we\n                                    // actually set values for Config on init\n                                    fault = new ReservedInstructionFault();\n                                }\n                                Status = status;\n                            '], {}))
                              
                                      std::cout << "di" << std::endl;
return 0;// Di(machInst);
                              break;
                            
                            case 0x1:  
                              // CP0Control::ei((['\n                                StatusReg status = Status;\n                                ConfigReg config = Config;\n                                if (config.ar >= 1) {\n                                    Rt = status;\n                                    status.ie = 1;\n                                } else {\n                                    fault = new ReservedInstructionFault();\n                                }\n                            '], {}))
                              
                                      std::cout << "ei" << std::endl;
return 0;// Ei(machInst);
                              break;
                            
                            default:  
                              // CP0Unimpl::unknown(([], {}))
                              
                                      std::cout << "UNKNOWN" << std::endl;
return 1;// CP0Unimplemented("unknown", machInst);
                              break;
                            }
                          
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    default:  
                      // CP0Unimpl::unknown(([], {}))
                      
                              std::cout << "UNKNOWN" << std::endl;
return 1;// CP0Unimplemented("unknown", machInst);
                      break;
                    }
                  
                case 0xa:  
                  // CP0Control::rdpgpr(['\n                        ConfigReg config = Config;\n                        if (config.ar >= 1) {\n                            // Rev 2 of the architecture\n                            panic("Shadow Sets Not Fully Implemented.\\n");\n                        } else {\n                          fault = new ReservedInstructionFault();\n                        }\n                    '],{})
                  
                          std::cout << "rdpgpr" << std::endl;
return 0;// Rdpgpr(machInst);
                  break;
                
                case 0xe:  
                  // CP0Control::wrpgpr(['\n                        ConfigReg config = Config;\n                        if (config.ar >= 1) {\n                            // Rev 2 of the architecture\n                            panic("Shadow Sets Not Fully Implemented.\\n");\n                        } else {\n                            fault = new ReservedInstructionFault();\n                        }\n                    '],{})
                  
                          std::cout << "wrpgpr" << std::endl;
return 0;// Wrpgpr(machInst);
                  break;
                }
              
            case 0x1:
              switch (FUNCTION) {
                
                case 0x18:  
                  // CP0Control::eret(['\n                        StatusReg status = Status;\n                        ConfigReg config = Config;\n                        SRSCtlReg srsCtl = SRSCtl;\n                        DPRINTF(MipsPRA,"Restoring PC - %x\\n",EPC);\n                        if (status.erl == 1) {\n                            status.erl = 0;\n                            NPC = ErrorEPC;\n                            // Need to adjust NNPC, otherwise things break\n                            NNPC = ErrorEPC + sizeof(MachInst);\n                        } else {\n                            NPC = EPC;\n                            // Need to adjust NNPC, otherwise things break\n                            NNPC = EPC + sizeof(MachInst);\n                            status.exl = 0;\n                            if (config.ar >=1 &&\n                                    srsCtl.hss > 0 &&\n                                    status.bev == 0) {\n                                srsCtl.css = srsCtl.pss;\n                                //xc->setShadowSet(srsCtl.pss);\n                            }\n                        }\n                        LLFlag = 0;\n                        Status = status;\n                        SRSCtl = srsCtl;\n                    ', 'IsReturn', 'IsSerializing', 'IsERET'],{})
                  
                          std::cout << "eret" << std::endl;
return 0;// Eret(machInst);
                  break;
                
                case 0x1f:  
                  // CP0Control::deret(['\n                        DebugReg debug = Debug;\n                        if (debug.dm == 1) {\n                            debug.dm = 1;\n                            debug.iexi = 0;\n                            NPC = DEPC;\n                        } else {\n                            NPC = NPC;\n                            // Undefined;\n                        }\n                        Debug = debug;\n                    ', 'IsReturn', 'IsSerializing', 'IsERET'],{})
                  
                          std::cout << "deret" << std::endl;
return 0;// Deret(machInst);
                  break;
                
                case 0x1:  
                  // CP0TLB::tlbr(['\n                        MipsISA::PTE *PTEntry =\n                            xc->tcBase()->getITBPtr()->\n                                getEntry(Index & 0x7FFFFFFF);\n                        if (PTEntry == NULL) {\n                            fatal("Invalid PTE Entry received on "\n                                "a TLBR instruction\\n");\n                        }\n                        /* Setup PageMask */\n                        // If 1KB pages are not enabled, a read of PageMask\n                        // must return 0b00 in bits 12, 11\n                        PageMask = (PTEntry->Mask << 11);\n                        /* Setup EntryHi */\n                        EntryHi = ((PTEntry->VPN << 11) | (PTEntry->asid));\n                        /* Setup Entry Lo0 */\n                        EntryLo0 = ((PTEntry->PFN0 << 6) |\n                                    (PTEntry->C0 << 3) |\n                                    (PTEntry->D0 << 2) |\n                                    (PTEntry->V0 << 1) |\n                                    PTEntry->G);\n                        /* Setup Entry Lo1 */\n                        EntryLo1 = ((PTEntry->PFN1 << 6) |\n                                    (PTEntry->C1 << 3) |\n                                    (PTEntry->D1 << 2) |\n                                    (PTEntry->V1 << 1) |\n                                    PTEntry->G);\n                    '],{})
                  
                          std::cout << "tlbr" << std::endl;
return 0;// Tlbr(machInst);
                  break;
                
                case 0x2:  
                  // CP0TLB::tlbwi(['\n                        //Create PTE\n                        MipsISA::PTE newEntry;\n                        //Write PTE\n                        newEntry.Mask = (Addr)(PageMask >> 11);\n                        newEntry.VPN = (Addr)(EntryHi >> 11);\n                        /*  PageGrain _ ESP                    Config3 _ SP */\n                        if (bits(PageGrain, 28) == 0 || bits(Config3, 4) ==0) {\n                            // If 1KB pages are *NOT* enabled, lowest bits of\n                            // the mask are 0b11 for TLB writes\n                            newEntry.Mask |= 0x3;\n                            // Reset bits 0 and 1 if 1KB pages are not enabled\n                            newEntry.VPN &= 0xFFFFFFFC;\n                        }\n                        newEntry.asid = (uint8_t)(EntryHi & 0xFF);\n\n                        newEntry.PFN0 = (Addr)(EntryLo0 >> 6);\n                        newEntry.PFN1 = (Addr)(EntryLo1 >> 6);\n                        newEntry.D0 = (bool)((EntryLo0 >> 2) & 1);\n                        newEntry.D1 = (bool)((EntryLo1 >> 2) & 1);\n                        newEntry.V1 = (bool)((EntryLo1 >> 1) & 1);\n                        newEntry.V0 = (bool)((EntryLo0 >> 1) & 1);\n                        newEntry.G = (bool)((EntryLo0 & EntryLo1) & 1);\n                        newEntry.C0 = (uint8_t)((EntryLo0 >> 3) & 0x7);\n                        newEntry.C1 = (uint8_t)((EntryLo1 >> 3) & 0x7);\n                        /* Now, compute the AddrShiftAmount and OffsetMask -\n                           TLB optimizations */\n                        /* Addr Shift Amount for 1KB or larger pages */\n                        if ((newEntry.Mask & 0xFFFF) == 3) {\n                            newEntry.AddrShiftAmount = 12;\n                        } else if ((newEntry.Mask & 0xFFFF) == 0x0000) {\n                            newEntry.AddrShiftAmount = 10;\n                        } else if ((newEntry.Mask & 0xFFFC) == 0x000C) {\n                            newEntry.AddrShiftAmount = 14;\n                        } else if ((newEntry.Mask & 0xFFF0) == 0x0030) {\n                            newEntry.AddrShiftAmount = 16;\n                        } else if ((newEntry.Mask & 0xFFC0) == 0x00C0) {\n                            newEntry.AddrShiftAmount = 18;\n                        } else if ((newEntry.Mask & 0xFF00) == 0x0300) {\n                            newEntry.AddrShiftAmount = 20;\n                        } else if ((newEntry.Mask & 0xFC00) == 0x0C00) {\n                            newEntry.AddrShiftAmount = 22;\n                        } else if ((newEntry.Mask & 0xF000) == 0x3000) {\n                            newEntry.AddrShiftAmount = 24;\n                        } else if ((newEntry.Mask & 0xC000) == 0xC000) {\n                            newEntry.AddrShiftAmount = 26;\n                        } else if ((newEntry.Mask & 0x30000) == 0x30000) {\n                            newEntry.AddrShiftAmount = 28;\n                        } else {\n                            fatal("Invalid Mask Pattern Detected!\\n");\n                        }\n                        newEntry.OffsetMask =\n                            (1 << newEntry.AddrShiftAmount) - 1;\n\n                        MipsISA::TLB *Ptr = xc->tcBase()->getITBPtr();\n                        Config3Reg config3 = Config3;\n                        PageGrainReg pageGrain = PageGrain;\n                        int SP = 0;\n                        if (bits(config3, config3.sp) == 1 &&\n                            bits(pageGrain, pageGrain.esp) == 1) {\n                            SP = 1;\n                        }\n                        Ptr->insertAt(newEntry, Index & 0x7FFFFFFF, SP);\n                    '],{})
                  
                          std::cout << "tlbwi" << std::endl;
return 0;// Tlbwi(machInst);
                  break;
                
                case 0x6:  
                  // CP0TLB::tlbwr(['\n                        //Create PTE\n                        MipsISA::PTE newEntry;\n                        //Write PTE\n                        newEntry.Mask = (Addr)(PageMask >> 11);\n                        newEntry.VPN = (Addr)(EntryHi >> 11);\n                        /*  PageGrain _ ESP                    Config3 _ SP */\n                        if (bits(PageGrain, 28) == 0 ||\n                            bits(Config3, 4) == 0) {\n                            // If 1KB pages are *NOT* enabled, lowest bits of\n                            // the mask are 0b11 for TLB writes\n                            newEntry.Mask |= 0x3;\n                            // Reset bits 0 and 1 if 1KB pages are not enabled\n                            newEntry.VPN &= 0xFFFFFFFC;\n                        }\n                        newEntry.asid = (uint8_t)(EntryHi & 0xFF);\n\n                        newEntry.PFN0 = (Addr)(EntryLo0 >> 6);\n                        newEntry.PFN1 = (Addr)(EntryLo1 >> 6);\n                        newEntry.D0 = (bool)((EntryLo0 >> 2) & 1);\n                        newEntry.D1 = (bool)((EntryLo1 >> 2) & 1);\n                        newEntry.V1 = (bool)((EntryLo1 >> 1) & 1);\n                        newEntry.V0 = (bool)((EntryLo0 >> 1) & 1);\n                        newEntry.G = (bool)((EntryLo0 & EntryLo1) & 1);\n                        newEntry.C0 = (uint8_t)((EntryLo0 >> 3) & 0x7);\n                        newEntry.C1 = (uint8_t)((EntryLo1 >> 3) & 0x7);\n                        /* Now, compute the AddrShiftAmount and OffsetMask -\n                           TLB optimizations */\n                        /* Addr Shift Amount for 1KB or larger pages */\n                        if ((newEntry.Mask & 0xFFFF) == 3){\n                            newEntry.AddrShiftAmount = 12;\n                        } else if ((newEntry.Mask & 0xFFFF) == 0x0000) {\n                            newEntry.AddrShiftAmount = 10;\n                        } else if ((newEntry.Mask & 0xFFFC) == 0x000C) {\n                            newEntry.AddrShiftAmount = 14;\n                        } else if ((newEntry.Mask & 0xFFF0) == 0x0030) {\n                            newEntry.AddrShiftAmount = 16;\n                        } else if ((newEntry.Mask & 0xFFC0) == 0x00C0) {\n                            newEntry.AddrShiftAmount = 18;\n                        } else if ((newEntry.Mask & 0xFF00) == 0x0300) {\n                            newEntry.AddrShiftAmount = 20;\n                        } else if ((newEntry.Mask & 0xFC00) == 0x0C00) {\n                            newEntry.AddrShiftAmount = 22;\n                        } else if ((newEntry.Mask & 0xF000) == 0x3000) {\n                            newEntry.AddrShiftAmount = 24;\n                        } else if ((newEntry.Mask & 0xC000) == 0xC000) {\n                            newEntry.AddrShiftAmount = 26;\n                        } else if ((newEntry.Mask & 0x30000) == 0x30000) {\n                            newEntry.AddrShiftAmount = 28;\n                        } else {\n                            fatal("Invalid Mask Pattern Detected!\\n");\n                        }\n                        newEntry.OffsetMask =\n                            (1 << newEntry.AddrShiftAmount) - 1;\n\n                        MipsISA::TLB *Ptr = xc->tcBase()->getITBPtr();\n                        Config3Reg config3 = Config3;\n                        PageGrainReg pageGrain = PageGrain;\n                        int SP = 0;\n                        if (bits(config3, config3.sp) == 1 &&\n                            bits(pageGrain, pageGrain.esp) == 1) {\n                            SP = 1;\n                        }\n                        Ptr->insertAt(newEntry, Random, SP);\n                    '],{})
                  
                          std::cout << "tlbwr" << std::endl;
return 0;// Tlbwr(machInst);
                  break;
                
                case 0x8:  
                  // CP0TLB::tlbp(['\n                        Config3Reg config3 = Config3;\n                        PageGrainReg pageGrain = PageGrain;\n                        EntryHiReg entryHi = EntryHi;\n                        int tlbIndex;\n                        Addr vpn;\n                        if (pageGrain.esp == 1 && config3.sp ==1) {\n                            vpn = EntryHi >> 11;\n                        } else {\n                            // Mask off lower 2 bits\n                            vpn = ((EntryHi >> 11) & 0xFFFFFFFC);\n                        }\n                        tlbIndex = xc->tcBase()->getITBPtr()->\n                                   probeEntry(vpn, entryHi.asid);\n                        // Check TLB for entry matching EntryHi\n                        if (tlbIndex != -1) {\n                            Index = tlbIndex;\n                        } else {\n                            // else, set Index = 1 << 31\n                            Index = (1 << 31);\n                        }\n                    '],{})
                  
                          std::cout << "tlbp" << std::endl;
return 0;// Tlbp(machInst);
                  break;
                
                case 0x20:  
                  // CP0Unimpl::wait([],{})
                  
                          std::cout << "wait" << std::endl;
return 0;// CP0Unimplemented("wait", machInst);
                  break;
                
                default:  
                  // CP0Unimpl::unknown(([], {}))
                  
                          std::cout << "UNKNOWN" << std::endl;
return 1;// CP0Unimplemented("unknown", machInst);
                  break;
                }
              
            default:
              
              // Unknown::unknown(([], {}))
              std::cout << "UNKNOWN" << std::endl;
              return 1;//Unknown(machInst);
              break;
            }
          
        case 0x1:
          switch (RS_MSB) {
            
            case 0x0:
              switch (RS_HI) {
                
                case 0x0:
                  switch (RS_LO) {
                    
                    case 0x0:  
                      // CP1Control::mfc1([' Rt_uw = Fs_uw; '],{})
                      
                              std::cout << "mfc1" << std::endl;
return 0;// Mfc1(machInst);
                      break;
                    
                    case 0x2:  
                      // CP1Control::cfc1(['\n                            switch (FS) {\n                              case 0:\n                                Rt = FIR;\n                                break;\n                              case 25:\n                                Rt = (FCSR & 0xFE000000) >> 24 |\n                                     (FCSR & 0x00800000) >> 23;\n                                break;\n                              case 26:\n                                Rt = (FCSR & 0x0003F07C);\n                                break;\n                              case 28:\n                                Rt = (FCSR & 0x00000F80) |\n                                     (FCSR & 0x01000000) >> 21 |\n                                     (FCSR & 0x00000003);\n                                break;\n                              case 31:\n                                Rt = FCSR;\n                                break;\n                              default:\n                                warn("FP Control Value (%d) Not Valid");\n                            }\n                        '],{})
                      
                              std::cout << "cfc1" << std::endl;
return 0;// Cfc1(machInst);
                      break;
                    
                    case 0x3:  
                      // CP1Control::mfhc1([' Rt_uw = Fs_ud<63:32>; '],{})
                      
                              std::cout << "mfhc1" << std::endl;
return 0;// Mfhc1(machInst);
                      break;
                    
                    case 0x4:  
                      // CP1Control::mtc1([' Fs_uw = Rt_uw; '],{})
                      
                              std::cout << "mtc1" << std::endl;
return 0;// Mtc1(machInst);
                      break;
                    
                    case 0x6:  
                      // CP1Control::ctc1(['\n                            switch (FS) {\n                              case 25:\n                                FCSR = (Rt_uw<7:1> << 25) |  // move 31-25\n                                       (FCSR & 0x01000000) | // bit 24\n                                       (FCSR & 0x004FFFFF);  // bit 22-0\n                                break;\n                              case 26:\n                                FCSR = (FCSR & 0xFFFC0000) | // move 31-18\n                                       Rt_uw<17:12> << 12 |  // bit 17-12\n                                       (FCSR & 0x00000F80) << 7 | // bit 11-7\n                                       Rt_uw<6:2> << 2 |     // bit 6-2\n                                       (FCSR & 0x00000002);  // bit 1-0\n                                break;\n                              case 28:\n                                FCSR = (FCSR & 0xFE000000) | // move 31-25\n                                       Rt_uw<2:2> << 24 |    // bit 24\n                                       (FCSR & 0x00FFF000) << 23 | // bit 23-12\n                                       Rt_uw<11:7> << 7 |    // bit 24\n                                       (FCSR & 0x000007E) |\n                                       Rt_uw<1:0>;           // bit 22-0\n                                break;\n                              case 31:\n                                FCSR = Rt_uw;\n                                break;\n\n                              default:\n                                panic("FP Control Value (%d) "\n                                        "Not Available. Ignoring Access "\n                                        "to Floating Control Status "\n                                        "Register", FS);\n                            }\n                        '],{})
                      
                              std::cout << "ctc1" << std::endl;
return 0;// Ctc1(machInst);
                      break;
                    
                    case 0x7:  
                      // CP1Control::mthc1(['\n                             uint64_t fs_hi = Rt_uw;\n                             uint64_t fs_lo = Fs_ud & 0x0FFFFFFFF;\n                             Fs_ud = (fs_hi << 32) | fs_lo;\n                        '],{})
                      
                              std::cout << "mthc1" << std::endl;
return 0;// Mthc1(machInst);
                      break;
                    
                    case 0x1:  
                      // CP1Unimpl::dmfc1([],{})
                      
                              std::cout << "dmfc1" << std::endl;
return 0;// CP1Unimplemented("dmfc1", machInst);
                      break;
                    
                    case 0x5:  
                      // CP1Unimpl::dmtc1([],{})
                      
                              std::cout << "dmtc1" << std::endl;
return 0;// CP1Unimplemented("dmtc1", machInst);
                      break;
                    
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                case 0x1:
                  switch (RS_LO) {
                    
                    case 0x0:
                      switch (ND) {
                        
                        case 0x0:
                          switch (TF) {
                            
                            case 0x0:  
                              // Branch::bc1f(['\n                                    cond = getCondCode(FCSR, BRANCH_CC) == 0;\n                                '],{})
                              
                                      std::cout << "bc1f" << std::endl;
return 0;// Bc1f(machInst);
                              break;
                            
                            case 0x1:  
                              // Branch::bc1t(['\n                                    cond = getCondCode(FCSR, BRANCH_CC) == 1;\n                                '],{})
                              
                                      std::cout << "bc1t" << std::endl;
return 0;// Bc1t(machInst);
                              break;
                            
                            default:
                              
                              // Unknown::unknown(([], {}))
                              std::cout << "UNKNOWN" << std::endl;
                              return 1;//Unknown(machInst);
                              break;
                            }
                          
                        case 0x1:
                          switch (TF) {
                            
                            case 0x0:  
                              // Branch::bc1fl(['\n                                    cond = getCondCode(FCSR, BRANCH_CC) == 0;\n                                ', 'Likely'],{})
                              
                                      std::cout << "bc1fl" << std::endl;
return 0;// Bc1fl(machInst);
                              break;
                            
                            case 0x1:  
                              // Branch::bc1tl(['\n                                    cond = getCondCode(FCSR, BRANCH_CC) == 1;\n                                ', 'Likely'],{})
                              
                                      std::cout << "bc1tl" << std::endl;
return 0;// Bc1tl(machInst);
                              break;
                            
                            default:
                              
                              // Unknown::unknown(([], {}))
                              std::cout << "UNKNOWN" << std::endl;
                              return 1;//Unknown(machInst);
                              break;
                            }
                          
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x1:  
                      // CP1Unimpl::bc1any2([],{})
                      
                              std::cout << "bc1any2" << std::endl;
return 0;// CP1Unimplemented("bc1any2", machInst);
                      break;
                    
                    case 0x2:  
                      // CP1Unimpl::bc1any4([],{})
                      
                              std::cout << "bc1any4" << std::endl;
return 0;// CP1Unimplemented("bc1any4", machInst);
                      break;
                    
                    default:  
                      // CP1Unimpl::unknown([],{})
                      
                              std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                      break;
                    }
                  
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x1:
              switch (RS_HI) {
                
                case 0x2:
                  switch (RS_LO) {
                    
                    case 0x0:
                      switch (FUNCTION_HI) {
                        
                        case 0x0:
                          switch (FUNCTION_LO) {
                            
                            case 0x0:  
                              // FloatOp::add_s([' Fd_sf = Fs_sf + Ft_sf; '],{})
                              
                                      std::cout << "add_s" << std::endl;
return 0;// Add_s(machInst);
                              break;
                            
                            case 0x1:  
                              // FloatOp::sub_s([' Fd_sf = Fs_sf - Ft_sf; '],{})
                              
                                      std::cout << "sub_s" << std::endl;
return 0;// Sub_s(machInst);
                              break;
                            
                            case 0x2:  
                              // FloatOp::mul_s([' Fd_sf = Fs_sf * Ft_sf; '],{})
                              
                                      std::cout << "mul_s" << std::endl;
return 0;// Mul_s(machInst);
                              break;
                            
                            case 0x3:  
                              // FloatOp::div_s([' Fd_sf = Fs_sf / Ft_sf; '],{})
                              
                                      std::cout << "div_s" << std::endl;
return 0;// Div_s(machInst);
                              break;
                            
                            case 0x4:  
                              // FloatOp::sqrt_s([' Fd_sf = sqrt(Fs_sf); '],{})
                              
                                      std::cout << "sqrt_s" << std::endl;
return 0;// Sqrt_s(machInst);
                              break;
                            
                            case 0x5:  
                              // FloatOp::abs_s([' Fd_sf = fabs(Fs_sf); '],{})
                              
                                      std::cout << "abs_s" << std::endl;
return 0;// Abs_s(machInst);
                              break;
                            
                            case 0x7:  
                              // FloatOp::neg_s([' Fd_sf = -Fs_sf; '],{})
                              
                                      std::cout << "neg_s" << std::endl;
return 0;// Neg_s(machInst);
                              break;
                            
                            case 0x6:  
                              // BasicOp::mov_s(([' Fd_sf = Fs_sf; '], {}))
                              
                                      std::cout << "mov_s" << std::endl;
return 0;// Mov_s(machInst);
                              break;
                            
                            default:
                              
                              // Unknown::unknown(([], {}))
                              std::cout << "UNKNOWN" << std::endl;
                              return 1;//Unknown(machInst);
                              break;
                            }
                          
                        case 0x1:
                          switch (FUNCTION_LO) {
                            
                            case 0x0:  
                              // FloatConvertOp::round_l_s([' val = Fs_sf; ', 'ToLong', 'Round'],{})
                              
                                      std::cout << "round_l_s" << std::endl;
return 0;// Round_l_s(machInst);
                              break;
                            
                            case 0x1:  
                              // FloatConvertOp::trunc_l_s([' val = Fs_sf; ', 'ToLong', 'Trunc'],{})
                              
                                      std::cout << "trunc_l_s" << std::endl;
return 0;// Trunc_l_s(machInst);
                              break;
                            
                            case 0x2:  
                              // FloatConvertOp::ceil_l_s([' val = Fs_sf;', 'ToLong', 'Ceil'],{})
                              
                                      std::cout << "ceil_l_s" << std::endl;
return 0;// Ceil_l_s(machInst);
                              break;
                            
                            case 0x3:  
                              // FloatConvertOp::floor_l_s([' val = Fs_sf; ', 'ToLong', 'Floor'],{})
                              
                                      std::cout << "floor_l_s" << std::endl;
return 0;// Floor_l_s(machInst);
                              break;
                            
                            case 0x4:  
                              // FloatConvertOp::round_w_s([' val = Fs_sf; ', 'ToWord', 'Round'],{})
                              
                                      std::cout << "round_w_s" << std::endl;
return 0;// Round_w_s(machInst);
                              break;
                            
                            case 0x5:  
                              // FloatConvertOp::trunc_w_s([' val = Fs_sf; ', 'ToWord', 'Trunc'],{})
                              
                                      std::cout << "trunc_w_s" << std::endl;
return 0;// Trunc_w_s(machInst);
                              break;
                            
                            case 0x6:  
                              // FloatConvertOp::ceil_w_s([' val = Fs_sf; ', 'ToWord', 'Ceil'],{})
                              
                                      std::cout << "ceil_w_s" << std::endl;
return 0;// Ceil_w_s(machInst);
                              break;
                            
                            case 0x7:  
                              // FloatConvertOp::floor_w_s([' val = Fs_sf; ', 'ToWord', 'Floor'],{})
                              
                                      std::cout << "floor_w_s" << std::endl;
return 0;// Floor_w_s(machInst);
                              break;
                            
                            default:
                              
                              // Unknown::unknown(([], {}))
                              std::cout << "UNKNOWN" << std::endl;
                              return 1;//Unknown(machInst);
                              break;
                            }
                          
                        case 0x2:
                          switch (FUNCTION_LO) {
                            
                            case 0x1:
                              switch (MOVCF) {
                                
                                case 0x0:  
                                  // BasicOp::movf_s(['\n                                        Fd = (getCondCode(FCSR,CC) == 0) ?\n                                             Fs : Fd;\n                                    '],{})
                                  
                                          std::cout << "movf_s" << std::endl;
return 0;// Movf_s(machInst);
                                  break;
                                
                                case 0x1:  
                                  // BasicOp::movt_s(['\n                                        Fd = (getCondCode(FCSR,CC) == 1) ?\n                                             Fs : Fd;\n                                    '],{})
                                  
                                          std::cout << "movt_s" << std::endl;
return 0;// Movt_s(machInst);
                                  break;
                                
                                default:
                                  
                                  // Unknown::unknown(([], {}))
                                  std::cout << "UNKNOWN" << std::endl;
                                  return 1;//Unknown(machInst);
                                  break;
                                }
                              
                            case 0x2:  
                              // BasicOp::movz_s([' Fd = (Rt == 0) ? Fs : Fd; '],{})
                              
                                      std::cout << "movz_s" << std::endl;
return 0;// Movz_s(machInst);
                              break;
                            
                            case 0x3:  
                              // BasicOp::movn_s([' Fd = (Rt != 0) ? Fs : Fd; '],{})
                              
                                      std::cout << "movn_s" << std::endl;
return 0;// Movn_s(machInst);
                              break;
                            
                            case 0x5:  
                              // FloatOp::recip_s([' Fd = 1 / Fs; '],{})
                              
                                      std::cout << "recip_s" << std::endl;
return 0;// Recip_s(machInst);
                              break;
                            
                            case 0x6:  
                              // FloatOp::rsqrt_s([' Fd = 1 / sqrt(Fs); '],{})
                              
                                      std::cout << "rsqrt_s" << std::endl;
return 0;// Rsqrt_s(machInst);
                              break;
                            
                            default:  
                              // CP1Unimpl::unknown([],{})
                              
                                      std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                              break;
                            }
                          
                        case 0x3:  
                          // CP1Unimpl::unknown(([], {}))
                          
                                  std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                          break;
                        
                        case 0x4:
                          switch (FUNCTION_LO) {
                            
                            case 0x1:  
                              // FloatConvertOp::cvt_d_s([' val = Fs_sf; ', 'ToDouble'],{})
                              
                                      std::cout << "cvt_d_s" << std::endl;
return 0;// Cvt_d_s(machInst);
                              break;
                            
                            case 0x4:  
                              // FloatConvertOp::cvt_w_s([' val = Fs_sf; ', 'ToWord'],{})
                              
                                      std::cout << "cvt_w_s" << std::endl;
return 0;// Cvt_w_s(machInst);
                              break;
                            
                            case 0x5:  
                              // FloatConvertOp::cvt_l_s([' val = Fs_sf; ', 'ToLong'],{})
                              
                                      std::cout << "cvt_l_s" << std::endl;
return 0;// Cvt_l_s(machInst);
                              break;
                            
                            case 0x6:  
                              // FloatOp::cvt_ps_s((['\n                                Fd_ud = (uint64_t) Fs_uw << 32 |\n                                        (uint64_t) Ft_uw;\n                            '], {}))
                              
                                      std::cout << "cvt_ps_s" << std::endl;
return 0;// Cvt_ps_s(machInst);
                              break;
                            
                            default:  
                              // CP1Unimpl::unknown([],{})
                              
                                      std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                              break;
                            }
                          
                        case 0x5:  
                          // CP1Unimpl::unknown(([], {}))
                          
                                  std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                          break;
                        
                        case 0x6:
                          switch (FUNCTION_LO) {
                            
                            case 0x0:  
                              // FloatCompareOp::c_f_s([' cond = 0; ', 'SinglePrecision', 'UnorderedFalse'],{})
                              
                                      std::cout << "c_f_s" << std::endl;
return 0;// C_f_s(machInst);
                              break;
                            
                            case 0x1:  
                              // FloatCompareOp::c_un_s([' cond = 0; ', 'SinglePrecision', 'UnorderedTrue'],{})
                              
                                      std::cout << "c_un_s" << std::endl;
return 0;// C_un_s(machInst);
                              break;
                            
                            case 0x2:  
                              // FloatCompareOp::c_eq_s([' cond = (Fs_sf == Ft_sf); ', 'UnorderedFalse'],{})
                              
                                      std::cout << "c_eq_s" << std::endl;
return 0;// C_eq_s(machInst);
                              break;
                            
                            case 0x3:  
                              // FloatCompareOp::c_ueq_s([' cond = (Fs_sf == Ft_sf); ', 'UnorderedTrue'],{})
                              
                                      std::cout << "c_ueq_s" << std::endl;
return 0;// C_ueq_s(machInst);
                              break;
                            
                            case 0x4:  
                              // FloatCompareOp::c_olt_s([' cond = (Fs_sf < Ft_sf); ', 'UnorderedFalse'],{})
                              
                                      std::cout << "c_olt_s" << std::endl;
return 0;// C_olt_s(machInst);
                              break;
                            
                            case 0x5:  
                              // FloatCompareOp::c_ult_s([' cond = (Fs_sf < Ft_sf); ', 'UnorderedTrue'],{})
                              
                                      std::cout << "c_ult_s" << std::endl;
return 0;// C_ult_s(machInst);
                              break;
                            
                            case 0x6:  
                              // FloatCompareOp::c_ole_s([' cond = (Fs_sf <= Ft_sf); ', 'UnorderedFalse'],{})
                              
                                      std::cout << "c_ole_s" << std::endl;
return 0;// C_ole_s(machInst);
                              break;
                            
                            case 0x7:  
                              // FloatCompareOp::c_ule_s([' cond = (Fs_sf <= Ft_sf); ', 'UnorderedTrue'],{})
                              
                                      std::cout << "c_ule_s" << std::endl;
return 0;// C_ule_s(machInst);
                              break;
                            
                            default:
                              
                              // Unknown::unknown(([], {}))
                              std::cout << "UNKNOWN" << std::endl;
                              return 1;//Unknown(machInst);
                              break;
                            }
                          
                        case 0x7:
                          switch (FUNCTION_LO) {
                            
                            case 0x0:  
                              // FloatCompareOp::c_sf_s([' cond = 0; ', 'SinglePrecision', 'UnorderedFalse', 'QnanException'],{})
                              
                                      std::cout << "c_sf_s" << std::endl;
return 0;// C_sf_s(machInst);
                              break;
                            
                            case 0x1:  
                              // FloatCompareOp::c_ngle_s([' cond = 0; ', 'SinglePrecision', 'UnorderedTrue', 'QnanException'],{})
                              
                                      std::cout << "c_ngle_s" << std::endl;
return 0;// C_ngle_s(machInst);
                              break;
                            
                            case 0x2:  
                              // FloatCompareOp::c_seq_s([' cond = (Fs_sf == Ft_sf); ', 'UnorderedFalse', 'QnanException'],{})
                              
                                      std::cout << "c_seq_s" << std::endl;
return 0;// C_seq_s(machInst);
                              break;
                            
                            case 0x3:  
                              // FloatCompareOp::c_ngl_s([' cond = (Fs_sf == Ft_sf); ', 'UnorderedTrue', 'QnanException'],{})
                              
                                      std::cout << "c_ngl_s" << std::endl;
return 0;// C_ngl_s(machInst);
                              break;
                            
                            case 0x4:  
                              // FloatCompareOp::c_lt_s([' cond = (Fs_sf < Ft_sf); ', 'UnorderedFalse', 'QnanException'],{})
                              
                                      std::cout << "c_lt_s" << std::endl;
return 0;// C_lt_s(machInst);
                              break;
                            
                            case 0x5:  
                              // FloatCompareOp::c_nge_s([' cond = (Fs_sf < Ft_sf); ', 'UnorderedTrue', 'QnanException'],{})
                              
                                      std::cout << "c_nge_s" << std::endl;
return 0;// C_nge_s(machInst);
                              break;
                            
                            case 0x6:  
                              // FloatCompareOp::c_le_s([' cond = (Fs_sf <= Ft_sf); ', 'UnorderedFalse', 'QnanException'],{})
                              
                                      std::cout << "c_le_s" << std::endl;
return 0;// C_le_s(machInst);
                              break;
                            
                            case 0x7:  
                              // FloatCompareOp::c_ngt_s([' cond = (Fs_sf <= Ft_sf); ', 'UnorderedTrue', 'QnanException'],{})
                              
                                      std::cout << "c_ngt_s" << std::endl;
return 0;// C_ngt_s(machInst);
                              break;
                            
                            default:
                              
                              // Unknown::unknown(([], {}))
                              std::cout << "UNKNOWN" << std::endl;
                              return 1;//Unknown(machInst);
                              break;
                            }
                          
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x1:
                      switch (FUNCTION_HI) {
                        
                        case 0x0:
                          switch (FUNCTION_LO) {
                            
                            case 0x0:  
                              // FloatOp::add_d([' Fd_df = Fs_df + Ft_df; '],{})
                              
                                      std::cout << "add_d" << std::endl;
return 0;// Add_d(machInst);
                              break;
                            
                            case 0x1:  
                              // FloatOp::sub_d([' Fd_df = Fs_df - Ft_df; '],{})
                              
                                      std::cout << "sub_d" << std::endl;
return 0;// Sub_d(machInst);
                              break;
                            
                            case 0x2:  
                              // FloatOp::mul_d([' Fd_df = Fs_df * Ft_df; '],{})
                              
                                      std::cout << "mul_d" << std::endl;
return 0;// Mul_d(machInst);
                              break;
                            
                            case 0x3:  
                              // FloatOp::div_d([' Fd_df = Fs_df / Ft_df; '],{})
                              
                                      std::cout << "div_d" << std::endl;
return 0;// Div_d(machInst);
                              break;
                            
                            case 0x4:  
                              // FloatOp::sqrt_d([' Fd_df = sqrt(Fs_df); '],{})
                              
                                      std::cout << "sqrt_d" << std::endl;
return 0;// Sqrt_d(machInst);
                              break;
                            
                            case 0x5:  
                              // FloatOp::abs_d([' Fd_df = fabs(Fs_df); '],{})
                              
                                      std::cout << "abs_d" << std::endl;
return 0;// Abs_d(machInst);
                              break;
                            
                            case 0x7:  
                              // FloatOp::neg_d([' Fd_df = -1 * Fs_df; '],{})
                              
                                      std::cout << "neg_d" << std::endl;
return 0;// Neg_d(machInst);
                              break;
                            
                            case 0x6:  
                              // BasicOp::mov_d(([' Fd_df = Fs_df; '], {}))
                              
                                      std::cout << "mov_d" << std::endl;
return 0;// Mov_d(machInst);
                              break;
                            
                            default:
                              
                              // Unknown::unknown(([], {}))
                              std::cout << "UNKNOWN" << std::endl;
                              return 1;//Unknown(machInst);
                              break;
                            }
                          
                        case 0x1:
                          switch (FUNCTION_LO) {
                            
                            case 0x0:  
                              // FloatConvertOp::round_l_d([' val = Fs_df; ', 'ToLong', 'Round'],{})
                              
                                      std::cout << "round_l_d" << std::endl;
return 0;// Round_l_d(machInst);
                              break;
                            
                            case 0x1:  
                              // FloatConvertOp::trunc_l_d([' val = Fs_df; ', 'ToLong', 'Trunc'],{})
                              
                                      std::cout << "trunc_l_d" << std::endl;
return 0;// Trunc_l_d(machInst);
                              break;
                            
                            case 0x2:  
                              // FloatConvertOp::ceil_l_d([' val = Fs_df; ', 'ToLong', 'Ceil'],{})
                              
                                      std::cout << "ceil_l_d" << std::endl;
return 0;// Ceil_l_d(machInst);
                              break;
                            
                            case 0x3:  
                              // FloatConvertOp::floor_l_d([' val = Fs_df; ', 'ToLong', 'Floor'],{})
                              
                                      std::cout << "floor_l_d" << std::endl;
return 0;// Floor_l_d(machInst);
                              break;
                            
                            case 0x4:  
                              // FloatConvertOp::round_w_d([' val = Fs_df; ', 'ToWord', 'Round'],{})
                              
                                      std::cout << "round_w_d" << std::endl;
return 0;// Round_w_d(machInst);
                              break;
                            
                            case 0x5:  
                              // FloatConvertOp::trunc_w_d([' val = Fs_df; ', 'ToWord', 'Trunc'],{})
                              
                                      std::cout << "trunc_w_d" << std::endl;
return 0;// Trunc_w_d(machInst);
                              break;
                            
                            case 0x6:  
                              // FloatConvertOp::ceil_w_d([' val = Fs_df; ', 'ToWord', 'Ceil'],{})
                              
                                      std::cout << "ceil_w_d" << std::endl;
return 0;// Ceil_w_d(machInst);
                              break;
                            
                            case 0x7:  
                              // FloatConvertOp::floor_w_d([' val = Fs_df; ', 'ToWord', 'Floor'],{})
                              
                                      std::cout << "floor_w_d" << std::endl;
return 0;// Floor_w_d(machInst);
                              break;
                            
                            default:
                              
                              // Unknown::unknown(([], {}))
                              std::cout << "UNKNOWN" << std::endl;
                              return 1;//Unknown(machInst);
                              break;
                            }
                          
                        case 0x2:
                          switch (FUNCTION_LO) {
                            
                            case 0x1:
                              switch (MOVCF) {
                                
                                case 0x0:  
                                  // BasicOp::movf_d(['\n                                        Fd_df = (getCondCode(FCSR,CC) == 0) ?\n                                                       Fs_df : Fd_df;\n                                    '],{})
                                  
                                          std::cout << "movf_d" << std::endl;
return 0;// Movf_d(machInst);
                                  break;
                                
                                case 0x1:  
                                  // BasicOp::movt_d(['\n                                        Fd_df = (getCondCode(FCSR,CC) == 1) ?\n                                                       Fs_df : Fd_df;\n                                    '],{})
                                  
                                          std::cout << "movt_d" << std::endl;
return 0;// Movt_d(machInst);
                                  break;
                                
                                default:
                                  
                                  // Unknown::unknown(([], {}))
                                  std::cout << "UNKNOWN" << std::endl;
                                  return 1;//Unknown(machInst);
                                  break;
                                }
                              
                            case 0x2:  
                              // BasicOp::movz_d(['\n                                    Fd_df = (Rt == 0) ? Fs_df : Fd_df;\n                                '],{})
                              
                                      std::cout << "movz_d" << std::endl;
return 0;// Movz_d(machInst);
                              break;
                            
                            case 0x3:  
                              // BasicOp::movn_d(['\n                                    Fd_df = (Rt != 0) ? Fs_df : Fd_df;\n                                '],{})
                              
                                      std::cout << "movn_d" << std::endl;
return 0;// Movn_d(machInst);
                              break;
                            
                            case 0x5:  
                              // FloatOp::recip_d([' Fd_df = 1 / Fs_df; '],{})
                              
                                      std::cout << "recip_d" << std::endl;
return 0;// Recip_d(machInst);
                              break;
                            
                            case 0x6:  
                              // FloatOp::rsqrt_d([' Fd_df = 1 / sqrt(Fs_df); '],{})
                              
                                      std::cout << "rsqrt_d" << std::endl;
return 0;// Rsqrt_d(machInst);
                              break;
                            
                            default:  
                              // CP1Unimpl::unknown([],{})
                              
                                      std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                              break;
                            }
                          
                        case 0x4:
                          switch (FUNCTION_LO) {
                            
                            case 0x0:  
                              // FloatConvertOp::cvt_s_d([' val = Fs_df; ', 'ToSingle'],{})
                              
                                      std::cout << "cvt_s_d" << std::endl;
return 0;// Cvt_s_d(machInst);
                              break;
                            
                            case 0x4:  
                              // FloatConvertOp::cvt_w_d([' val = Fs_df; ', 'ToWord'],{})
                              
                                      std::cout << "cvt_w_d" << std::endl;
return 0;// Cvt_w_d(machInst);
                              break;
                            
                            case 0x5:  
                              // FloatConvertOp::cvt_l_d([' val = Fs_df; ', 'ToLong'],{})
                              
                                      std::cout << "cvt_l_d" << std::endl;
return 0;// Cvt_l_d(machInst);
                              break;
                            
                            default:  
                              // CP1Unimpl::unknown(([], {}))
                              
                                      std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                              break;
                            }
                          
                        case 0x6:
                          switch (FUNCTION_LO) {
                            
                            case 0x0:  
                              // FloatCompareOp::c_f_d([' cond = 0; ', 'DoublePrecision', 'UnorderedFalse'],{})
                              
                                      std::cout << "c_f_d" << std::endl;
return 0;// C_f_d(machInst);
                              break;
                            
                            case 0x1:  
                              // FloatCompareOp::c_un_d([' cond = 0; ', 'DoublePrecision', 'UnorderedTrue'],{})
                              
                                      std::cout << "c_un_d" << std::endl;
return 0;// C_un_d(machInst);
                              break;
                            
                            case 0x2:  
                              // FloatCompareOp::c_eq_d([' cond = (Fs_df == Ft_df); ', 'UnorderedFalse'],{})
                              
                                      std::cout << "c_eq_d" << std::endl;
return 0;// C_eq_d(machInst);
                              break;
                            
                            case 0x3:  
                              // FloatCompareOp::c_ueq_d([' cond = (Fs_df == Ft_df); ', 'UnorderedTrue'],{})
                              
                                      std::cout << "c_ueq_d" << std::endl;
return 0;// C_ueq_d(machInst);
                              break;
                            
                            case 0x4:  
                              // FloatCompareOp::c_olt_d([' cond = (Fs_df < Ft_df); ', 'UnorderedFalse'],{})
                              
                                      std::cout << "c_olt_d" << std::endl;
return 0;// C_olt_d(machInst);
                              break;
                            
                            case 0x5:  
                              // FloatCompareOp::c_ult_d([' cond = (Fs_df < Ft_df); ', 'UnorderedTrue'],{})
                              
                                      std::cout << "c_ult_d" << std::endl;
return 0;// C_ult_d(machInst);
                              break;
                            
                            case 0x6:  
                              // FloatCompareOp::c_ole_d([' cond = (Fs_df <= Ft_df); ', 'UnorderedFalse'],{})
                              
                                      std::cout << "c_ole_d" << std::endl;
return 0;// C_ole_d(machInst);
                              break;
                            
                            case 0x7:  
                              // FloatCompareOp::c_ule_d([' cond = (Fs_df <= Ft_df); ', 'UnorderedTrue'],{})
                              
                                      std::cout << "c_ule_d" << std::endl;
return 0;// C_ule_d(machInst);
                              break;
                            
                            default:
                              
                              // Unknown::unknown(([], {}))
                              std::cout << "UNKNOWN" << std::endl;
                              return 1;//Unknown(machInst);
                              break;
                            }
                          
                        case 0x7:
                          switch (FUNCTION_LO) {
                            
                            case 0x0:  
                              // FloatCompareOp::c_sf_d([' cond = 0; ', 'DoublePrecision', 'UnorderedFalse', 'QnanException'],{})
                              
                                      std::cout << "c_sf_d" << std::endl;
return 0;// C_sf_d(machInst);
                              break;
                            
                            case 0x1:  
                              // FloatCompareOp::c_ngle_d([' cond = 0; ', 'DoublePrecision', 'UnorderedTrue', 'QnanException'],{})
                              
                                      std::cout << "c_ngle_d" << std::endl;
return 0;// C_ngle_d(machInst);
                              break;
                            
                            case 0x2:  
                              // FloatCompareOp::c_seq_d([' cond = (Fs_df == Ft_df); ', 'UnorderedFalse', 'QnanException'],{})
                              
                                      std::cout << "c_seq_d" << std::endl;
return 0;// C_seq_d(machInst);
                              break;
                            
                            case 0x3:  
                              // FloatCompareOp::c_ngl_d([' cond = (Fs_df == Ft_df); ', 'UnorderedTrue', 'QnanException'],{})
                              
                                      std::cout << "c_ngl_d" << std::endl;
return 0;// C_ngl_d(machInst);
                              break;
                            
                            case 0x4:  
                              // FloatCompareOp::c_lt_d([' cond = (Fs_df < Ft_df); ', 'UnorderedFalse', 'QnanException'],{})
                              
                                      std::cout << "c_lt_d" << std::endl;
return 0;// C_lt_d(machInst);
                              break;
                            
                            case 0x5:  
                              // FloatCompareOp::c_nge_d([' cond = (Fs_df < Ft_df); ', 'UnorderedTrue', 'QnanException'],{})
                              
                                      std::cout << "c_nge_d" << std::endl;
return 0;// C_nge_d(machInst);
                              break;
                            
                            case 0x6:  
                              // FloatCompareOp::c_le_d([' cond = (Fs_df <= Ft_df); ', 'UnorderedFalse', 'QnanException'],{})
                              
                                      std::cout << "c_le_d" << std::endl;
return 0;// C_le_d(machInst);
                              break;
                            
                            case 0x7:  
                              // FloatCompareOp::c_ngt_d([' cond = (Fs_df <= Ft_df); ', 'UnorderedTrue', 'QnanException'],{})
                              
                                      std::cout << "c_ngt_d" << std::endl;
return 0;// C_ngt_d(machInst);
                              break;
                            
                            default:
                              
                              // Unknown::unknown(([], {}))
                              std::cout << "UNKNOWN" << std::endl;
                              return 1;//Unknown(machInst);
                              break;
                            }
                          
                        default:  
                          // CP1Unimpl::unknown(([], {}))
                          
                                  std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                          break;
                        }
                      
                    case 0x2:  
                      // CP1Unimpl::unknown(([], {}))
                      
                              std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                      break;
                    
                    case 0x3:  
                      // CP1Unimpl::unknown(([], {}))
                      
                              std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                      break;
                    
                    case 0x7:  
                      // CP1Unimpl::unknown(([], {}))
                      
                              std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                      break;
                    
                    case 0x4:
                      switch (FUNCTION) {
                        
                        case 0x20:  
                          // FloatConvertOp::cvt_s_w([' val = Fs_sw; ', 'ToSingle'],{})
                          
                                  std::cout << "cvt_s_w" << std::endl;
return 0;// Cvt_s_w(machInst);
                          break;
                        
                        case 0x21:  
                          // FloatConvertOp::cvt_d_w([' val = Fs_sw; ', 'ToDouble'],{})
                          
                                  std::cout << "cvt_d_w" << std::endl;
return 0;// Cvt_d_w(machInst);
                          break;
                        
                        case 0x26:  
                          // CP1Unimpl::cvt_ps_w(([], {}))
                          
                                  std::cout << "cvt_ps_w" << std::endl;
return 0;// CP1Unimplemented("cvt_ps_w", machInst);
                          break;
                        
                        default:  
                          // CP1Unimpl::unknown(([], {}))
                          
                                  std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                          break;
                        }
                      
                    case 0x5:
                      switch (FUNCTION) {
                        
                        case 0x20:  
                          // FloatConvertOp::cvt_s_l([' val = Fs_sd; ', 'ToSingle'],{})
                          
                                  std::cout << "cvt_s_l" << std::endl;
return 0;// Cvt_s_l(machInst);
                          break;
                        
                        case 0x21:  
                          // FloatConvertOp::cvt_d_l([' val = Fs_sd; ', 'ToDouble'],{})
                          
                                  std::cout << "cvt_d_l" << std::endl;
return 0;// Cvt_d_l(machInst);
                          break;
                        
                        case 0x26:  
                          // CP1Unimpl::cvt_ps_l(([], {}))
                          
                                  std::cout << "cvt_ps_l" << std::endl;
return 0;// CP1Unimplemented("cvt_ps_l", machInst);
                          break;
                        
                        default:  
                          // CP1Unimpl::unknown(([], {}))
                          
                                  std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                          break;
                        }
                      
                    case 0x6:
                      switch (FUNCTION_HI) {
                        
                        case 0x0:
                          switch (FUNCTION_LO) {
                            
                            case 0x0:  
                              // Float64Op::add_ps(['\n                                    Fd1_sf = Fs1_sf + Ft2_sf;\n                                    Fd2_sf = Fs2_sf + Ft2_sf;\n                                '],{})
                              
                                      std::cout << "add_ps" << std::endl;
return 0;// Add_ps(machInst);
                              break;
                            
                            case 0x1:  
                              // Float64Op::sub_ps(['\n                                    Fd1_sf = Fs1_sf - Ft2_sf;\n                                    Fd2_sf = Fs2_sf - Ft2_sf;\n                                '],{})
                              
                                      std::cout << "sub_ps" << std::endl;
return 0;// Sub_ps(machInst);
                              break;
                            
                            case 0x2:  
                              // Float64Op::mul_ps(['\n                                    Fd1_sf = Fs1_sf * Ft2_sf;\n                                    Fd2_sf = Fs2_sf * Ft2_sf;\n                                '],{})
                              
                                      std::cout << "mul_ps" << std::endl;
return 0;// Mul_ps(machInst);
                              break;
                            
                            case 0x5:  
                              // Float64Op::abs_ps(['\n                                    Fd1_sf = fabs(Fs1_sf);\n                                    Fd2_sf = fabs(Fs2_sf);\n                                '],{})
                              
                                      std::cout << "abs_ps" << std::endl;
return 0;// Abs_ps(machInst);
                              break;
                            
                            case 0x6:  
                              // Float64Op::mov_ps(['\n                                    Fd1_sf = Fs1_sf;\n                                    Fd2_sf = Fs2_sf;\n                                '],{})
                              
                                      std::cout << "mov_ps" << std::endl;
return 0;// Mov_ps(machInst);
                              break;
                            
                            case 0x7:  
                              // Float64Op::neg_ps(['\n                                    Fd1_sf = -(Fs1_sf);\n                                    Fd2_sf = -(Fs2_sf);\n                                '],{})
                              
                                      std::cout << "neg_ps" << std::endl;
return 0;// Neg_ps(machInst);
                              break;
                            
                            default:  
                              // CP1Unimpl::unknown(([], {}))
                              
                                      std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                              break;
                            }
                          
                        case 0x1:  
                          // CP1Unimpl::unknown(([], {}))
                          
                                  std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                          break;
                        
                        case 0x2:
                          switch (FUNCTION_LO) {
                            
                            case 0x1:
                              switch (MOVCF) {
                                
                                case 0x0:  
                                  // Float64Op::movf_ps(['\n                                        Fd1 = (getCondCode(FCSR, CC) == 0) ?\n                                            Fs1 : Fd1;\n                                        Fd2 = (getCondCode(FCSR, CC+1) == 0) ?\n                                            Fs2 : Fd2;\n                                    '],{})
                                  
                                          std::cout << "movf_ps" << std::endl;
return 0;// Movf_ps(machInst);
                                  break;
                                
                                case 0x1:  
                                  // Float64Op::movt_ps(['\n                                        Fd2 = (getCondCode(FCSR, CC) == 1) ?\n                                            Fs1 : Fd1;\n                                        Fd2 = (getCondCode(FCSR, CC+1) == 1) ?\n                                            Fs2 : Fd2;\n                                    '],{})
                                  
                                          std::cout << "movt_ps" << std::endl;
return 0;// Movt_ps(machInst);
                                  break;
                                
                                default:
                                  
                                  // Unknown::unknown(([], {}))
                                  std::cout << "UNKNOWN" << std::endl;
                                  return 1;//Unknown(machInst);
                                  break;
                                }
                              
                            case 0x2:  
                              // Float64Op::movz_ps(['\n                                    Fd1 = (getCondCode(FCSR, CC) == 0) ?\n                                        Fs1 : Fd1;\n                                    Fd2 = (getCondCode(FCSR, CC) == 0) ?\n                                        Fs2 : Fd2;\n                                '],{})
                              
                                      std::cout << "movz_ps" << std::endl;
return 0;// Movz_ps(machInst);
                              break;
                            
                            case 0x3:  
                              // Float64Op::movn_ps(['\n                                    Fd1 = (getCondCode(FCSR, CC) == 1) ?\n                                        Fs1 : Fd1;\n                                    Fd2 = (getCondCode(FCSR, CC) == 1) ?\n                                        Fs2 : Fd2;\n                                '],{})
                              
                                      std::cout << "movn_ps" << std::endl;
return 0;// Movn_ps(machInst);
                              break;
                            
                            default:  
                              // CP1Unimpl::unknown(([], {}))
                              
                                      std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                              break;
                            }
                          
                        case 0x3:  
                          // CP1Unimpl::unknown(([], {}))
                          
                                  std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                          break;
                        
                        case 0x4:
                          switch (FUNCTION_LO) {
                            
                            case 0x0:  
                              // FloatOp::cvt_s_pu(([' Fd_sf = Fs2_sf; '], {}))
                              
                                      std::cout << "cvt_s_pu" << std::endl;
return 0;// Cvt_s_pu(machInst);
                              break;
                            
                            default:  
                              // CP1Unimpl::unknown(([], {}))
                              
                                      std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                              break;
                            }
                          
                        case 0x5:
                          switch (FUNCTION_LO) {
                            
                            case 0x0:  
                              // FloatOp::cvt_s_pl(([' Fd_sf = Fs1_sf; '], {}))
                              
                                      std::cout << "cvt_s_pl" << std::endl;
return 0;// Cvt_s_pl(machInst);
                              break;
                            
                            case 0x4:  
                              // Float64Op::pll(['\n                                    Fd_ud = (uint64_t)Fs1_uw << 32 | Ft1_uw;\n                                '],{})
                              
                                      std::cout << "pll" << std::endl;
return 0;// Pll(machInst);
                              break;
                            
                            case 0x5:  
                              // Float64Op::plu(['\n                                    Fd_ud = (uint64_t)Fs1_uw << 32 | Ft2_uw;\n                                '],{})
                              
                                      std::cout << "plu" << std::endl;
return 0;// Plu(machInst);
                              break;
                            
                            case 0x6:  
                              // Float64Op::pul(['\n                                    Fd_ud = (uint64_t)Fs2_uw << 32 | Ft1_uw;\n                                '],{})
                              
                                      std::cout << "pul" << std::endl;
return 0;// Pul(machInst);
                              break;
                            
                            case 0x7:  
                              // Float64Op::puu(['\n                                    Fd_ud = (uint64_t)Fs2_uw << 32 | Ft2_uw;\n                                '],{})
                              
                                      std::cout << "puu" << std::endl;
return 0;// Puu(machInst);
                              break;
                            
                            default:  
                              // CP1Unimpl::unknown(([], {}))
                              
                                      std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                              break;
                            }
                          
                        case 0x6:
                          switch (FUNCTION_LO) {
                            
                            case 0x0:  
                              // FloatPSCompareOp::c_f_ps([' cond1 = 0; ', ' cond2 = 0; ', 'UnorderedFalse'],{})
                              
                                      std::cout << "c_f_ps" << std::endl;
return 0;// C_f_ps(machInst);
                              break;
                            
                            case 0x1:  
                              // FloatPSCompareOp::c_un_ps([' cond1 = 0; ', ' cond2 = 0; ', 'UnorderedTrue'],{})
                              
                                      std::cout << "c_un_ps" << std::endl;
return 0;// C_un_ps(machInst);
                              break;
                            
                            case 0x2:  
                              // FloatPSCompareOp::c_eq_ps([' cond1 = (Fs1_sf == Ft1_sf); ', ' cond2 = (Fs2_sf == Ft2_sf); ', 'UnorderedFalse'],{})
                              
                                      std::cout << "c_eq_ps" << std::endl;
return 0;// C_eq_ps(machInst);
                              break;
                            
                            case 0x3:  
                              // FloatPSCompareOp::c_ueq_ps([' cond1 = (Fs1_sf == Ft1_sf); ', ' cond2 = (Fs2_sf == Ft2_sf); ', 'UnorderedTrue'],{})
                              
                                      std::cout << "c_ueq_ps" << std::endl;
return 0;// C_ueq_ps(machInst);
                              break;
                            
                            case 0x4:  
                              // FloatPSCompareOp::c_olt_ps([' cond1 = (Fs1_sf < Ft1_sf); ', ' cond2 = (Fs2_sf < Ft2_sf); ', 'UnorderedFalse'],{})
                              
                                      std::cout << "c_olt_ps" << std::endl;
return 0;// C_olt_ps(machInst);
                              break;
                            
                            case 0x5:  
                              // FloatPSCompareOp::c_ult_ps([' cond1 = (Fs_sf < Ft_sf); ', ' cond2 = (Fs2_sf < Ft2_sf); ', 'UnorderedTrue'],{})
                              
                                      std::cout << "c_ult_ps" << std::endl;
return 0;// C_ult_ps(machInst);
                              break;
                            
                            case 0x6:  
                              // FloatPSCompareOp::c_ole_ps([' cond1 = (Fs_sf <= Ft_sf); ', ' cond2 = (Fs2_sf <= Ft2_sf); ', 'UnorderedFalse'],{})
                              
                                      std::cout << "c_ole_ps" << std::endl;
return 0;// C_ole_ps(machInst);
                              break;
                            
                            case 0x7:  
                              // FloatPSCompareOp::c_ule_ps([' cond1 = (Fs1_sf <= Ft1_sf); ', ' cond2 = (Fs2_sf <= Ft2_sf); ', 'UnorderedTrue'],{})
                              
                                      std::cout << "c_ule_ps" << std::endl;
return 0;// C_ule_ps(machInst);
                              break;
                            
                            default:
                              
                              // Unknown::unknown(([], {}))
                              std::cout << "UNKNOWN" << std::endl;
                              return 1;//Unknown(machInst);
                              break;
                            }
                          
                        case 0x7:
                          switch (FUNCTION_LO) {
                            
                            case 0x0:  
                              // FloatPSCompareOp::c_sf_ps([' cond1 = 0; ', ' cond2 = 0; ', 'UnorderedFalse', 'QnanException'],{})
                              
                                      std::cout << "c_sf_ps" << std::endl;
return 0;// C_sf_ps(machInst);
                              break;
                            
                            case 0x1:  
                              // FloatPSCompareOp::c_ngle_ps([' cond1 = 0; ', ' cond2 = 0; ', 'UnorderedTrue', 'QnanException'],{})
                              
                                      std::cout << "c_ngle_ps" << std::endl;
return 0;// C_ngle_ps(machInst);
                              break;
                            
                            case 0x2:  
                              // FloatPSCompareOp::c_seq_ps([' cond1 = (Fs1_sf == Ft1_sf); ', ' cond2 = (Fs2_sf == Ft2_sf); ', 'UnorderedFalse', 'QnanException'],{})
                              
                                      std::cout << "c_seq_ps" << std::endl;
return 0;// C_seq_ps(machInst);
                              break;
                            
                            case 0x3:  
                              // FloatPSCompareOp::c_ngl_ps([' cond1 = (Fs1_sf == Ft1_sf); ', ' cond2 = (Fs2_sf == Ft2_sf); ', 'UnorderedTrue', 'QnanException'],{})
                              
                                      std::cout << "c_ngl_ps" << std::endl;
return 0;// C_ngl_ps(machInst);
                              break;
                            
                            case 0x4:  
                              // FloatPSCompareOp::c_lt_ps([' cond1 = (Fs1_sf < Ft1_sf); ', ' cond2 = (Fs2_sf < Ft2_sf); ', 'UnorderedFalse', 'QnanException'],{})
                              
                                      std::cout << "c_lt_ps" << std::endl;
return 0;// C_lt_ps(machInst);
                              break;
                            
                            case 0x5:  
                              // FloatPSCompareOp::c_nge_ps([' cond1 = (Fs1_sf < Ft1_sf); ', ' cond2 = (Fs2_sf < Ft2_sf); ', 'UnorderedTrue', 'QnanException'],{})
                              
                                      std::cout << "c_nge_ps" << std::endl;
return 0;// C_nge_ps(machInst);
                              break;
                            
                            case 0x6:  
                              // FloatPSCompareOp::c_le_ps([' cond1 = (Fs1_sf <= Ft1_sf); ', ' cond2 = (Fs2_sf <= Ft2_sf); ', 'UnorderedFalse', 'QnanException'],{})
                              
                                      std::cout << "c_le_ps" << std::endl;
return 0;// C_le_ps(machInst);
                              break;
                            
                            case 0x7:  
                              // FloatPSCompareOp::c_ngt_ps([' cond1 = (Fs1_sf <= Ft1_sf); ', ' cond2 = (Fs2_sf <= Ft2_sf); ', 'UnorderedTrue', 'QnanException'],{})
                              
                                      std::cout << "c_ngt_ps" << std::endl;
return 0;// C_ngt_ps(machInst);
                              break;
                            
                            default:
                              
                              // Unknown::unknown(([], {}))
                              std::cout << "UNKNOWN" << std::endl;
                              return 1;//Unknown(machInst);
                              break;
                            }
                          
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                default:  
                  // CP1Unimpl::unknown(([], {}))
                  
                          std::cout << "UNKNOWN" << std::endl;
return 1;// CP1Unimplemented("unknown", machInst);
                  break;
                }
              
            default:
              
              // Unknown::unknown(([], {}))
              std::cout << "UNKNOWN" << std::endl;
              return 1;//Unknown(machInst);
              break;
            }
          
        case 0x2:
          switch (RS_MSB) {
            
            case 0x0:
              switch (RS_HI) {
                
                case 0x0:
                  switch (RS_LO) {
                    
                    case 0x0:  
                      // CP2Unimpl::mfc2([],{})
                      
                              std::cout << "mfc2" << std::endl;
return 0;// CP2Unimplemented("mfc2", machInst);
                      break;
                    
                    case 0x2:  
                      // CP2Unimpl::cfc2([],{})
                      
                              std::cout << "cfc2" << std::endl;
return 0;// CP2Unimplemented("cfc2", machInst);
                      break;
                    
                    case 0x3:  
                      // CP2Unimpl::mfhc2([],{})
                      
                              std::cout << "mfhc2" << std::endl;
return 0;// CP2Unimplemented("mfhc2", machInst);
                      break;
                    
                    case 0x4:  
                      // CP2Unimpl::mtc2([],{})
                      
                              std::cout << "mtc2" << std::endl;
return 0;// CP2Unimplemented("mtc2", machInst);
                      break;
                    
                    case 0x6:  
                      // CP2Unimpl::ctc2([],{})
                      
                              std::cout << "ctc2" << std::endl;
return 0;// CP2Unimplemented("ctc2", machInst);
                      break;
                    
                    case 0x7:  
                      // CP2Unimpl::mftc2([],{})
                      
                              std::cout << "mftc2" << std::endl;
return 0;// CP2Unimplemented("mftc2", machInst);
                      break;
                    
                    default:  
                      // CP2Unimpl::unknown([],{})
                      
                              std::cout << "UNKNOWN" << std::endl;
return 1;// CP2Unimplemented("unknown", machInst);
                      break;
                    }
                  
                case 0x1:
                  switch (ND) {
                    
                    case 0x0:
                      switch (TF) {
                        
                        case 0x0:  
                          // CP2Unimpl::bc2f([],{})
                          
                                  std::cout << "bc2f" << std::endl;
return 0;// CP2Unimplemented("bc2f", machInst);
                          break;
                        
                        case 0x1:  
                          // CP2Unimpl::bc2t([],{})
                          
                                  std::cout << "bc2t" << std::endl;
return 0;// CP2Unimplemented("bc2t", machInst);
                          break;
                        
                        default:  
                          // CP2Unimpl::unknown([],{})
                          
                                  std::cout << "UNKNOWN" << std::endl;
return 1;// CP2Unimplemented("unknown", machInst);
                          break;
                        }
                      
                    case 0x1:
                      switch (TF) {
                        
                        case 0x0:  
                          // CP2Unimpl::bc2fl([],{})
                          
                                  std::cout << "bc2fl" << std::endl;
return 0;// CP2Unimplemented("bc2fl", machInst);
                          break;
                        
                        case 0x1:  
                          // CP2Unimpl::bc2tl([],{})
                          
                                  std::cout << "bc2tl" << std::endl;
return 0;// CP2Unimplemented("bc2tl", machInst);
                          break;
                        
                        default:  
                          // CP2Unimpl::unknown([],{})
                          
                                  std::cout << "UNKNOWN" << std::endl;
return 1;// CP2Unimplemented("unknown", machInst);
                          break;
                        }
                      
                    default:  
                      // CP2Unimpl::unknown([],{})
                      
                              std::cout << "UNKNOWN" << std::endl;
return 1;// CP2Unimplemented("unknown", machInst);
                      break;
                    }
                  
                default:  
                  // CP2Unimpl::unknown([],{})
                  
                          std::cout << "UNKNOWN" << std::endl;
return 1;// CP2Unimplemented("unknown", machInst);
                  break;
                }
              
            default:  
              // CP2Unimpl::unknown([],{})
              
                      std::cout << "UNKNOWN" << std::endl;
return 1;// CP2Unimplemented("unknown", machInst);
              break;
            }
          
        case 0x3:
          switch (FUNCTION_HI) {
            
            case 0x0:
              switch (FUNCTION_LO) {
                
                case 0x0:  
                  // LoadIndexedMemory::lwxc1([' Fd_uw = Mem_uw; '],{})
                  
                   /*{
                       MipsStaticInst *i = new Lwxc1(machInst);
                       //if (RT == 0) {
                       // i = makeNop(i);
                       // }
                       return i;
                   }*/
                   std::cout << "lwxc1" << std::endl;
                   return 0;
                  break;
                
                case 0x1:  
                  // LoadIndexedMemory::ldxc1([' Fd_ud = Mem_ud; '],{})
                  
                   /*{
                       MipsStaticInst *i = new Ldxc1(machInst);
                       //if (RT == 0) {
                       // i = makeNop(i);
                       // }
                       return i;
                   }*/
                   std::cout << "ldxc1" << std::endl;
                   return 0;
                  break;
                
                case 0x5:  
                  // LoadIndexedMemory::luxc1([' Fd_ud = Mem_ud; ', ' EA = (Rs + Rt) & ~7; '],{})
                  
                   /*{
                       MipsStaticInst *i = new Luxc1(machInst);
                       //if (RT == 0) {
                       // i = makeNop(i);
                       // }
                       return i;
                   }*/
                   std::cout << "luxc1" << std::endl;
                   return 0;
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x1:
              switch (FUNCTION_LO) {
                
                case 0x0:  
                  // StoreIndexedMemory::swxc1([' Mem_uw = Fs_uw; '],{})
                  
                          std::cout << "swxc1" << std::endl;
return 0;// Swxc1(machInst);
                  break;
                
                case 0x1:  
                  // StoreIndexedMemory::sdxc1([' Mem_ud = Fs_ud; '],{})
                  
                          std::cout << "sdxc1" << std::endl;
return 0;// Sdxc1(machInst);
                  break;
                
                case 0x5:  
                  // StoreIndexedMemory::suxc1([' Mem_ud = Fs_ud; ', ' EA = (Rs + Rt) & ~7; '],{})
                  
                          std::cout << "suxc1" << std::endl;
return 0;// Suxc1(machInst);
                  break;
                
                case 0x7:  
                  // Prefetch::prefx(([' EA = Rs + Rt; '], {}))
                  
                          std::cout << "prefx" << std::endl;
return 0;// Prefx(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x3:
              switch (FUNCTION_LO) {
                
                case 0x6:  
                  // Float64Op::alnv_ps((['\n                    if (Rs<2:0> == 0) {\n                        Fd_ud = Fs_ud;\n                    } else if (Rs<2:0> == 4) {\n                        if (GuestByteOrder == BigEndianByteOrder)\n                            Fd_ud = Fs_ud<31:0> << 32 | Ft_ud<63:32>;\n                        else\n                            Fd_ud = Ft_ud<31:0> << 32 | Fs_ud<63:32>;\n                    } else {\n                        Fd_ud = Fd_ud;\n                    }\n                '], {}))
                  
                          std::cout << "alnv_ps" << std::endl;
return 0;// Alnv_ps(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x4:
              switch (FUNCTION_LO) {
                
                case 0x0:  
                  // FloatAccOp::madd_s([' Fd_sf = (Fs_sf * Ft_sf) + Fr_sf; '],{})
                  
                          std::cout << "madd_s" << std::endl;
return 0;// Madd_s(machInst);
                  break;
                
                case 0x1:  
                  // FloatAccOp::madd_d([' Fd_df = (Fs_df * Ft_df) + Fr_df; '],{})
                  
                          std::cout << "madd_d" << std::endl;
return 0;// Madd_d(machInst);
                  break;
                
                case 0x6:  
                  // FloatAccOp::madd_ps(['\n                        Fd1_sf = (Fs1_df * Ft1_df) + Fr1_df;\n                        Fd2_sf = (Fs2_df * Ft2_df) + Fr2_df;\n                    '],{})
                  
                          std::cout << "madd_ps" << std::endl;
return 0;// Madd_ps(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x5:
              switch (FUNCTION_LO) {
                
                case 0x0:  
                  // FloatAccOp::msub_s([' Fd_sf = (Fs_sf * Ft_sf) - Fr_sf; '],{})
                  
                          std::cout << "msub_s" << std::endl;
return 0;// Msub_s(machInst);
                  break;
                
                case 0x1:  
                  // FloatAccOp::msub_d([' Fd_df = (Fs_df * Ft_df) - Fr_df; '],{})
                  
                          std::cout << "msub_d" << std::endl;
return 0;// Msub_d(machInst);
                  break;
                
                case 0x6:  
                  // FloatAccOp::msub_ps(['\n                        Fd1_sf = (Fs1_df * Ft1_df) - Fr1_df;\n                        Fd2_sf = (Fs2_df * Ft2_df) - Fr2_df;\n                    '],{})
                  
                          std::cout << "msub_ps" << std::endl;
return 0;// Msub_ps(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x6:
              switch (FUNCTION_LO) {
                
                case 0x0:  
                  // FloatAccOp::nmadd_s([' Fd_sf = (-1 * Fs_sf * Ft_sf) - Fr_sf; '],{})
                  
                          std::cout << "nmadd_s" << std::endl;
return 0;// Nmadd_s(machInst);
                  break;
                
                case 0x1:  
                  // FloatAccOp::nmadd_d([' Fd_df = (-1 * Fs_df * Ft_df) - Fr_df; '],{})
                  
                          std::cout << "nmadd_d" << std::endl;
return 0;// Nmadd_d(machInst);
                  break;
                
                case 0x6:  
                  // FloatAccOp::nmadd_ps(['\n                        Fd1_sf = -((Fs1_df * Ft1_df) + Fr1_df);\n                        Fd2_sf = -((Fs2_df * Ft2_df) + Fr2_df);\n                    '],{})
                  
                          std::cout << "nmadd_ps" << std::endl;
return 0;// Nmadd_ps(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x7:
              switch (FUNCTION_LO) {
                
                case 0x0:  
                  // FloatAccOp::nmsub_s([' Fd_sf = (-1 * Fs_sf * Ft_sf) + Fr_sf; '],{})
                  
                          std::cout << "nmsub_s" << std::endl;
return 0;// Nmsub_s(machInst);
                  break;
                
                case 0x1:  
                  // FloatAccOp::nmsub_d([' Fd_df = (-1 * Fs_df * Ft_df) + Fr_df; '],{})
                  
                          std::cout << "nmsub_d" << std::endl;
return 0;// Nmsub_d(machInst);
                  break;
                
                case 0x6:  
                  // FloatAccOp::nmsub_ps(['\n                        Fd1_sf = -((Fs1_df * Ft1_df) - Fr1_df);\n                        Fd2_sf = -((Fs2_df * Ft2_df) - Fr2_df);\n                    '],{})
                  
                          std::cout << "nmsub_ps" << std::endl;
return 0;// Nmsub_ps(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            default:
              
              // Unknown::unknown(([], {}))
              std::cout << "UNKNOWN" << std::endl;
              return 1;//Unknown(machInst);
              break;
            }
          
        case 0x4:  
          // Branch::beql([' cond = (Rs_sw == Rt_sw); ', 'Likely'],{})
          
                  std::cout << "beql" << std::endl;
return 0;// Beql(machInst);
          break;
        
        case 0x5:  
          // Branch::bnel([' cond = (Rs_sw != Rt_sw); ', 'Likely'],{})
          
                  std::cout << "bnel" << std::endl;
return 0;// Bnel(machInst);
          break;
        
        case 0x6:  
          // Branch::blezl([' cond = (Rs_sw <= 0); ', 'Likely'],{})
          
                  std::cout << "blezl" << std::endl;
return 0;// Blezl(machInst);
          break;
        
        case 0x7:  
          // Branch::bgtzl([' cond = (Rs_sw > 0); ', 'Likely'],{})
          
                  std::cout << "bgtzl" << std::endl;
return 0;// Bgtzl(machInst);
          break;
        
        default:
          
          // Unknown::unknown(([], {}))
          std::cout << "UNKNOWN" << std::endl;
          return 1;//Unknown(machInst);
          break;
        }
      
    case 0x3:
      switch (OPCODE_LO) {
        
        case 0x4:
          switch (FUNCTION_HI) {
            
            case 0x0:
              switch (FUNCTION_LO) {
                
                case 0x2:  
                  // IntOp::mul((['\n                    int64_t temp1 = Rs_sd * Rt_sd;\n                    Rd_sw = temp1<31:0>;\n                ', 'IntMultOp'], {}))
                  
                   /*{
                       MipsStaticInst *i = new Mul(machInst);
                       //if (RD == 0) {
                           //i = makeNop(i);
                           //}
                       return i;
                   }*/
                   std::cout << "mul" << std::endl;
                   return 0;
                  break;
                
                case 0x0:  
                  // HiLoRdSelValOp::madd(['\n                        val = ((int64_t)HI_RD_SEL << 32 | LO_RD_SEL) +\n                              (Rs_sd * Rt_sd);\n                    ', 'IntMultOp'],{})
                  
                          std::cout << "madd" << std::endl;
return 0;// Madd(machInst);
                  break;
                
                case 0x1:  
                  // HiLoRdSelValOp::maddu(['\n                        val = ((uint64_t)HI_RD_SEL << 32 | LO_RD_SEL) +\n                              (Rs_ud * Rt_ud);\n                    ', 'IntMultOp'],{})
                  
                          std::cout << "maddu" << std::endl;
return 0;// Maddu(machInst);
                  break;
                
                case 0x4:  
                  // HiLoRdSelValOp::msub(['\n                        val = ((int64_t)HI_RD_SEL << 32 | LO_RD_SEL) -\n                              (Rs_sd * Rt_sd);\n                    ', 'IntMultOp'],{})
                  
                          std::cout << "msub" << std::endl;
return 0;// Msub(machInst);
                  break;
                
                case 0x5:  
                  // HiLoRdSelValOp::msubu(['\n                        val = ((uint64_t)HI_RD_SEL << 32 | LO_RD_SEL) -\n                              (Rs_ud * Rt_ud);\n                    ', 'IntMultOp'],{})
                  
                          std::cout << "msubu" << std::endl;
return 0;// Msubu(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x4:
              switch (FUNCTION_LO) {
                
                case 0x0:  
                  // BasicOp::clz(['\n                        int cnt = 32;\n                        for (int idx = 31; idx >= 0; idx--) {\n                            if (Rs<idx:idx> == 1) {\n                                cnt = 31 - idx;\n                                break;\n                            }\n                        }\n                        Rd_uw = cnt;\n                    '],{})
                  
                          std::cout << "clz" << std::endl;
return 0;// Clz(machInst);
                  break;
                
                case 0x1:  
                  // BasicOp::clo(['\n                        int cnt = 32;\n                        for (int idx = 31; idx >= 0; idx--) {\n                            if (Rs<idx:idx> == 0) {\n                                cnt = 31 - idx;\n                                break;\n                            }\n                        }\n                        Rd_uw = cnt;\n                    '],{})
                  
                          std::cout << "clo" << std::endl;
return 0;// Clo(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x7:
              switch (FUNCTION_LO) {
                
                case 0x7:  
                  // FailUnimpl::sdbbp(([], {}))
                  
                          std::cout << "sdbbp" << std::endl;
return 0;// FailUnimplemented("sdbbp", machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            default:
              
              // Unknown::unknown(([], {}))
              std::cout << "UNKNOWN" << std::endl;
              return 1;//Unknown(machInst);
              break;
            }
          
        case 0x7:
          switch (FUNCTION_HI) {
            
            case 0x0:
              switch (FUNCTION_LO) {
                
                case 0x0:  
                  // BasicOp::ext([' Rt_uw = bits(Rs_uw, MSB+LSB, LSB); '],{})
                  
                          std::cout << "ext" << std::endl;
return 0;// Ext(machInst);
                  break;
                
                case 0x4:  
                  // BasicOp::ins(['\n                        Rt_uw = bits(Rt_uw, 31, MSB+1) << (MSB+1) |\n                                bits(Rs_uw, MSB-LSB, 0) << LSB |\n                                bits(Rt_uw, LSB-1, 0);\n                    '],{})
                  
                          std::cout << "ins" << std::endl;
return 0;// Ins(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x1:
              switch (FUNCTION_LO) {
                
                case 0x0:  
                  // MT_Control::fork(['\n                        forkThread(xc->tcBase(), fault, RD, Rs, Rt);\n                    ', 'UserMode'],{})
                  
                          std::cout << "fork" << std::endl;
return 0;// Fork(machInst);
                  break;
                
                case 0x1:  
                  // MT_Control::yield(['\n                        Rd_sw = yieldThread(xc->tcBase(), fault, Rs_sw,\n                                            YQMask);\n                    ', 'UserMode'],{})
                  
                          std::cout << "yield" << std::endl;
return 0;// Yield(machInst);
                  break;
                
                case 0x2:
                  switch (OP_HI) {
                    
                    case 0x0:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // LoadIndexedMemory::lwx([' Rd_sw = Mem_sw; '],{})
                          
                           /*{
                               MipsStaticInst *i = new Lwx(machInst);
                               //if (RT == 0) {
                               // i = makeNop(i);
                               // }
                               return i;
                           }*/
                           std::cout << "lwx" << std::endl;
                           return 0;
                          break;
                        
                        case 0x4:  
                          // LoadIndexedMemory::lhx([' Rd_sw = Mem_sh; '],{})
                          
                           /*{
                               MipsStaticInst *i = new Lhx(machInst);
                               //if (RT == 0) {
                               // i = makeNop(i);
                               // }
                               return i;
                           }*/
                           std::cout << "lhx" << std::endl;
                           return 0;
                          break;
                        
                        case 0x6:  
                          // LoadIndexedMemory::lbux([' Rd_uw = Mem_ub; '],{})
                          
                           /*{
                               MipsStaticInst *i = new Lbux(machInst);
                               //if (RT == 0) {
                               // i = makeNop(i);
                               // }
                               return i;
                           }*/
                           std::cout << "lbux" << std::endl;
                           return 0;
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                case 0x4:  
                  // DspIntOp::insv((['\n                    int pos = dspctl<5:0>;\n                    int size = dspctl<12:7> - 1;\n                    Rt_uw = insertBits(Rt_uw, pos+size,\n                                       pos, Rs_uw<size:0>);\n                '], {}))
                  
                          std::cout << "insv" << std::endl;
return 0;// Insv(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x2:
              switch (FUNCTION_LO) {
                
                case 0x0:
                  switch (OP_HI) {
                    
                    case 0x0:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // DspIntOp::addu_qb(['\n                                Rd_uw = dspAdd(Rs_uw, Rt_uw, SIMD_FMT_QB,\n                                               NOSATURATE, UNSIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "addu_qb" << std::endl;
return 0;// Addu_qb(machInst);
                          break;
                        
                        case 0x1:  
                          // DspIntOp::subu_qb(['\n                                Rd_uw = dspSub(Rs_uw, Rt_uw, SIMD_FMT_QB,\n                                               NOSATURATE, UNSIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "subu_qb" << std::endl;
return 0;// Subu_qb(machInst);
                          break;
                        
                        case 0x4:  
                          // DspIntOp::addu_s_qb(['\n                                Rd_uw = dspAdd(Rs_uw, Rt_uw, SIMD_FMT_QB,\n                                               SATURATE, UNSIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "addu_s_qb" << std::endl;
return 0;// Addu_s_qb(machInst);
                          break;
                        
                        case 0x5:  
                          // DspIntOp::subu_s_qb(['\n                                Rd_uw = dspSub(Rs_uw, Rt_uw, SIMD_FMT_QB,\n                                               SATURATE, UNSIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "subu_s_qb" << std::endl;
return 0;// Subu_s_qb(machInst);
                          break;
                        
                        case 0x6:  
                          // DspIntOp::muleu_s_ph_qbl(['\n                                Rd_uw = dspMuleu(Rs_uw, Rt_uw,\n                                                 MODE_L, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "muleu_s_ph_qbl" << std::endl;
return 0;// Muleu_s_ph_qbl(machInst);
                          break;
                        
                        case 0x7:  
                          // DspIntOp::muleu_s_ph_qbr(['\n                                Rd_uw = dspMuleu(Rs_uw, Rt_uw,\n                                                 MODE_R, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "muleu_s_ph_qbr" << std::endl;
return 0;// Muleu_s_ph_qbr(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x1:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // DspIntOp::addu_ph(['\n                                Rd_uw = dspAdd(Rs_uw, Rt_uw, SIMD_FMT_PH,\n                                               NOSATURATE, UNSIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "addu_ph" << std::endl;
return 0;// Addu_ph(machInst);
                          break;
                        
                        case 0x1:  
                          // DspIntOp::subu_ph(['\n                                Rd_uw = dspSub(Rs_uw, Rt_uw, SIMD_FMT_PH,\n                                               NOSATURATE, UNSIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "subu_ph" << std::endl;
return 0;// Subu_ph(machInst);
                          break;
                        
                        case 0x2:  
                          // DspIntOp::addq_ph(['\n                                Rd_uw = dspAdd(Rs_uw, Rt_uw, SIMD_FMT_PH,\n                                               NOSATURATE, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "addq_ph" << std::endl;
return 0;// Addq_ph(machInst);
                          break;
                        
                        case 0x3:  
                          // DspIntOp::subq_ph(['\n                                Rd_uw = dspSub(Rs_uw, Rt_uw, SIMD_FMT_PH,\n                                               NOSATURATE, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "subq_ph" << std::endl;
return 0;// Subq_ph(machInst);
                          break;
                        
                        case 0x4:  
                          // DspIntOp::addu_s_ph(['\n                                Rd_uw = dspAdd(Rs_uw, Rt_uw, SIMD_FMT_PH,\n                                               SATURATE, UNSIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "addu_s_ph" << std::endl;
return 0;// Addu_s_ph(machInst);
                          break;
                        
                        case 0x5:  
                          // DspIntOp::subu_s_ph(['\n                                Rd_uw = dspSub(Rs_uw, Rt_uw, SIMD_FMT_PH,\n                                               SATURATE, UNSIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "subu_s_ph" << std::endl;
return 0;// Subu_s_ph(machInst);
                          break;
                        
                        case 0x6:  
                          // DspIntOp::addq_s_ph(['\n                                Rd_uw = dspAdd(Rs_uw, Rt_uw, SIMD_FMT_PH,\n                                               SATURATE, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "addq_s_ph" << std::endl;
return 0;// Addq_s_ph(machInst);
                          break;
                        
                        case 0x7:  
                          // DspIntOp::subq_s_ph(['\n                                Rd_uw = dspSub(Rs_uw, Rt_uw, SIMD_FMT_PH,\n                                               SATURATE, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "subq_s_ph" << std::endl;
return 0;// Subq_s_ph(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x2:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // DspIntOp::addsc(['\n                                int64_t dresult;\n                                dresult = Rs_ud + Rt_ud;\n                                Rd_sw = dresult<31:0>;\n                                dspctl = insertBits(dspctl, 13, 13,\n                                                    dresult<32:32>);\n                            '],{})
                          
                                  std::cout << "addsc" << std::endl;
return 0;// Addsc(machInst);
                          break;
                        
                        case 0x1:  
                          // DspIntOp::addwc(['\n                                int64_t dresult;\n                                dresult = Rs_sd + Rt_sd + dspctl<13:13>;\n                                Rd_sw = dresult<31:0>;\n                                if (dresult<32:32> != dresult<31:31>)\n                                    dspctl = insertBits(dspctl, 20, 20, 1);\n                            '],{})
                          
                                  std::cout << "addwc" << std::endl;
return 0;// Addwc(machInst);
                          break;
                        
                        case 0x2:  
                          // DspIntOp::modsub(['\n                                Rd_sw = (Rs_sw == 0) ? Rt_sw<23:8> :\n                                                       Rs_sw - Rt_sw<7:0>;\n                            '],{})
                          
                                  std::cout << "modsub" << std::endl;
return 0;// Modsub(machInst);
                          break;
                        
                        case 0x4:  
                          // DspIntOp::raddu_w_qb(['\n                                Rd_uw = Rs_uw<31:24> + Rs_uw<23:16> +\n                                        Rs_uw<15:8> + Rs_uw<7:0>;\n                            '],{})
                          
                                  std::cout << "raddu_w_qb" << std::endl;
return 0;// Raddu_w_qb(machInst);
                          break;
                        
                        case 0x6:  
                          // DspIntOp::addq_s_w(['\n                                Rd_sw = dspAdd(Rs_sw, Rt_sw, SIMD_FMT_W,\n                                               SATURATE, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "addq_s_w" << std::endl;
return 0;// Addq_s_w(machInst);
                          break;
                        
                        case 0x7:  
                          // DspIntOp::subq_s_w(['\n                                Rd_sw = dspSub(Rs_sw, Rt_sw, SIMD_FMT_W,\n                                               SATURATE, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "subq_s_w" << std::endl;
return 0;// Subq_s_w(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x3:
                      switch (OP_LO) {
                        
                        case 0x4:  
                          // DspIntOp::muleq_s_w_phl(['\n                                Rd_sw = dspMuleq(Rs_sw, Rt_sw,\n                                                 MODE_L, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "muleq_s_w_phl" << std::endl;
return 0;// Muleq_s_w_phl(machInst);
                          break;
                        
                        case 0x5:  
                          // DspIntOp::muleq_s_w_phr(['\n                                Rd_sw = dspMuleq(Rs_sw, Rt_sw,\n                                                 MODE_R, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "muleq_s_w_phr" << std::endl;
return 0;// Muleq_s_w_phr(machInst);
                          break;
                        
                        case 0x6:  
                          // DspIntOp::mulq_s_ph(['\n                                Rd_sw = dspMulq(Rs_sw, Rt_sw, SIMD_FMT_PH,\n                                                SATURATE, NOROUND, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "mulq_s_ph" << std::endl;
return 0;// Mulq_s_ph(machInst);
                          break;
                        
                        case 0x7:  
                          // DspIntOp::mulq_rs_ph(['\n                                Rd_sw = dspMulq(Rs_sw, Rt_sw, SIMD_FMT_PH,\n                                                SATURATE, ROUND, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "mulq_rs_ph" << std::endl;
return 0;// Mulq_rs_ph(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                case 0x1:
                  switch (OP_HI) {
                    
                    case 0x0:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // DspIntOp::cmpu_eq_qb(['\n                                dspCmp(Rs_uw, Rt_uw, SIMD_FMT_QB,\n                                       UNSIGNED, CMP_EQ, &dspctl);\n                            '],{})
                          
                                  std::cout << "cmpu_eq_qb" << std::endl;
return 0;// Cmpu_eq_qb(machInst);
                          break;
                        
                        case 0x1:  
                          // DspIntOp::cmpu_lt_qb(['\n                                dspCmp(Rs_uw, Rt_uw, SIMD_FMT_QB,\n                                       UNSIGNED, CMP_LT, &dspctl);\n                            '],{})
                          
                                  std::cout << "cmpu_lt_qb" << std::endl;
return 0;// Cmpu_lt_qb(machInst);
                          break;
                        
                        case 0x2:  
                          // DspIntOp::cmpu_le_qb(['\n                                dspCmp(Rs_uw, Rt_uw, SIMD_FMT_QB,\n                                       UNSIGNED, CMP_LE, &dspctl);\n                            '],{})
                          
                                  std::cout << "cmpu_le_qb" << std::endl;
return 0;// Cmpu_le_qb(machInst);
                          break;
                        
                        case 0x3:  
                          // DspIntOp::pick_qb(['\n                                Rd_uw = dspPick(Rs_uw, Rt_uw,\n                                                SIMD_FMT_QB, &dspctl);\n                            '],{})
                          
                                  std::cout << "pick_qb" << std::endl;
return 0;// Pick_qb(machInst);
                          break;
                        
                        case 0x4:  
                          // DspIntOp::cmpgu_eq_qb(['\n                                Rd_uw = dspCmpg(Rs_uw, Rt_uw, SIMD_FMT_QB,\n                                                UNSIGNED, CMP_EQ );\n                            '],{})
                          
                                  std::cout << "cmpgu_eq_qb" << std::endl;
return 0;// Cmpgu_eq_qb(machInst);
                          break;
                        
                        case 0x5:  
                          // DspIntOp::cmpgu_lt_qb(['\n                                Rd_uw = dspCmpg(Rs_uw, Rt_uw, SIMD_FMT_QB,\n                                                UNSIGNED, CMP_LT);\n                            '],{})
                          
                                  std::cout << "cmpgu_lt_qb" << std::endl;
return 0;// Cmpgu_lt_qb(machInst);
                          break;
                        
                        case 0x6:  
                          // DspIntOp::cmpgu_le_qb(['\n                                Rd_uw = dspCmpg(Rs_uw, Rt_uw, SIMD_FMT_QB,\n                                                UNSIGNED, CMP_LE);\n                            '],{})
                          
                                  std::cout << "cmpgu_le_qb" << std::endl;
return 0;// Cmpgu_le_qb(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x1:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // DspIntOp::cmp_eq_ph(['\n                                dspCmp(Rs_uw, Rt_uw, SIMD_FMT_PH,\n                                       SIGNED, CMP_EQ, &dspctl);\n                            '],{})
                          
                                  std::cout << "cmp_eq_ph" << std::endl;
return 0;// Cmp_eq_ph(machInst);
                          break;
                        
                        case 0x1:  
                          // DspIntOp::cmp_lt_ph(['\n                                dspCmp(Rs_uw, Rt_uw, SIMD_FMT_PH,\n                                       SIGNED, CMP_LT, &dspctl);\n                            '],{})
                          
                                  std::cout << "cmp_lt_ph" << std::endl;
return 0;// Cmp_lt_ph(machInst);
                          break;
                        
                        case 0x2:  
                          // DspIntOp::cmp_le_ph(['\n                                dspCmp(Rs_uw, Rt_uw, SIMD_FMT_PH,\n                                       SIGNED, CMP_LE, &dspctl);\n                            '],{})
                          
                                  std::cout << "cmp_le_ph" << std::endl;
return 0;// Cmp_le_ph(machInst);
                          break;
                        
                        case 0x3:  
                          // DspIntOp::pick_ph(['\n                                Rd_uw = dspPick(Rs_uw, Rt_uw,\n                                                SIMD_FMT_PH, &dspctl);\n                            '],{})
                          
                                  std::cout << "pick_ph" << std::endl;
return 0;// Pick_ph(machInst);
                          break;
                        
                        case 0x4:  
                          // DspIntOp::precrq_qb_ph(['\n                                Rd_uw = Rs_uw<31:24> << 24 |\n                                        Rs_uw<15:8> << 16 |\n                                        Rt_uw<31:24> << 8 |\n                                        Rt_uw<15:8>;\n                            '],{})
                          
                                  std::cout << "precrq_qb_ph" << std::endl;
return 0;// Precrq_qb_ph(machInst);
                          break;
                        
                        case 0x5:  
                          // DspIntOp::precr_qb_ph(['\n                                Rd_uw = Rs_uw<23:16> << 24 |\n                                        Rs_uw<7:0> << 16 |\n                                        Rt_uw<23:16> << 8 |\n                                        Rt_uw<7:0>;\n                            '],{})
                          
                                  std::cout << "precr_qb_ph" << std::endl;
return 0;// Precr_qb_ph(machInst);
                          break;
                        
                        case 0x6:  
                          // DspIntOp::packrl_ph(['\n                                Rd_uw = dspPack(Rs_uw, Rt_uw, SIMD_FMT_PH);\n                            '],{})
                          
                                  std::cout << "packrl_ph" << std::endl;
return 0;// Packrl_ph(machInst);
                          break;
                        
                        case 0x7:  
                          // DspIntOp::precrqu_s_qb_ph(['\n                                Rd_uw = dspPrecrqu(Rs_uw, Rt_uw, &dspctl);\n                            '],{})
                          
                                  std::cout << "precrqu_s_qb_ph" << std::endl;
return 0;// Precrqu_s_qb_ph(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x2:
                      switch (OP_LO) {
                        
                        case 0x4:  
                          // DspIntOp::precrq_ph_w(['\n                                Rd_uw = Rs_uw<31:16> << 16 | Rt_uw<31:16>;\n                            '],{})
                          
                                  std::cout << "precrq_ph_w" << std::endl;
return 0;// Precrq_ph_w(machInst);
                          break;
                        
                        case 0x5:  
                          // DspIntOp::precrq_rs_ph_w(['\n                                Rd_uw = dspPrecrq(Rs_uw, Rt_uw,\n                                                  SIMD_FMT_W, &dspctl);\n                            '],{})
                          
                                  std::cout << "precrq_rs_ph_w" << std::endl;
return 0;// Precrq_rs_ph_w(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x3:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // DspIntOp::cmpgdu_eq_qb(['\n                                Rd_uw = dspCmpgd(Rs_uw, Rt_uw, SIMD_FMT_QB,\n                                                 UNSIGNED, CMP_EQ, &dspctl);\n                            '],{})
                          
                                  std::cout << "cmpgdu_eq_qb" << std::endl;
return 0;// Cmpgdu_eq_qb(machInst);
                          break;
                        
                        case 0x1:  
                          // DspIntOp::cmpgdu_lt_qb(['\n                                Rd_uw = dspCmpgd(Rs_uw, Rt_uw, SIMD_FMT_QB,\n                                                 UNSIGNED, CMP_LT, &dspctl);\n                            '],{})
                          
                                  std::cout << "cmpgdu_lt_qb" << std::endl;
return 0;// Cmpgdu_lt_qb(machInst);
                          break;
                        
                        case 0x2:  
                          // DspIntOp::cmpgdu_le_qb(['\n                                Rd_uw = dspCmpgd(Rs_uw, Rt_uw, SIMD_FMT_QB,\n                                                 UNSIGNED, CMP_LE, &dspctl);\n                            '],{})
                          
                                  std::cout << "cmpgdu_le_qb" << std::endl;
return 0;// Cmpgdu_le_qb(machInst);
                          break;
                        
                        case 0x6:  
                          // DspIntOp::precr_sra_ph_w(['\n                                Rt_uw = dspPrecrSra(Rt_uw, Rs_uw, RD,\n                                                    SIMD_FMT_W, NOROUND);\n                            '],{})
                          
                                  std::cout << "precr_sra_ph_w" << std::endl;
return 0;// Precr_sra_ph_w(machInst);
                          break;
                        
                        case 0x7:  
                          // DspIntOp::precr_sra_r_ph_w(['\n                                Rt_uw = dspPrecrSra(Rt_uw, Rs_uw, RD,\n                                                    SIMD_FMT_W, ROUND); \n                            '],{})
                          
                                  std::cout << "precr_sra_r_ph_w" << std::endl;
return 0;// Precr_sra_r_ph_w(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                case 0x2:
                  switch (OP_HI) {
                    
                    case 0x0:
                      switch (OP_LO) {
                        
                        case 0x1:  
                          // DspIntOp::absq_s_qb(['\n                                Rd_sw = dspAbs(Rt_sw, SIMD_FMT_QB, &dspctl);\n                            '],{})
                          
                                  std::cout << "absq_s_qb" << std::endl;
return 0;// Absq_s_qb(machInst);
                          break;
                        
                        case 0x2:  
                          // DspIntOp::repl_qb(['\n                                Rd_uw = RS_RT<7:0> << 24 |\n                                        RS_RT<7:0> << 16 |\n                                        RS_RT<7:0> << 8 |\n                                        RS_RT<7:0>;\n                            '],{})
                          
                                  std::cout << "repl_qb" << std::endl;
return 0;// Repl_qb(machInst);
                          break;
                        
                        case 0x3:  
                          // DspIntOp::replv_qb(['\n                                Rd_sw = Rt_uw<7:0> << 24 |\n                                        Rt_uw<7:0> << 16 |\n                                        Rt_uw<7:0> << 8 |\n                                        Rt_uw<7:0>;\n                            '],{})
                          
                                  std::cout << "replv_qb" << std::endl;
return 0;// Replv_qb(machInst);
                          break;
                        
                        case 0x4:  
                          // DspIntOp::precequ_ph_qbl(['\n                                Rd_uw = dspPrece(Rt_uw, SIMD_FMT_QB, UNSIGNED,\n                                                 SIMD_FMT_PH, SIGNED, MODE_L);\n                            '],{})
                          
                                  std::cout << "precequ_ph_qbl" << std::endl;
return 0;// Precequ_ph_qbl(machInst);
                          break;
                        
                        case 0x5:  
                          // DspIntOp::precequ_ph_qbr(['\n                                Rd_uw = dspPrece(Rt_uw, SIMD_FMT_QB, UNSIGNED,\n                                                 SIMD_FMT_PH, SIGNED, MODE_R);\n                            '],{})
                          
                                  std::cout << "precequ_ph_qbr" << std::endl;
return 0;// Precequ_ph_qbr(machInst);
                          break;
                        
                        case 0x6:  
                          // DspIntOp::precequ_ph_qbla(['\n                                Rd_uw = dspPrece(Rt_uw, SIMD_FMT_QB, UNSIGNED,\n                                                 SIMD_FMT_PH, SIGNED, MODE_LA);\n                            '],{})
                          
                                  std::cout << "precequ_ph_qbla" << std::endl;
return 0;// Precequ_ph_qbla(machInst);
                          break;
                        
                        case 0x7:  
                          // DspIntOp::precequ_ph_qbra(['\n                                Rd_uw = dspPrece(Rt_uw, SIMD_FMT_QB, UNSIGNED,\n                                                 SIMD_FMT_PH, SIGNED, MODE_RA);\n                            '],{})
                          
                                  std::cout << "precequ_ph_qbra" << std::endl;
return 0;// Precequ_ph_qbra(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x1:
                      switch (OP_LO) {
                        
                        case 0x1:  
                          // DspIntOp::absq_s_ph(['\n                                Rd_sw = dspAbs(Rt_sw, SIMD_FMT_PH, &dspctl);\n                            '],{})
                          
                                  std::cout << "absq_s_ph" << std::endl;
return 0;// Absq_s_ph(machInst);
                          break;
                        
                        case 0x2:  
                          // DspIntOp::repl_ph(['\n                                Rd_uw = (sext<10>(RS_RT))<15:0> << 16 |\n                                        (sext<10>(RS_RT))<15:0>;\n                            '],{})
                          
                                  std::cout << "repl_ph" << std::endl;
return 0;// Repl_ph(machInst);
                          break;
                        
                        case 0x3:  
                          // DspIntOp::replv_ph(['\n                                Rd_uw = Rt_uw<15:0> << 16 |\n                                        Rt_uw<15:0>;\n                            '],{})
                          
                                  std::cout << "replv_ph" << std::endl;
return 0;// Replv_ph(machInst);
                          break;
                        
                        case 0x4:  
                          // DspIntOp::preceq_w_phl(['\n                                Rd_uw = dspPrece(Rt_uw, SIMD_FMT_PH, SIGNED,\n                                                 SIMD_FMT_W, SIGNED, MODE_L);\n                            '],{})
                          
                                  std::cout << "preceq_w_phl" << std::endl;
return 0;// Preceq_w_phl(machInst);
                          break;
                        
                        case 0x5:  
                          // DspIntOp::preceq_w_phr(['\n                                Rd_uw = dspPrece(Rt_uw, SIMD_FMT_PH, SIGNED,\n                                                 SIMD_FMT_W, SIGNED, MODE_R);\n                            '],{})
                          
                                  std::cout << "preceq_w_phr" << std::endl;
return 0;// Preceq_w_phr(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x2:
                      switch (OP_LO) {
                        
                        case 0x1:  
                          // DspIntOp::absq_s_w(['\n                                Rd_sw = dspAbs(Rt_sw, SIMD_FMT_W, &dspctl);\n                            '],{})
                          
                                  std::cout << "absq_s_w" << std::endl;
return 0;// Absq_s_w(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x3:
                      switch (OP_LO) {
                        
                        case 0x3:  
                          // IntOp::bitrev((['\n                            Rd_uw = bitrev( Rt_uw<15:0> );\n                        '], {}))
                          
                           /*{
                               MipsStaticInst *i = new Bitrev(machInst);
                               //if (RD == 0) {
                                   //i = makeNop(i);
                                   //}
                               return i;
                           }*/
                           std::cout << "bitrev" << std::endl;
                           return 0;
                          break;
                        
                        case 0x4:  
                          // DspIntOp::preceu_ph_qbl(['\n                                Rd_uw = dspPrece(Rt_uw, SIMD_FMT_QB,\n                                                 UNSIGNED, SIMD_FMT_PH,\n                                                 UNSIGNED, MODE_L);\n                            '],{})
                          
                                  std::cout << "preceu_ph_qbl" << std::endl;
return 0;// Preceu_ph_qbl(machInst);
                          break;
                        
                        case 0x5:  
                          // DspIntOp::preceu_ph_qbr(['\n                                Rd_uw = dspPrece(Rt_uw, SIMD_FMT_QB,\n                                                 UNSIGNED, SIMD_FMT_PH,\n                                                 UNSIGNED, MODE_R );\n                            '],{})
                          
                                  std::cout << "preceu_ph_qbr" << std::endl;
return 0;// Preceu_ph_qbr(machInst);
                          break;
                        
                        case 0x6:  
                          // DspIntOp::preceu_ph_qbla(['\n                                Rd_uw = dspPrece(Rt_uw, SIMD_FMT_QB,\n                                                 UNSIGNED, SIMD_FMT_PH,\n                                                 UNSIGNED, MODE_LA );\n                            '],{})
                          
                                  std::cout << "preceu_ph_qbla" << std::endl;
return 0;// Preceu_ph_qbla(machInst);
                          break;
                        
                        case 0x7:  
                          // DspIntOp::preceu_ph_qbra(['\n                                Rd_uw = dspPrece(Rt_uw, SIMD_FMT_QB,\n                                                 UNSIGNED, SIMD_FMT_PH,\n                                                 UNSIGNED, MODE_RA);\n                            '],{})
                          
                                  std::cout << "preceu_ph_qbra" << std::endl;
return 0;// Preceu_ph_qbra(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                case 0x3:
                  switch (OP_HI) {
                    
                    case 0x0:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // DspIntOp::shll_qb(['\n                                Rd_sw = dspShll(Rt_sw, RS, SIMD_FMT_QB,\n                                                NOSATURATE, UNSIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shll_qb" << std::endl;
return 0;// Shll_qb(machInst);
                          break;
                        
                        case 0x1:  
                          // DspIntOp::shrl_qb(['\n                                Rd_sw = dspShrl(Rt_sw, RS, SIMD_FMT_QB,\n                                                UNSIGNED);\n                            '],{})
                          
                                  std::cout << "shrl_qb" << std::endl;
return 0;// Shrl_qb(machInst);
                          break;
                        
                        case 0x2:  
                          // DspIntOp::shllv_qb(['\n                                Rd_sw = dspShll(Rt_sw, Rs_sw, SIMD_FMT_QB,\n                                                NOSATURATE, UNSIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shllv_qb" << std::endl;
return 0;// Shllv_qb(machInst);
                          break;
                        
                        case 0x3:  
                          // DspIntOp::shrlv_qb(['\n                                Rd_sw = dspShrl(Rt_sw, Rs_sw, SIMD_FMT_QB,\n                                                UNSIGNED);\n                            '],{})
                          
                                  std::cout << "shrlv_qb" << std::endl;
return 0;// Shrlv_qb(machInst);
                          break;
                        
                        case 0x4:  
                          // DspIntOp::shra_qb(['\n                                Rd_sw = dspShra(Rt_sw, RS, SIMD_FMT_QB,\n                                                NOROUND, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shra_qb" << std::endl;
return 0;// Shra_qb(machInst);
                          break;
                        
                        case 0x5:  
                          // DspIntOp::shra_r_qb(['\n                                Rd_sw = dspShra(Rt_sw, RS, SIMD_FMT_QB,\n                                                ROUND, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shra_r_qb" << std::endl;
return 0;// Shra_r_qb(machInst);
                          break;
                        
                        case 0x6:  
                          // DspIntOp::shrav_qb(['\n                                Rd_sw = dspShra(Rt_sw, Rs_sw, SIMD_FMT_QB,\n                                                NOROUND, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shrav_qb" << std::endl;
return 0;// Shrav_qb(machInst);
                          break;
                        
                        case 0x7:  
                          // DspIntOp::shrav_r_qb(['\n                                Rd_sw = dspShra(Rt_sw, Rs_sw, SIMD_FMT_QB,\n                                                ROUND, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shrav_r_qb" << std::endl;
return 0;// Shrav_r_qb(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x1:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // DspIntOp::shll_ph(['\n                                Rd_uw = dspShll(Rt_uw, RS, SIMD_FMT_PH,\n                                                NOSATURATE, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shll_ph" << std::endl;
return 0;// Shll_ph(machInst);
                          break;
                        
                        case 0x1:  
                          // DspIntOp::shra_ph(['\n                                Rd_sw = dspShra(Rt_sw, RS, SIMD_FMT_PH,\n                                                NOROUND, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shra_ph" << std::endl;
return 0;// Shra_ph(machInst);
                          break;
                        
                        case 0x2:  
                          // DspIntOp::shllv_ph(['\n                                Rd_sw = dspShll(Rt_sw, Rs_sw, SIMD_FMT_PH,\n                                                NOSATURATE, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shllv_ph" << std::endl;
return 0;// Shllv_ph(machInst);
                          break;
                        
                        case 0x3:  
                          // DspIntOp::shrav_ph(['\n                                Rd_sw = dspShra(Rt_sw, Rs_sw, SIMD_FMT_PH,\n                                                NOROUND, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shrav_ph" << std::endl;
return 0;// Shrav_ph(machInst);
                          break;
                        
                        case 0x4:  
                          // DspIntOp::shll_s_ph(['\n                                Rd_sw = dspShll(Rt_sw, RS, SIMD_FMT_PH,\n                                                SATURATE, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shll_s_ph" << std::endl;
return 0;// Shll_s_ph(machInst);
                          break;
                        
                        case 0x5:  
                          // DspIntOp::shra_r_ph(['\n                                Rd_sw = dspShra(Rt_sw, RS, SIMD_FMT_PH,\n                                                ROUND, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shra_r_ph" << std::endl;
return 0;// Shra_r_ph(machInst);
                          break;
                        
                        case 0x6:  
                          // DspIntOp::shllv_s_ph(['\n                                Rd_sw = dspShll(Rt_sw, Rs_sw, SIMD_FMT_PH,\n                                                SATURATE, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shllv_s_ph" << std::endl;
return 0;// Shllv_s_ph(machInst);
                          break;
                        
                        case 0x7:  
                          // DspIntOp::shrav_r_ph(['\n                                Rd_sw = dspShra(Rt_sw, Rs_sw, SIMD_FMT_PH,\n                                                ROUND, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shrav_r_ph" << std::endl;
return 0;// Shrav_r_ph(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x2:
                      switch (OP_LO) {
                        
                        case 0x4:  
                          // DspIntOp::shll_s_w(['\n                                Rd_sw = dspShll(Rt_sw, RS, SIMD_FMT_W,\n                                                SATURATE, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shll_s_w" << std::endl;
return 0;// Shll_s_w(machInst);
                          break;
                        
                        case 0x5:  
                          // DspIntOp::shra_r_w(['\n                                Rd_sw = dspShra(Rt_sw, RS, SIMD_FMT_W,\n                                                ROUND, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shra_r_w" << std::endl;
return 0;// Shra_r_w(machInst);
                          break;
                        
                        case 0x6:  
                          // DspIntOp::shllv_s_w(['\n                                Rd_sw = dspShll(Rt_sw, Rs_sw, SIMD_FMT_W,\n                                                SATURATE, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shllv_s_w" << std::endl;
return 0;// Shllv_s_w(machInst);
                          break;
                        
                        case 0x7:  
                          // DspIntOp::shrav_r_w(['\n                                Rd_sw = dspShra(Rt_sw, Rs_sw, SIMD_FMT_W,\n                                                ROUND, SIGNED, &dspctl);\n                            '],{})
                          
                                  std::cout << "shrav_r_w" << std::endl;
return 0;// Shrav_r_w(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x3:
                      switch (OP_LO) {
                        
                        case 0x1:  
                          // DspIntOp::shrl_ph(['\n                                Rd_sw = dspShrl(Rt_sw, RS, SIMD_FMT_PH,\n                                                UNSIGNED);\n                            '],{})
                          
                                  std::cout << "shrl_ph" << std::endl;
return 0;// Shrl_ph(machInst);
                          break;
                        
                        case 0x3:  
                          // DspIntOp::shrlv_ph(['\n                                Rd_sw = dspShrl(Rt_sw, Rs_sw, SIMD_FMT_PH,\n                                                UNSIGNED);\n                            '],{})
                          
                                  std::cout << "shrlv_ph" << std::endl;
return 0;// Shrlv_ph(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x3:
              switch (FUNCTION_LO) {
                
                case 0x0:
                  switch (OP_HI) {
                    
                    case 0x0:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // DspIntOp::adduh_qb(['\n                                Rd_uw = dspAddh(Rs_sw, Rt_sw, SIMD_FMT_QB,\n                                                NOROUND, UNSIGNED);\n                            '],{})
                          
                                  std::cout << "adduh_qb" << std::endl;
return 0;// Adduh_qb(machInst);
                          break;
                        
                        case 0x1:  
                          // DspIntOp::subuh_qb(['\n                                Rd_uw = dspSubh(Rs_sw, Rt_sw, SIMD_FMT_QB,\n                                                NOROUND, UNSIGNED);\n                            '],{})
                          
                                  std::cout << "subuh_qb" << std::endl;
return 0;// Subuh_qb(machInst);
                          break;
                        
                        case 0x2:  
                          // DspIntOp::adduh_r_qb(['\n                                Rd_uw = dspAddh(Rs_sw, Rt_sw, SIMD_FMT_QB,\n                                                ROUND, UNSIGNED);\n                            '],{})
                          
                                  std::cout << "adduh_r_qb" << std::endl;
return 0;// Adduh_r_qb(machInst);
                          break;
                        
                        case 0x3:  
                          // DspIntOp::subuh_r_qb(['\n                                Rd_uw = dspSubh(Rs_sw, Rt_sw, SIMD_FMT_QB,\n                                                ROUND, UNSIGNED);\n                            '],{})
                          
                                  std::cout << "subuh_r_qb" << std::endl;
return 0;// Subuh_r_qb(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x1:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // DspIntOp::addqh_ph(['\n                                Rd_uw = dspAddh(Rs_sw, Rt_sw, SIMD_FMT_PH,\n                                                NOROUND, SIGNED);\n                            '],{})
                          
                                  std::cout << "addqh_ph" << std::endl;
return 0;// Addqh_ph(machInst);
                          break;
                        
                        case 0x1:  
                          // DspIntOp::subqh_ph(['\n                                Rd_uw = dspSubh(Rs_sw, Rt_sw, SIMD_FMT_PH,\n                                                NOROUND, SIGNED);\n                            '],{})
                          
                                  std::cout << "subqh_ph" << std::endl;
return 0;// Subqh_ph(machInst);
                          break;
                        
                        case 0x2:  
                          // DspIntOp::addqh_r_ph(['\n                                Rd_uw = dspAddh(Rs_sw, Rt_sw, SIMD_FMT_PH,\n                                                ROUND, SIGNED);\n                            '],{})
                          
                                  std::cout << "addqh_r_ph" << std::endl;
return 0;// Addqh_r_ph(machInst);
                          break;
                        
                        case 0x3:  
                          // DspIntOp::subqh_r_ph(['\n                                Rd_uw = dspSubh(Rs_sw, Rt_sw, SIMD_FMT_PH,\n                                                ROUND, SIGNED);\n                            '],{})
                          
                                  std::cout << "subqh_r_ph" << std::endl;
return 0;// Subqh_r_ph(machInst);
                          break;
                        
                        case 0x4:  
                          // DspIntOp::mul_ph(['\n                                Rd_sw = dspMul(Rs_sw, Rt_sw, SIMD_FMT_PH,\n                                               NOSATURATE, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "mul_ph" << std::endl;
return 0;// Mul_ph(machInst);
                          break;
                        
                        case 0x6:  
                          // DspIntOp::mul_s_ph(['\n                                Rd_sw = dspMul(Rs_sw, Rt_sw, SIMD_FMT_PH,\n                                               SATURATE, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "mul_s_ph" << std::endl;
return 0;// Mul_s_ph(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x2:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // DspIntOp::addqh_w(['\n                                Rd_uw = dspAddh(Rs_sw, Rt_sw, SIMD_FMT_W,\n                                                NOROUND, SIGNED);\n                            '],{})
                          
                                  std::cout << "addqh_w" << std::endl;
return 0;// Addqh_w(machInst);
                          break;
                        
                        case 0x1:  
                          // DspIntOp::subqh_w(['\n                                Rd_uw = dspSubh(Rs_sw, Rt_sw, SIMD_FMT_W,\n                                                NOROUND, SIGNED);\n                            '],{})
                          
                                  std::cout << "subqh_w" << std::endl;
return 0;// Subqh_w(machInst);
                          break;
                        
                        case 0x2:  
                          // DspIntOp::addqh_r_w(['\n                                Rd_uw = dspAddh(Rs_sw, Rt_sw, SIMD_FMT_W,\n                                                ROUND, SIGNED);\n                            '],{})
                          
                                  std::cout << "addqh_r_w" << std::endl;
return 0;// Addqh_r_w(machInst);
                          break;
                        
                        case 0x3:  
                          // DspIntOp::subqh_r_w(['\n                                Rd_uw = dspSubh(Rs_sw, Rt_sw, SIMD_FMT_W,\n                                                ROUND, SIGNED);\n                            '],{})
                          
                                  std::cout << "subqh_r_w" << std::endl;
return 0;// Subqh_r_w(machInst);
                          break;
                        
                        case 0x6:  
                          // DspIntOp::mulq_s_w(['\n                                Rd_sw = dspMulq(Rs_sw, Rt_sw, SIMD_FMT_W,\n                                                SATURATE, NOROUND, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "mulq_s_w" << std::endl;
return 0;// Mulq_s_w(machInst);
                          break;
                        
                        case 0x7:  
                          // DspIntOp::mulq_rs_w(['\n                                Rd_sw = dspMulq(Rs_sw, Rt_sw, SIMD_FMT_W,\n                                                SATURATE, ROUND, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "mulq_rs_w" << std::endl;
return 0;// Mulq_rs_w(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x4:
              switch (SA) {
                
                case 0x2:  
                  // BasicOp::wsbh(['\n                        Rd_uw = Rt_uw<23:16> << 24 |\n                                Rt_uw<31:24> << 16 |\n                                Rt_uw<7:0>   << 8  |\n                                Rt_uw<15:8>;\n                    '],{})
                  
                          std::cout << "wsbh" << std::endl;
return 0;// Wsbh(machInst);
                  break;
                
                case 0x10:  
                  // BasicOp::seb([' Rd_sw = Rt_sb; '],{})
                  
                          std::cout << "seb" << std::endl;
return 0;// Seb(machInst);
                  break;
                
                case 0x18:  
                  // BasicOp::seh([' Rd_sw = Rt_sh; '],{})
                  
                          std::cout << "seh" << std::endl;
return 0;// Seh(machInst);
                  break;
                
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x6:
              switch (FUNCTION_LO) {
                
                case 0x0:
                  switch (OP_HI) {
                    
                    case 0x0:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // DspHiLoOp::dpa_w_ph(['\n                                dspac = dspDpa(dspac, Rs_sw, Rt_sw, ACDST,\n                                               SIMD_FMT_PH, SIGNED, MODE_L);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "dpa_w_ph" << std::endl;
return 0;// Dpa_w_ph(machInst);
                          break;
                        
                        case 0x1:  
                          // DspHiLoOp::dps_w_ph(['\n                                dspac = dspDps(dspac, Rs_sw, Rt_sw, ACDST,\n                                               SIMD_FMT_PH, SIGNED, MODE_L);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "dps_w_ph" << std::endl;
return 0;// Dps_w_ph(machInst);
                          break;
                        
                        case 0x2:  
                          // DspHiLoOp::mulsa_w_ph(['\n                                dspac = dspMulsa(dspac, Rs_sw, Rt_sw,\n                                                 ACDST, SIMD_FMT_PH );\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "mulsa_w_ph" << std::endl;
return 0;// Mulsa_w_ph(machInst);
                          break;
                        
                        case 0x3:  
                          // DspHiLoOp::dpau_h_qbl(['\n                                dspac = dspDpa(dspac, Rs_sw, Rt_sw, ACDST,\n                                               SIMD_FMT_QB, UNSIGNED, MODE_L);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "dpau_h_qbl" << std::endl;
return 0;// Dpau_h_qbl(machInst);
                          break;
                        
                        case 0x4:  
                          // DspHiLoOp::dpaq_s_w_ph(['\n                                dspac = dspDpaq(dspac, Rs_sw, Rt_sw,\n                                                ACDST, SIMD_FMT_PH,\n                                                SIMD_FMT_W, NOSATURATE,\n                                                MODE_L, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "dpaq_s_w_ph" << std::endl;
return 0;// Dpaq_s_w_ph(machInst);
                          break;
                        
                        case 0x5:  
                          // DspHiLoOp::dpsq_s_w_ph(['\n                                dspac = dspDpsq(dspac, Rs_sw, Rt_sw,\n                                                ACDST, SIMD_FMT_PH,\n                                                SIMD_FMT_W, NOSATURATE,\n                                                MODE_L, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "dpsq_s_w_ph" << std::endl;
return 0;// Dpsq_s_w_ph(machInst);
                          break;
                        
                        case 0x6:  
                          // DspHiLoOp::mulsaq_s_w_ph(['\n                                dspac = dspMulsaq(dspac, Rs_sw, Rt_sw,\n                                                  ACDST, SIMD_FMT_PH,\n                                                  &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "mulsaq_s_w_ph" << std::endl;
return 0;// Mulsaq_s_w_ph(machInst);
                          break;
                        
                        case 0x7:  
                          // DspHiLoOp::dpau_h_qbr(['\n                                dspac = dspDpa(dspac, Rs_sw, Rt_sw, ACDST,\n                                               SIMD_FMT_QB, UNSIGNED, MODE_R);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "dpau_h_qbr" << std::endl;
return 0;// Dpau_h_qbr(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x1:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // DspHiLoOp::dpax_w_ph(['\n                                dspac = dspDpa(dspac, Rs_sw, Rt_sw, ACDST,\n                                               SIMD_FMT_PH, SIGNED, MODE_X);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "dpax_w_ph" << std::endl;
return 0;// Dpax_w_ph(machInst);
                          break;
                        
                        case 0x1:  
                          // DspHiLoOp::dpsx_w_ph(['\n                                dspac = dspDps(dspac, Rs_sw, Rt_sw, ACDST,\n                                               SIMD_FMT_PH, SIGNED, MODE_X);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "dpsx_w_ph" << std::endl;
return 0;// Dpsx_w_ph(machInst);
                          break;
                        
                        case 0x3:  
                          // DspHiLoOp::dpsu_h_qbl(['\n                                dspac = dspDps(dspac, Rs_sw, Rt_sw, ACDST,\n                                               SIMD_FMT_QB, UNSIGNED, MODE_L);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "dpsu_h_qbl" << std::endl;
return 0;// Dpsu_h_qbl(machInst);
                          break;
                        
                        case 0x4:  
                          // DspHiLoOp::dpaq_sa_l_w(['\n                                dspac = dspDpaq(dspac, Rs_sw, Rt_sw,\n                                                ACDST, SIMD_FMT_W,\n                                                SIMD_FMT_L, SATURATE,\n                                                MODE_L, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "dpaq_sa_l_w" << std::endl;
return 0;// Dpaq_sa_l_w(machInst);
                          break;
                        
                        case 0x5:  
                          // DspHiLoOp::dpsq_sa_l_w(['\n                                dspac = dspDpsq(dspac, Rs_sw, Rt_sw,\n                                                ACDST, SIMD_FMT_W,\n                                                SIMD_FMT_L, SATURATE,\n                                                MODE_L, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "dpsq_sa_l_w" << std::endl;
return 0;// Dpsq_sa_l_w(machInst);
                          break;
                        
                        case 0x7:  
                          // DspHiLoOp::dpsu_h_qbr(['\n                                dspac = dspDps(dspac, Rs_sw, Rt_sw, ACDST,\n                                               SIMD_FMT_QB, UNSIGNED, MODE_R);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "dpsu_h_qbr" << std::endl;
return 0;// Dpsu_h_qbr(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x2:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // DspHiLoOp::maq_sa_w_phl(['\n                                dspac = dspMaq(dspac, Rs_uw, Rt_uw,\n                                               ACDST, SIMD_FMT_PH,\n                                               MODE_L, SATURATE, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "maq_sa_w_phl" << std::endl;
return 0;// Maq_sa_w_phl(machInst);
                          break;
                        
                        case 0x2:  
                          // DspHiLoOp::maq_sa_w_phr(['\n                                dspac = dspMaq(dspac, Rs_uw, Rt_uw,\n                                               ACDST, SIMD_FMT_PH,\n                                               MODE_R, SATURATE, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "maq_sa_w_phr" << std::endl;
return 0;// Maq_sa_w_phr(machInst);
                          break;
                        
                        case 0x4:  
                          // DspHiLoOp::maq_s_w_phl(['\n                                dspac = dspMaq(dspac, Rs_uw, Rt_uw,\n                                               ACDST, SIMD_FMT_PH,\n                                               MODE_L, NOSATURATE, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "maq_s_w_phl" << std::endl;
return 0;// Maq_s_w_phl(machInst);
                          break;
                        
                        case 0x6:  
                          // DspHiLoOp::maq_s_w_phr(['\n                                dspac = dspMaq(dspac, Rs_uw, Rt_uw,\n                                               ACDST, SIMD_FMT_PH,\n                                               MODE_R, NOSATURATE, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "maq_s_w_phr" << std::endl;
return 0;// Maq_s_w_phr(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x3:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // DspHiLoOp::dpaqx_s_w_ph(['\n                                dspac = dspDpaq(dspac, Rs_sw, Rt_sw,\n                                                ACDST, SIMD_FMT_PH,\n                                                SIMD_FMT_W, NOSATURATE,\n                                                MODE_X, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "dpaqx_s_w_ph" << std::endl;
return 0;// Dpaqx_s_w_ph(machInst);
                          break;
                        
                        case 0x1:  
                          // DspHiLoOp::dpsqx_s_w_ph(['\n                                dspac = dspDpsq(dspac, Rs_sw, Rt_sw,\n                                                ACDST, SIMD_FMT_PH,\n                                                SIMD_FMT_W, NOSATURATE,\n                                                MODE_X, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "dpsqx_s_w_ph" << std::endl;
return 0;// Dpsqx_s_w_ph(machInst);
                          break;
                        
                        case 0x2:  
                          // DspHiLoOp::dpaqx_sa_w_ph(['\n                                dspac = dspDpaq(dspac, Rs_sw, Rt_sw,\n                                                ACDST, SIMD_FMT_PH,\n                                                SIMD_FMT_W, SATURATE,\n                                                MODE_X, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "dpaqx_sa_w_ph" << std::endl;
return 0;// Dpaqx_sa_w_ph(machInst);
                          break;
                        
                        case 0x3:  
                          // DspHiLoOp::dpsqx_sa_w_ph(['\n                                dspac = dspDpsq(dspac, Rs_sw, Rt_sw,\n                                                ACDST, SIMD_FMT_PH,\n                                                SIMD_FMT_W, SATURATE,\n                                                MODE_X, &dspctl);\n                            ', 'IntMultOp'],{})
                          
                                  std::cout << "dpsqx_sa_w_ph" << std::endl;
return 0;// Dpsqx_sa_w_ph(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                case 0x1:
                  switch (OP_HI) {
                    
                    case 0x0:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // IntOp::append(['\n                                Rt_uw = (Rt_uw << RD) | bits(Rs_uw, RD - 1, 0);\n                                '],{})
                          
                           /*{
                               MipsStaticInst *i = new Append(machInst);
                               //if (RD == 0) {
                                   //i = makeNop(i);
                                   //}
                               return i;
                           }*/
                           std::cout << "append" << std::endl;
                           return 0;
                          break;
                        
                        case 0x1:  
                          // IntOp::prepend(['\n                                Rt_uw = (Rt_uw >> RD) |\n                                        (bits(Rs_uw, RD - 1, 0) << (32 - RD));\n                            '],{})
                          
                           /*{
                               MipsStaticInst *i = new Prepend(machInst);
                               //if (RD == 0) {
                                   //i = makeNop(i);
                                   //}
                               return i;
                           }*/
                           std::cout << "prepend" << std::endl;
                           return 0;
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x2:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // IntOp::balign(['\n                                Rt_uw = (Rt_uw << (8 * BP)) |\n                                        (Rs_uw >> (8 * (4 - BP)));\n                            '],{})
                          
                           /*{
                               MipsStaticInst *i = new Balign(machInst);
                               //if (RD == 0) {
                                   //i = makeNop(i);
                                   //}
                               return i;
                           }*/
                           std::cout << "balign" << std::endl;
                           return 0;
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            case 0x7:
              switch (FUNCTION_LO) {
                
                case 0x0:
                  switch (OP_HI) {
                    
                    case 0x0:
                      switch (OP_LO) {
                        
                        case 0x0:  
                          // DspHiLoOp::extr_w(['\n                                Rt_uw = dspExtr(dspac, SIMD_FMT_W, RS,\n                                                NOROUND, NOSATURATE, &dspctl);\n                            '],{})
                          
                                  std::cout << "extr_w" << std::endl;
return 0;// Extr_w(machInst);
                          break;
                        
                        case 0x1:  
                          // DspHiLoOp::extrv_w(['\n                                Rt_uw = dspExtr(dspac, SIMD_FMT_W, Rs_uw,\n                                                NOROUND, NOSATURATE, &dspctl);\n                            '],{})
                          
                                  std::cout << "extrv_w" << std::endl;
return 0;// Extrv_w(machInst);
                          break;
                        
                        case 0x2:  
                          // DspHiLoOp::extp(['\n                                Rt_uw = dspExtp(dspac, RS, &dspctl);\n                            '],{})
                          
                                  std::cout << "extp" << std::endl;
return 0;// Extp(machInst);
                          break;
                        
                        case 0x3:  
                          // DspHiLoOp::extpv(['\n                                Rt_uw = dspExtp(dspac, Rs_uw, &dspctl);\n                            '],{})
                          
                                  std::cout << "extpv" << std::endl;
return 0;// Extpv(machInst);
                          break;
                        
                        case 0x4:  
                          // DspHiLoOp::extr_r_w(['\n                                Rt_uw = dspExtr(dspac, SIMD_FMT_W, RS,\n                                                ROUND, NOSATURATE, &dspctl);\n                            '],{})
                          
                                  std::cout << "extr_r_w" << std::endl;
return 0;// Extr_r_w(machInst);
                          break;
                        
                        case 0x5:  
                          // DspHiLoOp::extrv_r_w(['\n                                Rt_uw = dspExtr(dspac, SIMD_FMT_W, Rs_uw,\n                                                ROUND, NOSATURATE, &dspctl);\n                            '],{})
                          
                                  std::cout << "extrv_r_w" << std::endl;
return 0;// Extrv_r_w(machInst);
                          break;
                        
                        case 0x6:  
                          // DspHiLoOp::extr_rs_w(['\n                                Rt_uw = dspExtr(dspac, SIMD_FMT_W, RS,\n                                                ROUND, SATURATE, &dspctl);\n                            '],{})
                          
                                  std::cout << "extr_rs_w" << std::endl;
return 0;// Extr_rs_w(machInst);
                          break;
                        
                        case 0x7:  
                          // DspHiLoOp::extrv_rs_w(['\n                                Rt_uw = dspExtr(dspac, SIMD_FMT_W, Rs_uw,\n                                                ROUND, SATURATE, &dspctl);\n                            '],{})
                          
                                  std::cout << "extrv_rs_w" << std::endl;
return 0;// Extrv_rs_w(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x1:
                      switch (OP_LO) {
                        
                        case 0x2:  
                          // DspHiLoOp::extpdp(['\n                                Rt_uw = dspExtpd(dspac, RS, &dspctl);\n                            '],{})
                          
                                  std::cout << "extpdp" << std::endl;
return 0;// Extpdp(machInst);
                          break;
                        
                        case 0x3:  
                          // DspHiLoOp::extpdpv(['\n                                Rt_uw = dspExtpd(dspac, Rs_uw, &dspctl);\n                            '],{})
                          
                                  std::cout << "extpdpv" << std::endl;
return 0;// Extpdpv(machInst);
                          break;
                        
                        case 0x6:  
                          // DspHiLoOp::extr_s_h(['\n                                Rt_uw = dspExtr(dspac, SIMD_FMT_PH, RS,\n                                                NOROUND, SATURATE, &dspctl);\n                            '],{})
                          
                                  std::cout << "extr_s_h" << std::endl;
return 0;// Extr_s_h(machInst);
                          break;
                        
                        case 0x7:  
                          // DspHiLoOp::extrv_s_h(['\n                                Rt_uw = dspExtr(dspac, SIMD_FMT_PH, Rs_uw,\n                                                NOROUND, SATURATE, &dspctl);\n                            '],{})
                          
                                  std::cout << "extrv_s_h" << std::endl;
return 0;// Extrv_s_h(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x2:
                      switch (OP_LO) {
                        
                        case 0x2:  
                          // DspIntOp::rddsp(['\n                                Rd_uw = readDSPControl(&dspctl, RDDSPMASK);\n                            '],{})
                          
                                  std::cout << "rddsp" << std::endl;
return 0;// Rddsp(machInst);
                          break;
                        
                        case 0x3:  
                          // DspIntOp::wrdsp(['\n                                writeDSPControl(&dspctl, Rs_uw, WRDSPMASK);\n                            '],{})
                          
                                  std::cout << "wrdsp" << std::endl;
return 0;// Wrdsp(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    case 0x3:
                      switch (OP_LO) {
                        
                        case 0x2:  
                          // DspHiLoOp::shilo(['\n                                if (sext<6>(HILOSA) < 0) {\n                                    dspac = (uint64_t)dspac <<\n                                                -sext<6>(HILOSA);\n                                } else {\n                                    dspac = (uint64_t)dspac >>\n                                                sext<6>(HILOSA);\n                                }\n                            '],{})
                          
                                  std::cout << "shilo" << std::endl;
return 0;// Shilo(machInst);
                          break;
                        
                        case 0x3:  
                          // DspHiLoOp::shilov(['\n                                if (sext<6>(Rs_sw<5:0>) < 0) {\n                                    dspac = (uint64_t)dspac <<\n                                                -sext<6>(Rs_sw<5:0>);\n                                } else {\n                                    dspac = (uint64_t)dspac >>\n                                                sext<6>(Rs_sw<5:0>);\n                                }\n                            '],{})
                          
                                  std::cout << "shilov" << std::endl;
return 0;// Shilov(machInst);
                          break;
                        
                        case 0x7:  
                          // DspHiLoOp::mthlip(['\n                                dspac = dspac << 32;\n                                dspac |= Rs_uw;\n                                dspctl = insertBits(dspctl, 5, 0,\n                                                    dspctl<5:0> + 32);\n                            '],{})
                          
                                  std::cout << "mthlip" << std::endl;
return 0;// Mthlip(machInst);
                          break;
                        
                        default:
                          
                          // Unknown::unknown(([], {}))
                          std::cout << "UNKNOWN" << std::endl;
                          return 1;//Unknown(machInst);
                          break;
                        }
                      
                    default:
                      
                      // Unknown::unknown(([], {}))
                      std::cout << "UNKNOWN" << std::endl;
                      return 1;//Unknown(machInst);
                      break;
                    }
                  
                case 0x3:
                  switch (OP) {
                    
                    case 0x0:
                      /*switch (FullSystemInt) {
                        
                        case 0x0:
                          switch (RD) {
                            
                            case 0x1d:  
                              // BasicOp::rdhwr_se(([' Rt = TpValue; '], {}))
                              
                                      std::cout << "rdhwr_se" << std::endl;
return 0;// Rdhwr_se(machInst);
                              break;
                            
                            default:
                              
                              // FailUnimpl::rdhwr(([], {}))
                              
                                      std::cout << "rdhwr" << std::endl;
return 0;// FailUnimplemented("rdhwr", machInst);
                              break;
                            }
                          
                        default:
                          
                          // FailUnimpl::rdhwr(([], {}))
                          
                                  std::cout << "rdhwr" << std::endl;
return 0;// FailUnimplemented("rdhwr", machInst);
                          break;
                        }*/
                      
                    default:
                      
                      // FailUnimpl::rdhwr(([], {}))
                      
                              std::cout << "rdhwr" << std::endl;
return 0;// FailUnimplemented("rdhwr", machInst);
                      break;
                    }
                  
                default:
                  
                  // Unknown::unknown(([], {}))
                  std::cout << "UNKNOWN" << std::endl;
                  return 1;//Unknown(machInst);
                  break;
                }
              
            default:
              
              // Unknown::unknown(([], {}))
              std::cout << "UNKNOWN" << std::endl;
              return 1;//Unknown(machInst);
              break;
            }
          
        default:
          
          // Unknown::unknown(([], {}))
          std::cout << "UNKNOWN" << std::endl;
          return 1;//Unknown(machInst);
          break;
        }
      
    case 0x4:
      switch (OPCODE_LO) {
        
        case 0x0:  
          // LoadMemory::lb([' Rt_sw = Mem_sb; '],{})
          
           /*{
               MipsStaticInst *i = new Lb(machInst);
               //if (RT == 0) {
               // i = makeNop(i);
               // }
               return i;
           }*/
           std::cout << "lb" << std::endl;
           return 0;
          break;
        
        case 0x1:  
          // LoadMemory::lh([' Rt_sw = Mem_sh; '],{})
          
           /*{
               MipsStaticInst *i = new Lh(machInst);
               //if (RT == 0) {
               // i = makeNop(i);
               // }
               return i;
           }*/
           std::cout << "lh" << std::endl;
           return 0;
          break;
        
        case 0x3:  
          // LoadMemory::lw([' Rt_sw = Mem_sw; '],{})
          
           /*{
               MipsStaticInst *i = new Lw(machInst);
               //if (RT == 0) {
               // i = makeNop(i);
               // }
               return i;
           }*/
           std::cout << "lw" << std::endl;
           return 0;
          break;
        
        case 0x4:  
          // LoadMemory::lbu([' Rt_uw = Mem_ub;'],{})
          
           /*{
               MipsStaticInst *i = new Lbu(machInst);
               //if (RT == 0) {
               // i = makeNop(i);
               // }
               return i;
           }*/
           std::cout << "lbu" << std::endl;
           return 0;
          break;
        
        case 0x5:  
          // LoadMemory::lhu([' Rt_uw = Mem_uh; '],{})
          
           /*{
               MipsStaticInst *i = new Lhu(machInst);
               //if (RT == 0) {
               // i = makeNop(i);
               // }
               return i;
           }*/
           std::cout << "lhu" << std::endl;
           return 0;
          break;
        
        case 0x2:  
          // LoadUnalignedMemory::lwl(['\n                uint32_t mem_shift = 24 - (8 * byte_offset);\n                Rt_uw = mem_word << mem_shift | (Rt_uw & mask(mem_shift));\n            '],{})
          
           /*{
               MipsStaticInst *i = new Lwl(machInst);
               //if (RT == 0) {
               // i = makeNop(i);
               // }
               return i;
           }*/
           std::cout << "lwl" << std::endl;
           return 0;
          break;
        
        case 0x6:  
          // LoadUnalignedMemory::lwr(['\n                uint32_t mem_shift = 8 * byte_offset;\n                Rt_uw = (Rt_uw & (mask(mem_shift) << (32 - mem_shift))) |\n                        (mem_word >> mem_shift);\n            '],{})
          
           /*{
               MipsStaticInst *i = new Lwr(machInst);
               //if (RT == 0) {
               // i = makeNop(i);
               // }
               return i;
           }*/
           std::cout << "lwr" << std::endl;
           return 0;
          break;
        
        default:
          
          // Unknown::unknown(([], {}))
          std::cout << "UNKNOWN" << std::endl;
          return 1;//Unknown(machInst);
          break;
        }
      
    case 0x5:
      switch (OPCODE_LO) {
        
        case 0x0:  
          // StoreMemory::sb([' Mem_ub = Rt<7:0>; '],{})
          
                  std::cout << "sb" << std::endl;
return 0;// Sb(machInst);
          break;
        
        case 0x1:  
          // StoreMemory::sh([' Mem_uh = Rt<15:0>; '],{})
          
                  std::cout << "sh" << std::endl;
return 0;// Sh(machInst);
          break;
        
        case 0x3:  
          // StoreMemory::sw([' Mem_uw = Rt<31:0>; '],{})
          
                  std::cout << "sw" << std::endl;
return 0;// Sw(machInst);
          break;
        
        case 0x2:  
          // StoreUnalignedMemory::swl(['\n                uint32_t reg_shift = 24 - (8 * byte_offset);\n                uint32_t mem_shift = 32 - reg_shift;\n                mem_word = (mem_word & (mask(reg_shift) << mem_shift)) |\n                           (Rt_uw >> reg_shift);\n                '],{})
          
                  std::cout << "swl" << std::endl;
return 0;// Swl(machInst);
          break;
        
        case 0x6:  
          // StoreUnalignedMemory::swr(['\n                uint32_t reg_shift = 8 * byte_offset;\n                mem_word = Rt_uw << reg_shift |\n                           (mem_word & (mask(reg_shift)));\n            '],{})
          
                  std::cout << "swr" << std::endl;
return 0;// Swr(machInst);
          break;
        
        case 0x7:  
          // CP0Control::cache(['\n                //Addr CacheEA = Rs_uw + OFFSET;\n                //fault = xc->CacheOp((uint8_t)CACHE_OP,(Addr) CacheEA);\n            '],{})
          
                  std::cout << "cache" << std::endl;
return 0;// Cache(machInst);
          break;
        
        default:
          
          // Unknown::unknown(([], {}))
          std::cout << "UNKNOWN" << std::endl;
          return 1;//Unknown(machInst);
          break;
        }
      
    case 0x6:
      switch (OPCODE_LO) {
        
        case 0x0:  
          // LoadMemory::ll([' Rt_uw = Mem_uw; '],{'mem_flags': 'LLSC'})
          
           /*{
               MipsStaticInst *i = new Ll(machInst);
               //if (RT == 0) {
               // i = makeNop(i);
               // }
               return i;
           }*/
           std::cout << "ll" << std::endl;
           return 0;
          break;
        
        case 0x1:  
          // LoadMemory::lwc1([' Ft_uw = Mem_uw; '],{})
          
           /*{
               MipsStaticInst *i = new Lwc1(machInst);
               //if (RT == 0) {
               // i = makeNop(i);
               // }
               return i;
           }*/
           std::cout << "lwc1" << std::endl;
           return 0;
          break;
        
        case 0x5:  
          // LoadMemory::ldc1([' Ft_ud = Mem_ud; '],{})
          
           /*{
               MipsStaticInst *i = new Ldc1(machInst);
               //if (RT == 0) {
               // i = makeNop(i);
               // }
               return i;
           }*/
           std::cout << "ldc1" << std::endl;
           return 0;
          break;
        
        case 0x2:  
          // CP2Unimpl::lwc2(([], {}))
          
                  std::cout << "lwc2" << std::endl;
return 0;// CP2Unimplemented("lwc2", machInst);
          break;
        
        case 0x6:  
          // CP2Unimpl::ldc2(([], {}))
          
                  std::cout << "ldc2" << std::endl;
return 0;// CP2Unimplemented("ldc2", machInst);
          break;
        
        case 0x3:  
          // Prefetch::pref(([], {}))
          
                  std::cout << "pref" << std::endl;
return 0;// Pref(machInst);
          break;
        
        default:
          
          // Unknown::unknown(([], {}))
          std::cout << "UNKNOWN" << std::endl;
          return 1;//Unknown(machInst);
          break;
        }
      
    case 0x7:
      switch (OPCODE_LO) {
        
        case 0x0:  
          // StoreCond::sc(([' Mem_uw = Rt_uw; ', ' uint64_t tmp = write_result;\n                              Rt_uw = (tmp == 0 || tmp == 1) ? tmp : Rt_uw;\n                           '], {'inst_flags': 'IsStoreConditional', 'mem_flags': 'LLSC'}))
          
                  std::cout << "sc" << std::endl;
return 0;// Sc(machInst);
          break;
        
        case 0x1:  
          // StoreMemory::swc1([' Mem_uw = Ft_uw; '],{})
          
                  std::cout << "swc1" << std::endl;
return 0;// Swc1(machInst);
          break;
        
        case 0x5:  
          // StoreMemory::sdc1([' Mem_ud = Ft_ud; '],{})
          
                  std::cout << "sdc1" << std::endl;
return 0;// Sdc1(machInst);
          break;
        
        case 0x2:  
          // CP2Unimpl::swc2(([], {}))
          
                  std::cout << "swc2" << std::endl;
return 0;// CP2Unimplemented("swc2", machInst);
          break;
        
        case 0x6:  
          // CP2Unimpl::sdc2(([], {}))
          
                  std::cout << "sdc2" << std::endl;
return 0;// CP2Unimplemented("sdc2", machInst);
          break;
        
        default:
          
          // Unknown::unknown(([], {}))
          std::cout << "UNKNOWN" << std::endl;
          return 1;//Unknown(machInst);
          break;
        }
      
    default:
      
      // Unknown::unknown(([], {}))
      std::cout << "UNKNOWN" << std::endl;
      return 1;//Unknown(machInst);
      break;
    }
  }
