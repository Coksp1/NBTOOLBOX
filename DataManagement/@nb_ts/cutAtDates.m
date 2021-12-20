function obj = cutAtDates(obj,endDates)
% Syntax:
%
% obj = cutAtDates(obj,endDates)
%
% Description:
%
% Cut the time-series of the variables of the object.
% 
% Input:
% 
% - obj       : An object of class nb_ts
%
% - endDates  : A nPages x nVars nb_date array.
%
% Output: 
% 
% - obj       : An object of class nb_ts
% 
% Written by Kenneth S. Paulsen  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    siz = size(endDates);
    if siz(1) ~= obj.numberOfDatasets
        error(['The endDates input must have ' int2str(obj.numberOfDatasets) 
               'rows. Has ' int2str(siz(1))])
    end
    if siz(2) ~= obj.numberOfVariables
        error(['The endDates input must have ' int2str(obj.numberOfVariables) 
               'columns. Has ' int2str(siz(2))])
    end
    
    storeUpdatable = obj.updateable;
    obj.updateable = false;
    
    for pp = 1:obj.numberOfDatasets
        for ii = 1:obj.numberOfVariables
            if endDates(pp,ii) < obj.endDate
                obj = setToNaN(obj,endDates(pp,ii) + 1,obj.endDate,obj.variables(ii),pp);
            end
        end
    end
    
    obj.updateable = storeUpdatable;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@cutAtDates,{endDates});
        
    end
    
end
