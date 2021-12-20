function obj = expand(obj,newStartDate,newEndDate,type,warningOff)
% Syntax:
%
% obj = expand(obj,newStartDate,newEndDate,type,warningOff)
%
% Description:
%
% Expand the current nb_ts object with more dates and data
% 
% Input:
% 
% - obj          : An object of class nb_ts
% 
% - newStartDate : The wanted new start date of the data.
% 
% - newEndDate   : The wanted new end date of the data.
% 
% - type         : Type of the appended data :
% 
%                  - 'nan'   : Expanded data is all nan (default)
%                  - 'zeros' : Expanded data is all zeros
%                  - 'ones'  : Expanded data is all ones
%                  - 'rand'  : Expanded data is all random numbers
%                  - 'obs'   : Expand the data with first observation 
%                              (before) or last observation after
% 
% - warningOff   : Give 'off' to suppress warning if no expansion 
%                  has taken place. Both 'newStartDate' and
%                  'newEndDate' is inside the window.
% 
% Output:
% 
% - obj          : An nb_ts object with expanded timespan
% 
% Examples:
%
% obj = expand(obj,'1900Q1','2050Q1');
% obj = expand(obj,'1900Q1','2050Q1','zeros');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        warningOff = 'on';
        if nargin < 4
            type = '';
            if nargin < 3
                newEndDate = '';
                if nargin < 2
                    newStartDate = '';
                end
            end
        end
    end

    if isempty(type)
       type = 'nan';
    end

    if isempty(newEndDate)
        newEndDateT = obj.endDate;
    else
        newEndDateT = interpretDateInput(obj,newEndDate);
    end

    if isempty(newStartDate)
        newStartDateT = obj.startDate; 
    else
        newStartDateT = interpretDateInput(obj,newStartDate);
    end

    dim2 = obj.numberOfVariables;
    dim3 = obj.numberOfDatasets;

    % Find the number of added periods
    numOfNewPerBefore = obj.startDate - newStartDateT;
    numOfNewPerAfter  = newEndDateT - obj.endDate;

    % Add data for the number of periods before
    if numOfNewPerBefore < 0
        if strcmp(warningOff,'on')
            warning('nb_ts:expand:newStartDateAfter','The new start date of the data is after or the same as the current start date. Nothing is done!') 
        end
    elseif numOfNewPerBefore > 0

        switch type 
            case 'nan'
                added = nan(numOfNewPerBefore,dim2,dim3);
            case 'zeros'
                added = zeros(numOfNewPerBefore,dim2,dim3);
            case 'ones'
                added = ones(numOfNewPerBefore,dim2,dim3);
            case 'rand'
                added = rand(numOfNewPerBefore,dim2,dim3); 
            case 'obs'
                added = repmat(obj.data(1,:,:),[numOfNewPerBefore,1,1]);
            otherwise
                error([mfilename ':: Unsupported type; ' type ' (The supported types is; ''obs'', ''rand'', ''nan'', ''zeros'' and ''ones'')'])
        end
        if isa(obj.data,'nb_distribution')
            added = nb_distribution.double2Dist(added);
        end
        obj.data      = [added;obj.data];
        obj.startDate = newStartDateT;
    end

    % Add data for the number of periods after
    if numOfNewPerAfter < 0
        if strcmp(warningOff,'on')
            warning('nb_ts:expand:newEndDateBefore','The new end date of the data is before or the same as the current end date. Nothing is done!') 
        end
    elseif numOfNewPerAfter > 0

        switch type 

            case 'nan'
                added = nan(numOfNewPerAfter,dim2,dim3);
            case 'zeros'
                added = zeros(numOfNewPerAfter,dim2,dim3);
            case 'ones'
                added = ones(numOfNewPerAfter,dim2,dim3);
            case 'rand'  
                added = rand(numOfNewPerAfter,dim2,dim3);
            case 'obs' 
                added = repmat(obj.data(end,:,:),[numOfNewPerAfter,1,1]);    
            otherwise
                error([mfilename ':: Unsupported type; ' type ' (The supported types is; ''obs'', ''rand'', ''nan'', ''zeros'' and ''ones'')'])
        end
        if isa(obj.data,'nb_distribution')
            added = nb_distribution.double2Dist(added);
        end
        obj.data    = [obj.data;added];
        obj.endDate = newEndDateT;
    end
    
    if obj.isUpdateable() && ~obj.isBeingMerged
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@expand,{newStartDate,newEndDate,type,warningOff});
        
    end

end
