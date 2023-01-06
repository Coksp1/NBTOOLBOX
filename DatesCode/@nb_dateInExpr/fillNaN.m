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
% - obj       : An object of class nb_dateInExpr.
%
% - date      : The end date of the returned dataset. Either a nb_date 
%               object or string with the date, or a number indicating 
%               how many periods back in time from the date today, i.e. 0 
%               is today, -1 is past period and 1 is next period. Default
%               is to use the end date of the object.
%
%               Caution : If the given date is before the date of the 
%                         object nothing will be done to the returned 
%                         object.
% 
% Output:
% 
% - obj : An object of class nb_dateInExpr.
%
% Examples:
% 
% d2 = fillNaN(d);
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        date = '';
    end
    if isempty(date)
        return;
    end
    freq = obj.date.frequency;
    if isnumeric(date)
        date = nb_date.today(freq) + date;
    elseif ischar(date)
        date = nb_date.toDate(date,freq);
    end
    if date > obj.date
        obj.date = date;
    end

end
