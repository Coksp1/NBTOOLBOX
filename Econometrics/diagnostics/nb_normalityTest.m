function [stat,pval] = nb_normalityTest(y,k)
% Syntax:
%
% [stat,pval] = nb_normalityTest(residual)
% [stat,pval] = nb_normalityTest(residual,k)
%
% Description:
%
% This is the Jarque-Bera test, which test for normality. Null hypothesis
% of the test is that the series y is normal.
%
% Input:
% 
% - residual : A nobs x neq double.
% 
% - k        : Number of estimated parameters of the model.
%
% Output:
% 
% - stat     : The test-statistic. As a 1 x neq double.
%
% - pval     : The p-values. As a 1 x neq double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        k = 0;
    end

    n    = size(y,1);
    D1   = skewness(y,1);
    D2   = kurtosis(y,1);
    stat = (n - k + 1)/6*(D1.^2) + (n - k + 1)/24*(D2 - 3).^2;
    pval = 1 - chi2cdf(stat,2);

end





