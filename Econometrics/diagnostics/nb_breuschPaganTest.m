function [stat,pval] = nb_breuschPaganTest(residual,X)
% Syntax:
%
% [stat,pval] = nb_breuschPaganTest(residual,X)
%
% Description:
%
% Test for heteroscedasticity of residuals from a regression using the 
% Breusch-Pagan test. 
% 
% This test is corrected for possible non-normality in the residuals based
% on Koenker(1981) and Koenker and Bassett (1982).
%
% Caution: It will test each equation individually.
%
% Input:
% 
% - residual : A nobs x neq double with the residuals.
%
% - X        : The models regressors, as a nobs x nxvar double. The
%              constant should not be included.
%
% Output:
% 
% - stat     : The test-statistics.
%
% - pval     : The p-value.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [T,nxvar] = size(X);
    N         = size(residual,2);
       
    % Construct the statistic
    eps    = residual.^2;
    sig    = (residual'*residual)/T;
    sig    = diag(sig)';
    sig    = sig(ones(T,1),:);
    g      = eps - ones(T,N);
    Z      = [ones(T,1),X];
    ZZ     = Z'*Z;
    ZZINV  = eye(nxvar+1)/ZZ;
    v      = (eps - sig).^2;
    V      = sum(v)/T;
    stat   = diag((g'*(Z*ZZINV*Z')*g))';
    stat   = stat./V;
    
    % Do the kij-squared-test
    pval = 1 - nb_distribution.chis_cdf(stat,nxvar);
     
end
