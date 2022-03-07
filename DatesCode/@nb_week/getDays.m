function days = getDays(obj)
% Syntax:
% 
% days = getDays(obj)
%
% Description:
%  
% Get all the days of the given week as a cell of nb_day
% objects
% 
% Input:
% 
% - obj  : An object of class nb_week
% 
% Output:
% 
% - days : A cell array of nb_day objects
% 
% Examples:
%
% days = obj.getDays();
% 
% Written by Kenneth S. Paulsen
       
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    days = cell(1,7);
    for ii = 1:6 
        dayT               = nb_week.getXLSDate(obj.week,ii + 1,obj.year,false);
        dayT               = dayT{1};
        days{ii}           = nb_day(dayT);
        days{ii}.dayOfWeek = obj.dayOfWeek;
    end
    dayT                = nb_week.getXLSDate(obj.week,1,obj.year,false);
    dayT                = dayT{1};
    days{end}           = nb_day(dayT);
    days{end}.dayOfWeek = obj.dayOfWeek;
            
end
