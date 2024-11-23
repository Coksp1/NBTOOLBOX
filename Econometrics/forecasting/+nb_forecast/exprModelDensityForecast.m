function [fData,evalFcst] = exprModelDensityForecast(Z,restrictions,model,options,results,nSteps,iter,actual,inputs)
% Syntax:
%
% [fData,evalFcst] = nb_forecast.exprModelDensityForecast(Z,...
%           restrictions,model,options,results,nSteps,iter,actual,inputs)
%
% Description:
%
% Produce density forecast of a model using expressions using bootstrap.
%
% This function does not handle Markov switching models!
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    draws          = inputs.draws;
    parameterDraws = inputs.parameterDraws;
    method         = inputs.method;
    try options    = options(iter); catch; end %#ok<CTCH>
    if strcmpi(iter,'end')
        betaT = results.beta{1};
        iter  = size(betaT,3);
    end   
    
    % Check if we are going to extrapolate exogenous variables
    if ~isempty(inputs.exoProj)
        error([mfilename ':: The expProj input is not yet supported for density forecast.',...
            'Please contact the NB toolbox development team, if needed.'])
    end
    
    % Then we loop through each simulated data and produce forcast based on
    % the estimation on that data
    %......................................................................
    dep = options.dependentOrig;
    if ~isempty(inputs.reporting)
        dep = [dep, inputs.reporting(:,1)'];
    end
    nRes = length(model.res);
    nDep = length(dep);
    Y    = nan(nSteps,nDep,parameterDraws*draws);
    nExo = length(model.exo);
    X    = nan(nSteps,nExo,parameterDraws*draws);
    if parameterDraws == 1 % Only residual uncertainty
        
        % Make draws from the distributions of the exogenous and the shocks
        try
            E = nb_forecast.multvnrnd(results.sigma(:,:,iter),nSteps,draws);
        catch Err
            vcvCorr = nb_covrepair(results.sigma(:,:,iter));
            E       = nb_forecast.multvnrnd(vcvCorr,nSteps,draws);
            if sum(vcvCorr(:)-model.sigma(:)) > eps^(1/4)
                rethrow(Err)
            end
        end
        
        % Make draws number of simulations of the residual and forecast
        % conditional on those residuals
        for jj = 1:draws
            [Y(:,:,jj),X(:,:,jj)] = nb_forecast.exprModelForecast(Z,E(:,:,jj),nSteps,options,restrictions,results,inputs,model,iter);
        end
        
    else % Parameter uncertainty
        
        % Create waiting bar window (If already created we add a new 
        % waiting bar to that one)
        [h,inputs] = nb_forecast.createParameterUncertaintyWaitbar(inputs);

        % Bootstrap coefficients
        if isfield(options,'missingData')
            bootstrapFunc = @nb_missingEstimator.bootstrapModel;
        else
            bootstrapFunc = @nb_exprEstimator.bootstrapModel;
        end
        [betaD,sigmaD] = bootstrapFunc(model,options,results,method,parameterDraws,iter);
        
        % Preallocate
        E    = nan(nRes,nSteps,parameterDraws*draws);
        X    = nan(nSteps,nExo,parameterDraws*draws);
        kk   = 0;
        ii   = 0;
        jj   = 0;
        res  = results;
        note = nb_when2Notify(parameterDraws);
        while kk < parameterDraws

            ii = ii + 1;
            jj = jj + 1;
            
            % Assign the results struct the posterior draw (Only using the last
            % periods estimation if recursive estimation is done)
            try
                res.beta  = betaD{ii};
                res.sigma = sigmaD(:,:,ii);
            catch %#ok<CTCH>            
                % Out of draws, so we need more!
                [betaD,sigmaD] = bootstrapFunc(model,options,results,method,ceil(parameterDraws*inputs.newDraws),iter);
                ii             = 0;
                continue
            end
            
            % Make draws from the distributions of the exogenous and the shocks
            kk  = kk + 1;
            mm  = draws*(kk-1);
            ind = 1+mm:draws+mm;
            try
                E(:,:,ind) = nb_forecast.multvnrnd(res.sigma,nSteps,draws);
            catch Err
                vcvCorr    = nb_covrepair(res.sigma);
                E(:,:,ind) = nb_forecast.multvnrnd(vcvCorr,nSteps,draws);
                if sum(vcvCorr(:)-model.sigma(:)) > eps^(1/4)
                    rethrow(Err)
                end
            end

            % Make draws number of simulations of the residual and forecast
            % conditional on those residuals
            for jj = ind
                [Y(:,:,jj),X(:,:,jj)] = nb_forecast.exprModelForecast(Z,E(:,:,jj),nSteps,options,restrictions,res,inputs,model,iter);
            end

            % Report current estimate in the waitbar's message field
            if ~inputs.parallel
                if h.canceling
                    error([mfilename ':: User terminated'])
                end

                if rem(kk,note) == 0
                    h.status2 = kk;
                    h.text2   = ['Finished with ' int2str(kk) ' replications in ' int2str(jj) ' tries  using bootstrap...'];
                end
            end

        end
        
        % Delete the waitbar.
        if ~inputs.parallel
            deleteSecond(h) 
        end
        
    end
    
    % Merge with exogenous and shocks if wanted
    if strcmpi(inputs.output,'all') || strcmpi(inputs.output,'full')
        if isempty(inputs.missing)
            Y   = [Y,X,permute(E,[2,1,3])];
            dep = [dep,model.exo,model.res];
        end
    end
    
    % Keep only the varOfInterest if it is given
    if ~isempty(inputs.varOfInterest)
        if ischar(inputs.varOfInterest)
            vars = cellstr(inputs.varOfInterest);
        else
            vars = inputs.varOfInterest;
        end
        [ind,indV] = ismember(vars,dep);
        if any(~ind)
            error([mfilename ':: The following variables are not forecasted (incl reporting) by the model; ' toString(varsOI(~ind))])
        end
        indV       = indV(ind);
        Y          = Y(:,indV,:);
        dep        = dep(indV);
    end
    
    % Evalaute and report forecast
    [fData,evalFcst] = nb_forecast.evaluateDensityForecast(Y,actual,dep,model,options,inputs);
      
end
