function obj = mavg(obj,backward,forward)
% Syntax:
%
% obj = mavg(obj,backward,forward)
%
% Description:
%
% Taking moving avarage of all the timeseries of the nb_ts object
% 
% Input:
% 
% - obj      : An object of class nb_ts
% 
% - backward : Number of periods backward in time to calculate the 
%              moving average
% 
% - forward  : Number of periods forward in time to calculate the 
%              moving average
% 
% Output:
% 
% - obj      : An nb_ts object storing the calculated moving 
%              average
% 
% Examples: 
% 
% data = nb_ts(rand(50,2)*3,'','2011Q1',{'Var1','Var2'});
% 
% mAvg10 = mavg(data,9,0); % (10 year moving average)
%
% See also:
% nb_mavg
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
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@mavg,{backward,forward});
        
    end
    
end
