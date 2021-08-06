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
% ret = obj == aObj;
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    try
        ret = eq([obj.halfYearNr],[aObj.halfYearNr]);
    catch
        error('Matrix dimensions must agree.')
    end

end
