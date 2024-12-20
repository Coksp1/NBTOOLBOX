function numberOfWeeks = getNumberOfWeeks(obj)
% Syntax:
% 
% numberOfWeeks = getNumberOfWeeks(obj)
%
% Description:
%  
% Get the number of weeks in the given month
%        
% Input:
%         
% - obj          : An object of class nb_month
%
% Output:
%        
% - numberOfWeeks : The number of weeks, given as double
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    startWeek     = getWeek(obj,true);
    lastWeek      = getWeek(obj,false);
    numberOfWeeks = (lastWeek - startWeek) + 1;

end
