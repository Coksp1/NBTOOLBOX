function months = getMonths(obj)
% Syntax:
% 
% months = getMonths(obj)
%
% Description:
%   
% Get all the months of the given half year as a cell of nb_month
% objects
% 
% Input:
% 
% - obj    : An object of class nb_semiAnnual
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    months = cell(1,6); 
    for ii = 1:6
        months{ii}           = nb_month(ii + (obj.halfYear - 1)*6,obj.year);
        months{ii}.dayOfWeek = obj.dayOfWeek;
    end   

end
