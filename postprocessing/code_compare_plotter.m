figure

subplot(2,1,1);
bar(avg_benchmark_successes_data_concat_split_int_float,'barwidth',1);
colormap('cool')
set(gca,'XTick',1:21)
set(gca,'XTickLabel',[int_benchmark_names(int_benchmark_indices); float_benchmark_names(float_benchmark_indices); 'Geo. Mean'])
ylabel('Average Rate of Heuristic Recovery','FontSize',14)
set(gca,'xlim',[0 22])
set(gca,'ylim',[0 1])
set(gca,'ytick',0:0.25:1);
set(gca,'FontSize',14);
xlabel('(a) Data Memory')
xticklabel_rotate([],45,[],'fontsize',14)
hold on;
bar([1:21], random_recovery_probs,'k','barwidth',1);

subplot(2,1,2);
bar(avg_benchmark_successes_inst_concat_split_int_float,'barwidth',1);
colormap('cool')
set(gca,'XTick',1:21)
set(gca,'XTickLabel',[int_benchmark_names(int_benchmark_indices); float_benchmark_names(float_benchmark_indices); 'Geo. Mean'])
ylabel('Average Rate of Heuristic Recovery','FontSize',14)
set(gca,'xlim',[0 22])
set(gca,'ylim',[0 1])
set(gca,'ytick',0:0.25:1);
set(gca,'FontSize',14);
xlabel('(b) Instruction Memory')
xticklabel_rotate([],45,[],'fontsize',14)
hold on
bar([1:21], random_recovery_probs,'k','barwidth',1);


legend({'(39,32) SECDED - Hsiao', '(39,32) SECDED - Davydov', '(72,64) SECDED - Hsiao', '(72,64) SECDED - Davydov', '(45,32) DECTED', '(79,64) DECTED', '(144,128) SSCDSD - Kaneda'},'fontsize',12,'fontname','arial')
% inst_text_box = uicontrol('style','text')
% set(inst_text_box,'String','(b) Instruction Memory','fontsize',14,'fontname','arial')
% data_text_box = uicontrol('style','text')
% set(data_text_box,'String','(a) Data Memory','fontsize',14,'fontname','arial')
% set(inst_text_box,'backgroundcolor',[1 1 1])
% set(data_text_box,'backgroundcolor',[1 1 1])