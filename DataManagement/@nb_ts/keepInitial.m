function obj = keepInitial(obj,seasonalPattern,start)
% Syntax:
%
% obj = keepInitial(obj,seasonalPattern,start)
%
% Description:
%
% Keep inital value for the variables in the object.
% 
% Input:
% 
% - obj             : An object of class nb_ts.
%
% - seasonalPattern : Give true to keep the seasonal pattern. Default is
%                     false.
% 
% - start           : From the date to start. 
%
% Output:
% 
% - obj             : An object of class nb_ts.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        start = '';
        if nargin < 2
            seasonalPattern = false;
        end
    end

    startInt = interpretDateInput(obj,start);
    if isempty(startInt)
        startInt = obj.startDate;
    end
    
    startInd = startInt - obj.startDate + 1;
    d        = obj.data;
    if seasonalPattern
        lag = obj.frequency;
    else
        lag = 1;
    end
    da  = d;
    for ii = lag+startInd:obj.numberOfObservations
        da(ii,:,:) = da(ii-lag,:,:);
    end
    for ii = startInd-1:-1:1
        da(ii,:,:) = da(ii+lag,:,:);
    end
    
    obj.data = da;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@keepInitial,{seasonalPattern,start});
        
    end
    
end
