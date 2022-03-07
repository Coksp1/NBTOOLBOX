function ret = eq(obj,aObj)
% Syntax:
% 
% ret = eq(obj,aObj)
%
% Description:
%
% Tests if the two objects represent the same date
% 
% Input:
% 
% - obj   : An object of class nb_quarter
% 
% - aObj  : Another object of class nb_quarter
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
        ret = eq([obj.quarterNr],[aObj.quarterNr]);
    catch
        error('Matrix dimensions must agree.')
    end

end
