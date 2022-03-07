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
% - obj   : An object of class nb_month
% 
% - aObj  : Another object of class nb_month
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    try
        ret = eq([obj.monthNr],[aObj.monthNr]);
    catch
        error('Matrix dimensions must agree.')
    end

end
