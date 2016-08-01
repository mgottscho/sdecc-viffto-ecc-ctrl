% instruction hotness converter thingy
% Author: Mark Gottscho <mgottscho@ucla.edu>
% In the end, you want insts and instcounts as output
% TODO: clean this mess up

input_directory = 'D:\Dropbox\ECCGroup\data\instruction-mixes\rv64g\post-processed\hsiao-code\random-sampling\2016-7-25 rv64g 1000inst filter-rank pick_first';
dir_contents = dir(input_directory);
loopvar2=1;
for loopvar1=1:size(dir_contents,1)
    if ~dir_contents(loopvar1).isdir || strcmp(dir_contents(loopvar1).name, '.') == 1 || strcmp(dir_contents(loopvar1).name, '..') == 1
        continue;
    end
    
    mybenchmarks{loopvar2,1} = dir_contents(loopvar1).name;
    loopvar2 = loopvar2+1;
end

instructions = containers.Map();
dest_regs = containers.Map();
for loopvar1=1:size(mybenchmarks,1)
    load([input_directory filesep mybenchmarks{loopvar1} filesep 'rv64g-' mybenchmarks{loopvar1} '-inst-heuristic-recovery.mat']);
    
    %mnemonic
    for loopvar2=1:size(unique_inst)
        inst = unique_inst{loopvar2};
        if ~instructions.isKey(inst)
            instmap_perbenchmark = containers.Map();
            for loopvar3=1:size(mybenchmarks,1)
                instmap_perbenchmark(mybenchmarks{loopvar3}) = 0;
            end
        else
            instmap_perbenchmark = instructions(inst);
        end
        instmap_perbenchmark(benchmark) = unique_inst_counts(loopvar2);
        instructions(inst) = instmap_perbenchmark;
    end
    
    %rd
    for loopvar2=1:size(unique_rd)
        rd = unique_rd{loopvar2};
        if ~dest_regs.isKey(rd)
            rdmap_perbenchmark = containers.Map();
            for loopvar3=1:size(mybenchmarks,1)
                rdmap_perbenchmark(mybenchmarks{loopvar3}) = 0;
            end
        else
            rdmap_perbenchmark = dest_regs(rd);
        end
        rdmap_perbenchmark(benchmark) = unique_rd_counts(loopvar2);
        dest_regs(rd) = rdmap_perbenchmark;
    end

    display(['Finished ' benchmark]);
end

