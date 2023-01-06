function [Y,XE,states,PAI,solution] = densityPosterior(y0,restrictions,model,options,results,nSteps,iter,inputs,solution)
% Syntax:
%
% [Y,XE,states,solution] = nb_forecast.densityPosterior(y0,restrictions,...
%       model,options,results,nSteps,draws,parameterDraws,iter,inputs,...
%       solution)
%
% Description:
%
% Produce density forecast using posterior draws.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if strcmpi(model.class,'nb_dsge')
        if iscell(model.ss)
            ss = model.ss;
        else
            y0 = y0 - model.ss;
            ss = [];
            if ~isempty(restrictions.Y)
                condY          = restrictions.Y;
                ssY            = model.ss(restrictions.indY);
                restrictions.Y = bsxfun(@minus,condY,ssY');
            end
        end
    else
        ss = [];
    end

    draws          = inputs.draws;
    parameterDraws = inputs.parameterDraws;
    regimeDraws    = inputs.regimeDraws;
    if ~nb_isModelMarkovSwitching(model)
        regimeDraws = 1;
    end
    
    % Only allow one identification per posterior draws?
    if isfield(model,'identification')
        model.identification.draws = 1;
    end

    try options = options(iter); catch; end %#ok<CTCH>
    if parameterDraws == 1 && options.recursive_estim 
        func = str2func([model.class, '.solveRecursive']);
    else
        func = str2func([model.class, '.solveNormal']);
    end
    if isfield(model,'identification')
        identified = true;
    else
        identified = false;
    end
    missingVar = nb_forecast.isMissingVar(options);

    nVars = size(y0,1);
    if parameterDraws == 1 % Only residual uncertainty
        
        if restrictions.type ~= 3 || ~restrictions.softConditioning 
            % No identification even for VARs when not conditional 
            % forecast!
            if ~strcmpi(restrictions.class,'nb_dsge')
                model = func(results,options);
            end
        end 
        
        % Calculate density forecast
        modelIter = nb_forecast.getModelMatrices(model,iter,false,options,nSteps);
        if restrictions.type ~= 3 || ~restrictions.softConditioning 
            if identified
                % But we need to rescale the residual standard 
                % deviation to N(0,1) as this is assumed for a 
                % identified model!
                QS            = transpose(chol(modelIter.vcv));
                modelIter.C   = modelIter.C*QS;
                modelIter.vcv = eye(size(QS,1));
            end
        end

        % Make draws from the distributions of the exogenous and the shocks
        if regimeDraws == 1
            [E,X,states,solution] = nb_forecast.drawShocksAndExogenous(y0,modelIter,ss,nSteps,draws,restrictions,solution,inputs,options);
        else
            [E,X,states,solution] = nb_forecast.drawRegimes(y0,modelIter,ss,nSteps,draws,restrictions,solution,inputs,options);
        end
        
        if iscell(modelIter.C)
            sizeC3 = size(modelIter.C{1},3);
        else
            sizeC3 = size(modelIter.C,3);
        end
        if sizeC3 > 1
           E = [E,zeros(size(E,1),sizeC3-1,size(E,3))]; 
        end
        
        % Check if bounded forecast are going to be made
        inp = [];
        if isfield(inputs,'bounds')
            if ~nb_isempty(inputs.bounds)
               inp = nb_forecast.setUpForBoundedForecast(nSteps,model,restrictions,inputs,draws*regimeDraws); 
            end
        end   
        
        % If we are dealing with missing observation we need to draw
        % nowcast as well
        if isempty(inputs.missing)
            Y0 = y0(:,:,ones(1,regimeDraws*draws));
        else
            if missingVar
                nowcast = 0;
                if ~isempty(inputs.missing)
                    nowcast = max(sum(inputs.missing,1));    
                end
                if nowcast == 0
                    Y0 = y0(:,:,ones(1,regimeDraws*draws));
                else
                    if strcmpi(inputs.method,'asymptotic')
                        yD = results.smoothed.variables.data(:,1:nVars,iter);
                        T  = find(~isnan(yD(:,1)),1,'last');
                        yD = yD(T-nowcast+1:T,:);
                        pD = results.pD(:,:,:,iter);
                        Y0 = nb_forecast.drawNowcastFromKalmanFilter(yD',pD,regimeDraws*draws);
                    else
                        if ~isfield(options,'pathToSave')
                            error([mfilename ':: No estimation is done, so can''t draw from the posterior.'])
                        end
                        try
                            coeffDraws = nb_loadDraws(options.pathToSave);
                        catch Err
                            nb_error('It seems to me that the estimation results has been saved in a folder you no longer have access to.',Err)
                        end
                        if ~options.real_time_estim
                            coeffDraws = coeffDraws(iter);
                        end
                        pD = mean(coeffDraws.pD,4);
                        yD = mean(coeffDraws.yD(end-nowcast+1:end,1:nVars,:),3);
                        Y0 = nb_forecast.drawNowcastFromKalmanFilter(yD',pD,regimeDraws*draws);
                    end
                end
            else
                Y0 = nb_forecast.drawNowcast(y0,options,results,model,inputs,iter); 
            end
            Ynow = Y0;     
        end
        
        % Make draws number of simulations of the residual and forecast
        % conditional on those residuals
        Y = nan(nVars,nSteps + 1,draws*regimeDraws);
        if nb_isModelMarkovSwitching(model)
            PAI = nan(length(model.regimes),nSteps + 1,draws*regimeDraws);
        else
            PAI = nan(0,nSteps + 1,draws);
        end
        for jj = 1:draws*regimeDraws
            [Y(:,:,jj),states(:,:,jj),PAI(:,:,jj),E(:,:,jj)] = nb_forecast.condShockForecastEngine(...
                Y0(:,end,jj),modelIter.A,modelIter.B,modelIter.C,ss,modelIter.Qfunc,...
                X(:,:,jj),E(:,:,jj),states(:,:,jj),restrictions,nSteps,inp);
        end
        
        % Append contribution of exogenous variables when dealing with
        % ARIMA models
        if strcmpi(model.class,'nb_arima')
            [Y(1,2:end,:),Z] = nb_forecast.addZContribution(Y(1,2:end,:),model,options,restrictions,inputs,draws,iter);
        end

        if ~isempty(inp)
            deleteThird(inp.waitbar);
        end
    
    %======================================================================    
    else % More than 1 parameter draw
    %======================================================================    
        
        E = nan(length(model.res),nSteps,regimeDraws*parameterDraws*draws);
        X = nan(length(model.exo),nSteps,regimeDraws*parameterDraws*draws);
        if strcmpi(model.class,'nb_arima')
            Z = nan(length(model.factors),nSteps,regimeDraws*parameterDraws*draws);
        end
        states = nan(nSteps,1,regimeDraws*parameterDraws*draws);
        Y      = nan(nVars,nSteps + 1,regimeDraws*parameterDraws*draws);
        if nb_isModelMarkovSwitching(model)
            PAI = nan(length(model.regimes),nSteps+1,regimeDraws*parameterDraws*draws);
        else
            PAI = nan(0,nSteps+1,regimeDraws*parameterDraws*draws);
        end
        
        % Create waiting bar window (If already created we add a new 
        % waiting bar to that one)
        if ~inputs.parallel
            if isfield(inputs,'waitbar')
               h      = inputs.waitbar;
               h.lock = 3; % Recursive forecast
            else
                if isfield(inputs,'index')
                    figureName = ['Forecast for Model ' int2str(inputs.index) ' of ' int2str(inputs.nObj)];
                else
                    figureName = 'Forecast';
                end
                h      = nb_waitbar5([],figureName,true);
                h.lock = 2;
                inputs.waitbar = h;
            end
            h.text2          = 'Starting...'; 
            h.maxIterations2 = parameterDraws;
        else
            h = false;
        end
        
        % Check if bounded forecast are going to be made
        inp = [];
        if isfield(inputs,'bounds')
            if ~nb_isempty(inputs.bounds)
               inp = nb_forecast.setUpForBoundedForecast(nSteps,model,restrictions,inputs,draws*regimeDraws); 
            end
        end 
        
        % Get the posterior draws
        if strcmpi(inputs.method,'asymptotic')
            drawFunc = str2func([options.estimator '.drawParameters']);
            if missingVar
                [betaD,sigmaD,yD,pD] = drawFunc(results,options,parameterDraws,iter);
            else
                [betaD,sigmaD] = drawFunc(results,options,parameterDraws,iter);
            end
            extra = 0;
        else
            if ~isfield(options,'pathToSave')
                error([mfilename ':: No bayesian estimation is done, so can''t draw from the posterior.'])
            end
            try
                coeffDraws = nb_loadDraws(options.pathToSave);
            catch Err
                nb_error('It seems to me that the estimation results has been saved in a folder you no longer have access to.',Err)
            end
            if ~options.real_time_estim
                coeffDraws = coeffDraws(iter);
            end
            [extra,betaD,sigmaD,yD,pD] = nb_forecast.drawMoreFromPosterior(inputs,coeffDraws);
        end
        
        % If we are dealing with missing observation we need to draw
        % nowcast as well (only for some missing methods at this point)
        nowcast = 0;
        if ~isempty(inputs.missing)
            forecastOrKalman = false;
            if any(strcmpi(options.missingMethod,{'forecast','kalman'}))
                forecastOrKalman = true;
            else
                Y0All = nb_forecast.drawNowcast(y0,options,results,model,inputs,iter);  
            end
            nowcast = max(sum(inputs.missing,1));
            Ynow    = nan(nVars,nowcast,regimeDraws*parameterDraws*draws);     
        end
        
        % Start looping over parameter draws
        ii       = 0;
        jj       = 0;
        kk       = 0;
        res      = struct('beta',[],'sigma',[]);
        note     = nb_when2Notify(parameterDraws);
        func     = str2func([model.class, '.solveNormal']);
        while kk < parameterDraws

            ii = ii + 1;
            jj = jj + 1;

            % Assign the results struct the posterior draw (Only using the last
            % periods estimation if recursive estimation is done)
            try
                res.beta  = betaD(:,:,ii);
                res.sigma = sigmaD(:,:,ii);
            catch %#ok<CTCH>
                % Out of posterior draws, so we need more!
                if strcmpi(inputs.method,'asymptotic')
                    if missingVar
                        [betaD,sigmaD,yD,pD] = drawFunc(results,options,round(parameterDraws*inputs.newDraws),iter);
                    else
                        [betaD,sigmaD] = drawFunc(results,options,round(parameterDraws*inputs.newDraws),iter);
                    end
                else
                    [betaD,sigmaD,yD,pD] = nb_drawFromPosterior(coeffDraws,round(parameterDraws*inputs.newDraws),h);
                end
                ii = 1;
            end
            
            % Assign the results struct the posterior draw
            res.beta  = betaD(:,:,ii);
            res.sigma = sigmaD(:,:,ii);

            % Solve the model given the posterior draw
            if restrictions.type == 3 || restrictions.softConditioning
                try
                    if identified
                        modelDraw = func(res,options,model.identification);
                    else
                        modelDraw = func(res,options);
                    end
                catch %#ok<CTCH>
                    continue
                end
            else
                % No identification even for VARs when not conditional 
                % forecast!
                modelDraw = func(res,options);
                if identified
                    % But we need to rescale the residual standard 
                    % deviation to N(0,1) as this is assumed for a 
                    % identified model!
                    QS            = transpose(chol(modelDraw.vcv));
                    modelDraw.C   = modelDraw.C*QS;
                    modelDraw.vcv = eye(size(QS,1));
                end
            end

            if inputs.stabilityTest
                if iscell(modelDraw.A)
                    error([mfilename ':: the ''stabilityTest'' input is not possible to use with a Markov-switching or break-points model.'])
                end
                [~,~,modulus] = nb_calcRoots(modelDraw.A);
                if any(modulus > 1)
                    continue
                end
            end 
            
            % Calculate density forecast
            modelDraw = nb_forecast.getModelMatrices(modelDraw,'end',false,options,nSteps);

            % Make draws from the distributions of the exogenous and the shocks
            kk  = kk + 1;
            mm  = regimeDraws*draws*(kk-1);
            ind = 1+mm:regimeDraws*draws+mm;
            if regimeDraws == 1
                [E(:,:,ind),X(:,:,ind),states(:,:,ind)] = nb_forecast.drawShocksAndExogenous(y0,modelDraw,ss,nSteps,draws,restrictions,struct(),inputs,options);
            else
                [E(:,:,ind),X(:,:,ind),states(:,:,ind)] = nb_forecast.drawRegimes(y0,modelDraw,ss,nSteps,draws,restrictions,struct(),inputs,options);
            end
            
            % If we are dealing with missing observation we need to draw
            % nowcast as well (some method are not related to the parameter
            % draw of the given model an is already produced)
            if isempty(inputs.missing)
                Y0 = y0(:,:,ones(1,regimeDraws*draws));
            else
                % Nowcasts
                if missingVar
                    Y0 = nb_forecast.drawNowcastFromKalmanFilter(yD(end-nowcast+1:end,1:nVars,ii)',pD(:,:,:,ii),regimeDraws*draws);  
                elseif forecastOrKalman
                    Y0 = nb_forecast.drawNowcast(y0,options,res,modelDraw,inputs,1);
                else
                    Y0 = Y0All(:,:,ind);
                end
            end
            
            % Make draws number of simulations of the residual and forecast
            % conditional on those residuals
            hh = 1;
            for qq = ind
                [Y(:,:,qq),states(:,:,qq),PAI(:,:,qq)] = nb_forecast.condShockForecastEngine(...
                    Y0(:,end,hh),modelDraw.A,modelDraw.B,modelDraw.C,ss,modelDraw.Qfunc,...
                    X(:,:,qq),E(:,:,qq),states(:,:,qq),restrictions.PAI0,nSteps,inp);
                hh = hh + 1;
            end
            
            % Append contribution of exogenous variables when dealing with
            % ARIMA models
            if strcmpi(model.class,'nb_arima')
                [Y(1,2:end,ind),Z(:,:,ind)] = nb_forecast.addZContribution(Y(1,2:end,ind),modelDraw,options,restrictions,inputs,draws,1);
            end
            
            % Store nowcast
            if nowcast > 0
                if missingVar
                    if strcmpi(inputs.method,'asymptotic')
                        Ynow(:,:,ind) = repmat(yD(end-nowcast+1:end,1:nVars,ii)',[1,1,draws]);
                    else
                        Ynow(:,:,ind) = Y0;
                    end
                elseif forecastOrKalman
                    Ynow(:,:,ind) = Y0;
                else
                    Ynow(:,:,ind) = Y0All(:,:,ind);
                end    
            end
            
            % Report current status in the waitbar's message field
            if ~inputs.parallel
                if h.canceling
                    error([mfilename ':: User terminated'])
                end
                if rem(kk,note) == 0
                    h.status2 = kk + extra;
                    h.text2   = ['Finished with ' int2str(kk) ' posterior draws in ' int2str(jj) ' tries...'];
                end
            end

        end
        
        % Delete the waitbar.
        if ~isempty(inp)
            deleteThird(inp.waitbar);
        end
        if ~inputs.parallel
            deleteSecond(h);
        end
        
    end
    
    if ~isempty(inputs.missing)
        % First period of the nowcast is already in Y!
        Y = [Ynow(:,1:end-1,:),Y];
    end
    
    if strcmpi(model.class,'nb_dsge')
        if ~iscell(model.ss) % If MS already taken care of
            Y = bsxfun(@plus,Y,model.ss); 
        end
    end
    
    if strcmpi(model.class,'nb_arima')
        XE = [permute(Z,[2,1,3]),permute(E(:,1:nSteps,:),[2,1,3])];
    else
        XE = [permute(X,[2,1,3]),permute(E(:,1:nSteps,:),[2,1,3])];
    end
          
end
