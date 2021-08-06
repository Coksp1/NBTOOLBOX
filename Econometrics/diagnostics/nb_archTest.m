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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    residual    = residual.^2;
    [stat,pval] = nb_autocorrTest(residual,lags);
    
end
