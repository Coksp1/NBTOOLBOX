function obj = setDayOfWeek(obj,dayOfWeek)
% Syntax:
%
% obj = setDayOfWeek(obj,dayOfWeek)
%
% Description:
%
% Set the day of week number of a set of nb_date objects.
% 
% Input:
% 
% - obj : A nb_date object. May be a vector or matrix.
% 
% Output:
% 
% - obj : A nb_date object with the same size as the obj input.
%
% See also:
% nb_date.dayOfWeek
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [obj.dayOfWeek] = deal(dayOfWeek);

end
