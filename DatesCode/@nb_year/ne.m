function ret = ne(obj,aObj)
% Syntax:
% 
% ret = ne(obj,aObj)
%
% Description:
%   
% Tests if the two objects not representing the same date
% 
% Input:
% 
% - obj   : An object of class nb_year
% 
% - aObj  : An object of class nb_year
% 
% Output:
% 
% - ret   : 1 if obj is not equal to aObj, 0 else
%     
% Examples:
% 
% ret = obj ~= aObj;
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    try
        ret = [obj.yearNr] ~= [aObj.yearNr];
    catch 
        error([mfilename ':: It is not possible to test if a object of class ' class(obj) ' is not equal to a object of class ' class(aObj) '.']) 
    end

end

