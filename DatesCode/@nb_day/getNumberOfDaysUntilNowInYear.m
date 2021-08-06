function numberOfDaysUntilNowInYear = getNumberOfDaysUntilNowInYear(obj)
% Syntax:
% 
% numberOfDaysUntilNowInYear = getNumberOfDaysUntilNowInYear(obj)
%
% Description:
% 
% Get the number of days until now in the current year
% 
% Input:
% 
% - obj : An nb_day object
% 
% Output:
% 
% - numberOfDaysUntilNowInYear : Number of days until now in the
%                                current year as a double.
%                                
% Examples:
% 
% ret = obj.getNumberOfDaysUntilNowInYear();
% 
% Written by Kenneth S. Paulsen                             

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch obj.month

        case 1
            numberOfDaysUntilNowInYear = 0;  
        case 2 
            numberOfDaysUntilNowInYear = 31;
        case 3
            numberOfDaysUntilNowInYear = 59; 
        case 4
            numberOfDaysUntilNowInYear = 90;
        case 5
            numberOfDaysUntilNowInYear = 120;
        case 6  
            numberOfDaysUntilNowInYear = 151; 
        case 7 
            numberOfDaysUntilNowInYear = 181;
        case 8 
            numberOfDaysUntilNowInYear = 212;
        case 9
            numberOfDaysUntilNowInYear = 243;    
        case 10
            numberOfDaysUntilNowInYear = 273;
        case 11
            numberOfDaysUntilNowInYear = 304;
        case 12
            numberOfDaysUntilNowInYear = 334;    

    end

    if obj.leapYear && obj.month >= 3

        numberOfDaysUntilNowInYear = numberOfDaysUntilNowInYear + 1;

    end

    numberOfDaysUntilNowInYear = numberOfDaysUntilNowInYear + obj.day;

end
