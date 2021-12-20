function [stat,pval] = nb_LMVARTest(residual,X,j)
% Syntax:
%
% [stat,pval] = nb_LMVARTest(residual,X,j)
%
% Description:
%
% Test for autocorrelation of residuals of a VAR model using the 
% LM test. See section 4.3.3 of Juselius (2006).
%
% Auxiliary regression:
% residual(t) = A*X(t) + B*residual_(t-j) + u(t)
%
% Input:
% 
% - residual : A nobs x neq double with the residuals.
%
% - X        : The models regressors, as a nobs x nxvar double. Should not
%              include the constant!
%
% - j        : The lag (of the residual) to include in the auxiliary 
%              regression.
%
% Output:
% 
% - stat     : The test-statistics.
%
% - pval     : The p-value.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [T,p]       = size(residual);
    k           = size(X,2)/p;
    resLag      = lag(residual,j);
    ind         = isnan(resLag);
    resLag(ind) = 0;
    Z           = [X,resLag];
    [~,~,~,~,u] = nb_ols(residual,Z,0,0);
    SIGMA       = (residual'*residual)/T;
    SIGMAJ      = (u'*u)/T;
    stat        = -(T - p*(k + 1) -0.5)*log(det(SIGMAJ)/det(SIGMA));
    pval        = 1 - nb_distribution.chis_cdf(stat,p^2);
    
end
