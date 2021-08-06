function fcst = exprModel(model,options,results,startInd,endInd,nSteps,inputs)
% Syntax:
%
% fcst = nb_forecast.exprModel(model,options,results,startInd,endInd,...
%                   nSteps,inputs)
%
% Description:
%
% Produce forecast of a model using expressions, see the nb_exprModel 
% class.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Use the same seed when returning the "random" numbers
    %--------------------------------------------------------------
    seed          = 2.0719e+05;
    defaultStream = RandStream.getGlobalStream;
    savedState    = defaultStream.State;
    s             = RandStream.create('mt19937ar','seed',seed);
    RandStream.setGlobalStream(s);
    
    % Do the forecasting
    %------------------------------------------------------------------
    try
        fcst = produceFcst(model,options,results,startInd,endInd,nSteps,inputs);
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
function fcst = produceFcst(model,options,results,start,finish,nSteps,inputs)  
    
    % Check conditional data
    if ~isempty(inputs.condDB)
        test = ismember(inputs.condDBVars,options.dependentOrig);
        if any(test)
            error([mfilename ':: Cannot conditional on dependent variables if ',...
                   'the model is of class nb_exprModel. You try to condition on ',...
                   toString(inputs.condDBVars(test))])
        end
        if ~isempty(inputs.fcstEval) 
            error([mfilename ':: Cannot use conditional information when doing ',...
                   'out-of-sample or in-sample recursive forecast with a model of ',...
                   'class nb_exprModel.']); 
        end
    end

    % Get actual data
    Z   = options.data;
    dep = options.dependentOrig;
    if isfield(inputs,'reporting')
        if ~isempty(inputs.reporting)
            indRepRemove = ismember(inputs.reporting(:,1),dep);
            dep          = [dep,inputs.reporting(~indRepRemove,1)']; % Include reported variables as well
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
    
    if ~isempty(inputs.varOfInterest)
        vars = inputs.varOfInterest;
        if ~iscell(vars)
            vars = {vars};
        end
        test = ismember(vars,options.dataVariables);
        if any(~test)
            error([mfilename ':: The follwing variable is not part of the model or among the reported variables; ' toString(vars(~test))])
        end
        fcstVar = inputs.varOfInterest;
        dep     = fcstVar;
    else
        if or(strcmpi(inputs.output,'all'), strcmpi(inputs.output,'full'))
            fcstVar = dep;
            if isempty(inputs.missing)
                fcstVar = [fcstVar,model.exo,model.res];
            end
        else
            fcstVar = dep;
        end
    end
    numVar = length(fcstVar);
    
    % Get the actual lower and upper percentiles
    if isempty(inputs.draws)
        inputs.draws = 1;
    end
    if isempty(inputs.perc)
        dim3 = inputs.draws*inputs.parameterDraws; % Number of simulations
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
    point = inputs.draws < 2 && inputs.parameterDraws < 2;
    
    %===============================================================================================
    if ~isempty(inputs.fcstEval) % Out of sample forecast or in sample forecast 
    %===============================================================================================
    
        % Get some properties
        [start,finish,start_est,startFcst] = nb_forecast.getStartAndEnd(inputs,model,options,start,finish);

        % Get the actual data to evaluate against
        actual = nb_forecast.getActual(options,inputs,model,nSteps+nowcast,dep,startFcst-nowcast);
          
        % Create waiting bar window
        [h,iter,closeWaitbar] = nb_forecast.createWaitbar(inputs,start,finish);
        inputs.waitbar        = h;
        
        % Do the recursive forecast for each period   
        forecastData = nan(nSteps,numVar,dim3,iter);
        kk           = 1;
        if options(end).recursive_estim   
            jj = start - options(end).recursive_estim_start_ind + start_est;
            if iter > size(results.beta{1},3)
                error([mfilename ':: The number recursive forecasting periods (',...
                       int2str(iter) ') are greater than the number of recursive estimation ',...
                       'periods (' size(results.beta{1},3) ').'])
            end
        else
            jj = 1;
        end
        
        note = nb_when2Notify(iter);
        for ii = start:finish
        
            % Calculate forecast
            if options(end).recursive_estim
                index = jj;
            else
                index = 1;
            end
            
            % Store the iteration index
            restrictions.index = kk;
            restrictions.start = startFcst(kk)-1;
            
            if point
                [Y,evalFcstT] = nb_forecast.exprModelPointForecast(Z,restrictions,model,options,results,...
                                            nSteps,index,actual(:,:,kk),inputs);
            else
                [Y,evalFcstT] = nb_forecast.exprModelDensityForecast(Z,restrictions,model,options,results,...
                                            nSteps,index,actual(:,:,kk),inputs);
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
                fprintf(h.Value,['Recursive Forecast for Model '  int2str(inputs.index) ' of ' int2str(inputs.nObj) '; '...
                                 'Finished with ' int2str(kk) ' of ' int2str(iter) ' iterations...\r\n']); 
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
        if ~inputs.parallel
            % Delete waiting bar
            if closeWaitbar
                delete(h);
            end
        end
        missing              = [];
        nowcast              = false;
        startInd             = startFcst;
        correctForAllMissing = false;
        mSteps               = nSteps;
        
    %======================================================================
    else % Not recursive forecast
    %======================================================================
        
        % Get starting obs
        mSteps = nSteps;
        if isempty(start)
            options   = options(end);
            startFcst = options.estim_end_ind + 1;
        else
            startFcst = start;
            if start < 2
                startD     = nb_date.date2freq(results.dataStartDate);
                startFcstD = startD + (start-1);
                startC     = startD + 1;
                error([mfilename ':: Cannot forecast from a date (',...
                       toString(startFcstD) ') before the start date of estimation + 1 (',...
                       toString(startC) ').'])
            end
        end
        
        if options(end).recursive_estim
            iter = startFcst - options(end).recursive_estim_start_ind;
        else
            iter = 1;
        end
        
        % Get missing structure
        correctForAllMissing = false;
        nowcast              = false;
        if or(strcmpi(inputs.output,'all'), strcmpi(inputs.output,'full'))
            missing  = [];
            startInd = startFcst;
        else
            missing = zeros(1,length(dep));
            endHist = startFcst - 1;
            for ii = 1:length(dep)
               indDepOne   = strcmp(dep{ii},options.dataVariables);
               missing(ii) = endHist - find(~isnan(Z(:,indDepOne)),1,'last');
            end
            minM = min(missing);
            if all(missing(1) == missing)
                % All dependent are missing the same number of observations
                % then we correct for that later on
                correctForAllMissing = true;
                missing              = [];
            else
                nowcast = any(missing < 0);
                missing = missing - minM;
            end
            nSteps   = nSteps - minM;
            startInd = startFcst - minM;
        end
        
        % Calculate forecast
        restrictions.index = 1;
        restrictions.start = startFcst - 1;
        if point
            [Y,evalFcst] = nb_forecast.exprModelPointForecast(Z,restrictions,model,options,results,nSteps,iter,[],inputs);
        else
            [Y,evalFcst] = nb_forecast.exprModelDensityForecast(Z,restrictions,model,options,results,nSteps,iter,[],inputs);
        end
        forecastData = Y;
        
    end
    
    % Some properties may be to memory intensive, so we can save does to 
    % files and store the path to the file instead
    saveToFile = false;
    if inputs.saveToFile && inputs.draws > 1
        [evalFcst,saveToFile] = nb_forecast.saveToFile(evalFcst,inputs);
    end
    
    % Clean up inputs, so they can be used when model is updated later
    inputs = nb_forecast.cleanUpInputs(inputs);
    
    % Collect forecast of dependent variables
    if correctForAllMissing
        forecastData = forecastData(1+abs(minM):end,:);
    end
    fcst = struct('data',           forecastData,...
                  'variables',      {fcstVar},...
                  'dependent',      {dep},...
                  'nSteps',         mSteps,...
                  'type',           'unconditional',...
                  'start',          startInd,...
                  'nowcast',        nowcast,...
                  'missing',        missing,...
                  'evaluation',     evalFcst,...
                  'method',         inputs.method,...
                  'draws',          inputs.draws,...
                  'parameterDraws', inputs.parameterDraws,...
                  'regimeDraws',    inputs.regimeDraws,...
                  'perc',           inputs.perc,...
                  'inputs',         inputs,...
                  'saveToFile',     saveToFile);
    
    
end
