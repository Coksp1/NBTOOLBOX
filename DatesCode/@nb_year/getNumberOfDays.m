function numberOfDays = getNumberOfDays(obj)
% Syntax:
% 
% numberOfDays = getNumberOfDays(obj)
%
% Description:
%  
% Get the number of days in the given year
%        
% Input:
%         
% - obj          : An object of class nb_year
%
% Output:
%        
% - numberOfDays : The number of days, given as double
%
% Examples:
%
% numberOfDays = obj.getNumberOfDays();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if obj.leapYear
        numberOfDays = 366;
    else
        numberOfDays = 365; 
    end

end
