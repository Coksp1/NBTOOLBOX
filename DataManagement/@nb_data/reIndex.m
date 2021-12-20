function obj = reIndex(obj,obs,baseValue)
% Syntax:
%
% obj = reIndex(obj,date,baseValue)
%
% Description:
% 
% Reindex the data of the object to a new obs.
% 
% Input:
% 
% - obj       : An object of class nb_data
% 
% - obs       : The obs at which the data should be reindexed to. 
%               (Reindexed to baseValue, default is 100)
%
% - baseValue : A number to re-index the series to. Default is 100.
%               
% Output:
% 
% - obj       : An object of class nb_data where all the objects
%               series are reindexed to 100 at the given obs
% 
% Examples:
% 
% obj = reIndex(obj,5)
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        baseValue = 100;
    end
    
    if ischar(obs)
        obs = str2double(obs);  
    end
    
    if isempty(obs)
        obs = 1.5;
    end

    if ~(isnumeric(obs) && mod(obs,1) == 0) 
        error([mfilename ':: the ''obs'' input must either be a string (with an integer) or an integer.'])
    end

    indexPeriod     = obs - obj.startObs + 1;
    indexPeriodData = obj.data(indexPeriod,:,:);
    factor          = baseValue./indexPeriodData;
    obj.data        = obj.data.*repmat(factor,[obj.numberOfObservations,1,1]);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@reIndex,{obs});
        
    end

end
