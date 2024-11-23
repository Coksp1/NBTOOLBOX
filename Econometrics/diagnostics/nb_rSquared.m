function [rSquared,adjRSquared] = nb_rSquared(y,residual,numCoeff)
% Syntax:
%
% [rSquared,adjRSquared] = nb_rSquared(y,x,beta)
%
% Description:
%
% Calculate R-Squared and/or adjusted R-Squared of (an) estimated
% equation(s).
%
% Inspired by the vare function of LeSage.
%
% Input:
% 
% - y         : A double vector with the dependent variable of the 
%               regression. A double matrix nobs x neqs.
%
% - residual  :  The residual of the regression. A double vector 
%                nobs x neqs.
%
% - numCoeff  : The number of estimated parameters of the model. 
%               As 1 x neqs double.
% 
% Output: 
% 
% - rSquared    : As 1 x neqs double.
%
% - adjRSquared : As 1 x neqs double.
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    T = size(residual,1);

    % R-Squared
    sigu     = diag(residual'*residual)';
    ym       = y - repmat(mean(y,1),T,1);
    rsqr1    = sigu;
    rsqr2    = diag(ym'*ym)';
    rSquared = 1.0 - rsqr1./rsqr2;

    % Adjusted R-squared
    rsqr1            = rsqr1./(T - numCoeff);
    rsqr2            = rsqr2/(T - 1.0);
    ind              = rsqr2 ~= 0;
    adjRSquared      = rSquared;
    adjRSquared(ind) = 1 - (rsqr1(ind)./rsqr2(ind)); 

end
