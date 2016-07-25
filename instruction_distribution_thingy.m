% instruction hotness converter thingy
% Author: Mark Gottscho <mgottscho@ucla.edu>
% Load benchmark results .mat file and then run this to post-process the
% instruction hotness stuff
% In the end, you want insts and instcounts as output

for loopvar=1:size(unique_inst)
    inst = unique_inst{loopvar};
    if ~instructions.isKey(inst)
        instmap_perbenchmark = containers.Map();
        instmap_perbenchmark('bzip2') = 0;
        instmap_perbenchmark('h264ref') = 0;
        instmap_perbenchmark('mcf') = 0;
        instmap_perbenchmark('perlbench') = 0;
        instmap_perbenchmark('povray') = 0;
    else
        instmap_perbenchmark = instructions(inst);
    end
    instmap_perbenchmark(benchmark) = unique_inst_counts(loopvar);
    instructions(inst) = instmap_perbenchmark;
end

insts = instructions.keys()';
for i=1:size(insts,1)
    inst = instructions(insts{i});
    instcounts(i) = inst(benchmark)';
end


