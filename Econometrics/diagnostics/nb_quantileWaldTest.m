function [wTest,wProb] = nb_quantileWaldTest(A,c,X,beta,residual,q)    
% Syntax:
%
% [wTest,wProb] = nb_quantileWaldTest(A,b,X,beta,residual,q)  
%
% Description:
%
% Calculates the Wald-statistics for a general linear restriction.
%
% A*beta = c
% 
% This will be the null hypotheses, and we can reject it if wProb < alpha,
% where alpha is the choosen significance level.
% 
% Input:
% 
% - A         : A nrestrictions x ncoeff*nq double with the linear 
%               restrictions of the estimated coefficients (beta).
%
% - c         : A nrestrictions x 1 double with what the linear 
%               restrictions should equal.
% 
% - X         : The right hand side regressors. As a nobs x ncoeff
%               matrix.
%
% - beta      : A ncoeff*nq x 1 double with the estimated coefficients. We 
%               allow for beta to include estimated coefficients of
%               different quantiles q (nq>1). We order the coefficients 
%               [coeff(q(1));coeff(q(2));...], i.e. in the order of the
%               input q.
%
% - residual  : A nobs x nq double with the residual from the 
%               regression. NOTE: Not in use at the moment! If we allow
%               for departure IID and the normality approximation we need 
%               to use an empirical estimate of the sparisity function 
%               based on these residuals!
%
% - q         : A 1 x nq double with the quantiles. Must be in [0,1].
%
% Output:
% 
% - wTest : Wald-statistic
%
% - wProb : Wald-test statistic p-value.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    m     = size(A,1); 
    discr = A*beta - c;
    n     = size(X,1);
    Dinv  = n*inv(X'*X); %#ok<MINV>
    omega = sparsityOMG(X,residual,q);
    norm  = A*kron(omega,Dinv)*A';
    wTest = (discr'/norm)*discr/m;
    wProb = 1 - nb_distribution.chis_cdf(wTest,rank(A));
    
end

%==========================================================================
function omega = sparsityOMG(X,residual,q)
% See https://support.sas.com/documentation/onlinedoc/stat/141/qreg.pdf
% Section Confidence Interval.
%
% Here we use the assumption of IID and approximation of normality!
    
    n     = size(X,1);
    nq    = size(q,2);
    omega = nan(nq,nq);
    psi   = @(x)nb_distribution.normal_pdf(x,0,1);
    PSI   = @(x)nb_distribution.normal_icdf(x,0,1);
    h_n   = n^(-1/3)*(PSI(1 - 0.05/2))^(2/3)*((1.5*(psi(PSI(q))).^2)./(2*(PSI(q)).^2 + 1)).^(1/3);
    for ii = 1:nq
        for jj = 1:nq
            omega(ii,jj) = (min(q(ii),q(jj)) - q(ii)*q(jj))*...
                sparsityFun(q(ii),h_n(ii),PSI)*sparsityFun(q(jj),h_n(jj),PSI);
        end
    end
    
end

%==========================================================================
function s_n = sparsityFun(q,h_n,PSI)
    s_n = (1/2*h_n)*(PSI(min(q + h_n,1-eps)) - PSI(max(q - h_n,eps))); 
end
