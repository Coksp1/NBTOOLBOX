function halfYears = getHalfYears(obj)
% Syntax:
% 
% halfYears = getHalfYears(obj)
%
% Description:
%  
% Get all the half years of the given year as a cell of 
% nb_semiAnnual objects
% 
% Input:
% 
% - obj       : An object of class nb_year
% 
% Output:
% 
% - halfYears : A cell array of nb_semiAnnual objects
% 
% Examples:
%
% halfYears = obj.getHalfYears();
% 
% Written by Kenneth S. Paulsen       

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    halfYears = cell(1,2); 
    for ii = 1:2
        halfYears{ii}           = nb_semiAnnual(ii,obj.year);
        halfYears{ii}.dayOfWeek = obj.dayOfWeek;
    end  

end
