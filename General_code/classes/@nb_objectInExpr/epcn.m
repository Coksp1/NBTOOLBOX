function obj = epcn(obj,~,~)
% Syntax:
%
% obj = epcn(obj,lag,stripNaN)
%
% Description:
%
% Calculate exact percentage growth, using the formula: 
% 100*(x(t) - x(t-1))/x(t-1).
% 
% Input:
% 
% - obj       : An object of class nb_objectInExpr
% 
% - lag       : Any
% 
% - stripNaN  : Any
% 
% Output:
% 
% - obj       : An nb_objectInExpr object.
% 
% Examples:
%
% obj = epcn(obj);   % period-on-period growth
% obj = epcn(obj,4); % 4-periods growth
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

end
