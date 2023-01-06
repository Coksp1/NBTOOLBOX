function months = getMonths(obj)
% Syntax:
% 
% months = getMonths(obj)
%
% Description:
%   
% Get all the months of the given year as a cell of nb_month
% objects
% 
% Input:
% 
% - obj    : An object of class nb_year
% 
% Output:
% 
% - months : A cell array of nb_month objects
% 
% Examples:
%
% months = obj.getMonths();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    months = cell(1,12); 
    for ii = 1:12
        months{ii}           = nb_month(ii,obj.year);
        months{ii}.dayOfWeek = obj.dayOfWeek;
    end  

end
