function obj = bkfilter1s(obj,low,high)
% Syntax:
%
% obj = bkfilter1s(obj,low,high)
%
% Description:
%
% Do one sided band pass-filtering of all the dataseries of the 
% object. (Returns the gap) Will strip nan values when calculating 
% the filter. 
% 
% Input:
% 
% - obj  : An object of class nb_math_ts
% 
% - low  : Lowest frequency. > 2
%
% - high : Highest frequency. > low
%   
% Output:
% 
% - obj  : An object of class nb_math_ts with the one-sided band 
%          pass filtered data.
% 
% Examples:
% 
% obj = obj.bkfilter1s(12,24);
% obj = bkfilter1s(obj,12,24);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = nb_bkfilter1s(obj.data,low,high);

end
