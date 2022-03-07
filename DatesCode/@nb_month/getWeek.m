function week = getWeek(obj,first,dayOfWeek)
% Syntax:
% 
% week = getWeek(obj,first,dayOfWeek)
%
% Description:
% 
% Get the first or last week of the month, given as a nb_week 
% object.
%         
% Input:
%         
% - obj       : An object of class nb_month
%         
% - first     : 1 : First week
%               0 : Last week
%                 
% - dayOfWeek : The weekday the given week represents when 
%               converted to a day. (1-7 (Monday-Sunday)). Default
%               is to use the dayOfWeek property.
%
% Output:
%         
% - week  : An nb_week object
% 
% Examples:
%
% week = obj.getWeek();    % Will return the first week of the year
% week = obj.getWeek(0);   % Will return the last week of the year
% 
% Written by Kenneth S. Paulsen
       
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        dayOfWeek = obj.dayOfWeek;
        if nargin < 2
            first = 1;
        end
    end
    
    if numel(obj) > 1
        siz        = size(obj);
        obj        = obj(:);
        s          = prod(siz);
        week(1,s)  = nb_week;
        for ii = 1:s  
            week(ii) = getWeek(obj(ii),first,dayOfWeek);
        end
        week = reshape(week,siz);
        return
    end
    
    if first 
        day = getDay(obj,2);
    else
        day = getDay(obj,3);
    end
    week           = getWeek(day);
    week.dayOfWeek = dayOfWeek;
    
end
