function obj = rlag(obj,t,endDate)
% Syntax:
%
% obj = rlag(obj,t,endDate)
%
% Description:
%
% Append data with use of the rolling lag operator  
% 
% Input:
% 
% - obj      : An object of class nb_ts
%
% - t        : The number of lags to use for the rolling window
% 
% - endDate  : The new end date
% 
% Output: 
% 
% - obj      : An object of class ts
% 
% Examples:
%
% obj = nb_ts(rand(20,1),'','1','Var1')
% obj = rlag(obj,4,'30')
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    endDateWin = interpretDateInput(obj,endDate);
    len        = (endDateWin - obj.endDate);
    if len < 1
        error([mfilename ':: The endDate input must be after the endDate of the object'])
    end
    appended = nb_rlag(obj.data,t,len);
    
    % Update data properties
    obj.data    = [obj.data;appended];
    obj.endDate = endDateWin;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@rlag,{t,endDate});
        
    end
    
end
