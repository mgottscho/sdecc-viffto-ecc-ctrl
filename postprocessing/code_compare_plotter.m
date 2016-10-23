avg_benchmark_successes_concat = NaN(20,7);
avg_benchmark_successes_concat(:,1) = avg_benchmark_successes_hsiao_39_32;
avg_benchmark_successes_concat(:,2) = avg_benchmark_successes_davydov_39_32;
avg_benchmark_successes_concat(:,3) = avg_benchmark_successes_hsiao_72_64;
avg_benchmark_successes_concat(:,4) = avg_benchmark_successes_davydov_72_64;
avg_benchmark_successes_concat(:,5) = avg_benchmark_successes_bose_45_32;
avg_benchmark_successes_concat(:,6) = avg_benchmark_successes_bose_79_64;
avg_benchmark_successes_concat(:,7) = avg_benchmark_successes_fujiwara_144_128;
avg_benchmark_successes_concat(21,:) = geomean(avg_benchmark_successes_concat(1:20,:));
benchmark_names{21,1} = 'Geometric Mean';
figure
barh(avg_benchmark_successes_concat)
colormap(cold)
set(gca,'YDir','reverse')
set(gca,'YTick',1:21)
set(gca,'YTickLabel',benchmark_names)
xlabel('Average Rate of Heuristic Recovery')
set(gca,'ylim',[0 22])
legend({'(39,32) SECDED - Hsiao', '(39,32) SECDED - Davydov', '(72,64) SECDED - Hsiao', '(72,64) SECDED - Davydov', '(45,32) DECTED', '(79,64) DECTED', '(144,128) SSCDSD - Fujiwara'})