function [test,prob] = nb_whiteTest(residual,X)
% Syntax:
%
% [test,prob] = nb_whiteTest(residual,X)
%
% Description:
%
% White (1980) test for heteroscedasticity.
% 
% Input:
% 
% - residual : Residuals from the model. As a nobs x 1 double.
%
% - X        : Regressors from the model. As a nobs x nxvar double. Should
%              not include a constant.
%
% Output:
% 
% - test  : Test statistic
%
% - fProb : P-value of test
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [T,nxvar] = size(X);
    
    % Construct regressors of auxiliary regression, cross and square terms
    m  = sum(1:nxvar);
    Z  = nan(T,m);
    kk = 1;
    for ii = 1:nxvar      
        for jj = ii:nxvar
            Z(:,kk) = X(:,ii).*X(:,jj);
            kk = kk + 1;
        end
    end
    
    % Add the actual regressors as well
    Z        = [X,Z];
    numCoeff = size(Z,2);
    
    % Construct dependent variable
    eps = residual.^2;
    
    % Estimate eq
    [~,~,~,~,res,~] = nb_ols(eps,Z,1,0);
    
    % Do the kij-squared-test
    test = T*nb_rSquared(eps,res,numCoeff);
    prob = 1 - nb_distribution.chis_cdf(test,numCoeff - 1);
    
end
