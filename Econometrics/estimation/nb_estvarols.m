function [beta,stdBeta,tStatBeta,pValBeta,residual,x] = nb_estvarols(y,nlag,x,constant,timeTrend,stdType)
% Syntax:
%
% varargout = nb_estvarols(y,nlag,x,constant)
%
% Description:
%
% Estimate a VAR model using OLS
%
% Input:
% 
% - y         : A nobs x nvar matrix with endogenous regressors.
%
% - nlag      : The number of lags of the VAR. Default is 1.
%
% - constant  : If a constant should be included in the regression.
%               Default is 1, i.e. include constant.
%
% - timeTrend : If a linear time trend is wanted in the estimation. 
%               Will be added first/second in the right hand side 
%               variables. Default is not to add it (0).
%
% - x         : A nobs x nxvar matrix with exogenous regressors.
%
% - stdType   : - 'w'    : Will return White heteroskedasticity
%                          robust standard errors. 
%               - 'nw'   : Will return Newey-West heteroskedasticity
%                          and autocorrelation robust standard errors.
%                          
%                          To estimate the covariance matrix of the
%                          estimated parameters the bartlett kernel is 
%                          used with the bandwidth set to 
%                          floor(4(T/100)^(2/9)) as Eviews also uses.
%
%                - 'h'   : Will return homoskedasticity only
%                          robust standard errors. Default.
%
% Output: 
% 
% - beta      : A nxvar x neqs vector with the estimated 
%               parameters.
%
% - stdBeta   : A nxvar x neqs vector with the standard deviation  
%               of the estimated paramteres.
%
% - tStatBeta : A nxvar x neqs vector with t-statistics of the 
%               estimated paramteres.
%
% - pValBeta  : A nxvar x neqs vector with the p-values of the 
%               estimated paramteres.
%
% - residual   : Residual from the estimated equation. As an 
%                nobs x neq matrix. 
%
% - x          : Regressors including constant and time-trend.
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 6
        stdType = 'h';
        if nargin < 5
            timeTrend = 0;
            if nargin < 4
                constant = 1;
                if nargin < 3
                    x = [];
                end
            end
        end
    end

    % Size variables
    nx = size(x,2);

    % Form the right hand side matrix
    ylag = nb_mlag(y,nlag);
    if nx > 0                
        xmat = [ylag,x];
    else
        xmat = ylag;
    end
    xmat = xmat(nlag+1:end,:);

    % Form the left hand side matrix
    ymat = y(nlag+1:end,:);

    % Estimate single equation
    [beta,stdBeta,tStatBeta,pValBeta,residual] = nb_ols(ymat,xmat,constant,timeTrend,stdType);

end
