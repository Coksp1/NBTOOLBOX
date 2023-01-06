function fcst = nb_forecast(model,options,results,startInd,endInd,nSteps,inputs,condDB,condDBVars,shockProps)
% Syntax:
%
% forecastDB = nb_forecast(model,options,results,startInd,endInd,nSteps,...
%                          inputs,condDB,condDBVars,shockProps)
%
% Description:
%
% Do conditional forecast with a model written on a companion form.
%
% See Junior Maih (2010), Conditional forecast in DSGE models and
% Kenneth S. Paulsen (2010), Conditional forecasting with DSGE models - 
% A conditional copula approach.
%
% This function makes it also possible to use arbitary distribution to draw
% from to make uncertainty bands:
%
% 1. It is possible to identify the shock given the conditional information
%    and then using the shockProps input to specify the distributions to
%    draw from around the identified shocks. It is important that the
%    mean of the specified distributions are the same as the identified 
%    shocks!
%
% 2. It is possible to use the condDB input to provide the distributions
%    to condition on. Then by using the correlation matrix provided by
%    inputs.sigma and a guassian copula random draws are made from the 
%    multivariate conditional distribution. For each draw the shocks to
%    match the conditional information are found and the conditional
%    forecats for that draw is produced. This will map the distribution
%    of the conditional information into restrictions on the distribution
%    of the shocks. You should check the distribution of the shocks after
%    using this algorithm to assure you that the identification has
%    succeeded.
%
% Input:
% 
% - model      : See the solution property to the model object being
%                forecasted. E.g. the property solution of the
%                nb_model_generic class.
%
% - options    : Estimation options. Output from the estimator functions.
%                E.g. nb_olsEstimator.estimate.
%
% - results    : Estimation results. Output from the estimator functions.
%                E.g. nb_olsEstimator.estimate.
%
% - startInd   : The start period of the forecast. (I.e. history + 1)
%
% - endInd     : If recursive conditional forecast is wanted this period
%                must be provided. Be aware that the condDB input must then
%                have its third dimension set to:
%
%                nPeriods = endInd - startInd + 1
%
%                If empty nPeriods = 1.
%
% - nSteps     : The number of steps to forecast. Default is 8.
%
% - inputs     : A struct with fields (See nb_model_generic.forecast)
%         
% - condDB     : One of the following:
%
%                > A double with size nSteps x nCondVar x nPeriods with the  
%                  information to condition on.
%
%                  If you condition on endogenous variables (possibly 
%                  residuals/shocks also) this function will find the  
%                  linear combination of the shock that minimize its 
%                  variance.
%               
%                > A double with size nSteps x nCondVar x 3 with the  
%                  information to condition on. Page 2 must include the 
%                  upper bound and page 3 the lower bound of the truncated  
%                  normal distribution for the given conditional 
%                  information. Both bound can be given as nan 
%                  (-inf or inf). Be aware that it is also possible to use
%                  truncated distribution with the next input type, but
%                  that the algorithm used by this options is much faster.
%                  (Of cource here all conditional information must be 
%                  either normal or truncated normal.)
%
%                > A nb_distribution object with size nSteps x nCondVar x 1  
%                  with the distributions to condition on.
%
%                  If you condition on endogenous variables (only) and no
%                  residuals/shocks this function will find the linear 
%                  combination of the shock that minimize its variance for
%                  each draw from the multivariate distribution created by
%                  using a copula with the provided marginals and the
%                  correlation matrix (See inputs.sigma).           
% 
%                All the variables in thex_t matrix must be provided. 
%                I.e. model.exo variables. (Except seasonals, constant and  
%                time-trend). The data  must be ordered accordingly to 
%                condDBVars (second dimension), and the first observation 
%                is taken to be startInd. 
%                
%                To be able to match your restrictions on endogenous
%                variables to a specified group of shock use the 
%                shockProps input.
%
%                Caution : If empty unconditional forecast will be 
%                          produced or forecast condition on exogenous 
%                          variables set to zero (Except seasonals,  
%                          constant and time-trend)
%
% - condDBVars : A cellstr with the variables to condition on. Can include
%                endogenous, exogenous and shock variables.
%
% - shockProps : A 1xnExo struct with fields:
%   
%                > Name              : The name of the residual/shock  
%                                      to use to match the conditional 
%                                      information. If an exogenous
%                                      variable is not included here, it
%                                      means that it is not activated.
%
%                > StandardDeviation : Standard deviation of the shock.
%                                      This option can be used to adjust
%                                      the standard deviation away from the
%                                      estimated one. If given as nan the
%                                      estimated one is used. 
%
%                > Horizon           : Anticipated horizon of the shocks.
%
%                > Periods           : The active periods of the shock. If 
%                                      nan, the shock is active for all 
%                                      periods.
%
% Output:
% 
% - forecast : A struct with the forecast output.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Set some default values
    options = nb_defaultField(options,'real_time_estim',false);
    options = nb_defaultField(options,'recursive_estim',false);
    options = nb_defaultField(options,'estimator','');
    options = nb_defaultField(options,'class','');
    if ischar(inputs.fcstEval) && ~isempty(inputs.fcstEval)
        inputs.fcstEval = cellstr(inputs.fcstEval);
    end
    inputs = nb_defaultField(inputs,'condDBStart',1);
    inputs = nb_defaultField(inputs,'condDBType','soft');
    inputs = nb_defaultField(inputs,'density',false);
    inputs = nb_defaultField(inputs,'kalmanFilter',false);
    
    if strcmpi(model.class,'nb_exprModel')
        inputs.condDB     = condDB;
        inputs.condDBVars = condDBVars;
        fcst              = nb_forecast.exprModel(model,options,results,startInd,endInd,nSteps,inputs);
        return
    end
    
    % Early test
    try
        if any(strcmpi(model.class,{'nb_fmsa','nb_sa','nb_midas'}))
            if nSteps > length(model.endo)
                error('nb_forecast:ToHighNStep',[mfilename ':: The model type nb_fmsa/nb_sa/nb_midas cannot forecast longer than its option nStep (' int2str(length(model.endo)) '). '...
                                 'Attempts to forecast ' int2str(nSteps) ' periods.'])
            end
        end
    catch Err
        if strcmpi(Err.identifier,'nb_forecast:ToHighNStep')
            rethrow(Err)
        else
            error([mfilename ':: The model solution (struct) is not correct!'])
        end
    end
    
    if strcmpi(model.class,'nb_midas')
        fcst = nb_forecast.midas(model,options,results,startInd,endInd,nSteps,inputs);
        return
    end
    
    % Check inputs
    %--------------------------------------------------------------
    if strcmpi(options(end).estimType,'bayesian')
        if isempty(inputs.method)
            inputs.method = 'posterior';
        elseif ~strcmpi(inputs.method,'posterior')
            error([mfilename ':: Density forecast method ''posterior'' is the only supported method for bayesian models.']) 
        end
    else
        if isempty(inputs.method)
            if strcmpi(options(1).estimator,'nb_mlEstimator')
                inputs.method = 'asymptotic';
            else
                inputs.method = 'bootstrap';
            end
        elseif strcmpi(inputs.method,'posterior')
            error([mfilename ':: Density forecast method ''posterior'' is only supported for bayesian methods.']) 
        end
    end 
    
    if ~isfield(inputs,'foundReplic')
        inputs.foundReplic = [];
    end
    if ~nb_isempty(inputs.foundReplic)
        if options(end).recursive_estim && ~isempty(inputs.fcstEval)
            error([mfilename ':: The foundReplic input cannot be used with recursive out-of-sample forecasting.'])
        end
    end
    
    % Interpret the bins input
    %-------------------------
    inputs = nb_forecast.interpretBins(options(end),inputs);
    
    % Prepare the conditional data
    %------------------------------------------------------------------
    inputs.startInd = startInd;
    inputs.endInd   = endInd;
    if ~isempty(inputs.fcstEval)
        if isempty(endInd)
            endInd = options(end).estim_end_ind + 1;
        end
    end
    
    if isempty(endInd)
        inputs.nPeriods = 1;
        if isempty(startInd)
            if isfield(options,'estim_end_ind')
                start = options(end).estim_end_ind;
            else
                start = 1;
            end
        else
            start = startInd - 1;
            if ~isempty(inputs.exoProj)
               if start >  options(end).estim_end_ind
                  error([mfilename ':: Cannot forecast from a period after estim_end_date + 1 when using the ''exoProj'' option.']) 
               end
            end
        end
    else
        if isempty(startInd)
            if isempty(options(end).recursive_estim_start_ind)
                start = options(end).estim_start_ind;
            else 
                start = options(end).recursive_estim_start_ind;
            end
            inputs.nPeriods = endInd - start;
        else
            inputs.nPeriods = endInd - startInd + 1;
            start           = startInd - 1;
        end
    end
    if isfield(inputs,'initPeriods')
        if isempty(inputs.initPeriods)
            inputs.initPeriods = 0;
        end
    else
        inputs.initPeriods = 0;
    end
    
    nSteps = max(nSteps,size(condDB,1) + inputs.condDBStart - 1 - inputs.initPeriods);
    
    % We need the start and end index of forecast inside 
    % nb_forecast.prepareRestrictions
    inputsT          = inputs;
    inputsT.startInd = start;
    inputsT.endInd   = endInd;
    restrictions     = nb_forecast.prepareRestrictions(model,options(end),results,nSteps,condDB,condDBVars,inputsT,shockProps);
    
    % Get the number of anticipated steps
    %-----------------------------------------------------------------
    if nb_isempty(shockProps)
        numAntSteps = 1;
    else
        if isfield(shockProps,'Horizon')
            numAntSteps = max([shockProps.Horizon]);
        else
            numAntSteps = 1;
        end
    end

    % Reset models residual covariance matrix
    %------------------------------------------------------------------
    if isfield(restrictions,'covE')
        
        if iscell(model.vcv)
            vcv = model.vcv{1};
        else
            vcv = model.vcv;
        end
        if size(restrictions.covE,1) ~= size(vcv,1) || size(restrictions.covE,2) ~= size(vcv,2)
            error([mfilename ':: When manually reseting the covariance matrix of the shocks/residuals the dimension '...
                'of the new matrix must be the same as the old one.'])
        end
        if iscell(model.vcv)
            for ii = 1:length(model.vcv)
                model.vcv{ii} = restrictions.covE;
            end
        else
            model.vcv = restrictions.covE;
        end
        
    end
    
    % Get the expanded solution (given anticipated shocks)
    % Assume that all shocks has variance 1
    %------------------------------------------------------------------
    if numAntSteps > 1
        if ~isfield(model,'CE')
            error([mfilename ':: If the shockProps indicate anticipated shock you need to solve the model with the same assumption. See nb_dsge.solve.'])
        end
    end
    
    % Use the same seed when returning the "random" numbers
    %--------------------------------------------------------------
    if isfield(inputs,'seed')
        seed = inputs.seed;
    else
        seed = 1;
    end
    defaultStream = RandStream.getGlobalStream;
    savedState    = defaultStream.State;
    s             = RandStream.create('mt19937ar','seed',seed);
    RandStream.setGlobalStream(s);
    
    % Do the forecasting
    %------------------------------------------------------------------
    try
        fcst = generalForecast(model,options,results,startInd,endInd,...
                                    nSteps,inputs,restrictions);
    catch Err
        defaultStream.State = savedState;
        RandStream.setGlobalStream(defaultStream);
        rethrow(Err)
    end
    
    % Set seed back to old
    %------------------------------------------------------------------
    defaultStream.State = savedState;
    RandStream.setGlobalStream(defaultStream);

