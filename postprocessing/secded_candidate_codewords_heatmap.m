z=1;
cc_2d = NaN(n+1,n+1);
mean_results_candidate_messages = mean(results_candidate_messages);
for err_bitpos_1=1:n-1
    for err_bitpos_2=err_bitpos_1+1:n
        cc_2d(err_bitpos_2,err_bitpos_1) = mean_results_candidate_messages(z);
        z=z+1;
    end
end

figure;
colormap(prism);
pcolor(cc_2d);
xlabel('Index of 1st bit in error', 'FontSize', 12, 'FontName', 'Arial');
ylabel('Index of 2nd bit in error', 'FontSize', 12, 'FontName', 'Arial');
set(gca,'XAxisLocation','top'); 
set(gca,'YDir','reverse');

set(gca,'XTick',[1 [5:5:n+1]]);
xtick = get(gca, 'XTick');
xticklabel = get(gca, 'XTickLabel');
set(gca,'XTick',xtick+0.6);
set(gca,'XTickLabel',xticklabel);

set(gca,'YTick',[2 [5:5:n]]);
%set(gca,'YTickLabel',fliplr([[1 5:5:n+1]]));
ytick = get(gca, 'YTick');
yticklabel = get(gca, 'YTickLabel');
set(gca,'YTick',[ytick(1:end-1)+0.6 ytick(end)]);
set(gca,'YTickLabel',yticklabel);
set(gca,'TickLength',[0 0]);
%title(['Number of Candidate Codewords for ' code_type ' (' num2str(n) ',' num2str(k) ')'], 'FontSize', 12, 'FontName', 'Arial');