function [] = secded_surf(values,n)

z=1;
values_2d = NaN(n+1,n+1);
mean_values = mean(values);
for err_bitpos_1=1:n-1
    for err_bitpos_2=err_bitpos_1+1:n
        values_2d(err_bitpos_2,err_bitpos_1) = mean_values(z);
        z=z+1;
    end
end

figure;
surf(values_2d);
xlim([1 n]);
ylim([1 n]);
zlim([0 1]);

xlabel('Index of 1st bit in error', 'FontSize', 12, 'FontName', 'Arial');
ylabel('Index of 2nd bit in error', 'FontSize', 12, 'FontName', 'Arial');
zlabel('Average Rate of Heuristic Recovery');

end

