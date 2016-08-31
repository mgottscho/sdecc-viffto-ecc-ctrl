z=1;
cc_2d = NaN(n+1,n+1);
mean_results_candidate_messages = mean(results_candidate_messages);
for err_bitpos_1=1:n-1
    for err_bitpos_2=err_bitpos_1+1:n
        cc_2d(err_bitpos_2,err_bitpos_1+1) = mean_results_candidate_messages(z);
        z=z+1;
    end
end

figure;
pcolor(flipud(cc_2d));
xlim([2 n+1]);
set(gca,'XTick',[2 [5:5:n+1]]);
set(gca,'XAxisLocation','top');
xtick = get(gca, 'XTick');
xticklabel = get(gca, 'XTickLabel');
set(gca,'XTick',xtick+0.6);
set(gca,'XTickLabel',xticklabel);
ylim([2 n+1]);
set(gca,'YTick',fliplr([n+1:-5:0]));
set(gca,'YTickLabel',fliplr([[1 5:5:n+1]]));
ytick = get(gca, 'YTick');
yticklabel = get(gca, 'YTickLabel');
set(gca,'YTick',[ytick(1:end-1)+0.6 ytick(end)]);
set(gca,'YTickLabel',yticklabel);
set(gca,'TickLength',[0 0]);
ylabel('Index of 1st bit in error', 'FontSize', 12, 'FontName', 'Arial');
xlabel('Index of 2nd bit in error', 'FontSize', 12, 'FontName', 'Arial');
title(['Number of Candidate Codewords for ' code_type ' (' num2str(n) ',' num2str(k) ')'], 'FontSize', 12, 'FontName', 'Arial');