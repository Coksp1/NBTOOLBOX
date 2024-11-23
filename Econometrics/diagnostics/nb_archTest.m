function [stat,pval] = nb_archTest(residual,lags)
% Syntax:
%
% [stat,pval] = nb_archTest(residual,lags)
%
% Description:
%
% Arch test of residuals from a regression.
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

    residual    = residual.^2;
    [stat,pval] = nb_autocorrTest(residual,lags);
    
end
