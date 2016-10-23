avg_benchmark_successes_concat = NaN(20,5);
avg_benchmark_successes_concat(:,1) = avg_benchmark_successes_si_perfect;
avg_benchmark_successes_concat(:,2) = avg_benchmark_successes_si_split;
avg_benchmark_successes_concat(:,3) = avg_benchmark_successes_si_aggregate;
avg_benchmark_successes_concat(:,4) = avg_benchmark_successes_si_none;
avg_benchmark_successes_concat(:,5) = avg_benchmark_successes_baseline;
avg_benchmark_successes_concat(21,:) = geomean(avg_benchmark_successes_concat(1:20,:));
benchmark_names{21,1} = 'Geometric Mean';
figure
barh(avg_benchmark_successes_concat)
colormap(hot)
set(gca,'YDir','reverse')
set(gca,'YTick',1:21)
set(gca,'YTickLabel',benchmark_names)
xlabel('Average Rate of Heuristic Recovery')
set(gca,'ylim',[0 22])
legend({'Per-Benchmark SI (Ideal)', 'Split Integer/Float Aggregate SI (This Work)', 'Aggregate SI', 'No SI', 'Baseline Random Pick of Candidate'})