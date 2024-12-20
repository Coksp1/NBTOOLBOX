function ret = eq(obj,aObj)
% Syntax:
% 
% ret = eq(obj,aObj)
%
% Description:
%
% Tests if the two objects representing the same dates
% 
% Input:
% 
% - obj   : An object of class nb_year
% 
% - aObj  : Another object of class nb_year
% 
% Output:
% 
% - ret   : 1 if equal, 0 else
%     
% Examples:
%
% ret = obj == aObj;
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    try
        ret = eq([obj.yearNr],[aObj.yearNr]);
    catch
        error('Matrix dimensions must agree.')
    end

end
