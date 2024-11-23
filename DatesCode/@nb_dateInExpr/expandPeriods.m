function obj = expandPeriods(obj,periods,~)
% Syntax:
%
% obj = expandPeriods(obj,periods,type)
%
% Description:
%
% This method expands a nb_math_ts object, which means we need to take
% add periods to date.
% 
% Input:
% 
% - obj          : An object of class nb_dateInExpr
% 
% - periods      : The number of periods to expand by. If negative the 
%                  it will be ignored.
% 
% - type         : Any
% 
% Output:
% 
% - obj          : An nb_dateInExpr object.
% 
% Examples:
%
% obj = expandPeriods(obj,2);
% obj = expandPeriods(obj,-2);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if periods > 0
        obj.date = obj.date + periods;
    end
    
end
