function [fData,evalFcst,solution] = densityForecast(y0,restrictions,model,options,results,nSteps,iter,actual,inputs,solution)
% Syntax:
%
% [fData,evalFcst,solution] = nb_forecast.densityForecast(y0,...
%      restrictions,model,options,results,nSteps,start,iter,actual,...
%      inputs,solution)
%
% Description:
%
% Produce density forecast with wanted method
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    try options = options(iter); catch; end %#ok<CTCH>

    % Get the variables to forecast
    dep = nb_forecast.getForecastVariables(options,model,inputs,'densityForecast');
    if strcmpi(model.class,'nb_tvp')
        [Y,XE] = nb_forecast.tvp(restrictions,model,options,results,nSteps,iter,inputs,'density');
    elseif strcmpi(model.class,'nb_dsge') && options.stochasticTrend
        [Y,X,E] = nb_forecast.forecastStochasticTrend(y0,restrictions,model,options,results,nSteps,iter,inputs);  
        XE      = permute([X;E],[2,1,3]);
    elseif strcmpi(model.class,'nb_midas')
        Y = nb_forecast.midasDensityForecast(y0,restrictions,model,options,results,nSteps,iter,inputs);
    elseif strcmpi(options(end).estim_method,'quantile')
        if any(strcmpi('logScore',inputs.fcstEval))
            error([mfilename ':: Cannot evaluate logScore of density forecast produced by a model estimated by quantile regression.'])
        end
        inputs.estimateDensities = false;
        if isfield(inputs,'reporting')
            if ~isempty(inputs.reporting)
                error([mfilename ':: Cannot do reporting when denity forecast are produced by a model estimated by quantile regression.'])
            end
        end
        Y  = nb_forecast.quantileDensityForecast(y0,restrictions,model,options,results,nSteps,iter,inputs);
        XE = nan(size(Y,1),0,size(Y,3));
    elseif strcmpi(model.class,'nb_fmdyn')
        error([mfilename ':: Cannot produce density forecast of nb_fmdyn class yet.'])
    else
        
        if ~nb_isempty(inputs.foundReplic)
            [Y,XE,states,PAI] = nb_forecast.densityFoundReplic(y0,restrictions,model,options,results,nSteps,iter,inputs);
        else
            switch lower(inputs.method)
                case {'bootstrap','wildbootstrap','blockbootstrap','mblockbootstrap','rblockbootstrap','wildblockbootstrap','copulabootstrap'}
                    if isfield(model,'F') % Factor model
                        % Factor models are much more complicated animals to 
                        % bootstrap, as also the factors needs to be bootstraped.
                        [Y,XE,solution] = nb_forecast.densityBootstrapFactorModel(y0,restrictions,model,options,results,nSteps,iter,inputs,solution);
                    else
                        [Y,XE,solution] = nb_forecast.densityBootstrap(y0,restrictions,model,options,results,nSteps,iter,inputs,solution);
                    end
                case {'posterior','asymptotic'}
                    [Y,XE,states,PAI,solution] = nb_forecast.densityPosterior(y0,restrictions,model,options,results,nSteps,iter,inputs,solution);
                otherwise
                    error([mfilename ':: Unsupported error band method; ' inputs.method '.'])
            end
        end
        
        % Special stuff for models with measurement equation
        modelIter = nb_forecast.getModelMatrices(model,iter,false,options,nSteps);
        if isfield(modelIter,'H') && ~any(strcmpi(model.class,{'nb_arima','nb_fmsa'}))
            % Dealing with a model with a measurement equation!
            if ~isempty(inputs.observables)
                X          = XE(:,1:size(modelIter.B,2),:);
                [depN,YT]  = nb_forecast.doMeasurementEq(options,results,inputs,nSteps,modelIter,Y(:,:,1),X(:,:,1)',dep,iter);
                YN         = nan(size(YT,1),size(YT,2),size(Y,3));
                YN(:,:,1)  = YT;
                for ii = 2:size(Y,3)
                    [~,YT]     = nb_forecast.doMeasurementEq(options,results,inputs,nSteps,modelIter,Y(:,:,ii),X(:,:,ii)',dep,iter);
                    YN(:,:,ii) = YT;
                end
                Y   = YN;
                dep = depN;
            end
        end
        
        % Here we transpose all single forecast, so dim1 is nSteps and 2 is 
        % nVars
        numDep = length(dep);
        if isempty(inputs.missing)
            Y = Y(1:numDep,2:end,:);
        else
            Y = Y(1:numDep,:,:); % Report nowcast as well
        end
        Y = permute(Y,[2,1,3]);
        
    end
    
    % Undiff ARIMA model
    if strcmpi(options.estimator,'nb_arimaEstimator')
        Y   = nb_forecast.undiffARIMA(options,restrictions.start,Y); 
        dep = regexprep(dep,'diff\d_','');
    end
    
    % Merge the states if we are dealing with a MArkov switching model
    if nb_isModelMarkovSwitching(model)
        if isempty(inputs.missing)
            PAI = permute(PAI(:,2:end,:),[2,1,3]);
            Y   = [Y,states,PAI];
        else
            PAI = permute(PAI(:,1:end,:),[2,1,3]);
            Y   = [Y,[nan(1,1,size(states,3));states],PAI];
        end
        dep = [dep,'states',model.regimes];
    end
    
    % Create reported variables
    if isfield(inputs,'reporting')
        if ~isempty(inputs.reporting)
            [Y,dep] = nb_forecast.createReportedVariables(options,inputs,Y,dep,restrictions.start,iter);
        end
    end
    
    % Merge with exogenous and shocks if wanted
    if strcmpi(inputs.output,'all') || strcmpi(inputs.output,'full')
        if isempty(inputs.missing)
            if not(any(strcmpi(model.class,{'nb_fmsa','nb_sa','nb_midas'})))
                Y = [Y,XE];
                if strcmpi(model.class,'nb_arima')
                    dep = [dep,model.factors,model.res];
                elseif strcmpi(model.class,'nb_tvp')
                    dep = [dep,model.factors,model.res,model.parameters,model.paramRes];    
                else
                    dep = [dep,model.exo,model.res];
                end
            end
        end
    end
    
    % Keep only the varOfInterest if it is given
    if ~isempty(inputs.varOfInterest)
        if ischar(inputs.varOfInterest)
            vars = cellstr(inputs.varOfInterest);
        else
            vars = inputs.varOfInterest;
        end
        if strcmpi(model.class,'nb_favar') || strcmpi(model.class,'nb_fmdyn')
            vars = [vars,inputs.observables];
        end
        [ind,indV] = ismember(vars,dep);
        indV       = indV(ind);
        Y          = Y(:,indV,:);
        dep        = dep(indV);
    end
    
    % Evalaute and report forecast
    [fData,evalFcst] = nb_forecast.evaluateDensityForecast(Y,actual,dep,model,options,inputs);
    
end
