function fh = calculateMarginalLikelihood(par,paramMin,paramMax,hyperParam,nCoeff,y,X,yFull,XFull,nLags,options)
% Syntax:
%
% fh = nb_bVarEstimator.calculateMarginalLikelihood(par,paramMin,...
%           paramMax,hyperParam,nCoeff,y,X,yFull,XFull,nLags,options)
%
% See also:
% nb_bVarEstimator.doEmpiricalBayesian
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Map the parameter using log transformation
    ind = ~isnan(paramMin);
    if any(ind)
        par(ind) = paramMin(ind) + (paramMax(ind) - paramMin(ind))./(1 + exp(-par(ind)));
    end

    % Assign the current value of the hyperparameters
    N  = length(hyperParam);
    kk = 1;
    for ii = 1:N
        ind                            = kk:kk + nCoeff(ii) - 1;
        options.prior.(hyperParam{ii}) = par(ind);
        kk                             = kk + nCoeff(ii);
    end

    % Apply dummy priors
    [y,X,~,options] = nb_bVarEstimator.applyDummyPrior(options,y,X,yFull,XFull);
    
    % Evaluate the marginal likelihood
    if strcmp(options.prior.type,'glp')
        fh = nb_bVarEstimator.glp([],y,X,nLags,options.constant,options.constantAR,options.time_trend,options.prior,[],[]);  
    elseif strcmp(options.prior.type,'dsge')
        fh = nb_bVarEstimator.dsge([],y,X,nLags,options.constant,options.time_trend,options.prior,[],[]);  
    else
        fh = nb_bVarEstimator.nwishart([],y,X,nLags,options.constant,options.time_trend,options.prior,[],[]);
    end

    % Evaluate the hyperpriors
    if options.hyperprior
        kk = 1;
        for ii = 1:N
            hyperprior = options.prior.([hyperParam{ii} 'Hyperprior']);
            ind        = kk:kk + nCoeff(ii) - 1;
            fh         = fh + sum(log(hyperprior(par(ind))));
            kk         = kk + nCoeff(ii);
        end
    end
    
    % We minimize the minus the log marginal likelihood
    fh = -fh;
    
end
