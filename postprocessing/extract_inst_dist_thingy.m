% Extract inst distribution from map thing
% Mark Gottscho <mgottscho@ucla.edu>
% Set 'benchmark' before calling this
% TODO: clean this mess up

insts = instructions.keys()';
for i=1:size(insts,1)
    inst = instructions(insts{i});
    instcounts(i,1) = inst(benchmark)';
end
