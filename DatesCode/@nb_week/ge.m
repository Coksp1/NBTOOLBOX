function ret = ge(obj,aObj)
% Syntax:
%
% ret = ge(obj,aObj)
%
% Description:
%
% Tests if an object is greater than or equal to another object. 
% Which  will mean that the first input is after or the same 
% as the second input in the calendar
% 
% Input:
% 
% - obj   : An object of class nb_week
% 
% - aObj  : Another object of class nb_week
% 
% Output:
% 
% - ret   : 1 if obj >= aObj, 0 else
%     
% Examples:
%
% ret = obj >= aObj;
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    try
        ret = [obj.weekNr] >= [aObj.weekNr];
    catch
        error([mfilename ':: It is not possible to test if a object of class ' class(obj) ' is greater then a object of class ' class(aObj) '.']) 
    end

end
