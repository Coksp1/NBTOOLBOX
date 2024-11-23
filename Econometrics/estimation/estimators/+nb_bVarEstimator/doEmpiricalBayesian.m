function [betaD,sigmaD,XX,posterior,options,fVal,pY] = doEmpiricalBayesian(options,h,nLags,restrictions,y,X,yFull,XFull,func)
% Syntax:
%
% [betaD,sigmaD,XX,posterior,options,fVal,pY] = ...
%    nb_bVarEstimator.doEmpiricalBayesian(options,h,nLags,restrictions,...
%       y,X,yFull,XFull,func)
%
% Description:
%
% Estimate B-VAR model with optimizing hyperparameters of the priors. See
% Giannone, Lenza and Primiceri (2014), "Prior selection for vector 
% autoregressions"
%
% Caution: We do not use MCMC methods to sample from the posterior of the
%          hyperparameters even if options.hyperprior is set to true.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    if nargin < 9
        func = '';
    end

    options = nb_bVarEstimator.applyCovidFilter(options,y);

    % Get hyperparameters, inital values and bounds
    [hyperParam,nCoeff,init,lb,ub,paramMin,paramMax] = ...
        nb_bVarEstimator.getInitAndHyperParam(options);

    % Map the parameter using log transformation
    ind = ~isnan(paramMin);
    if any(ind)
        init(ind) = -log((paramMax(ind)-init(ind))./(init(ind)-paramMin(ind)));
        ub(ind)   = inf;
        lb(ind)   = -inf;
    end
    
    % Optimize over hyperparameters
    opt = nb_getDefaultOptimset(options.optimset,options.optimizer);
    if strcmpi(func,'calculateRMSE')
        fh = @(x)nb_bVarEstimator.calculateRMSE(x,paramMin,paramMax,...
            hyperParam,nCoeff,y,X,yFull,XFull,nLags,options);
    else
        if ~any(strcmpi(options.prior.type,{'glp','nwishart','dsge'}))
            error(['Unsupported prior type ' options.prior.type ' for empirical bayesian estimation.'])
        end
        fh = @(x)nb_bVarEstimator.calculateMarginalLikelihood(x,paramMin,...
            paramMax,hyperParam,nCoeff,y,X,yFull,XFull,nLags,options);
    end
    [estPar,fVal] = nb_callOptimizer(options.optimizer,fh,init,lb,ub,opt,...
        'Error occured during optimization of hyperparameters.');
    if ~strcmpi(func,'calculateRMSE')
        fVal = -fVal;
    end
    
    % Map back to normal transformation of the parameter
    if any(ind)
        estPar(ind) = paramMin(ind) + (paramMax(ind) - paramMin(ind))./(1 + exp(-estPar(ind)));
    end
    
    % Assign the optimized value of the hyperparameters
    N  = length(hyperParam);
    kk = 1;
    for ii = 1:N
        ind                            = kk:kk + nCoeff(ii) - 1;
        options.prior.(hyperParam{ii}) = estPar(ind);
        kk                             = kk + nCoeff(ii);
    end
    
    % Estimate the model at the found hyperparameters
    [betaD,sigmaD,XX,posterior,pY] = nb_bVarEstimator.doBayesian(...
        options,h,nLags,restrictions,y,X,yFull,XFull);

end
