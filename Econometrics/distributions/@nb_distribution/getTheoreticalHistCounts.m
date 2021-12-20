function hist = getTheoreticalHistCounts(obj,intervals)
% Syntax:
%
% hist = getTheoreticalHistCounts(obj,intervals)
%
% Description:
%
% Get the theoretical hist counts of the distribution. The output is per
% observation, so you need to multply it by the number of observation to
% get the final histogram counts.
% 
% Input:
% 
% - obj       : A nb_distribution object.
%
% - intervals : A 1 x N double with upper bound of the intervals of the
%               return histogram. intervals(end), should be the upper 
%               bound of the domain of the distribution.
%
% Output:
% 
% - hist      : A 1 x N double with the theoretical count of each interval.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

   if numel(obj) > 1
       error([mfilename ':: This method only support scalar nb_distribution object.'])
   end
   hist = cdf(intervals(:));
   hist = [0,hist];
   hist = diff(hist);
   
end
