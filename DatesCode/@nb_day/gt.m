function ret = gt(obj,aObj)
% Syntax:
% 
% ret = gt(obj,aObj)
%
% Description:
%   
% Tests if an object is greater than an another object. Which 
% will mean that the first input is after the second input in the
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
% - ret   : 1 if obj > aObj, 0 else
%     
% Examples:
%
% ret = obj > aObj;
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    try
        ret = [obj.dayNr] > [aObj.dayNr];
    catch Err
        error([mfilename ':: It is not possible to test if a object of class ' class(obj) ' is greater then a object of class ' class(aObj) '.']) 
    end

end
