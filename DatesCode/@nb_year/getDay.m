function day = getDay(obj,first)
% Syntax:
% 
% day = getDay(obj,first)
%
% Description:
% 
% Get the first or last day of the year, given as an nb_day object
%         
% Input:
%         
% - obj   : An object of class nb_year
%         
% - first : 1 : The first day
%           0 : The last day
%           2 : The first day that match the dayOfWeek property.
%           3 : The last day that match the dayOfWeek property.
%           4 : The first business day.
%                 
% Output:
%         
% - day   : An nb_day object
% 
% Examples:
%
% obj = nb_year(2020);
% day = obj.getDay();    % Will return the first day of the year
% day = obj.getDay(0);   % Will return the last day of the year
% day = obj.getDay(2);   % Will return the first sunday of the year
% day = obj.getDay(3);   % Will return the last sunday of the year
% 
% Written by Kenneth S. Paulsen
            
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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

    if first == 4
        day = nb_day(2,1,obj.year);
    elseif first == 3
        month = getMonth(obj,false);
        day   = getDay(month,first);
    elseif first == 2
        month = getMonth(obj,true);
        day   = getDay(month,first);
    elseif first == 1
        day = nb_day(1,1,obj.year);
    else
        day = nb_day(31,12,obj.year);
    end
    day.dayOfWeek = obj.dayOfWeek;

end
