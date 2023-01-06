function obj = pcn(obj,~,~)
% Syntax:
%
% obj = pcn(obj,lag,stripNaN)
%
% Description:
%
% Calculate log approximated percentage growth. Using the formula
% (log(t+lag) - log(t))*100
% 
% Input:
% 
% - obj      : An object of class nb_objectInExpr
%
% - lag      : The number of lags. Default is 1.
% 
% - stripNaN : Stip nan before calculating the growth rates.
% 
% Output:
% 
% - obj      : An object of class nb_objectInExpr
% 
% Examples:
% 
% obj = pcn(obj);   % period-on-period log approx. growth
% obj = pcn(obj,4); % 4-periods log approx. growth
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

end
