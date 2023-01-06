function days = getDays(obj)
% Syntax:
% 
% days = getDays(obj)
%
% Description:
%  
% Get all the days of the given quarter as a cell of nb_day
% objects
% 
% Input:
% 
% - obj  : An object of class nb_quarter
% 
% Output:
% 
% - days : A cell array of nb_day objects
% 
% Examples:
%
% days = obj.getDays();
% 
% Written by Kenneth S. Paulsen
         
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

	days = {};
	for ii = 1:3
		days = [days, nb_month(ii + (obj.quarter - 1)*3,obj.year).getDays()]; %#ok
	end  
            
end
