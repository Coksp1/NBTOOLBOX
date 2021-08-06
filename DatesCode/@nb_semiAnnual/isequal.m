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
% - obj   : An object of class nb_semiAnnual
% 
% - aObj  : Another object of class nb_semiAnnual
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
        ret = [obj.halfYearNr] == [aObj.halfYearNr];
    catch 
        error([mfilename ':: It is not possible to test if a object of class ' class(obj) ' is equal to a object of class ' class(aObj) '.'])
    end

end
