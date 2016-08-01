function [output_mneumonic] = dealias_alpha_mneumonic(input_mneumonic)
% This function de-aliases an Alpha ISA disassembler mneumonic. For instance,
% the ISA includes common pseudoinstructions and macros, as well as identically-encoded
% instructions that are aliases of each other. This function attempts to de-alias these cases.
% See the Alpha ISA manual v4, published 1998 by Compaq for detailed and authoritative information.
% From the manual: "Each pseudo-operation represents a particular instruction with either replicated
% fields (such as FMOV) or hard-coded zero fields. Since the pattern is distinct, these pseudo-operations
% can be decoded by instruction decode mechanisms."
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

switch input_mneumonic
    % Handle pseudoinstructions
    case 'br'
       output_mneumonic = 'br'; 
    case 'clr'
       output_mneumonic = 'bis'; 
    case 'fabs'
       output_mneumonic = 'cpys'; 
    case 'fclr'
       output_mneumonic = 'cpys'; 
    case 'fmov'
       output_mneumonic = 'cpys'; 
    case 'fneg'
       output_mneumonic = 'cpysn'; 
    case 'fnop'
       output_mneumonic = 'cpys'; 
    case 'mov' % FIXME: mov pseudoinstruction can be either lda or bis encoding depending on whether we are moving 16-bit sign ext literal or 8-bit zero-extended literal, respectively. For now, I am defaulting to lda...
       output_mneumonic = 'lda'; 
    case 'mf_fpcr'
       output_mneumonic = 'mf_fpcr';
    case 'mt_fpcr'
       output_mneumonic = 'mt_fpcr';
    case 'negf'
       output_mneumonic = 'subf';
    case 'negf/s'
       output_mneumonic = 'subf/s';
    case 'negg'
       output_mneumonic = 'subg';
    case 'negg/s'
       output_mneumonic = 'subg/s';
    case 'negl'
       output_mneumonic = 'subl';
    case 'negl/v'
       output_mneumonic = 'subl/v';
    case 'negl/v'
       output_mneumonic = 'subl/v';
    case 'negq'
       output_mneumonic = 'subq';
    case 'negq/v'
       output_mneumonic = 'subq/v';
    case 'negs'
       output_mneumonic = 'subs';
    case 'negs/su'
       output_mneumonic = 'subs/su';
    case 'negs/sui'
       output_mneumonic = 'subs/sui';
    case 'negt'
       output_mneumonic = 'subt';
    case 'negt/su'
       output_mneumonic = 'subt/su';
    case 'negt/sui'
       output_mneumonic = 'subt/sui';
    case 'nop'
       output_mneumonic = 'bis';
    case 'not'
       output_mneumonic = 'ornot';
    case 'sextl'
       output_mneumonic = 'addl';
    case 'unop'
       output_mneumonic = 'ldq_u';
    % Handle synonyms, which are not exhaustively listed in ISA manual, but these are explicitly listed on page A-14 of the handbook. Both the input and output mapping are legitimate instructions, but they are encoded identically and therefore are functionally identical. Who knows why the ISA was designed this way...
    case 'bic'
       output_mneumonic = 'andnot';
    case 'or'
       output_mneumonic = 'bis';
    case 'eqv'
       output_mneumonic = 'xornot';
    otherwise % no change in default case
       output_mneumonic = input_mneumonic;
end

end
