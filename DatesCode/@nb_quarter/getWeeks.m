function weeks = getWeeks(obj,dayOfWeek)
% Syntax:
% 
% weeks = getWeeks(obj,dayOfWeek)
%
% Description:
%   
% Get all the weeks of the given quarter as a cell of nb_week
% objects
% 
% Input:
% 
% - obj       : An object of class nb_quarter
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
% quarter = nb_quarter(1,2020);
% weeks   = quarter.getWeeks();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin > 1
        obj.dayOfWeek = dayOfWeek;
    end
    week    = getWeek(obj,true);
    numWeek = getNumberOfWeeks(obj);
    weeks   = cell(1,numWeek); 
    for ii = 1:numWeek-1
        weeks{ii} = week;
        week      = week + 1;
    end  
    weeks{end} = week;

end
