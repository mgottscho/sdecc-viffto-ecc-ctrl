% Unsorted success
avg_benchmark_successes_data_concat = NaN(21,7);
avg_benchmark_successes_data_concat(1:20,1) = avg_benchmark_successes_data_hsiao_39_32(:,1);
avg_benchmark_successes_data_concat(1:20,2) = avg_benchmark_successes_data_davydov_39_32(:,1);
avg_benchmark_successes_data_concat(1:20,3) = avg_benchmark_successes_data_hsiao_72_64(:,1);
avg_benchmark_successes_data_concat(1:20,4) = avg_benchmark_successes_data_davydov_72_64(:,1);
avg_benchmark_successes_data_concat(1:20,5) = avg_benchmark_successes_data_bose_45_32(:,1);
avg_benchmark_successes_data_concat(1:20,6) = avg_benchmark_successes_data_bose_79_64(:,1);
avg_benchmark_successes_data_concat(1:20,7) = avg_benchmark_successes_data_kaneda_144_128(:,1);
avg_benchmark_successes_data_concat(21,:) = geomean(avg_benchmark_successes_data_concat(1:20,:));

% Unsorted crash
avg_benchmark_could_have_crashed_data_concat = NaN(21,7);
avg_benchmark_could_have_crashed_data_concat(1:20,1) = avg_benchmark_could_have_crashed_data_hsiao_39_32(:,1);
avg_benchmark_could_have_crashed_data_concat(1:20,2) = avg_benchmark_could_have_crashed_data_davydov_39_32(:,1);
avg_benchmark_could_have_crashed_data_concat(1:20,3) = avg_benchmark_could_have_crashed_data_hsiao_72_64(:,1);
avg_benchmark_could_have_crashed_data_concat(1:20,4) = avg_benchmark_could_have_crashed_data_davydov_72_64(:,1);
avg_benchmark_could_have_crashed_data_concat(1:20,5) = avg_benchmark_could_have_crashed_data_bose_45_32(:,1);
avg_benchmark_could_have_crashed_data_concat(1:20,6) = avg_benchmark_could_have_crashed_data_bose_79_64(:,1);
avg_benchmark_could_have_crashed_data_concat(1:20,7) = avg_benchmark_could_have_crashed_data_kaneda_144_128(:,1);
avg_benchmark_could_have_crashed_data_concat(21,:) = geomean(avg_benchmark_could_have_crashed_data_concat(1:20,:));

% Unsorted miscorrect
avg_benchmark_miscorrect_data_concat = NaN(21,7);
avg_benchmark_miscorrect_data_concat(1:20,1) = avg_benchmark_miscorrect_data_hsiao_39_32(:,1);
avg_benchmark_miscorrect_data_concat(1:20,2) = avg_benchmark_miscorrect_data_davydov_39_32(:,1);
avg_benchmark_miscorrect_data_concat(1:20,3) = avg_benchmark_miscorrect_data_hsiao_72_64(:,1);
avg_benchmark_miscorrect_data_concat(1:20,4) = avg_benchmark_miscorrect_data_davydov_72_64(:,1);
avg_benchmark_miscorrect_data_concat(1:20,5) = avg_benchmark_miscorrect_data_bose_45_32(:,1);
avg_benchmark_miscorrect_data_concat(1:20,6) = avg_benchmark_miscorrect_data_bose_79_64(:,1);
avg_benchmark_miscorrect_data_concat(1:20,7) = avg_benchmark_miscorrect_data_kaneda_144_128(:,1);
avg_benchmark_miscorrect_data_concat(21,:) = geomean(avg_benchmark_miscorrect_data_concat(1:20,:));

% Int success
avg_benchmark_successes_data_concat_int = NaN(9,7);
avg_benchmark_successes_data_concat_int(1:9,1) = avg_benchmark_successes_data_hsiao_39_32(int_benchmark_indices,1);
avg_benchmark_successes_data_concat_int(1:9,2) = avg_benchmark_successes_data_davydov_39_32(int_benchmark_indices,1);
avg_benchmark_successes_data_concat_int(1:9,3) = avg_benchmark_successes_data_hsiao_72_64(int_benchmark_indices,1);
avg_benchmark_successes_data_concat_int(1:9,4) = avg_benchmark_successes_data_davydov_72_64(int_benchmark_indices,1);
avg_benchmark_successes_data_concat_int(1:9,5) = avg_benchmark_successes_data_bose_45_32(int_benchmark_indices,1);
avg_benchmark_successes_data_concat_int(1:9,6) = avg_benchmark_successes_data_bose_79_64(int_benchmark_indices,1);
avg_benchmark_successes_data_concat_int(1:9,7) = avg_benchmark_successes_data_kaneda_144_128(int_benchmark_indices,1);

