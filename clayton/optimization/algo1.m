clear
clc

load original_heat.mat
heat = original_heat;
stuck=[];

% %% Find minimum for index 6 along entire column
% location=0;
% minimum=100;
% for k=1:32
%     if (heat(k,6) < minimum && k~=6)
%         minimum=heat(k,6);
%         location=k;
%     end
% end
% 
% %Swap row and location
% heat=swap_cols(heat,6,location);
% heat=swap_rows(heat,6,location);
% 
% %mark which columns/rows can no longer be switched.
% stuck=[stuck 6 location];
% 
% %av at this time
% average6(heat)
% 
% %% Find minimum for index 5&6 along remaining terms.
% 
% location=0;
% minimum=100;
% for k=1:32
%     if (sum(heat(k,5:6)) < minimum   && k~=5 && ~any(k==stuck))
%         minimum=sum(heat(k,5:6));
%         location=k;
%     end
% end
% 
% %Swap row and location
% heat=swap_cols(heat,5,location);
% heat=swap_rows(heat,5,location);
% 
% %mark which columns/rows can no longer be switched.
% stuck=[stuck 5 location];
% 
% %av at this time
% average6(heat)
% 
% pcolor(heat)

%%
average6(heat)
    figure()
    pcolor(heat)
for round=6:-1:2
    location=0;
    minimum=1000;
    for k=1:32
        if (sum(heat(k,round:6)) < minimum   && k~=round && ~any(k==stuck))
            minimum=sum(heat(k,round:6));
            location=k;
        end
    end

    %Swap row and location
    heat=swap_cols(heat,round,location);
    heat=swap_rows(heat,round,location);

    %mark which columns/rows can no longer be switched.
    stuck=[stuck round location];

    %av at this time
    average6(heat)
    figure()
    pcolor(heat)
end






