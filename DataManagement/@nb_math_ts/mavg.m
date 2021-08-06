function obj = mavg(obj,backward,forward)
% Syntax:
%
% obj = mavg(obj,backward,forward)
%
% Description:
%
% Taking moving avarage of all the timeseries of the nb_math_ts 
% object
% 
% Input:
% 
% - obj      : An object of class nb_math_ts
% 
% - backward : Number of periods backward in time to calculate the 
%              moving average
% 
% - forward  : Number of periods forward in time to calculate the 
%              moving average
% 
% Output:
% 
% - obj      : An nb_math_ts object storing the calculated moving 
%              average
% 
% Examples: 
% 
% data   = nb_math_ts(rand(50,2)*3,'2011Q1');
% mAvg10 = mavg(data,9,0); % (10 year moving average)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    d     = obj.data;
    isNaN = isnan(d);
    if any(isNaN(:))
        obj.data = nb_nanmavg(d,backward,forward);
    else
        obj.data = nb_mavg(d,backward,forward);
    end

end
