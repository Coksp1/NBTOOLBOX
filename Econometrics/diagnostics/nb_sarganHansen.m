function [test,pval] = nb_sarganHansen(residual,x,inst,overident,constant,timeTrend)
% Syntax:
%
% [test,pval] = nb_sarganHansen(residual,x,z,inst,overident,constant,...
%                               timeTrend)
%
% Description:
%
% Sargan-Hansen test for instruments validity. Only for overidentified
% models.
% 
% For more see the documentation of DAG.
%
% Input:
% 
% - residual  : A double matrix of size nobs x neq of the residual 
%               from the overidentified regression(s).
%
% - x         : A double matrix of size nobs x nxvar of the 
%               exogenous variables of all equations of the 
%               regression.
%
% - inst      : A nobs x nivar double of the instruments for all 
%               the endogenous variables.
%
% - overident : The number of overidentifying restrictions. I.e. the number
%               of instruments which are included in the "equations" of the
%               endogenous variables, but not in the estimated equation.
%
% - constant  : If a constant is wanted in the estimation.
% 
% - timeTrend : If a linear time trend is wanted in the estimation.
% 
% Output:
% 
% - test : Sargan-Hansen statistic. A 1 x 1 double.
%
% - pval : P-value of the test statistic. The test statistic is distributed  
%          as F(nzvar,nobs - nzvar - nxvar).
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    n    = size(inst,1);
    nEq  = size(residual,2);
    test = nan(1,nEq);
    Z    = [x,inst];
    K    = size(Z,2);
    for ii = 1:nEq
    
        % Do the estimation
        [~,~,~,~,u] = nb_ols(residual(:,ii),Z,constant,timeTrend);

        % Construct the test statistic
        rSquared = nb_rSquared(residual(:,ii),u,K + constant + timeTrend);
        test(ii) = n*rSquared;

    end
    pval = 1 - nb_distribution.chis_cdf(test,overident);


end
