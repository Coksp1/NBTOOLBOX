function dwtest = nb_durbinWatson(y,x,beta)
% Syntax:
%
% dwtest = nb_durbinWatson(residual)
% dwtest = nb_durbinWatson(y,x,beta)
%
% Description:
%
% Durbin-Watson Statistic.
% 
% Input:
% 
% - y  : The dependent variable as a double or the residual if only
%        one input is provided. Must be a nobs x neqs double.
%
% - x  : The right hand side variables of the regression. Must be a 
%        nobs x neqs double.
%
% - beta : Estimated coefficients. As a ncoeff x neqs double.
% 
% Output:
% 
% - dwtest : Durbin-Watson Statistic. A 1 x neqs double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin == 1
        resid = y;
    else
        resid = y - x*beta;
    end

    T = size(resid,1);
    
    % Durbin-Watson
    sigu   = diag(resid'*resid);
    ediff  = resid(2:T,:) - resid(1:T-1,:);
    dwtest = diag(ediff'*ediff)./sigu; 
    dwtest = dwtest';
    
end
