function [stat,pval] = nb_breuschGodfreyTest(residual,X,lags)
% Syntax:
%
% [stat,pval] = nb_breuschGodfreyTest(residual,X,lags)
%
% Description:
%
% Test for autocorrelation of residuals from a regression using the 
% Breusch-Godfrey test.
% 
% Caution: It will test each equation individually.
%
% Input:
% 
% - residual : A nobs x neq double with the residuals.
%
% - X        : The models regressors, as a nobs x nxvar double. Should not
%              include the constant!
%
% - lags     : Number of lags of the residual in the auxiliary regression.
%
% Output:
% 
% - stat     : The test-statistics.
%
% - pval     : The p-value.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [n, k] = size(X);
    nEq    = size(residual,2);
    stat   = nan(1,nEq);
    X      = X(lags+1:end,:);
    for ii = 1:nEq
    
        % Construct the variables of the auxiliary regression 
        resLag = nb_mlag(residual(:,ii),lags);
        resLag = resLag(lags+1:end,:);
        res    = residual(lags+1:end,ii);
        Z      = [X,resLag];

        % Do the estimation
        [~,~,~,~,u] = nb_ols(res,Z,1,0);

        % Construct the test statistic
        rSquared = nb_rSquared(res,u,lags+k+1);
        stat(ii) = (n-lags)*rSquared;

    end
    pval = 1 - nb_distribution.chis_cdf(stat,lags);
        
end
