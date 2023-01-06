function day = getDay(obj,first)
% Syntax:
% 
% day = getDay(obj,first)
%
% Description:
%    
% Get the first or last day of the quarter, given as a nb_day 
% object
% 
% Input:
% 
% - obj      : An object of class nb_quarter
%
% - first    : 1 : First day (always 1)
%              0 : Last day (Either 28, 29, 30 or 31)
%              2 : The first day that match the dayOfWeek property.
%              3 : The last day that match the dayOfWeek property.
% 
% Output:
% 
% - day : An nb_day object
%  
% Examples:
%
% day = obj.getDay();  % Will return the first day of the quarter
% day = obj.getDay(1); % Will return the last day of the quarter
%
% Written by Kenneth S. Paulsen
            
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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
         
    if first == 3
        month = getMonth(obj,false);
        day   = getDay(month,first);
    elseif first == 2 || first == 4
        month = getMonth(obj,1);
        day   = getDay(month,first);
    elseif first
        day = nb_day(1,obj.quarter*3 - 2,obj.year);
    else
        month = nb_month(obj.quarter*3,obj.year);
        day   = nb_day(getNumberOfDays(month),obj.quarter*3,obj.year);
    end
    day.dayOfWeek = obj.dayOfWeek;

end
