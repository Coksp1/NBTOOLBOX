function numberOfDaysInMonth = getNumberOfDays(obj)
% Syntax:
% 
% numberOfDays = getNumberOfDays(obj)
%
% Description:
%  
% Get the number of days in the given month
%        
% Input:
%         
% - obj          : An object of class nb_month
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    switch obj.month

        case {1,3,5,7,8,10,12}

            numberOfDaysInMonth = 31;

        case {4,6,9,11}

            numberOfDaysInMonth = 30;

        case 2

            if obj.leapYear
                numberOfDaysInMonth = 29;
            else
                numberOfDaysInMonth = 28;
            end

    end

end
