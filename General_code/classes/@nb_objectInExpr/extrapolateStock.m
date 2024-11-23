function obj = extrapolateStock(obj,flow,~)
% Syntax:
%
% obj = extrapolateStock(obj,flow,depreciation)
%
% Description:
%
% Extrapolate stock with the flow from where the stock ends.
% 
% Input:
% 
% - obj          : An object of class nb_objectInExpr
% 
% - flow         : Any
% 
% - depreciation : Any
% 
% Output:
% 
% - obj          : An object of class nb_objectInExpr
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.date = nb_date.max(obj.date,flow.date);

end
