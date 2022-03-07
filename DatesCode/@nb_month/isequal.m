function ret = isequal(obj,aObj)
% Syntax:
% 
% ret = isequal(obj,aObj)
%
% Description:
%   
% Tests if the two objects representing the same date
% 
% Input:
% 
% - obj   : an object of class nb_month
% 
% - aObj  : another object of class nb_month
% 
% Output:
% 
% - ret   : 1 if equal, 0 else
%     
% Examples:
%
% ret = obj.isequal(aObj);
% ret = isequal(obj,aObj);
% 
% Written by Kenneth S. Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    try
        ret = [obj.monthNr] == [aObj.monthNr];
    catch 
        error([mfilename ':: It is not possible to test if an object of class ' class(obj) ' is equal to an object of class ' class(aObj) '.'])
    end

end
