function numberOfDaysUntilNowInMonth = getNumberOfDaysUntilNowInMonth(obj)
% Syntax:
% 
% numberOfDaysUntilNowInMonth = getNumberOfDaysUntilNowInMonth(obj)
% 
% Description:
%  
% Get the number of days in the current month
% 
% Input:
% 
% - obj : An object of class nb_day
% 
% Output:
% 
% - numberOfDaysUntilNowInMonth : Number of days of the current 
%                                 month of the date object.
%                                 
% Examples:
% 
% ret = obj.getNumberOfDaysUntilNowInMonth(); 
% 
% Written by Kenneth S. Paulsen                              

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    switch obj.month

        case {1,3,5,7,8,10,12}

            numberOfDaysUntilNowInMonth = 31;

        case {4,6,9,11}

            numberOfDaysUntilNowInMonth = 30;

        case 2

            if obj.leapYear
                numberOfDaysUntilNowInMonth = 29;
            else
                numberOfDaysUntilNowInMonth = 28;
            end

    end

end
