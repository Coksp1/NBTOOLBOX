function numberOfWeeks = getNumberOfWeeks(obj)
% Syntax:
% 
% numberOfWeeks = getNumberOfWeeks(obj)
%
% Description:
%  
% Get the number of weeks in the given half year
%        
% Input:
%         
% - obj          : An object of class nb_semiAnnual
%
% Output:
%        
% - numberOfWeeks : The number of weeks, given as double
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if obj.halfYear == 1
        
        numberOfWeeks = 26;
        
    else
    
        if nb_week.hasLeapWeek(obj.year)
            numberOfWeeks = 27;
        else
            numberOfWeeks = 26;
        end 
        
    end

end
