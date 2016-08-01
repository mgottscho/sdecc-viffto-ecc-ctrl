function [longestRun] = count_longest_run(bin)

longestRun = size(bin,2); % Init to max
zeros_start = find(diff(['1' bin])==-1); % multiple positions
zeros_end = find(diff([bin '1'])==1); % multiple positions
if size(zeros_start,2) <= 0 || size(zeros_end,2) <= 0 % no 0s found
    zeros_longestRun = 0;
else
    zeros_longestRun = max(zeros_end-zeros_start)+1;
end

ones_start = find(diff(['0' bin])==1); % multiple positions
ones_end = find(diff([bin '0'])==-1); % multiple positions
if size(ones_start,2) <= 0 || size(ones_end,2) <= 0 % no 1s found
    ones_longestRun = 0;
else
    ones_longestRun = max(ones_end-ones_start)+1;
end

longestRun = max(zeros_longestRun,ones_longestRun);

end
