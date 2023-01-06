function rmse = calculateRMSE(par,paramMin,paramMax,hyperParam,nCoeff,y,X,yFull,XFull,nLags,options)
% Syntax:
%
% rmse = nb_bVarEstimator.calculateRMSE(par,paramMin,paramMax,...
%           hyperParam,nCoeff,y,X,yFull,XFull,nLags,options)
%
% See also:
% nb_bVarEstimator.doEmpiricalBayesian
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    options = nb_defaultField(options,'hyperLearningSettings',nb_bVarEstimator.defaultHyperLearningSettings());

    % Evaluate the hyperpriors
    if options.hyperprior
        error('Cannot use priors for the hyper-parameters for the hyper learning algorithm!')
    end

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

    % Get out-of-sample forecast range
    T = size(y,1);
    S = ceil(T*options.hyperLearningSettings.startScorePerc);
    
    if isempty(options.hyperLearningSettings.variable)
        locVar = 1;
    else
        dep = options.dependent;
        if isfield(options,'block_exogenous')
            dep = [dep,options.block_exogenous];
        end
        locVar = strcmp(options.hyperLearningSettings.variable,dep);
        if ~any(locVar)
            error(['Cannot find the variable ' options.hyperLearningSettings.variable,...
                   ' (hyperLearningSettings.variable) among the dependent or ',...
                   'block_exogenous variables of the model.'])
        end
    end
    
    % Produce recusrive out-of-sample forecast
    fcst = nan(T-S,1);
    for tt = S:T-1 % Skip last, as we have no data to compare against!
    
        % Get sample for this recursion
        rem       = T - tt;
        yTemp     = y(1:end-rem,:);
        XTemp     = X(1:end-rem,:);
        yFullTemp = yFull(1:end-rem,:);
        XFullTemp = XFull(1:end-rem,:);
        
        % Apply dummy priors
        [yTemp,XTemp,constant,options] = nb_bVarEstimator.applyDummyPrior(options,yTemp,XTemp,yFullTemp,XFullTemp);

        % Evaluate the marginal likelihood
        if strcmp(options.prior.type,'glp')
            [beta,~] = nb_bVarEstimator.glp([],yTemp,XTemp,nLags,options.constant,options.constantAR,options.time_trend,options.prior,[],[]);   
        elseif strcmp(options.prior.type,'jeffrey') 
            [beta,~] = nb_bVarEstimator.jeffrey([],yTemp,XTemp,options.constant,options.time_trend,[],[]);
        elseif strcmp(options.prior.type,'minnesota') 
            if strcmpi(options.prior.method,'default')
                draws = 1;
            else
                draws = options.draws;
            end
            [beta,~] = nb_bVarEstimator.minnesota(draws,yTemp,XTemp,nLags,options.constant,options.constantAR,options.time_trend,options.prior,[],[]); 
            if draws > 1
                beta = mean(beta,3);
            end
        elseif strcmp(options.prior.type,'inwishart') 
            [beta,~] = nb_bVarEstimator.inwishart(options.draws,yTemp,XTemp,options.constant,options.time_trend,options.prior,[],[]); 
            beta     = mean(beta,3);
        elseif strcmp(options.prior.type,'laplace') 
            [beta,~] = nb_bVarEstimator.laplace(options.draws,yTemp,XTemp,options.constant,options.time_trend,options.prior,[],[]);
            beta     = mean(beta,3);    
        else
            [beta,~] = nb_bVarEstimator.nwishart([],yTemp,XTemp,nLags,options.constant,options.time_trend,options.prior,[],[]);
        end
        
        XEnd = XFullTemp(end,:);
        if options.time_trend
            XEnd = [tt, XEnd]; %#ok<AGROW>
        end
        if constant       
            XEnd = [1, XEnd]; %#ok<AGROW>
        end
        
        % Produce forecast
        fcstThis     = XEnd*beta;
        fcst(tt-S+1) = fcstThis(locVar);
        
    end

    % Calculate RMSE
    rmse = sqrt(mean((y(S+1:T,locVar) - fcst).^2));
    
end
