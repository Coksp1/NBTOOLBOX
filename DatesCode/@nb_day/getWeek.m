function week = getWeek(obj,dayOfWeek)
% Syntax:
% 
% week = getWeek(obj,dayOfWeek)
%
% Description:
% 
% Get the week of the day, given as an nb_week object
%         
% Input:
%         
% - obj       : An object of class nb_day       
%                 
% - dayOfWeek : The weekday the given week represents when 
%               converted to a day. (1-7 (Monday-Sunday)). Default
%               is to use the weekday(obj).
%
% Output:
%         
% - week  : An nb_week object
% 
% Examples:
%
% week = obj.getWeek();    % Will return the week of the day
% 
% Written by Kenneth S. Paulsen
       
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        dayOfWeek = [];
    end
    
    if numel(obj) > 1
        siz        = size(obj);
        obj        = obj(:);
        s          = prod(siz);
        week(1,s)  = nb_week;
        for ii = 1:s  
            week(ii) = getWeek(obj(ii),dayOfWeek);
        end
        week = reshape(week,siz);
        return
    end

    [weekNum,dow,yearN] = getWeekNumber(obj);
    if isempty(dayOfWeek)
        dayOfWeek = dow;
    end
    week = nb_week(weekNum,yearN,dayOfWeek);
   
end
