function obj = addTimeTrend(obj,start,finish, name)
% Syntax:
%
% obj = addTimeTrend(obj)
% obj = addTimeTrend(obj,start,finish, name)
%
% Description:
%
% Add a time trend variable to the nb_ts object
% 
% Input:
% 
% - obj     : A nb_ts object
%
% - start   : The start date of the time trend. Default is the start date
%             of the dataset
%
% - finish  : The end date of time trend. Default is the end date of the
%             dataset
%
% - name    : The name of the added variable. Default is 'timeTrend'
% 
% Output:
% 
% - obj     : A nb_ts object with the added time trend variable
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        name = '';
        if nargin < 3
            finish = '';      
            if nargin < 2
                start = '';
            end
        end
    end
    
    % Test the inputs:
    %-----------------
    if isempty(name)
        name = 'timeTrend';
    end
    
    if isempty(start)
        startD = obj.startDate;
    else
        startD = interpretDateInput(obj,start);
    end
    
    if isempty(finish)
        finishD = obj.endDate;
    else
        finishD = interpretDateInput(obj,finish);
    end
    
    startInd = (startD - obj.startDate) + 1;
    if startInd < 1 || startInd > obj.numberOfObservations

        error([mfilename ':: beginning of window (''' startD.toString ''') starts before the start date (''' obj.startDate.toString() ''') '...
                         'or starts after the end date (''' obj.endDate.toString ''') of the data '])

    end

    endInd = (finishD - obj.startDate) + 1;
    if endInd < 1 || endInd > obj.numberOfObservations

        error([mfilename ':: end of window (''' finishD.toString ''') ends after the end date (''' obj.endDate.toString ''') or '...
                         'ends before the start date (''' obj.startDate.toString() ''') of the data '])

    end
    
    % Add the time trend
    %-------------------
    periods = endInd - startInd + 1;
    pages   = obj.numberOfDatasets;
    dat     = nan(obj.numberOfObservations,1,pages);
    dat(startInd:endInd,:,:) = repmat([1:periods]',[1,1,pages]); %#ok<NBRAK>

    if obj.sorted
        obj.variables = sort([obj.variables name]);
        varInd        = find(strcmp(name,obj.variables));
        obj.data      = [obj.data(:,1:varInd-1,:), dat, obj.data(:,varInd:end,:)];
    else
        obj.variables = [obj.variables name];
        obj.data      = [obj.data,dat];
    end
        
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@addTimeTrend,{start,finish,name});
        
    end
    
end
