function numberOfDaysInMonth = getNumberOfDaysInMonth(month,leapYear)
% Syntax:
% 
% numberOfDays = nb_day.getNumberOfDaysInMonth(month,leapYear)
%
% Description:
%
% A static method of the class nb_day.
%  
% Get the number of days in the given month
%        
% Input:
%         
% - month     : An object of the class nb_day
% 
% - leapYear  : 1 if leapYear, 0 else
% 
% Output:
%        
% - numberOfDaysInMonth : Returns the number of days in the current
%                         month
%
% Examples:
%
% numberOfDays = nb_day.getNumberOfDaysInMonth(2,1); % returns 29
% numberOfDays = nb_day.getNumberOfDaysInMonth(2,0); % returns 28
% numberOfDays = nb_day.getNumberOfDaysInMonth(3,1); % returns 31
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch month

        case {1,3,5,7,8,10,12}

            numberOfDaysInMonth = 31;

        case {4,6,9,11}

            numberOfDaysInMonth = 30;

        case 2

            if leapYear
                numberOfDaysInMonth = 29;
            else
                numberOfDaysInMonth = 28;
            end

    end

end
