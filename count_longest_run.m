function [longestRun] = count_longest_run(bin)

bin

longestRun = size(bin,2); % Init to max
zeros_start = find(diff(bin)==-1)+1 % multiple positions
zeros_end = find(diff(bin)==1)+1 % multiple positions
zeros_longestRun = max(zeros_end-zeros_start)

ones_start = find(diff(['0' bin])==1) % multiple positions
ones_end = find(diff([bin '0'])==-1)+1 % multiple positions
ones_longestRun = max(ones_end-ones_start)

longestRun = max(zeros_longestRun,ones_longestRun)

end
