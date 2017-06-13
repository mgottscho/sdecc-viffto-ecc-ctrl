input_dir = '/Users/mark/Dropbox/SoftwareDefinedECC/data/rv64g/data-recovery/online-dynamic-sim/hsiao1970/72,64/SYSTEM-min-entropy8-pick-longest-run/crash-threshold-4.5/2017-03-13/jpeg';
output_dir = [input_dir filesep 'postprocessed'];
sdc_file = [input_dir filesep 'recovered_sdc.csv'];
benign_file = [input_dir filesep 'recovered_benign.csv'];
correct_file = [input_dir filesep 'recovered_correct.csv'];
policy = 'min-entropy8-pick-longest-run';
hash_mode = 'hash-none';
code = 'hsiao1970 (72,64)'
benchmark = 'jpeg';
tolerable_error_threshold = 0.1;
num_runs = 1000;

mkdir(output_dir);

sdc_input = dlmread(sdc_file);
benign_input = dlmread(benign_file);
correct_input = dlmread(correct_file);
overall_input = [sdc_input; benign_input; correct_input];

fraction_overall_sdcs = size(sdc_input,1) / num_runs
fraction_tolerable_sdcs = sum(sdc_input(:,2)<tolerable_error_threshold)/size(sdc_input,1)
mean_sdc_error = mean(sdc_input(:,2))
median_sdc_error = median(sdc_input(:,2))

fraction_tolerable_overall = sum(overall_input(:,2)<tolerable_error_threshold)/size(overall_input,1)
mean_overall_error = mean(overall_input(:,2))
median_overall_error = median(overall_input(:,2))
fraction_tolerable_output = sum(overall_input(:,2)<tolerable_error_threshold)/size(overall_input,1)

figure;
[y,x] = hist(overall_input(:,2),1000);
y = y/size(overall_input,1);
y2 = zeros(1,size(y,2));
for i=1:size(y,2)
    y2(i) = sum(y(1:i));
end
plot(x,y2);
ylabel('Fraction of Runs Below Output Error', 'FontSize', 14, 'FontName', 'Arial');
xlabel('Normalized Application Output Error', 'FontSize', 14, 'FontName', 'Arial');
set(gca,'FontSize',14,'FontName','Arial');

hold on;

[y,x] = hist(sdc_input(:,2),1000);
y = y/size(sdc_input,1);
y2 = zeros(1,size(y,2));
for i=1:size(y,2)
    y2(i) = sum(y(1:i));
end
plot(x,y2);

legend('Overall','SDCs only');
title([code ' ' hash_mode ' ' policy ' ' benchmark ' ' num2str(num_runs) ', crashes and hangs excluded']);
savefig(gcf,[output_dir filesep 'output_error_overall.fig']);
print(gcf, '-depsc2', [output_dir filesep 'output_error_overall.eps']);

figure; 
[y,x] = hist(overall_input(:,2),1000);
y = y/size(overall_input,1);
y2 = zeros(1,size(y,2));
for i=1:size(y,2)
    y2(i) = sum(y(1:i));
end
plot(x,y2);
ylabel('Fraction of Runs Below Output Error', 'FontSize', 14, 'FontName', 'Arial');
xlabel('Normalized Application Output Error', 'FontSize', 14, 'FontName', 'Arial');
set(gca,'FontSize',14,'FontName','Arial');
title([code ' ' hash_mode ' ' policy ' ' benchmark ' ' num2str(num_runs) ', crashes and hangs excluded']);
savefig(gcf,[output_dir filesep 'output_error_sdc.fig']);
print(gcf, '-depsc2', [output_dir filesep 'output_error_sdc.eps']);
    

save([output_dir filesep 'results.mat'], '-v7.3');
