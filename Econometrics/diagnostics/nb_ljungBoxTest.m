function [stat,pval] = nb_ljungBoxTest(residual,k)
% Syntax:
%
% [stat,pval] = nb_ljungBoxTest(residual,k)
%
% Description:
%
% Test for autocorrelation of residuals from a regression using the 
% Ljung-Box test. Only for a VAR model.
% 
% Input:
% 
% - residual : A nobs x neq double with the residuals.
%
% - k        : Number of lags of the VAR, as an integer.
%
% Output:
% 
% - stat     : The test-statistics.
%
% - pval     : The p-value.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Perform the regression:
    [T,nEq] = size(residual);
    T4      = ceil(T/4);
    resLag  = nb_mlag(residual,T4,'varFast');
    
    % Compute the test statistics:
    stat    = 0;
    SIGMA   = (residual'*residual)/T;
    SIGMAINV = eye(nEq)/SIGMA;
    for ii = 1:T4
        
        ind     = 1+(ii-1)*nEq:ii*nEq;
        SIGMAh  = (residual(ii+1:end,:)'*resLag(ii+1:end,ind))/T;
        SIGMAht = SIGMAh';
        stat    = stat + trace(SIGMAht*SIGMAINV*SIGMAht*SIGMAINV)/(T-ii);
        
    end
    stat = T*(T + 2)*stat;

    % Compute p-values:
    pval = 1 - nb_distribution.chis_cdf(stat,nEq*(T4 - k + 1) - nEq^2);

end