% Int crash
avg_benchmark_could_have_crashed_data_concat_int = NaN(9,7);
avg_benchmark_could_have_crashed_data_concat_int(1:9,1) = avg_benchmark_could_have_crashed_data_hsiao_39_32(int_benchmark_indices,1);
avg_benchmark_could_have_crashed_data_concat_int(1:9,2) = avg_benchmark_could_have_crashed_data_davydov_39_32(int_benchmark_indices,1);
avg_benchmark_could_have_crashed_data_concat_int(1:9,3) = avg_benchmark_could_have_crashed_data_hsiao_72_64(int_benchmark_indices,1);
avg_benchmark_could_have_crashed_data_concat_int(1:9,4) = avg_benchmark_could_have_crashed_data_davydov_72_64(int_benchmark_indices,1);
avg_benchmark_could_have_crashed_data_concat_int(1:9,5) = avg_benchmark_could_have_crashed_data_bose_45_32(int_benchmark_indices,1);
avg_benchmark_could_have_crashed_data_concat_int(1:9,6) = avg_benchmark_could_have_crashed_data_bose_79_64(int_benchmark_indices,1);
avg_benchmark_could_have_crashed_data_concat_int(1:9,7) = avg_benchmark_could_have_crashed_data_kaneda_144_128(int_benchmark_indices,1);

% Int miscorrect
avg_benchmark_miscorrect_data_concat_int = NaN(9,7);
avg_benchmark_miscorrect_data_concat_int(1:9,1) = avg_benchmark_miscorrect_data_hsiao_39_32(int_benchmark_indices,1);
avg_benchmark_miscorrect_data_concat_int(1:9,2) = avg_benchmark_miscorrect_data_davydov_39_32(int_benchmark_indices,1);
avg_benchmark_miscorrect_data_concat_int(1:9,3) = avg_benchmark_miscorrect_data_hsiao_72_64(int_benchmark_indices,1);
avg_benchmark_miscorrect_data_concat_int(1:9,4) = avg_benchmark_miscorrect_data_davydov_72_64(int_benchmark_indices,1);
avg_benchmark_miscorrect_data_concat_int(1:9,5) = avg_benchmark_miscorrect_data_bose_45_32(int_benchmark_indices,1);
avg_benchmark_miscorrect_data_concat_int(1:9,6) = avg_benchmark_miscorrect_data_bose_79_64(int_benchmark_indices,1);
avg_benchmark_miscorrect_data_concat_int(1:9,7) = avg_benchmark_miscorrect_data_kaneda_144_128(int_benchmark_indices,1);

% float success
avg_benchmark_successes_data_concat_float = NaN(11,7);
avg_benchmark_successes_data_concat_float(1:11,1) = avg_benchmark_successes_data_hsiao_39_32(float_benchmark_indices,1);
avg_benchmark_successes_data_concat_float(1:11,2) = avg_benchmark_successes_data_davydov_39_32(float_benchmark_indices,1);
avg_benchmark_successes_data_concat_float(1:11,3) = avg_benchmark_successes_data_hsiao_72_64(float_benchmark_indices,1);
avg_benchmark_successes_data_concat_float(1:11,4) = avg_benchmark_successes_data_davydov_72_64(float_benchmark_indices,1);
avg_benchmark_successes_data_concat_float(1:11,5) = avg_benchmark_successes_data_bose_45_32(float_benchmark_indices,1);
avg_benchmark_successes_data_concat_float(1:11,6) = avg_benchmark_successes_data_bose_79_64(float_benchmark_indices,1);
avg_benchmark_successes_data_concat_float(1:11,7) = avg_benchmark_successes_data_kaneda_144_128(float_benchmark_indices,1);

% float crash
avg_benchmark_could_have_crashed_data_concat_float = NaN(11,7);
avg_benchmark_could_have_crashed_data_concat_float(1:11,1) = avg_benchmark_could_have_crashed_data_hsiao_39_32(float_benchmark_indices,1);
avg_benchmark_could_have_crashed_data_concat_float(1:11,2) = avg_benchmark_could_have_crashed_data_davydov_39_32(float_benchmark_indices,1);
avg_benchmark_could_have_crashed_data_concat_float(1:11,3) = avg_benchmark_could_have_crashed_data_hsiao_72_64(float_benchmark_indices,1);
avg_benchmark_could_have_crashed_data_concat_float(1:11,4) = avg_benchmark_could_have_crashed_data_davydov_72_64(float_benchmark_indices,1);
avg_benchmark_could_have_crashed_data_concat_float(1:11,5) = avg_benchmark_could_have_crashed_data_bose_45_32(float_benchmark_indices,1);
avg_benchmark_could_have_crashed_data_concat_float(1:11,6) = avg_benchmark_could_have_crashed_data_bose_79_64(float_benchmark_indices,1);
avg_benchmark_could_have_crashed_data_concat_float(1:11,7) = avg_benchmark_could_have_crashed_data_kaneda_144_128(float_benchmark_indices,1);

