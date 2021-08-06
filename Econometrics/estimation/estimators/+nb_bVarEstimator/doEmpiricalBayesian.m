function [betaD,sigmaD,XX,posterior,options,fVal,pY] = doEmpiricalBayesian(options,h,nLags,restrictions,y,X,yFull,XFull)
% Syntax:
%
% [betaD,sigmaD,XX,posterior,options,fVal,pY] = ...
%    nb_bVarEstimator.doEmpiricalBayesian(options,h,nLags,restrictions,...
%       y,X,yFull,XFull)
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    % Get hyperparameters, inital values and bounds
    [hyperParam,nCoeff,init,lb,ub] = nb_bVarEstimator.getInitAndHyperParam(options);

    % Optimize over hyperparameters
    opt           = nb_getDefaultOptimset(options.optimset,'fmincon');
    fh            = @(x)nb_bVarEstimator.calculateMarginalLikelihood(x,hyperParam,nCoeff,y,X,yFull,XFull,nLags,options);
    [estPar,fVal] = nb_callOptimizer(options.optimizer,fh,init,lb,ub,opt,'Error occured during optimization of hyperparameters.');
    fVal          = -fVal;
    
    % Assign the optimized value of the hyperparameters
    N  = length(hyperParam);
    kk = 1;
    for ii = 1:N
        ind                            = kk:kk + nCoeff(ii) - 1;
        options.prior.(hyperParam{ii}) = estPar(ind);
        kk                             = kk + nCoeff(ii);
    end
    
    % Apply dummy observation prior
    [y,X,constant,options] = nb_bVarEstimator.applyDummyPrior(options,y,X,yFull,XFull);
    
    % Final estimation (i.e. draw from the posterior etc.)
    switch lower(options.prior.type)
        case 'glp'
            [betaD,sigmaD,XX,posterior,pY] = nb_bVarEstimator.glp(options.draws,y,X,nLags,options.constant,options.constantAR,options.time_trend,options.prior,restrictions,h);   
        case 'nwishart'
            [betaD,sigmaD,XX,posterior,pY] = nb_bVarEstimator.nwishart(options.draws,y,X,nLags,options.constant,options.time_trend,options.prior,restrictions,h);
        otherwise
            error([mfilename ':: Unsupported prior type ' options.prior.type ' for empirical bayesian estimation.'])
    end
    if options.prior.LR || options.prior.SC || options.prior.DIO
        options.constant = constant;
    end

end
