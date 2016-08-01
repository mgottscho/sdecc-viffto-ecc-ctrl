% Extract inst distribution from map thing
% Mark Gottscho <mgottscho@ucla.edu>
% Set 'benchmark' before calling this

insts = instructions.keys()';
for i=1:size(insts,1)
    inst = instructions(insts{i});
    instcounts(i,1) = inst(benchmark)';
end

rds = dest_regs.keys()';
for i=1:size(rds,1)
    rd = dest_regs(rds{i});
    rdcounts(i,1) = rd(benchmark)';
end