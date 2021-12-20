function obj = fillNaN(obj,date)
% Syntax:
%
% obj = fillNaN(obj)
% obj = fillNaN(obj,date)
%
% Description:
%
% Fill in for nan values with last valid observation.
% 
% Input:
% 
% - obj       : An object of class nb_math_ts.
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
% Output:
% 
% - obj : An object of class nb_ts.
%
% Examples:
% 
% d       = nb_math_ts.rand('2012Q1',10,3);
% d(3,3)  = nan;
% d(6,1)  = nan;
% d2      = fillNaN(d);
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        date = '';
    end
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
    
    % Fill in for NaN values
    data     = obj.data;
    isNotNaN = ~isnan(data);
    for pp = 1:obj.dim3
        for vv = 1:obj.dim2 
            loc = [find(isNotNaN(:,vv,pp));obj.dim1+1];
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
    
end
