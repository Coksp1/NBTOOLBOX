function obj = expandPeriods(obj,periods,type)
% Syntax:
%
% obj = expandPeriods(obj,periods,type)
%
% Description:
%
% Expand the data of the object by the number of wanted periods.
% 
% Input:
% 
% - obj     : An object of class nb_ts.
%
% - periods : The number of periods to expand by. If negative the added
%             periods will be added before the start date of the object.
%
% - type    : Type of the appended data :
% 
%              - 'nan'   : Expanded data is all nan (default)
%              - 'zeros' : Expanded data is all zeros
%              - 'ones'  : Expanded data is all ones
%              - 'rand'  : Expanded data is all random numbers
%              - 'obs'   : Expand the data with first observation 
%                          (before) or last observation after
%              - integer : Expand with a rolling window.
%
%
% Output:
% 
% - obj     : An object of class nb_ts.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'nan';
    end

    periods = round(periods);
    
    if periods < 0
        periods = -periods;
        neg     = 1;
    else
        neg     = 0;
    end

    if nb_isScalarInteger(type)
        if neg
            data = obj.data(1:type,:,:);
            pers = ceil(periods/type);
            data = repmat(data,[pers,1,1]);
            data = data(end-periods+1:end,:,:);
        else
            data = obj.data(end-type+1:end,:,:);
            pers = ceil(periods/type);
            data = repmat(data,[pers,1,1]);
            data = data(1:periods,:,:);
        end
    else
        switch lower(type)

            case 'nan'
                data = nan(periods,obj.numberOfVariables,obj.numberOfDatasets);
            case 'zeros'
                data = zeros(periods,obj.numberOfVariables,obj.numberOfDatasets);
            case 'ones'
                data = ones(periods,obj.numberOfVariables,obj.numberOfDatasets);
            case 'rand'
                data = rand(periods,obj.numberOfVariables,obj.numberOfDatasets);
            case 'obs'
                data = obj.data(end,:,:);
                data = data(ones(1,periods),:,:);
        end
    end
     
    if neg
        obj.data      = [data;obj.data];
        obj.startDate = obj.startDate - periods;
    else
        obj.data    = [obj.data;data];
        obj.endDate = obj.endDate + periods;
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object. 
        obj = obj.addOperation(@expandPeriods,{periods,type});
        
    end
    
end
