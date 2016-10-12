function [disassembly, legal, mnemonic, codec, rd, rs1, rs2, rs3, imm, arg] = parse_rv64g_decoder_output(message_hex)
% Parse the output of the RV64G instruction decoder into a set of semantic
% strings.
%
% Arguments:
%   message_hex -- String of hexadecimal characters
%
% Returns:
%   disassembly -- Cell array of strings showing parsed disassembly
%   legal -- Boolean: True if the message was a legal RV64G instruction.
%   mnemonic -- String: The semantic interpretation of an instruction's
%       operation, if legal, otherwise 'NA'
%   codec -- String: Encoding format of the instruction, if legal,
%       otherwise 'NA'
%   rd -- String: Destination register, if any, otherwise 'NA'
%   rs1 -- String: Source register 1, if any, otherwise 'NA'
%   rs2 -- String: Source register 2, if any, otherwise 'NA'
%   rs3 -- String: Source register 3, if any, otherwise 'NA'
%   imm -- String: Immediate value, if any, otherwise 'NA'
%   arg -- String: Arg value, if any, otherwise 'NA'

[status, decoderOutput] = MyRv64gDecoder(message_hex); % NOTE: this will only work if the decoder MEX file is properly compiled for your platform!
    
legal = 1;
if status == 1 % Illegal instruction
   legal = 0;
end

% Parse disassembly of instruction from string spit back by the instruction decoder
disassembly = textscan(decoderOutput, '%s', 'Delimiter', ':');
disassembly = disassembly{1};
disassembly = reshape(disassembly, 2, size(disassembly,1)/2)';
mnemonic = disassembly{4,2};
codec = disassembly{5,2};
rd = disassembly{6,2};
rs1 = disassembly{7,2};
rs2 = disassembly{8,2};
rs3 = disassembly{9,2};
imm = disassembly{10,2};
arg = disassembly{11,2};

end