% float miscorrect
avg_benchmark_miscorrect_data_concat_float = NaN(11,7);
avg_benchmark_miscorrect_data_concat_float(1:11,1) = avg_benchmark_miscorrect_data_hsiao_39_32(float_benchmark_indices,1);
avg_benchmark_miscorrect_data_concat_float(1:11,2) = avg_benchmark_miscorrect_data_davydov_39_32(float_benchmark_indices,1);
avg_benchmark_miscorrect_data_concat_float(1:11,3) = avg_benchmark_miscorrect_data_hsiao_72_64(float_benchmark_indices,1);
avg_benchmark_miscorrect_data_concat_float(1:11,4) = avg_benchmark_miscorrect_data_davydov_72_64(float_benchmark_indices,1);
avg_benchmark_miscorrect_data_concat_float(1:11,5) = avg_benchmark_miscorrect_data_bose_45_32(float_benchmark_indices,1);
avg_benchmark_miscorrect_data_concat_float(1:11,6) = avg_benchmark_miscorrect_data_bose_79_64(float_benchmark_indices,1);
avg_benchmark_miscorrect_data_concat_float(1:11,7) = avg_benchmark_miscorrect_data_kaneda_144_128(float_benchmark_indices,1);

% Aggregated sorted
avg_benchmark_successes_data_concat_split_int_float = [zeros(1,7); random_recovery_probs(1,:); avg_benchmark_successes_data_concat_int; avg_benchmark_successes_data_concat_float; avg_benchmark_successes_data_concat(21,:)];
avg_benchmark_could_have_crashed_data_concat_split_int_float = [ones(1,7); zeros(1,7); avg_benchmark_could_have_crashed_data_concat_int; avg_benchmark_could_have_crashed_data_concat_float; avg_benchmark_could_have_crashed_data_concat(21,:)];
avg_benchmark_miscorrect_data_concat_split_int_float = [zeros(1,7); 1-random_recovery_probs(1,:); avg_benchmark_miscorrect_data_concat_int; avg_benchmark_miscorrect_data_concat_float; avg_benchmark_miscorrect_data_concat(21,:)];
avg_benchmark_crash_false_positive_data_concat_split_int_float = avg_benchmark_successes_data_concat_split_int_float(3:end-1,:) - (1-(avg_benchmark_could_have_crashed_data_concat_split_int_float(3:end-1,:) + avg_benchmark_miscorrect_data_concat_split_int_float(3:end-1,:)));
avg_benchmark_crash_false_positive_data_concat_split_int_float(21,:) = geomean(avg_benchmark_crash_false_positive_data_concat_split_int_float(1:end-1,:));


stackData = NaN(23, 7, 3);
for bench=1:23
   for code=1:7
       stackData(bench,code,1) = 1-(avg_benchmark_could_have_crashed_data_concat_split_int_float(bench,code)+avg_benchmark_miscorrect_data_concat_split_int_float(bench,code));
       stackData(bench,code,2) = avg_benchmark_could_have_crashed_data_concat_split_int_float(bench,code);
       stackData(bench,code,3) = avg_benchmark_miscorrect_data_concat_split_int_float(bench,code);
   end
end


plotBarStackGroups(stackData,benchmark_names);
colormap([0 0 0; 0.5 0.5 0.5; 1 1 1]);
set(gca,'xlim',[0 23.4])
set(gca,'XTick',1:23)
set(gca,'XTickLabel',['conventional'; 'random candidate'; int_benchmark_names(int_benchmark_indices); float_benchmark_names(float_benchmark_indices); 'Geo. Mean'])

set(gca,'ylim',[0 1])
set(gca,'ytick',0:0.2:1);
ylabel('Fraction of DUEs','FontSize',12,'Color','Black');

set(gca,'FontSize',12,'FontName','Arial','XColor','Black','YColor','Black')
xticklabel_rotate([],45,[],'fontsize',12)
pos = get(gca,'Position');
pos(3) = 0.80;
pos(4) = 0.15;
set(gca,'Position',pos);
grid on;


stackData2 = NaN(21, 7, 2);
for bench=1:21
   for code=1:7
       stackData2(bench,code,1) = 1-avg_benchmark_crash_false_positive_data_concat_split_int_float(bench,code);
       stackData2(bench,code,2) = avg_benchmark_crash_false_positive_data_concat_split_int_float(bench,code);
   end
end

plotBarStackGroups(stackData2,benchmark_names);
colormap([0.5 0.5 0.5; 1 0 0]);
set(gca,'xlim',[0 21.4])
set(gca,'XTick',1:21)
set(gca,'XTickLabel',[int_benchmark_names(int_benchmark_indices); float_benchmark_names(float_benchmark_indices); 'Geo. Mean'])

set(gca,'ylim',[0 1])
set(gca,'ytick',0:0.2:1);
ylabel('Fraction of Crashes','FontSize',9,'Color','Black');

set(gca,'FontSize',12,'FontName','Arial','XColor','Black','YColor','Black')
xticklabel_rotate([],45,[],'fontsize',9)
pos = get(gca,'Position');
pos(3) = 0.80;
pos(4) = 0.15;
set(gca,'Position',pos);
grid on;

%lgd = legend({'(39,32) SECDED - Hsiao', '(39,32) SECDED - Davydov', '(72,64) SECDED - Hsiao', '(72,64) SECDED - Davydov', '(45,32) DECTED', '(79,64) DECTED', '(144,128) SSCDSD - Kaneda'}, 'Interpreter','latex','fontsize',12,'fontname','arial');