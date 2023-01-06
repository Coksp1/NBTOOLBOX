function obj = fillNaN(obj,date,variables)
% Syntax:
%
% obj = fillNaN(obj)
% obj = fillNaN(obj,date,variables)
%
% Description:
%
% Fill in for nan values with last valid observation.
% 
% Input:
% 
% - obj       : An object of class nb_ts.
%
% - date      : The end date of the returned dataset. Either a nb_date 
%               object or string with the date, or a number indicating 
%               how many periods back in time from the date today, i.e. 0 
%               is today, -1 is past period and 1 is next period. Default
%               is to use the end date of the object.
%
%               Caution : If the given date is before the end date of the 
%                        data of the object no extrapolation is done.
% 
% - variables : A cellstr with the variables to fill in nan for. Default
%               is all variables.
%
% Output:
% 
% - obj : An object of class nb_ts.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        variables = {};
        if nargin < 2
            date = '';
        end
    end
    inDate = date;
    if isempty(date)
        date = obj.endDate;
    end
    
    freq = obj.startDate.frequency;
    if isnumeric(date)
        date = nb_date.today(freq) + date;
    elseif ischar(date)
        date = nb_date.toDate(date,freq);
    end
    
    if date < obj.endDate
        date = obj.endDate;
    end
    
    if isempty(variables)
        indV = 1:obj.numberOfVariables;
    else
        [~,indV] = ismember(variables,obj.variables);
    end
    
    % Fill in for NaN values
    data     = obj.data;
    isNotNaN = ~isnan(data);
    for pp = 1:obj.numberOfDatasets
        for vv = indV 
            loc = [find(isNotNaN(:,vv,pp));obj.numberOfObservations+1];
            for ii = 2:length(loc)
                data(loc(ii-1)+1:loc(ii)-1,vv,pp) = data(loc(ii-1),vv,pp);
            end
        end
    end
    
    % Extrapolate to the wanted date
    periods = date - obj.endDate;
    if periods > 0
        ext  = data(end,:,:);
        data = [data;ext(ones(1,periods),:,:)];
    end
    
    % Update properties
    obj.data = data;
    if periods > 0
        obj.endDate = date;
    end
    
    if obj.isUpdateable()       
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@fillNaN,{inDate,variables});
    end
    
end
