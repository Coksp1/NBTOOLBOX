function numberOfDaysInQuarter = getNumberOfDays(obj)
% Syntax:
% 
% numberOfDaysInQuarter = getNumberOfDaysInMonth(obj)
%
% Description:
%  
% Get the number of days in the given quarter
%        
% Input:
%         
% - obj       : An object of the class nb_quarter
% 
% Output:
%        
% - numberOfDaysInQuarter : Returns the number of days in the 
%                           current quarter
%
% Examples:
%
% numberOfDays = obj.getNumberOfDaysInMonth();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

	switch obj.quarter
        case 1
            if obj.leapYear
                numberOfDaysInQuarter = 91;
            else
                numberOfDaysInQuarter = 90;
            end
        case 2
            numberOfDaysInQuarter = 91;
        case 3
            numberOfDaysInQuarter = 92;
        case 4
            numberOfDaysInQuarter = 92;
	end
            
end 
