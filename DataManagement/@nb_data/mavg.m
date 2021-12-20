function obj = mavg(obj,backward,forward,flag)
% Syntax:
%
% obj = mavg(obj,backward,forward,flag)
%
% Description:
%
% Taking moving avarage of all the series of the nb_data object
% 
% Input:
% 
% - obj      : An object of class nb_data
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
% - obj      : An nb_data object storing the calculated moving 
%              average
% 
% Examples: 
% 
% data = nb_data(rand(50,2)*3,'',1,{'Var1','Var2'});
% 
% mAvg10 = mavg(data,9,0); % (10 year moving average)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
