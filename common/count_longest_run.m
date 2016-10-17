function [longestRun] = count_longest_run(bin)
% Find the longest sequential run of either 0s or 1s, whichever is greater, in a string of binary characters.
% 
% Arguments:
%   bin --   String of k characters, where each is either '0' or '1'.
%
% Returns:
%   longestRUn -- Scalar, longest run of either 0s or 1s, whichever is greater. On error, longestRun is set to -1.
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu

%longestRun = size(bin,2); % Init to max
% commented out for speed

%% Check input validity to ensure each character is either '0' or '1' and no other value
% commented out for speed
%if (sum(bin == '1')+sum(bin == '0')) ~= size(bin,2)
%    longestRun = -1;
%    return;
%end


%% Find longest run of '0's
zeros_start = find(diff(['1' bin])==-1); % multiple positions
zeros_end = find(diff([bin '1'])==1); % multiple positions
if size(zeros_start,2) <= 0 || size(zeros_end,2) <= 0 % no 0s found
    zeros_longestRun = 0;
else
    zeros_longestRun = max(zeros_end-zeros_start)+1;
end

%% Find longest run of '1's
ones_start = find(diff(['0' bin])==1); % multiple positions
ones_end = find(diff([bin '0'])==-1); % multiple positions
if size(ones_start,2) <= 0 || size(ones_end,2) <= 0 % no 1s found
    ones_longestRun = 0;
else
    ones_longestRun = max(ones_end-ones_start)+1;
end

%% Find the greater of the two longest runs
longestRun = max(zeros_longestRun,ones_longestRun);

end
