function [ av ] = average6( heat )

total=0;
for row=1:5
    for col=row+1:6
        total = total + heat(row,col);
    end
end
av = total/15;

end

