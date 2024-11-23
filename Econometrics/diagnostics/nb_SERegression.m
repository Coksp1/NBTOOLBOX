function [SERegression,sumOfSqRes] = nb_SERegression(residual,numCoeff)
% Syntax:
%
% [SERegression,sumOfSqRes] = nb_SERegression(residual,numCoeff)
%
% Description:
%
% Calculates the Standard Error of the Regression and the 
% Sum-of-Squared Residuals.
% 
% Input:
% 
% - residual : The residuals from the ols regression. As a 
%              nobs x neqs double.
%
% - numCoeff : The number of estimated coefficients of the model.
%              As a 1 x neqs double.
% 
% Output:
% 
% - SERegression : Standard Error of the Regression. As a double. 
%
%                  Calculated using the formula:
%
%                  s = sqrt(residual'*residual/(T-numCoeff))
%
% - sumOfSqRes  : Sum-of-Squared Residuals
%
%                  S = residual'*residual 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    sumOfSqRes   = diag(residual'*residual)';
    T            = size(residual,1);
    SERegression = sqrt(sumOfSqRes./(T-numCoeff));

end
