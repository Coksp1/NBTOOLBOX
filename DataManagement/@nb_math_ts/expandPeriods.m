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
% - obj     : An object of class nb_math_ts.
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
% - obj     : An object of class nb_math_ts.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'nan';
    end

    if obj.dim2 > 1
        error('This method only handle a nb_math_ts object with one variables')
    end
    
    periods = round(periods);
    if periods < 0
        periods = -periods;
        neg     = 1;
    else
        neg     = 0;
    end

    if neg
        realStartDate = getRealStartDate(obj,'nb_date');
        per           = (realStartDate - obj.startDate) + 1;
        perExp        = periods - (realStartDate - obj.startDate);
        if perExp > 0
            data          = nan(perExp,obj.dim2,obj.dim3);
            obj.data      = [data;obj.data];
            obj.startDate = obj.startDate - perExp;
            per           = per + perExp;
        end
    else
        realEndDate = getRealEndDate(obj,'nb_date');
        per         = (realEndDate - obj.startDate) + 1;
        perExp      = periods - (obj.endDate - realEndDate);
        if perExp > 0
            data        = nan(perExp,obj.dim2,obj.dim3);
            obj.data    = [obj.data;data];
            obj.endDate = obj.endDate + perExp;
        end
    end
    
    if nb_isScalarInteger(type)
        if neg
            data = obj.data(per:per+type-1,:,:);
            pers = ceil(periods/type);
            data = repmat(data,[pers,1,1]);
            data = data(end-periods+1:end,:,:);
        else
            data = obj.data(per-type+1:per,:,:);
            pers = ceil(periods/type);
            data = repmat(data,[pers,1,1]);
            data = data(1:periods,:,:);
        end
    else
        switch lower(type)
            case 'nan'
                data = nan(periods,obj.dim2,obj.dim3);
            case 'zeros'
                data = zeros(periods,obj.dim2,obj.dim3);
            case 'ones'
                data = ones(periods,obj.dim2,obj.dim3);
            case 'rand'
                data = rand(periods,obj.dim2,obj.dim3);
            case 'obs'
                if neg
                    data = obj.data(1,:,:);
                else
                    data = obj.data(end,:,:);
                end
                data = data(ones(1,periods),:,:);
        end
    end
     
    if neg
        obj.data(per-periods+1:per) = data;
    else
        obj.data(per+1:per+periods) = data;
    end
    
end
