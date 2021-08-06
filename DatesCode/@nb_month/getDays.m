function days = getDays(obj)
% Syntax:
% 
% days = getDays(obj)
%
% Description:
%  
% Get all the days of the given month as a cell of nb_day
% objects
% 
% Input:
% 
% - obj  : An object of class nb_month
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

    switch obj.month
        case {1,3,5,7,8,10,12}
            days = days31(obj);
        case {4,6,9,11}
            days = days30(obj);
        case 2
            days = daysFebruary(obj);
    end

end
