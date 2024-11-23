function allDates = dates(obj)
% Syntax:
%
% allDates = dates(obj)
%
% Description:
%
% Get all the dates of the nb_math_ts object
% 
% Input:
% 
% - obj       : An object of class nb_math_ts
% 
% Output:
% 
% - allDates  : A cellstr with the dates of the object
% 
% Examples:
% 
% allDates = obj.dates();
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    allDates = obj.startDate:obj.endDate;

end
