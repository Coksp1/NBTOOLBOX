function weeks = getWeeks(obj,dayOfWeek)
% Syntax:
% 
% weeks = getWeeks(obj,dayOfWeek)
%
% Description:
%   
% Get all the weeks of the given year as a cell of nb_week
% objects
% 
% Input:
% 
% - obj       : An object of class nb_year
%                 
% - dayOfWeek : The weekday the given week represents when 
%               converted to a day. (1-7 (Monday-Sunday)). Default
%               is to use the dayOfWeek property.
% 
% Output:
% 
% - weeks     : A cell array of nb_week objects
% 
% Examples:
%
% year  = nb_year(2020);
% weeks = year.getWeeks();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        dayOfWeek = obj.dayOfWeek;
    end
    
    if nb_week.hasLeapWeek(obj.year)
        numweek = 53;
    else
        numweek = 52;
    end

    weeks = cell(1,numweek); 
    for ii = 1:numweek
        weeks{ii} = nb_week(ii,obj.year,dayOfWeek);
    end  

end
