function week = getWeek(obj,first,dayOfWeek)
% Syntax:
% 
% week = getWeek(obj,first,dayOfWeek)
%
% Description:
% 
% Get the first or last week of the half year, given as an nb_week 
% object
%         
% Input:
%         
% - obj       : An object of class nb_semiAnnual
%         
% - first     : 1 : first day
%               0 : last day
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
       
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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

    if obj.halfYear == 1
    
        if first
            week = nb_week(1,obj.year,dayOfWeek);
        else
            week = nb_week(26,obj.year,dayOfWeek);
        end
        
    else
        
        if first
            week = nb_week(27,obj.year,dayOfWeek);
        else
            if nb_week.hasLeapWeek(obj.year)
                week = nb_week(53,obj.year,dayOfWeek);
            else
                week = nb_week(52,obj.year,dayOfWeek);
            end
        end
        
    end

end
