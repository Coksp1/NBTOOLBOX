function day = getDay(obj,first)
% Syntax:
% 
% day = getDay(obj,first)
%
% Description:
% 
% Get the first or last day of the month, given as an nb_day object
%         
% Input:
%         
% - obj   : An object of class nb_month
%         
% - first : 1 : First day (always 1)
%           0 : Last day (Either 28, 29, 30 or 31)
%           2 : The first day that match the dayOfWeek property.
%           3 : The last day that match the dayOfWeek property.
%                 
% Output:
%         
% - day   : An nb_day object
% 
% Examples:
%
% day = obj.getDay();    % Will return the first day of the year
% day = obj.getDay(0);   % Will return the last day of the year
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
    
    if first == 4
        day = getFirstBusinessDay(obj);
    elseif first == 3
        
        day = nb_day(obj.getNumberOfDays(),obj.month,obj.year);
        dow = weekday(day);
        if dow ~= obj.dayOfWeek
            corr = obj.dayOfWeek;
            if obj.dayOfWeek > dow
                corr = corr - 7;
            end
            sub = dow - corr;
            day = day - sub;
        end
        
    elseif first == 2
        
        day = nb_day(1,obj.month,obj.year);
        dow = weekday(day);
        if dow ~= obj.dayOfWeek
            corr = obj.dayOfWeek;
            if obj.dayOfWeek < dow
                corr = corr + 7;
            end
            add = corr - dow;
            day = day + add;
        end
        
    elseif first
        day = nb_day(1,obj.month,obj.year);
    else
        day = nb_day(obj.getNumberOfDays(),obj.month,obj.year);
    end
    day.dayOfWeek = obj.dayOfWeek;
    
end

%==========================================================================
function day = getFirstBusinessDay(obj)

    switch obj.month
        case 1
            day = nb_day(2,obj.month,obj.year);
            if day.weekday == 7
                day = day + 2;
            elseif day.weekday == 1
                day = day + 1;
            end
        case {2,3,7,8,9,10,11,12}
            day = nb_day(1,obj.month,obj.year);
            if day.weekday == 7
                day = day + 2;
            elseif day.weekday == 1
                day = day + 1;
            end
        case {4,5,6}
            day   = nb_day(1,obj.month,obj.year);
            hDays = holidays(obj);
            if numel(hDays) == 0
                if day.weekday == 7
                    day = day + 2;
                elseif day.weekday == 1
                    day = day + 1;
                end
            else
                while any(day == hDays) || any(day.weekday == [7,1])
                    day = day + 1;
                end
            end
            
    end 

end
