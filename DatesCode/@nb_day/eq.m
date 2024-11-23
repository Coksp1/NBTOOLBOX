function ret = eq(obj,aObj)
% Syntax:
% 
% ret = eq(obj,aObj)
%
% Description:
%
% Tests if the two objects represent the same dates
% 
% Input:
% 
% - obj   : An object of class nb_day
% 
% - aObj  : Another object of class nb_day
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
        ret = eq([obj.dayNr],[aObj.dayNr]);
    catch
        error('Matrix dimensions must agree.')
    end

end
