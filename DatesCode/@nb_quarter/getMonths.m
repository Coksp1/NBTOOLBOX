function months = getMonths(obj)
% Syntax:
% 
% months = getMonths(obj)
%
% Description:
%   
% Get all the months of the given quarter as a cell array of 
% nb_month objects
% 
% Input:
% 
% - obj    : An object of class nb_quarter
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

	months = cell(1,3); 
	for ii = 1:3		
		months{ii}           = nb_month(ii + (obj.quarter - 1)*3,obj.year);	
        months{ii}.dayOfWeek = obj.dayOfWeek;
	end   
            
end
