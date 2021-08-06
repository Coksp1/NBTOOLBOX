function numberOfWeeks = getNumberOfWeeks(obj)
% Syntax:
% 
% numberOfWeeks = getNumberOfWeeks(obj)
%
% Description:
%  
% Get the number of weeks in the given year
%        
% Input:
%         
% - obj          : An object of class nb_year
%
% Output:
%        
% - numberOfWeeks : The number of weeks, given as double
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nb_week.hasLeapWeek(obj.year)
        numberOfWeeks = 53;
    else
        numberOfWeeks = 52; 
    end

end
