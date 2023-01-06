function obj = mavg(obj,backward,forward,flag)
% Syntax:
%
% obj = mavg(obj,backward,forward,flag)
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
% - flag     : If set to true the periods that does not have enough
%              observations forward or backward should be set to nan.
%              Default is false.
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        flag = false;
    end

    d     = obj.data;
    isNaN = isnan(d);
    if any(isNaN(:))
        obj.data = nb_nanmavg(d,backward,forward,flag);
    else
        obj.data = nb_mavg(d,backward,forward,flag);
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@mavg,{backward,forward,flag});
        
    end
    
end
