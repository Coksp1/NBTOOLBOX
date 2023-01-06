function ret = le(obj,aObj)
% Syntax:
% 
% ret = le(obj,aObj)
%
% Description:
%   
% Tests if an object is less then or equal to another object. 
% Which  will mean that the first input is before or the same as 
% the second input in the calendar.
% 
% Input:
% 
% - obj   : An object of class nb_month
% 
% - aObj  : An object of class nb_month
% 
% Output:
% 
% - ret   : 1 if obj <= aObj, 0 else
%     
% Examples:
%
% ret = obj <= aObj;
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    try
        ret = [obj.monthNr] <= [aObj.monthNr];
    catch 
        error([mfilename ':: It is not possible to test if a object of class ' class(obj) ' is less then a object of class ' class(aObj) '.']) 
    end

end
