function [fTest,fProb] = nb_restrictedFTest(A,c,X,beta,residual)    
% Syntax:
%
% [fTest,fProb] = nb_restrictedFTest(A,b,X,beta,residual)  
%
% Description:
%
% Calculates the F-statistics for a general linear restriction.
%
% A*beta = c
%
% This will be the null hypotheses, and we can reject it if fProb < alpha,
% where alpha is the choosen significance level.
% 
% Input:
% 
% - A         : A nrestrictions x ncoeff double with the linear 
%               restrictions of the estimated coefficients (beta).
%
% - c         : A nrestrictions x 1 double with what the linear 
%               restrictions should equal.
% 
% - X         : The right hand side regressors. As a nobs x ncoeff
%               matrix.
%
% - beta      : A ncoeff x 1 double with the estimated coefficients
%
% - residual  : A nobs x 1 double with the residual from the 
%               regression.
%
% Output:
% 
% - fTest : F-statistic
%
% - fProb : F-test statistic p-value.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    T     = size(residual,1);
    k     = size(beta,1);
    m     = size(A,1); 
    discr = A*beta - c;
    d     = X'*X;
    sigu  = residual'*residual/(T - k);
    norm  = sigu*(A/d)*A';
    fTest = (discr'/norm)*discr/m;
    fProb = nb_fStatPValue(fTest, m, T - k);
    
end
