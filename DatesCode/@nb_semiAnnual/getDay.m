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
% - obj   : An object of class nb_semiAnnual
%         
% - first : 1 : first day
%           0 : last day
%           2 : The first day that match the dayOfWeek property.
%           3 : The last day that match the dayOfWeek property.
%                 
% Output:
%         
% - day   : An nb_day object
% 
% Examples:
%
% obj = nb_semiAnnual(1,2020);
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

    if first == 3
        month = getMonth(obj,false);
        day   = getDay(month,first);
    elseif first == 2
        month = getMonth(obj,true);
        day   = getDay(month,first);
    elseif first
        day = nb_day(1,obj.halfYear*6 - 5,obj.year);
    else
        day = nb_day(nb_month(obj.halfYear*6,obj.year).getNumberOfDays(),obj.halfYear*6,obj.year);
    end
    day.dayOfWeek = obj.dayOfWeek;

end
