function day = getDay(obj,first)
% Syntax:
% 
% day = getDay(obj,first)
%
% Description:
%   
% Get the day of the week, given as a nb_day object
% 
% Input:
% 
% - obj      : An object of class nb_week
%
% - first    : 2 : Uses the dayOfWeek property.
%              1 : first day of the week (Monday)
%              0 : last day of the week (Sunday)
% 
% Output:
% 
% - day     : An nb_day object
% 
% Examples:
%
% month = obj.getDay();   % Will return the day
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
		first = 1;
    end
    
    if numel(obj) > 1
        [s1,s2]   = size(obj);
        obj       = obj(:);
        s         = s1*s2;
        day(1,s)  = nb_day;
        for ii = 1:s  
            day(ii) = getDay(obj(ii),first);
        end
        return
    end

    if first == 1
        date = nb_week.getXLSDate(obj.week,2,obj.year,0);
    elseif first == 2
        date = nb_week.getXLSDate(obj.week,obj.dayOfWeek,obj.year,0);
    else
        date = nb_week.getXLSDate(obj.week,1,obj.year,0);
    end
    date          = date{1};
    day           = nb_day(date);
    day.dayOfWeek = obj.dayOfWeek;
    
end
