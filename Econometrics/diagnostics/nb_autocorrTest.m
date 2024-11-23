function [stat,pval] = nb_autocorrTest(residual,lags)
% Syntax:
%
% [stat,pval] = nb_autocorrTest(residual,lags)
%
% Description:
%
% Test for autocorrelation of residuals from a regression.
% 
% Input:
% 
% - residual : A nobs x neq double with the residuals.
%
% - lags     : The number of lags of the test.
%
% Output:
% 
% - stat     : The test-statistics.
%
% - pval     : The p-value.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Perform the regression:
    [N,numTests] = size(residual);
    stat         = zeros(1,numTests);
    for order = 1:numTests
        X           =  [ones(N,1),nb_mlag(residual(:,order),lags)];
        X           =  X(lags+1:end,:);  
        y           =  residual(lags+1:end,order); 
        yHat        =  X*(X\y);                
        T           =  N - lags;           
        yHat        =  yHat - sum(yHat)/T;        
        y           =  y - sum(y)/T;              
        stat(order) =  (yHat'*yHat)/(y'*y);  % This is R^2
    end

    % Compute p-values:
    stat = (N-lags)*stat;
    pval = 1 - nb_distribution.chis_cdf(stat,lags);

end
