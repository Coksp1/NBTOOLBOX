function obj = expand(obj,newStartDate,newEndDate,warningOff)
% Syntax:
%
% obj = expand(obj,newStartDate,newEndDate,warningOff)
%
% Description:
%
% Expand the current nb_bd object with more dates and data.
% 
% Input:
% 
% - obj          : An object of class nb_bd
% 
% - newStartDate : The wanted new start date of the data.
% 
% - newEndDate   : The wanted new end date of the data.
%
% - warningOff   : Give 'off' to suppress warning if no expansion 
%                  has taken place. Both 'newStartDate' and
%        
% Output:
% 
% - obj          : An nb_bd object with expanded timespan
% 
% Examples:
%
% obj = nb_bd.rand('1901Q1',10,2);
% obj = expand(obj,'1900Q1','1903Q4');
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        warningOff = 'on';
        if nargin < 3
            newEndDate = '';
            if nargin < 2
                newStartDate = '';
            end
        end
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
            warning('nb_bd:expand:newStartDateAfter : The new start date of the data is after or the same as the current start date. Nothing is done!') 
        end
    elseif numOfNewPerBefore > 0

        if obj.indicator
            added = zeros(numOfNewPerBefore,dim2*dim3);
        else
            added = ones(numOfNewPerBefore,dim2*dim3);
        end
        
        if isa(obj.data,'nb_distribution')
            added = nb_distribution.double2Dist(added);
            warning('nb_distribution is not fully supported for nb_bd')
        end
        obj.locations = [added; obj.locations];
        obj.startDate = newStartDateT;
    end

    % Add data for the number of periods after
    if numOfNewPerAfter < 0
        if strcmp(warningOff,'on')
            warning('nb_bd:expand:newEndDateBefore : The new end date of the data is before or the same as the current end date. Nothing is done!') 
        end
    elseif numOfNewPerAfter > 0

        if obj.indicator
            added = zeros(numOfNewPerAfter,dim2*dim3);
        else
            added = ones(numOfNewPerAfter,dim2*dim3);
        end
        
        if isa(obj.data,'nb_distribution')
            added = nb_distribution.double2Dist(added);
            warning('nb_distribution is not fully supported for nb_bd')
        end
        obj.locations = [obj.locations; added];
        obj.endDate   = newEndDateT;
    end
    
    if obj.isUpdateable() && ~obj.isBeingMerged
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@expand,{newStartDate,newEndDate,warningOff});
        
    end

end
