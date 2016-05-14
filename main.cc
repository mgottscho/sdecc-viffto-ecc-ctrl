#include "MyDecoder.hh"
#include <iostream>
#include <sstream>
#include <iomanip>
#include <stdint.h>

#include "mex.h"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
//int main(int argc, char** argv) {
    /*if (argc != 2) {
        std::cout << "Usage: mipsdecode <INST>" << std::endl;
        std::cout << "where <INST> is a 32-bit MIPS instruction specified in hexadecimal format, e.g., 0xDEADBEEF." << std::endl;
        return 1;
    }*/

    /*if(nrhs != 1) {
            mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nrhs",
                                  "One input required.");
    }
    if(nlhs != 1) {
            mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nlhs",
                                  "One output required.");
    }*/

    /* make sure the first input argument is a string */
    /*if( !mxIsString(prhs[0]) || 
                  mxGetNumberOfElements(prhs[0]) != 1 ) {
            mexErrMsgIdAndTxt("MyToolbox:arrayProduct:notString",
                                  "Input must be a string.");
    }*/
    //uint32_t raw;
    unsigned int raw;

    std::stringstream ss;
    //std::string instString(argv[1]);
    char inputCharString[10];
    mxGetString(prhs[0], inputCharString, 10);
    std::string instString(inputCharString);
    ss << std::hex << instString;
    ss >> raw;

    std::cout << "Raw input: " << instString << std::endl;
    std::cout.fill('0');
    std::cout << "Interpreted as: 0x" << std::hex << std::setw(8) << raw << std::dec << std::endl;
    std::cout.fill(' ');
    
    MipsISA::ExtMachInst inst = static_cast<MipsISA::ExtMachInst>(raw);

    MipsISA::Decoder decoder;
    std::cout << "Disassembly: ";
    bool ret = decoder.decodeInst(inst);
    std::cout << "Result: ";
    if (ret) {
        std::cout << "ILLEGAL" << std::endl;
//        return ret;
    } else {
        std::cout << "valid" << std::endl;
        //return ret;
    }

    double* output = NULL;
    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
    output = mxGetPr(plhs[0]);
    if (ret)
        *output = 1;
    else
        *output = 0;
}
