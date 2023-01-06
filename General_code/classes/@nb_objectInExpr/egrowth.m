function obj = egrowth(obj,~,~)
% Syntax:
%
% obj = egrowth(obj,lag,stripNaN)
%
% Description:
%
% Calculate exact growth, using the formula: (x(t) - x(t-1))/x(t-1).
% 
% Input:
% 
% - obj      : An object of class nb_objectInExpr
% 
% - lag      : Any
% 
% - stripNaN : Any
% 
% Output:
% 
% - obj      : An nb_objectInExpr object.
% 
% Examples:
%
% obj = egrowth(obj);
% obj = egrowth(obj,4);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

end
