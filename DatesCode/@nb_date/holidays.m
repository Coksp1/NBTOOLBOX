function days = holidays(obj)
% Syntax:
%
% days = holidays(obj)
%
% Description:
%
% Find the holidays of the given date object.
% 
% Input:
% 
% - obj : An object of class nb_month, nb_quarter, nb_semiAnnual or 
%         nb_year.
% 
% Output:
% 
% - days : All the holidays as a vector of nb_day objects.
%
% See also:
% nb_date.easter, nb_date.ascensionDay, nb_date.pentecost,
% nb_date.christmas
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This function only handle a scalar object of class ',...
                         'nb_month, nb_quarter, nb_semiAnnual or nb_year.'])
    end

    if isa(obj,'nb_year')
        
        days(1,11)    = nb_day();
        days(1,1)     = nb_day(1,1,obj.year);
        days(1,2:5)   = easter(obj,'all');
        days(1,6)     = nb_day(1,5,obj.year);
        days(1,7)     = ascensionDay(obj);
        days(1,8)     = pentecost(obj);
        days(1,9)     = nb_day(17,5,obj.year);
        days(1,10:11) = christmas(obj);
        days          = sort(days);
        
    elseif isa(obj,'nb_semiAnnual')
        
        if obj.halfYear == 1
            days(1,9)   = nb_day(17,5,obj.year);
            days(1,1)   = nb_day(1,1,obj.year);
            days(1,2:5) = easter(obj,'all');
            days(1,6)   = nb_day(1,5,obj.year);
            days(1,7)   = ascensionDay(obj);
            days(1,8)   = pentecost(obj);
            days        = sort(days);
        else
            days = christmas(obj);
        end
        
    elseif isa(obj,'nb_quarter')
        
        if obj.quarter == 1
            days = nb_day(1,1,obj.year);
            e    = easter(obj,'all');
            ind  = [e.quarter] == 1;
            days = [days,e(ind)];
        elseif obj.quarter == 2
            
            days(1,8)   = nb_day(17,5,obj.year);
            days(1,1:4) = easter(obj,'all');
            days(1,5)   = nb_day(1,5,obj.year);
            days(1,6)   = ascensionDay(obj);
            days(1,7)   = pentecost(obj);
            ind         = [days.quarter] == 2;
            days        = days(ind);
            days        = sort(days);
        elseif obj.quarter == 4
            days = christmas(obj);
        else
            days = [];
        end
        
    elseif isa(obj,'nb_month')
        
        if obj.month == 1
            days = nb_day(1,1,obj.year);
        elseif obj.month == 3
            days = easter(obj,'all');
            ind  = [days.month] == 3;
            days = days(ind);
        elseif obj.month == 4
            days(1,5)   = ascensionDay(obj);
            days(1,1:4) = easter(obj,'all');
            ind         = [days.month] == 4;
            days        = days(ind);
        elseif obj.month == 5
            
            days(1,4) = nb_day(17,5,obj.year);
            days(1,1) = nb_day(1,5,obj.year);
            days(1,2) = ascensionDay(obj);
            days(1,3) = pentecost(obj);
            ind       = [days.month] == 5;
            days      = days(ind);
            days      = sort(days);
            
        elseif obj.month == 6
            days = pentecost(obj);
            ind  = [days.month] == 6;
            days = days(ind);
        elseif obj.month == 12
            days = christmas(obj);
        else
            days = [];
        end
        if numel(days) == 0
            days = [];
        end
        
    else
        error([mfilename ':: This function only handle a scalar object of class ',...
                         'nb_month, nb_quarter, nb_semiAnnual or nb_year.'])
    end

end
