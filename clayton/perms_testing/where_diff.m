differences = zeros(39,39);
for i=1:39
    for j=1:39
        if (heat_van(i,j)~=heat_swap(i,j))
            differences(i,j)=1;
        end
    end
end

pcolor(differences)
        