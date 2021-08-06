function obj = shrinkSample(obj,variables,periods)
% Syntax:
%
% obj = shrinkSample(obj,variables,periods)
%
% Description:
%
% Shrink sample to be balanced for a selected number of variables. (May 
% tolerate trailing nan with the selected number of periods)
% 
% Input:
% 
% - obj       : An object of class nb_ts
%
% - variables : A cellstr with the variables of interest
%
% - periods   : A integer with the number of tolerate trailing nan. Default
%               is 0.
% 
% Output: 
% 
% - obj       : An object of class nb_ts
% 
% See also:
% nb_ts.cutSample
%
% Written by Kenneth S. Paulsen  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        periods = 0;
    end
    
    if isempty(periods) || isnan(periods)
        periods = 0;
    end

    if ~nb_iswholenumber(periods)
        error([mfilename ':: The periods input must be an integer...'])
    end

    realEndDate = getRealEndDate(obj,'nb_date','all',variables);
    newEndDate  = realEndDate + periods;
    if newEndDate < obj.endDate
        ind                      = newEndDate - obj.startDate + 1;
        obj.data                 = obj.data(1:ind,:,:);
    elseif newEndDate > obj.endDate
        obj.data                 = [obj.data;nan(newEndDate - obj.endDate,obj.numberOfVariables,obj.numberOfDatasets)];
    end
    obj.endDate = newEndDate;

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@shrinkSample,{variables,periods});
        
    end
    
end
