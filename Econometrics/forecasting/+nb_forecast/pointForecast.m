function [Y,evalFcst,solution] = pointForecast(y0,restrictions,model,options,results,nSteps,iter,actual,inputs,solution)
% Syntax:
%
% [Y,evalFcst,solution] = nb_forecast.pointForecast(y0,restrictions,...
%                         model,options,results,nSteps,start,iter,...
%                         actual,inputs,solution)
%
% Description:
%
% Produce point forecast.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    inputs = nb_defaultField(inputs,'bounds',[]);
    if strcmpi(model.class,'nb_tvp')
        [Y,XE] = nb_forecast.tvp(restrictions,model,options,results,nSteps,iter,inputs,'point');
        dep    = nb_forecast.getForecastVariables(options,model,inputs,'pointForecast');
    elseif strcmpi(model.class,'nb_dsge') && options.stochasticTrend
        [Y,X,E] = nb_forecast.forecastStochasticTrend(y0,restrictions,model,options,results,nSteps,iter,inputs);
        dep     = nb_forecast.getForecastVariables(options,model,inputs,'pointForecast');
    else
        
        ss = [];
        if strcmpi(model.class,'nb_dsge')
            if iscell(model.ss)
                ss = model.ss;
            else
                y0 = y0 - model.ss;
                if ~isempty(restrictions.Y)
                    condY          = restrictions.Y;
                    ssY            = model.ss(restrictions.indY);
                    restrictions.Y = bsxfun(@minus,condY,ssY');
                end
            end 
        end

        try options = options(iter); catch; end %#ok<CTCH>

        forecastOrKalman = false;
        if ~isempty(inputs.missing)
            if strcmpi(options.missingMethod,'forecast') || strcmpi(options.missingMethod,'kalmanfilter')
                forecastOrKalman = true;
                % For the missing method 'forcast' we need to update the
                % nowcast given the full sample estimates (where the missing 
                % data are fill in for).
                yNow = nb_forecast.drawNowcast(y0,options,results,model,inputs,iter);
                y0   = yNow(:,end);
            end
        end

        % Get model info
        [A,B,C,~,Qfunc] = nb_forecast.getModelMatrices(model,iter);

        % Get the variables to forecast
        dep = nb_forecast.getForecastVariables(options,model,inputs,'pointForecast');

        % Are we doing conditional forecasting?
        index = restrictions.index;
        if restrictions.softConditioning

            [E,X,states,solution] = dsge.softConditionalProjectionEngine(y0,A,B,C,ss,Qfunc,nSteps,restrictions,solution);

        elseif restrictions.condDistribution

            if restrictions.type == 3 

                % Uses the mean of the distributions to make a point forecast
                [E,X,states,solution] = nb_forecast.conditionalProjectionEngine(y0,A,B,C,ss,Qfunc,nSteps,restrictions,solution);

            else % Only restrictions on exogenous and shocks

                X      = restrictions.X(:,:,index)'; % nb_distribution object
                X      = mean(X); %#ok<UDIM>
                E      = restrictions.E(:,:,index)'; % nb_distribution object
                E      = mean(E); %#ok<UDIM>   
                states = restrictions.states;

            end

        elseif restrictions.type == 3 % Restrictions on endogenous variables

            if ~nb_isempty(inputs.bounds)
                inputs.bounds         = nb_forecast.interpretRestrictions(inputs.bounds,model.endo,model.res);
                restrictions          = nb_forecast.expandRestrictionsForBoundedForecast(restrictions,nSteps);
                [E,X,states,solution] = nb_forecast.boundedConditionalProjectionEngine(y0,A,B,C,ss,Qfunc,nSteps,restrictions,solution,inputs);
                inputs.bounds         = []; % Remove bounds during last step
            else
                [E,X,states,solution] = nb_forecast.conditionalProjectionEngine(y0,A,B,C,ss,Qfunc,nSteps,restrictions,solution);
            end
            
        else % Only restrictions on exogenous and shocks

            if isfield(inputs,'exoProj')
                exoProj = inputs.exoProj;
            else
                exoProj = '';
            end
            X = restrictions.X(:,:,index)';
            if ~isempty(exoProj)
                XAR = nb_forecast.estimateAndBootstrapX(options,restrictions,1,restrictions.start,inputs); 
                X   = [X;XAR];
            end
            E      = restrictions.E(:,:,index)';
            states = restrictions.states;
            if iscell(C)
                CT = C{1};
            else
                CT = C;
            end
            if size(CT,3) > 1
                ShockHorizon = size(CT,3) - 1 + nSteps;
                if size(E,2) < ShockHorizon
                    E = [E,zeros(size(E,1),size(CT,3) - 1)]; % Expected shocks
                end
            end
        end

        % Do the forecast
        if strcmpi(model.class,'nb_fmsa')

            Y     = B*X(:,1);
            nDep  = length(dep);
            leads = size(Y,1)/nDep;
            Y     = reshape(Y,[nDep,leads]);
            Y     = permute(Y,[2,1]);
            Y     = Y(1:nSteps,:);

        elseif strcmpi(model.class,'nb_sa')

            Y     = B*X(:,1);
            nDep  = length(dep);
            leads = size(Y,1)/nDep;
            Y     = reshape(Y,[leads,nDep]);
            Y     = Y(1:nSteps,:);

        else
            
            % Check if bounded forecast (conditional on exogenous only)
            % are going to be made
            inp = [];
            if ~nb_isempty(inputs.bounds)
               inp = nb_forecast.setUpForBoundedForecast(nSteps,model,restrictions,inputs,1); 
            end

            [Y,states,PAI,E] = nb_forecast.condShockForecastEngine(y0,A,B,C,ss,Qfunc,X,E,states,restrictions,nSteps,inp);
            
            if strcmpi(model.class,'nb_dsge')
                if ~iscell(model.ss)
                    % In the case of Markov switching or model with
                    % break-points this is already taken care of...
                    Y = bsxfun(@plus,Y,model.ss); 
                end
            end

            if isfield(results,'densities')
               nDep  = length(nb_forecast.getForecastVariables(options,model,inputs,'notAll'));
               [Y,X] = nb_forecast.map2Density(results.densities,Y,X,nDep);
            end
                
            if forecastOrKalman
                Y = [yNow(:,1:end-1),Y];
            end
            
            if strcmpi(model.class,'nb_fmdyn') || strcmpi(model.class,'nb_favar')  
                if ~isempty(inputs.observables)% Factor model
                    [dep,Y] = nb_forecast.doMeasurementEq(inputs,nSteps,model,Y,X,dep,iter);
                end
            else
                if ~isempty(inputs.missing)
                    Y = Y(1:size(dep,2),:);
                else
                    Y = Y(1:size(dep,2),2:end);
                end
            end
            Y = permute(Y,[2,1]);

        end

        if strcmpi(model.class,'nb_arima')

            % Add contribution of exogenous variables in the observation
            % equation
            Y     = Y';
            [Y,Z] = nb_forecast.addZContribution(Y,model,options,restrictions,inputs,1,iter);
            Y     = Y';
 
            % Undiff ARIMA model
            Y   = nb_forecast.undiffARIMA(options,restrictions.start,Y); 
            dep = regexprep(dep,'diff\d_','');

        end

        % Special stuff for MF-VAR models
        if strcmpi(model.class,'nb_mfvar')
            [Y,dep] = nb_forecast.mapToObservablesMFVAR(Y,options,model,inputs,restrictions.start);
        end
        
        % Merge the states if we are dealing with a Markov-switching model
        if nb_isModelMarkovSwitching(model)
            if isempty(inputs.missing)
                Y = [Y,states(:),permute(PAI(:,2:end),[2,1])];
            else
                Y = [Y,[nan(size(inputs.missing,1),1);states(:)],permute(PAI,[2,1])]; % Include nowcast
            end
            dep = [dep,'states',model.regimes];
        end

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
            if not(strcmpi(model.class,'nb_fmsa') || strcmpi(model.class,'nb_sa'))
                if strcmpi(model.class,'nb_arima')
                    dep = [dep,model.factors,model.res];
                    Y   = [Y,permute(X,[2,1,3]),permute(Z,[2,1,3]),permute(E(:,1:nSteps,:),[2,1,3])];
                elseif strcmpi(model.class,'nb_tvp')
                    dep = [dep,model.factors,model.res,model.parameters,model.paramRes];
                    Y   = [Y,XE];
                else
                    dep = [dep,model.exo,model.res];
                    Y   = [Y,permute(X(:,1:nSteps,:),[2,1,3]),permute(E(:,1:nSteps,:),[2,1,3])];
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
        [ind,indV] = ismember(vars,dep);
        indV       = indV(ind);
        Y          = Y(:,indV,:);
        dep        = dep(indV);
    end
        
    % Evaluate point forecast
    evalFcst = nb_forecast.evaluatePointForecast(Y,actual,dep,model,inputs);
    if strcmpi(model.class,'nb_mfvar')
        evalFcst = nb_forecast.evaluatePointForecastLowFreq(evalFcst,options,Y,dep,model,inputs,restrictions.start);
    end
     
end