end

%==========================================================================
% SUB
%==========================================================================
function forecast = generalForecast(model,options,results,start,finish,nSteps,inputs,restrictions)

    % Get the starting values
    if isempty(inputs.fcstEval)
        last = start - 1;
    else
        last = finish - 1;
        if ~isempty(last) && last > options(end).estim_end_ind
            sDate = nb_date.date2freq(options(end).dataStartDate) + (options(end).estim_start_ind - 1);
            eDate = nb_date.date2freq(options(end).dataStartDate) + (options(end).estim_end_ind - 1);
            error([mfilename ':: Cannot locate starting values for recursive forecast outside the estimation sample; ' toString(sDate) ' - ' toString(eDate)])
        end
    end
    Y0 = nb_forecast.getStartingValues(inputs.startingValues,options,model,results,last);
    
    % Are we dealing with conditional information for the initial values?
    if inputs.condDBStart == 0
        Y0 = nb_forecast.setInitialValues2CondDB(Y0,model,restrictions);
    end
    
    if ~isempty(finish)
        if length(Y0) < finish - start + 1
            if isscalar(model.A)
                if model.A == 0
                    Y0 = [Y0;zeros(finish - start + 1 - length(Y0),size(Y0,2))]; % Not a dynamic model, so this is not a problem!
                else
                    error([mfilename ':: The end date of recursive forecast is outside the window of historical data. Cannot find a initial value.'])
                end
            else
                error([mfilename ':: The end date of recursive forecast is outside the window of historical data. Cannot find a initial value.'])
            end
        end
    end
    
    % Get the variables to forecast
    dep = nb_forecast.getForecastVariables(options,model,inputs,'notAll');
    if nb_isModelMarkovSwitching(model)
        if numel(options) > 1
            error([mfilename ':: Real-time forecast for Markov switching models are not supported.'])
        end        
        dep               = [dep,'states',model.regimes];
        restrictions.PAI0 = ms.getStartingProbabilities(inputs.startingProb,options,model,results);
    else
        restrictions.PAI0 = [];
    end
    
    if isfield(inputs,'reporting')
        if ~isempty(inputs.reporting)
            dep = [dep,inputs.reporting(:,1)']; % Include reported variables as well
        end
    end
    
    % nb_fmdyn should report all observables as default
    if isempty(inputs.observables) && isfield(model,'observables')
        inputs.observables = model.observables;
    end
    
    % Get the actual lower and upper percentiles
    if isempty(inputs.draws)
        inputs.draws = 1;
    end
    if ~iscell(model.A)
         inputs.regimeDraws = 1;
    end
    
    if ~isfield(options(end),'estim_method')
        options(end).estim_method = '';
    end
    quantile = strcmpi(options(end).estim_method,'quantile');
    
    if quantile
        
        inputs.perc = [];
        dim3        = length(options(end).quantile);
        if inputs.draws < 2 && inputs.parameterDraws < 2 % Point forecast
            model = nb_forecast.getQuantileModel(options,model,0.5);
            dim3  = 1;
        end
        
    else
        if isempty(inputs.perc)
            dim3 = inputs.draws*inputs.parameterDraws*inputs.regimeDraws; % Number of simulations
            if dim3 ~= 1
                dim3 = dim3 + 1; % One page for mean as well
            end
        else
            inputs.perc = nb_interpretPerc(inputs.perc,false);
            dim3        = size(inputs.perc,2) + 1;
        end

        if dim3 == 1
            inputs.perc = [];
        end
    end
    
    % Are we going to produce nowcast?
    nowcast        = 0;
    inputs.missing = [];
    if isfield(options(end),'missingMethod')
        if ~isempty(options(end).missingMethod)
            [nowcast,inputs.missing] = nb_forecast.checkForMissing(options(end),inputs,dep);
        end
    end
    
    % Preallocation
    fcstVar = dep;
    if strcmpi(model.class,'nb_arima')
        % For I(x) variables we need to get the actual variable to forecast
        if options(end).integration > 0
            fcstVar = regexprep(fcstVar,'diff\d_','');
            dep     = regexprep(dep,'diff\d_','');
        end
    end
    if or(strcmpi(inputs.output,'all'), strcmpi(inputs.output,'full'))
        if isempty(inputs.missing)
            if not(strcmpi(model.class,'nb_fmsa') || strcmpi(model.class,'nb_sa'))
                if strcmpi(model.class,'nb_arima')
                    fcstVar = [fcstVar,model.exo,model.factors,model.res];
                elseif strcmpi(model.class,'nb_tvp')
                    fcstVar = [fcstVar,model.factors,model.res,model.parameters,model.paramRes];
                else
                    fcstVar = [fcstVar,model.exo,model.res];
                end
            end
        end
    end
    allVars = fcstVar;
    
    if ~isempty(inputs.varOfInterest)
        if ischar(inputs.varOfInterest)
            vars = cellstr(inputs.varOfInterest);
        else
            vars = inputs.varOfInterest;
        end
        [ind,indV] = ismember(vars,dep);
        if any(~ind) && ~isempty(inputs.missing)
            error([mfilename ':: Could not locate the variable(s) ' toString(vars(~ind)) ' among the forecasted variables from this model. '...
                'Remember when the ''missing'' option is used during estimation, no exogenous variables can be asked for (''varOfInterest'' input.)'])
        end
        indV       = indV(ind);
        dep        = dep(indV);
        [ind,indV] = ismember(vars,fcstVar);
        indV       = indV(ind);
        fcstVar    = fcstVar(indV);
    end
    numVar = length(fcstVar);
    
    % Does conditional info introduce ragged-edge?
    if strcmpi(inputs.condDBType,'hard')
        [nowcastCond,missingCond] = nb_forecast.getMissingFromCondInfo(options(end),inputs,restrictions,allVars);
    end
    
    %===============================================================================================
    if ~isempty(inputs.fcstEval) % Out of sample forecast or in sample forecast 
    %===============================================================================================
    
        % Get some properties
        [start,finish,start_est,startFcst] = nb_forecast.getStartAndEnd(inputs,model,options,start,finish);

        % Get the actual data to evaluate against
        if startFcst(1) - nowcast <= 0
            ind             = startFcst - nowcast > 0;
            actualTemp      = nb_forecast.getActual(options,inputs,model,nSteps+nowcast,dep,startFcst(ind)-nowcast);
            actual          = nan(nSteps+nowcast,size(actualTemp,2),length(startFcst));
            actual(:,:,ind) = actualTemp;
        else
            actual = nb_forecast.getActual(options,inputs,model,nSteps+nowcast,dep,startFcst-nowcast);
        end
        
        % Create waiting bar window
        [h,iter,closeWaitbar] = nb_forecast.createWaitbar(inputs,start,finish);
        inputs.waitbar        = h;
        
        % Do the recursive forecast for each period   
        forecastData = nan(nSteps+nowcast,numVar,dim3,iter);
        kk           = 1;
        if options(end).recursive_estim && ~isempty(options(end).recursive_estim_start_ind)   
            jj = start - options(end).recursive_estim_start_ind + start_est;
            if iter > size(model.A,3)
                error([mfilename ':: The number recursive forecasting periods (' int2str(iter) ') are greater than the number of recursive estimation periods (' size(model.A,3) ').'])
            end
        else
            jj = 1;
        end
        
        note     = nb_when2Notify(iter);
        solution = struct(); % A struct storing matrices mapping the restrictions made, only solved once
        for ii = start:finish
        
            % Get starting obs
            y0 = Y0(ii,:)';
            
            % Store the iteration index
            restrictions.index = kk;
            restrictions.start = startFcst(kk)-1;
            
            % Calculate forecast
            if options(end).recursive_estim
                % If we are doing conditional forecasting with recursively 
                % changing parameters we need to re-construct the 
                % conditional matrices at every recursive period.
                % (Same will happend if we do conditional forecasting
                % with parameter uncertainty!)
                solution = struct(); 
                index    = jj;
            else
                index = 1;
            end
            
            if inputs.draws < 2 && inputs.parameterDraws < 2
                [Y,evalFcstT,solution] = nb_forecast.pointForecast(y0,restrictions,model,options,results,...
                                            nSteps,index,actual(:,:,kk),inputs,solution);
            else
                [Y,evalFcstT,solution] = nb_forecast.densityForecast(y0,restrictions,model,options,results,...
                                            nSteps,index,actual(:,:,kk),inputs,solution);
            end
            
            % Collect forecast of dependent variables
            forecastData(:,:,:,kk) = Y;
            try
                evalFcst = [evalFcst,evalFcstT]; %#ok<AGROW>
            catch %#ok<CTCH>
                evalFcst = evalFcstT;
            end
            
            % Report current estimate in the waitbar's message field
            if inputs.parallel
                if ~isempty(h)
                    fprintf(h.Value,['Recursive Forecast for Model '  int2str(inputs.index) ' of ' int2str(inputs.nObj) '; '...
                                     'Finished with ' int2str(kk) ' of ' int2str(iter) ' iterations...\r\n']); 
                end
            else
                if h.canceling
                    error([mfilename ':: User terminated'])
                end
                if rem(kk,note) == 0
                    h.status1 = kk;
                    h.text1   = ['Finished with ' int2str(kk) ' of ' int2str(iter) ' iterations...'];
                end
            end
            
            kk = kk + 1;
            jj = jj + 1;
                      
        end
        
        % Delete waiting bar
        if closeWaitbar
            delete(h);
        end
        
    %======================================================================
    else % Not recursive forecast
    %======================================================================
        
        % Get starting obs
        if isempty(start)
            y0        = Y0(end,:);
            options   = options(end);
            if isfield(options,'estim_end_ind')
                startFcst = options.estim_end_ind + 1;
            else
                startFcst = 1;
            end
        else
            startFcst = start;
            start_est = options(end).estim_start_ind;
            start     = start - start_est + 1;
            if strcmpi(model.class,'nb_arima')
                value = max(options(end).MA,options(end).AR);
                if start < 1 + value
                    startD    = nb_date.date2freq(options(end).dataStartDate);
                    startFcst = startD + (start-1);
                    startC    = startD + value;
                    error([mfilename ':: Cannot forecast from a date (' toString(startFcst) ') before the start date of estimation + ' int2str(value) ' (' toString(startC) '). '...
                        '(Initial values of MA or AR terms may also be missing)'])
                end
            else
                if start < 2
                    startD    = nb_date.date2freq(options(end).dataStartDate);
                    startFcst = startD + (start-1);
                    startC    = startD + 1;
                    error([mfilename ':: Cannot forecast from a date (' toString(startFcst) ') before the start date of estimation + 1 (' toString(startC) ').'])
                end
            end
            y0 = Y0(start-1,:);
        end
        
        if options(end).recursive_estim && ~isempty(options(end).recursive_estim_start_ind)
            iter = startFcst - options(end).recursive_estim_start_ind;
        else
            iter = 1;
        end
        
        % Calculate forecast
        restrictions.index = 1;
        restrictions.start = startFcst - 1;
        if inputs.draws > 1 || inputs.parameterDraws > 1 || inputs.regimeDraws > 1 || inputs.density
            [Y,evalFcst] = nb_forecast.densityForecast(y0',restrictions,model,options,results,nSteps,iter,[],inputs,struct());
        else
            [Y,evalFcst] = nb_forecast.pointForecast(y0',restrictions,model,options,results,nSteps,iter,[],inputs,struct());
        end
        forecastData = Y;
        
    end
    
    % Fixed the dependent output when dealing with MF-VAR
    if strcmpi(options(end).class,'nb_mfvar')
        indR = ismember(dep,model.endo);
        dep  = dep(~indR);
    end
    
    % Some properties may be to memory intensive, so we can save does to 
    % files and store the path to the file instead
    saveToFile = false;
    if inputs.saveToFile && inputs.draws > 1
        [evalFcst,saveToFile] = nb_forecast.saveToFile(evalFcst,inputs);
    end
    
    % When conditioning on dependent variables we must append missing info
    if strcmpi(inputs.condDBType,'hard')
        if ~isempty(missingCond)
            
            nowcast = nowcast + nowcastCond;
            if isempty(inputs.missing)
                inputs.missing = missingCond;
            else
                inputs.missing = [inputs.missing;missingCond];
            end
            
            % Split nowcast and forecast!
            nSteps = nSteps - nowcastCond; 
            if nSteps < 0
                % This should not happend??
                error('You have conditional information that is longer than the forecast.')
            end
            
            % Indicate where FORECAST starts!
            startFcst = startFcst + nowcastCond; 
        end
    end
    
    % Which of the reported variables are missing?
    missing = inputs.missing;
    if ~isempty(missing)
        [~,ind] = ismember(fcstVar,allVars);
        missing = missing(:,ind);
        lastNM  = find(~any(missing,2));
        if ~isempty(lastNM) && ~strcmpi(inputs.condDBType,'hard')
            lastNMFound = lastNM(1);
            for ii = 2:size(lastNM,1)
                if lastNM(ii) - lastNMFound > 1
                    % For a MF-VAR we may end up with a case that we have a
                    % non-missing observation in the middle here! So need
                    % to stop if the step > 1!
                    break
                else
                    lastNMFound = lastNM(ii);
                end
            end
            missing      = missing(lastNMFound+1:end,:);
            nowcast      = nowcast - lastNMFound;
            forecastData = forecastData(lastNMFound+1:end,:,:,:);
        end
        aMissing = any(missing,1);
        if all(~aMissing) && nSteps ~= 0 % None of the chosen variables have nowcast
            forecastData  = forecastData(1+nowcast:end,:,:,:);
            missing       = [];
            fields        = fieldnames(evalFcst);
            indNot        = ismember(fields,{'int','density'});
            fields        = fields(~indNot);
            for ii = 1:length(fields)
                fcstEvalT = {evalFcst.(fields{ii})};
                if ~isempty(fcstEvalT)
                    evalFcstTemp            = cellfun(@(x)x(1+nowcast:end,:),fcstEvalT,'UniformOutput',false);
                    [evalFcst.(fields{ii})] = deal(evalFcstTemp{:});
                end
            end
            nowcast = 0;
            nSteps  = size(forecastData,1);
        end
    end
        
    % Fix some stuff
    if restrictions.type == 3
        type = 'condendo';
    elseif restrictions.type == 2
        type = 'condexo';
    else
        type = 'unconditional';
    end 
    
    % Clean up inputs, so they can be used when model is updated later
    inputs = nb_forecast.cleanUpInputs(inputs);
    if quantile
        perc = options(end).quantile;
        if any(perc == 0.5)
            ind  = perc == 0.5;
            perc = perc(~ind);
        end
        perc = sort(perc)*100;
    else
        perc = inputs.perc;
    end
    
    if strcmpi(model.class,'nb_fmsa')
        if options(end).factorLead == 1 && ~options(end).unbalanced
            % In this case the regressors are leaded one period, as the
            % observables has one more period of data then the dependent.
            % This means that we are forecasting estime_end_ind + 2 instead
            % of estime_end_ind + 1
            startFcst = startFcst + 1;
        end
    end
    
    % Collect forecast of dependent variables
    forecast = struct('data',           forecastData,...
                      'variables',      {fcstVar},...
                      'dependent',      {dep},...
                      'nSteps',         nSteps,...
                      'type',           type,...
                      'start',          startFcst,...
                      'nowcast',        nowcast,...
                      'missing',        missing,...
                      'evaluation',     evalFcst,...
                      'method',         inputs.method,...
                      'draws',          inputs.draws,...
                      'parameterDraws', inputs.parameterDraws,...
                      'regimeDraws',    inputs.regimeDraws,...
                      'perc',           perc,...
                      'inputs',         inputs,...
                      'saveToFile',     saveToFile);

end
