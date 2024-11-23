function [betaD,sigmaD,R,ys,XX,posterior,options,fVal,pY] = doEmpiricalBayesianMF(options,h,nLags,restrictions,y,X,freq,H,mixing,func)
% Syntax:
%
% [betaD,sigmaD,R,ys,XX,posterior,options,fVal,pY] = ...
%    nb_bVarEstimator.doEmpiricalBayesian(options,h,nLags,restrictions,...
%       y,X,freq,H,mixing,func)
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
% We do the optimization step over a balanced dataset, and then use the
% hyperparameters from this step to estimate the model on the full dataset.
%
% Caution: Only missing observations at the end of the example is
%          supported!
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    if nargin < 10
        func = '';
    end

    % Get original prior, and reset to balanced data prior
    origPrior          = options.prior.type;
    options.prior.type = regexprep(options.prior.type,'MF$','');
    
    % Create needed data matrices
    ind   = ~any(isnan(y),2);
    s     = find(ind,1);
    e     = find(ind,1,'last');
    if any(~ind(s:e))
        error(['Cannot do empirical bayesian with missing observations ',...
            'in the middle of the sample for the prior ' origPrior])
    end
    yFull    = y(ind,:);
    XFull    = X(ind,:);
    yFullLag = nb_mlag(yFull,nLags,'varFast');
    XFull    = [XFull,yFullLag];
    yTemp    = yFull(nLags+1:end,:);
    XTemp    = XFull(nLags+1:end,:);
    
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
    
    % For non-missing priors we have nLags being actual lags minus 1!
    options.nLags = options.nLags - 1;
    
    % Optimize over hyperparameters
    opt = nb_getDefaultOptimset(options.optimset,options.optimizer);
    if strcmpi(func,'calculateRMSE')
        fh = @(x)nb_bVarEstimator.calculateRMSE(x,paramMin,paramMax,...
            hyperParam,nCoeff,yTemp,XTemp,yFull,XFull,nLags,options);
    else
        if ~any(strcmpi(origPrior,{'glpMF','nwishartMF'}))
            error(['Unsupported prior type ' options.prior.type ' for empirical bayesian estimation.'])
        end
        fh = @(x)nb_bVarEstimator.calculateMarginalLikelihood(x,paramMin,...
            paramMax,hyperParam,nCoeff,yTemp,XTemp,yFull,XFull,nLags,options);
    end
    [estPar,fVal] = nb_callOptimizer(options.optimizer,fh,init,lb,ub,opt,...
        'Error occured during optimization of hyperparameters.');
    if ~strcmpi(func,'calculateRMSE')
        pY   = -fVal;
        fVal = -fVal;
    else
        pY = [];
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
    
    % Reset prior and nLags
    options.prior.type = origPrior;
    options.nLags      = options.nLags + 1;
    
    % Estimate the model at the found hyperparameters
    [betaD,sigmaD,R,ys,XX,posterior] = nb_bVarEstimator.doBayesianMF(...
        options,h,nLags,restrictions,y,X,freq,H,mixing);

end
