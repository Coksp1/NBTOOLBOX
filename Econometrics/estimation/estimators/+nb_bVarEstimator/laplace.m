function [beta,sigma,x,posterior] = laplace(draws,y,x,constant,timeTrend,prior,restrictions,waitbar)
% Syntax:
%
% [beta,sigma,x] = nb_bVarEstimator.laplace(draws,y,x,constant,...
%       timeTrend,prior,restrictions,waitbar)
%
% Description:
%
% Estimate VAR model using laplace prior.
%
% Input:
% 
% - y            : A double matrix of size nobs x neq of the dependent 
%                  variable of the regression(s).
%
% - x            : A double matrix of size nobs x neq*nlags + h. Where h
%                  is the exogenous variables of the model.
%
% - draws        : Number of draws.
%
% - recDraws     : Number of draws to discard in the beginning.
%
% - Xt1          : Value of predictors at time T+1.
%
% - constant     : If a constant is wanted in the estimation. Will be
%                  added first in the right hand side variables.
% 
% - timeTrend    : If a linear time trend is wanted in the estimation. 
%                  Will be added first/second in the right hand side 
%                  variables. (First if constant is not given, else 
%                  second) 
%
% - restrictions : Index of parameters that are restricted to zero.
%
% - waitbar      : true, false or an object of class nb_waitbar5.
%
% - prior        : Struct with prior options. See nb_var.priorTemplate.
%
% Output: 
% 
% - beta       : A (extra + neq*nlags + h) x neq x draws matrix with the  
%                posterior draws of the estimted coefficents.
%
% - sigma      : A neq x neq x draws matrix with the posterior variance of 
%                the the estimated coefficients. 
%
% - X          : Regressors including constant and time-trend.
% 
% - posterior  : A struct with all the needed information to do posterior
%                draws.
%
% See also
% nb_bVarEstimator, nb_var 
%
% Written by Atle Loneland

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 8
        waitbar = true;
        if nargin < 7
            restrictions = [];
        end
    end
    if ~isempty(restrictions)
        error([mfilename ':: Block exogenous variables cannot be declared with the laplace prior.'])
    end

    % Are we dealing with all zero regressors?
    [~,numDep] = size(y);
    [x,indZR]  = nb_bVarEstimator.removeZR(x,constant,timeTrend,numDep,0);

    if isempty(x)
        sizeX = size(y,1);
        x     = zeros(sizeX,0);
    else
        sizeX = size(x,1);
    end

    % Add timetrend if wanted
    if timeTrend
        trend = 1:sizeX;
        x     = [trend', x];
    end

    % Add constant if wanted
    if constant        
        x = [ones(sizeX,1), x];
    end

    [T,numCoeff] = size(x);
    [~,numEq]    = size(y);
    xx           = x'*x;
    
    % Hyper prior
    lam2Prior = prior.lam2Prior;
    R2target  = .25;
    if isempty(lam2Prior)
        lam2 = sqrt(R2target/(8*numCoeff*(1 - R2target)^2));
    elseif isnumeric(lam2Prior) == 1
        lam2 = lam2Prior; 
    else
        error('The lam2Prior prior option must be [] or a number!')
    end
    
    % Initialize priors
    initSigma = zeros(numEq,numEq);
    initBeta  = zeros(numCoeff,numEq);
    for n = 1:numEq
        xy             = x'*y(:,n);
        RidgeVarAux    = 8*(1 - R2target)*lam2^2;
        initBeta(:,n)  = (xx+eye(numCoeff)/RidgeVarAux)\xy;
        res            = y(:,n) - x*initBeta(:,n);
        SSE            = res'*res;
        initSigma(n,n) = SSE/(T - numCoeff);
    end 
    
    % Gibbs sampling
    %------------------------
    [beta,sigma] = nb_bVarEstimator.laplaceDensity(y,x,initBeta,initSigma,lam2Prior,lam2,draws,prior.burn,prior.thin,waitbar);
       
    % Expand to include all zero regressors
    if any(~indZR)
        beta = nb_bVarEstimator.expandZR(beta,indZR); 
    end
    
    % Return all needed information to do posterior draws
    %----------------------------------------------------
    if nargout > 3
        posterior = struct('type','laplace','betaD',beta,'sigmaD',sigma,...
                           'regressors',x,'restrictions',{restrictions},'dependent',y,...
                           'burn',prior.burn,'thin',prior.thin,'lam2Prior',lam2Prior,...
                           'lam2',lam2);
    end

    
end
