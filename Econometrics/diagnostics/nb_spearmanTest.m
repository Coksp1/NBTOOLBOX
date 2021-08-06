function [tTest,pVal] = nb_spearmanTest(X,beta,resid)
% Syntax:
%
% [tTest,pVal] = nb_spearmanTest(X,beta,resid)
%
% Description:
%
% Spearman correlation test for heteroskedacity.
% 
% Input:
%
% - X     : The right hand side variables of the regression. Must be a 
%           nobs x 1 double.
%
% - beta  : Estimated coefficients. As a ncoeff x 1 double.
%
% - resid : Residual of regression. Must be a nobs x 1 double
% 
% Output:
% 
% - tTest : Spearman Statistic. A 1 x 1 double.
%
% - pVal  : P value of test.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [n,nvar] = size(X);

    % Construct predicted values
    pred = X*beta;
    
    % Rank the predicted y and the residual
    [~,ir] = sort(abs(resid),1,'ascend');
    [~,ip] = sort(pred,1,'ascend');
    
    d     = ir - ip;
    r     = 1 - 6*(d'*d)/(n*(n^2 - 1));
    tTest = r*sqrt(n - 2)/(sqrt(1 - r^2));
    pVal  = nb_tStatPValue(tTest,n-nvar);
    
end


