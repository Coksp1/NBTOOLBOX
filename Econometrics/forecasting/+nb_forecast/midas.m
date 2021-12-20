function fcst = midas(model,options,results,startInd,endInd,nSteps,inputs)
% Syntax:
%
% fcst = nb_forecast.midas(model,options,results,startInd,endInd,...
%                   nSteps,inputs)
%
% Description:
%
% Produce forecast of MIDAS models.
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
        fcst = midasFcst(model,options,results,startInd,endInd,nSteps,inputs);
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
function fcst = midasFcst(model,options,results,start,finish,nSteps,inputs)  
    
    if numel(options) > 1
        error('It is not possible to forecast models using the real_time_estim option set to true.')
    end
    
    % Get actual data (and values of lagged dependent variable)
    endo     = strrep(model.endo(1),'_lead1','');
    [~,indY] = ismember(endo,options.dataVariables);
    Y0       = options.data(options.start_low:options.increment:options.end_low,indY);
    
    % Get exogenous
    exo       = options.exogenous;
    [~,indX]  = ismember(exo,options(end).dataVariables);
    X0        = options.data(options.start_high:options.increment:options.end_high,indX);
    if any(strcmpi(options.algorithm,{'almon','legendre'}))
        
        % Transform exogenous using polynomials
        if strcmpi(options.algorithm,'almon')
            Q = nb_almonPoly(options.polyLags,options.nLags + 1,options.nExo); 
        elseif strcmpi(options.algorithm,'legendre')
            Q = nb_legendrePoly(options.polyLags,options.nLags + 1,options.nExo); 
        end
        P = options.polyLags;
        X = nan(size(X0,1),options.nExo*P);
        for t = 1:size(X0,1) 
            X(t,:) = transpose(Q*X0(t,:)');
        end
        X0 = X;
        
    elseif strcmpi(options.algorithm,'mean')
    
        % Transform exogenous using mean
        X = nan(size(X0,1),options.nExo);
        for ii = 1:options.nExo
           ind     = ii:nExo:nExo*nLags;
           X(:,ii) = mean(X0(:,ind),2);
        end
        X0 = X;
        
    end
    if options.constant
       X0 = [ones(size(X0,1),1),X0]; 
    end
    restrictions = struct('X',X0,'type',1,'softConditioning',false,'condDistribution',false,'states',ones(nSteps,1));
    
    % Get the actual lower and upper percentiles
    if isempty(inputs.draws)
        inputs.draws = 1;
    end
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
    
    % Get the forecast variables
    dep     = endo;
    fcstVar = dep;
    if isfield(inputs,'reporting')
        if ~isempty(inputs.reporting)
            fcstVar = [fcstVar,inputs.reporting(:,1)']; % Include reported variables as well
        end
    end
    if ~isempty(inputs.varOfInterest)
        if ischar(inputs.varOfInterest)
            vars = cellstr(inputs.varOfInterest);
        else
            vars = inputs.varOfInterest;
        end
        [ind,indV] = ismember(vars,fcstVar);
        if any(~ind)
            error([mfilename ':: The following variables cannot be asked for (''varOfInterest'' input.) for MIDAS models, i.e; ' toString(vars(~ind))])
        end
        indV       = indV(ind);
        fcstVar    = fcstVar(indV);
        [ind,indV] = ismember(vars,fcstVar);
        indV       = indV(ind);
        fcstVar    = fcstVar(indV);
    end
    numVar = length(fcstVar);
    
    %===============================================================================================
    if ~isempty(inputs.fcstEval) % Out of sample forecast or in sample forecast 
    %===============================================================================================
    
        % Get some properties
        if isempty(start)
            if options.recursive_estim
                start = options.recursive_estim_start_ind_low + 1;
            else
                start = 2; 
            end
        else
            if start < 2
                if input.startIndWarning
                    warning('nb_forecast:adjustStartInd',['Cannot start forecast evalutation before ',...
                        'the start date of estimation + 1 of estimation. Reset to first possible value.'])
                    start = 2;
                else
                    error([mfilename ':: Cannot start forecast evalutation before the start date of estimation + 1 of estimation.'])
                end
            end
            
            % Remove the real time estimation options before the start date 
            % of the forecast
            if numel(options) > 1
                ind = start - options.recursive_estim_start_ind_low;
                if ind < 1
                    error([mfilename ':: Cannot start real-time forecast before the recursive forecast start date.'])
                end
            end
            
        end
        
        if isempty(finish)
            finish = nb_date.date2freq(options.estim_end_date_low) - convert(nb_date.date2freq(options.dataStartDate),1) + 1;
        end
        startFcst = start:finish;
        
        if isempty(startFcst)
            error([mfilename ':: Cannot evaluate forecast. Start date is after the end date of estimation'])
        end
        
        if options.recursive_estim
            if startFcst(1) < 2
                start     = nb_date.date2freq(options.estim_start_date_low);
                startRec  = start + options.recursive_estim_start_ind_low;
                startFcst = start + (startFcst(1) - 1);
                error([mfilename ':: Cannot evaluate forecast. Start date (' toString(startFcst) ') is before the start date of recursive estimation + 1 (' toString(startRec) ')'])
            end
        else
            if startFcst(1) < 2
                start     = nb_date.date2freq(options.estim_start_date_low);
                startRec  = start + 1;
                startFcst = start + (startFcst(1) - 1);
                error([mfilename ':: Cannot evaluate forecast. Start date (' toString(startFcst) ') is before the start date of estimation + 1 (' toString(startRec) ')'])
            end
        end
        
        % Get the actual data to evaluate against
        actual = nb_forecast.getActual(options,inputs,model,nSteps,fcstVar,startFcst);
          
        % Create waiting bar window
        iter = finish - start + 1;
        if inputs.parallel
            h = inputs.waitbar;
        else
            if isfield(inputs,'index')
                h = nb_waitbar5([],['Recursive Forecast for Model '  int2str(inputs.index) ' of ' int2str(inputs.nObj) ],true);
            else
                h = nb_waitbar5([],'Recursive Forecast',true);
            end
            h.maxIterations1 = iter;
            h.text1          = 'Starting...'; 
            inputs.waitbar   = h;
        end
        
        % Do the recursive forecast for each period   
        forecastData = nan(nSteps,numVar,dim3,iter);
        kk           = 1;
        if options.recursive_estim   
            jj = start - options.recursive_estim_start_ind_low;
            if iter > size(model.A,3)
                error([mfilename ':: The number recursive forecasting periods (' int2str(iter) ') are greater than the number of recursive estimation periods (' size(model.A,3) ').'])
            end
        else
            jj = 1;
        end
        
        note = nb_when2Notify(iter);
        for ii = start:finish
        
            % Get starting obs
            y0 = Y0(ii-1,:)';
            
            % Store the iteration index
            restrictions.index = kk;
            restrictions.start = startFcst(kk)-1;
            
            % Calculate forecast
            if options.recursive_estim
                index = jj;
            else
                index = 1;
            end
            
            if inputs.draws < 2 && inputs.parameterDraws < 2
                [Y,evalFcstT] = nb_forecast.midasPointForecast(y0,restrictions,model,options,results,...
                                            nSteps,index,actual(:,:,kk),inputs);
            else
                [Y,evalFcstT] = nb_forecast.midasDensityForecast(y0,restrictions,model,options,results,...
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
            delete(h);
        end
        
    %======================================================================
    else % Not recursive forecast
    %======================================================================
        
        % Get starting obs. Se definition of start_low_in_low and
        % end_low_in_low in nb_midasEstimator.estimate
        if isempty(start)
            y0        = Y0(end,:);
            startFcst = options.end_low_in_low + 1;
        else
            startFcst = start + options.start_low_in_low;
            if start < 2
                startDLow = nb_date.date2freq(options.estim_start_date_low);
                startFcst = startDLow + (start-1);
                startC    = startDLow + 1;
                error([mfilename ':: Cannot forecast from a date (' toString(startFcst) ') before the start date of estimation + 1 (' toString(startC) ').'])
            end
            y0 = Y0(start-1,:);
        end
        
        % Which recursive estimation to index
        if options.recursive_estim
            iter = startFcst - options.recursive_estim_start_ind_low;
        else
            iter = 1;
        end
        
        % Calculate forecast
        restrictions.index = startFcst - options.start_low_in_low; % How to index restrictions.X
        restrictions.start = startFcst - 1; % The index of last date of history in low units
        if inputs.draws < 2 && inputs.parameterDraws < 2 && inputs.regimeDraws < 2
            [Y,evalFcst] = nb_forecast.midasPointForecast(y0',restrictions,model,options,results,nSteps,iter,[],inputs);
        else
            [Y,evalFcst] = nb_forecast.midasDensityForecast(y0',restrictions,model,options,results,nSteps,iter,[],inputs);
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
    fcst = struct('data',           forecastData,...
                  'variables',      {fcstVar},...
                  'dependent',      {dep},...
                  'nSteps',         nSteps,...
                  'type',           'unconditional',...
                  'start',          startFcst,...
                  'nowcast',        false,...
                  'missing',        [],...
                  'evaluation',     evalFcst,...
                  'method',         inputs.method,...
                  'draws',          inputs.draws,...
                  'parameterDraws', inputs.parameterDraws,...
                  'regimeDraws',    inputs.regimeDraws,...
                  'perc',           inputs.perc,...
                  'inputs',         inputs,...
                  'saveToFile',     saveToFile);
    
    
end
