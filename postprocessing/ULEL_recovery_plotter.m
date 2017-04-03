bar([avg_benchmark_successes_data avg_benchmark_successes_inst]);
colormap([0 0 0; 0.7 0.7 0.7]);
set(gca,'xcolor','black','ycolor','black','fontsize',10,'fontname','arial');
ylabel('Avg. Recov. Rate');
%xlabel('Benchmark');
set(gca,'xticklabel',benchmark_names, 'FontSize', 10);
set(gca,'ytick',[0:0.2:1]);
xticklabel_rotate([],45,[],'fontsize',10)
pos = get(gca,'Position');
pos(3) = 0.8;
pos(4) = 0.5;
set(gca,'Position',pos);
grid on;
lgd = legend({'Data Memory'; 'Instruction Memory'}, 'FontSize', 10);
pos = get(lgd,'Position');
pos(1) = 0.25;
pos(2) = 0.635;
set(lgd,'Position',pos);