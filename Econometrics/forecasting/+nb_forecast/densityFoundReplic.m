function [Y,XE,states,PAI] = densityFoundReplic(y0,restrictions,model,options,results,nSteps,iter,inputs)
% Syntax:
%
% [Y,XE,states,PAI] = nb_forecast.densityFoundReplic(y0,...
%       restrictions,model,options,results,nSteps,iter,inputs)
%
% Description:
%
% Produce density forecast using already solved models.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if strcmpi(model.class,'nb_dsge')
        if strcmpi(model.type,'rise')
            if iscell(model.ss)
                ss = model.ss;
            else
                y0 = y0 - model.ss;
                ss = [];
            end
        else
            ss = [];
        end
    else
        ss = [];
    end

    draws          = inputs.draws;
    actualDraws    = draws;
    if actualDraws == 1
        actualDraws = 0; % Prevent residual uncertainty
    end
    parameterDraws = inputs.parameterDraws;
    regimeDraws    = inputs.regimeDraws;
    if ~nb_isModelMarkovSwitching(model)
        regimeDraws = 1;
    end
    
    try options = options(iter); catch; end %#ok<CTCH>
    
    nVars = size(y0,1);
    if parameterDraws == 1 % Only residual uncertainty  
        error([mfilename ':: The number of parameter draws (parameterDraws) should be greater than 0 when using the foundReplic input.'])
    %======================================================================    
    else % More than 1 parameter draw
    %======================================================================    
        
        modelDraws = inputs.foundReplic;
        replic     = numel(modelDraws);
        if replic < parameterDraws
            error([mfilename ':: The number of solved models given by the foundReplic (' int2str(replic) ') input must be greater than the number '...
                             'of wanted parameter draws (parameterDraws==' int2str(parameterDraws) ').'])
        else
            modelDraws = modelDraws(1:parameterDraws);
        end
        
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
         
        % If we are dealing with missing observation we need to draw
        % nowcast as well (only for some missing methods at this point)
        if ~isempty(inputs.missing)
            forecastOrKalman = false;
            if any(strcmpi(options.missingMethod,{'forecast','kalman'}))
                forecastOrKalman = true;
            else
                Y0All = nb_forecast.drawNowcast(y0,options,results,model,inputs,iter);
            end
        end
        
        % Start looping over parameter draws
        note = nb_when2Notify(parameterDraws);
        for kk = 1:parameterDraws
            
            % Calculate density forecast
            [A,B,C,vcv,Qfunc] = nb_forecast.getModelMatrices(modelDraws(kk),'end');

            % Make draws from the distributions of the exogenous and the shocks
            mm  = regimeDraws*draws*(kk-1);
            ind = 1+mm:regimeDraws*draws+mm;
            if regimeDraws == 1
                [E(:,:,ind),X(:,:,ind),states(:,:,ind)] = nb_forecast.drawShocksAndExogenous(y0,A,B,C,ss,Qfunc,vcv,nSteps,actualDraws,restrictions,struct(),inputs);
            else
                [E(:,:,ind),X(:,:,ind),states(:,:,ind)] = nb_forecast.drawRegimes(y0,A,B,C,ss,Qfunc,vcv,nSteps,draws,restrictions,struct(),inputs,options);
            end
            
            % If we are dealing with missing observation we need to draw
            % nowcast as well (some method are not related to the parameter
            % draw of the given model an is already produced)
            if isempty(inputs.missing)
                Y0 = y0(:,:,ones(1,regimeDraws*draws));
            else
                % Nowcasts
                if forecastOrKalman
                    Y0 = nb_forecast.drawNowcast(y0,options,res,modelDraw,inputs,1);
                else
                    Y0 = Y0All(:,:,ind);
                end
            end
            
            % Make draws number of simulations of the residual and forecast
            % conditional on those residuals
            hh = 1;
            for qq = ind
                [Y(:,:,qq),states(:,:,qq),PAI(:,:,qq)] = nb_forecast.condShockForecastEngine(Y0(:,:,hh),A,B,C,ss,Qfunc,X(:,:,qq),E(:,:,qq),states(:,:,qq),restrictions.PAI0,nSteps,inp);
                hh = hh + 1;
            end
            
            % Append contribution of exogenous variables when dealing with
            % ARIMA models
            if strcmpi(model.class,'nb_arima')
                [Y(1,2:end,ind),Z(:,:,ind)] = nb_forecast.addZContribution(Y(1,2:end,ind),modelDraws(kk),options,restrictions,inputs,draws,1);
            end
            
            % Report current status in the waitbar's message field
            if ~inputs.parallel
                if h.canceling
                    error([mfilename ':: User terminated'])
                end
                if rem(kk,note) == 0
                    h.status2 = kk;
                    h.text2   = ['Finished with ' int2str(kk) ' parameter draws...'];
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
    
    if strcmpi(model.class,'nb_dsge')
        if strcmpi(model.type,'rise')
            if ~iscell(model.ss) % If MS already taken care of
                Y = bsxfun(@plus,Y,model.ss); 
            end
        end
    end
    
    if strcmpi(model.class,'nb_arima')
        XE = [permute(Z,[2,1,3]),permute(E(:,1:nSteps,:),[2,1,3])];
    else
        XE = [permute(X,[2,1,3]),permute(E(:,1:nSteps,:),[2,1,3])];
    end
          
end
