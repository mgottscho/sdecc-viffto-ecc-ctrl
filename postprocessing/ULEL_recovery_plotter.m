concat_data = [
     avg_benchmark_successes_data_r1...
     avg_benchmark_successes_data_r2...
     avg_benchmark_successes_data_r3;...
     mean(avg_benchmark_successes_data_r1) mean(avg_benchmark_successes_data_r2) mean(avg_benchmark_successes_data_r3);...
     avg_benchmark_successes_inst_r1...
     avg_benchmark_successes_inst_r2...
     avg_benchmark_successes_inst_r3;...
     mean(avg_benchmark_successes_inst_r1) mean(avg_benchmark_successes_inst_r2) mean(avg_benchmark_successes_inst_r3);...
     ];
benchmark_names_repeat = benchmark_names;
benchmark_names_repeat{12} = 'avg. data';
benchmark_names_repeat(13:23) = benchmark_names;
benchmark_names_repeat{24} = 'avg. inst.';
bar(concat_data);
colormap(flipud(gray(3)));
set(gca,'xcolor','black','ycolor','black','fontsize',10,'fontname','arial');
ylabel('Avg. Recov. Rate');
%xlabel('Benchmark');
set(gca,'xtick',(1:24));
set(gca,'xticklabel',benchmark_names_repeat, 'FontSize', 10);
set(gca,'ytick',[0:0.2:1]);
xticklabel_rotate([],45,[],'fontsize',10)
%pos = get(gca,'Position');
%pos(3) = 0.8;
%pos(4) = 0.5;
%set(gca,'Position',pos);
grid on;
lgd = legend({'r=1', 'r=2', 'r=3'}, 'FontSize', 10);
%pos = get(lgd,'Position');
%pos(1) = 0.25;
%pos(2) = 0.635;
%set(lgd,'Position',pos);