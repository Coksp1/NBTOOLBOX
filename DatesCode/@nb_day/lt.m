function ret = lt(obj,aObj)
% Syntax:
% 
% ret = lt(obj,aObj)
%
% Description:
%   
% Tests if an object is less then an another object. Which 
% will mean that the first input is before the second input in the
% calendar
% 
% Input:
% 
% - obj   : An object of class nb_day
% 
% - aObj  : An object of class nb_day
% 
% Output:
% 
% - ret   : 1 if obj < aObj, 0 else
%     
% Examples:
% 
% ret = obj < aObj;
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    try
        ret = [obj.dayNr] < [aObj.dayNr];
    catch 
        error([mfilename ':: It is not possible to test if a object of class ' class(obj) ' is less then a object of class ' class(aObj) '.']) 
    end

end
