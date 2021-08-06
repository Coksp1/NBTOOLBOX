function numberOfDaysInHalfYear = getNumberOfDays(obj)
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
% - obj          : An object of class nb_semiAnnual
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

    switch obj.halfYear
        case 1
            if obj.leapYear
                numberOfDaysInHalfYear = 182;
            else
                numberOfDaysInHalfYear = 181;
            end
        case 2
            numberOfDaysInHalfYear = 184;

    end
end 
