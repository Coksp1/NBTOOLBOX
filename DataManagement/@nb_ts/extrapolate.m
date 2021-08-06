function obj = extrapolate(obj,variables,toDate,varargin)
% Syntax:
%
% obj = extrapolate(obj,variables,toDate)
% obj = extrapolate(obj,variables,toDate,varargin)
%
% Description:
%
% Extrapolate last of observation of one variable to the wanted date.
% 
% Caution: This method only works on a single paged nb_ts object.
%
% Input:
% 
% - obj          : An object of class nb_ts
% 
% - variables    : A string with the name of the variable to extrapolate, 
%                  or a cellstr of the variables to extrapolate. Default
%                  is to extrapolate all variables. 
%
%                  Caution: When 'method' is set to copula only the
%                           selected variables are included in the 
%                           calculation of the extrapolated values.
% 
% - toDate       : Extrapolate to the given date. If the date is before the
%                  end date of the given variable no changes will be made,
%                  and with no warning. Can also be a integer with the
%                  number of periods to extrapolate.
%
% Optional inputs:
%
% - 'method'     : 
%
%       > 'end'    : Extrapolate series by using the last observation of 
%                    each series. I.e. a random walk forecast. Default.
%
%       > 'copula' : This approach tries to estimate the unconditional
%                    marginal distribution of each series in the dataset 
%                    and the (auto)correlation structure that discribe
%                    the connection between these series. Some series may
%                    have more observations than others!  
%
%                    Caution : This method works when the unconditional
%                              distribution from which the series are
%                              assumed to be drawn from are the same
%                              over time. E.g. the series must have the
%                              same volatility over the period. The second
%                              assumetion is that all the series are 
%                              stationary. Use the 'check' input to test 
%                              for non-stationarity by a ADF test for 
%                              unit-root. If it is found to have a unit
%                              root the series will be differenced when
%                              forecasted, and then transformed back to
%                              level after that step.
%
%        > 'ar'    : Extrapolate each series individually using a fitted
%                    AR model.
%
%        > 'var'   : Extrapolate all series using a fitted VAR model. Max
%                    number of variables is set to 10 for this option.
%
% - 'alpha'      : Significance level of ADF test for stationary series.
%                  Only an option for the 'copula' method.
%
% - 'check'      : Check for stationary series. If not found to be
%                  stationary the series will be differenced and
%                  extrapolated with this transformation before transformed
%                  back to its old level. Only an option for the 'copula' 
%                  method.
%
% - 'nLags'      : Number of lags to include when calculating the
%                  correlation matrix used by the copula. I.e. the number
%                  of historical observations to condition on when forming
%                  the conditional correlation matrix.
%
% - 'draws'      : The number of draws used to estimate the mean, when
%                  using the 'copula' method.
%
% - 'constant'   : Give true to to include constant in the AR models used 
%                  to extrapolate the individual series. Default is false.
%
% Output:
% 
% - obj          : An nb_ts object with extrapolate series.
% 
% Examples:
%
% obj = nb_ts.rand('1900',50,2,1);
% obj = extrapolate(obj,'Var1','1951');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if obj.numberOfDatasets > 1
        error([mfilename ':: The obj input can only have one page.'])
    end
    
    default = {'alpha',     0.05,   @isnumeric;...
               'check',     false,  @islogical;...
               'constant',  false,  @islogical;...
               'draws',     1000,   {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,0}};...
               'method',    'end',  @ischar;...   
               'nLags',     5,      {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,0}}};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    if isempty(toDate)
        error([mfilename ':: toDate cannot be empty.'])
    else
        if isnumeric(toDate) && isscalar(toDate)
            toDateT = round(toDate);
        else
            toDateT = interpretDateInput(obj,toDate);
        end
    end
    
    if isempty(variables)
        variables = obj.variables;
    end
    if ischar(variables)
        variables = cellstr(variables);
    end
    indV = ismember(obj.variables,variables);
    if all(~indV)
        error([mfilename ':: Non of the provided variables is part of the data.'])
    end

    % Choose extrapolate method
    switch lower(inputs.method)
        case 'ar'
            obj = arExtrapolate(obj,toDateT,indV,inputs);
        case 'var'
            obj = varExtrapolate(obj,toDateT,indV,inputs);
        case 'end'
            obj = endExtrapolate(obj,toDateT,indV);
        case 'copula'
            obj = copulaExtrapolate(obj,toDateT,indV,inputs);
        otherwise
            error([mfilename ':: The method ' inputs.method ' is not supported.'])
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@extrapolate,[{variables,toDate},varargin]);
        
    end

end

%==========================================================================
% SUB
%==========================================================================
function obj = endExtrapolate(obj,toDateT,indV)

    dim2 = obj.numberOfVariables;
    dim3 = obj.numberOfDatasets;
    if nb_iswholenumber(toDateT)
        
        indV    = find(indV);
        periods = toDateT;
        dataVar = obj.data(:,indV,:);
        nVar    = length(indV);
        varEnd  = indV;
        for ii = 1:nVar
            varEnd(ii) = find(any(~isnan(dataVar(:,ii,:)),3),1,'last');
        end
        perInd    = varEnd + periods;
        indNewEnd = max(perInd);
        if indNewEnd > obj.numberOfObservations
            expandPer   = indNewEnd - obj.numberOfObservations;
            obj.data    = [obj.data; nan(expandPer,dim2,dim3)];
            obj.endDate = obj.endDate + expandPer;
        end
        
        % Extrapolate the wanted variable
        for ii = 1:nVar
            obj.data(varEnd(ii)+1:indNewEnd,indV(ii),:) = repmat(obj.data(varEnd(ii),indV(ii),:),[indNewEnd - varEnd(ii),1,1]);    
        end
        
    else
        
        expandPer = toDateT - obj.endDate;
        if expandPer > 0
            obj.data    = [obj.data; nan(expandPer,dim2,dim3)];
            obj.endDate = toDateT;
        end
        indNewEnd = (toDateT - obj.startDate) + 1;
        
        % Extrapolate the wanted variables
        indV = find(indV);
        for ii = 1:length(indV)
            dataVar   = obj.data(:,indV(ii),:);
            varEnd    = find(any(~isnan(dataVar),3),1,'last');
            if varEnd < indNewEnd
                obj.data(varEnd+1:indNewEnd,indV(ii),:) = repmat(obj.data(varEnd,indV(ii),:),[indNewEnd - varEnd,1,1]);    
            end
        end
        
    end

end

%==========================================================================
function obj = copulaExtrapolate(obj,toDateT,indV,inputs)

    nVars = sum(indV);
    nLags = inputs.nLags;
    draws = inputs.draws;

    % Find the number of extrapolating period
    if nb_iswholenumber(toDateT)
        periods = toDateT;
    else
        periods = toDateT - obj.endDate;
    end
    
    % Find the balanced dataset
    isNaN   = any(isnan(obj.data),2);
    dataEmp = obj.data(~isNaN,indV);
    
    % Check for unit root
    if inputs.check
        statInd = true(1,nVars);
        results = nb_adf(dataEmp,'lagLengthCrit','sic');
        for ii = 1:nVars
           if results(ii).rhoPValue > inputs.alpha
               statInd(ii)   = false;
               dataEmp(:,ii) = [nan;diff(dataEmp(:,ii))];
           end
        end
        if any(~statInd)
            dataEmp = dataEmp(2:end,:);
        end
    end
    
    % Demean data
    dataM   = mean(dataEmp,1);
    dataEmp = bsxfun(@minus,dataEmp,dataM);
    
    % Estimate the unconditional distributions of each variable
    distEst = nb_distribution.sim2KernelDist(permute(dataEmp,[3,2,1])); 
    distEst = distEst(:);
    
    % Condition on known observations
    condData = obj.data(:,indV);
    isNaN    = any(~isfinite(condData),2);
    realEnd  = find(~isNaN,1,'last') + 1;
    condData = obj.data(realEnd-nLags+1:end,indV);
    if inputs.check
        if any(~statInd)
           condData(:,~statInd) = diff(obj.data(realEnd-nLags:end,~statInd),1); 
        end
    end
    condData = bsxfun(@minus,condData,dataM);
    
    % Replicate distributions for all periods
    fStep             = size(condData,1);
    tStep             = fStep + periods;
    dist(nVars,tStep) = nb_distribution;
    for ii = 2:tStep
       dist(:,ii) = copy(distEst); 
    end
    
    for jj = 1:nVars
        for ii = 1:fStep
            distT = dist(jj,ii);
            if ~isnan(condData(ii,jj))
                distT.conditionalValue = condData(ii,jj);
            end
        end
    end
    
    % Calculate correlation matrix
    c = nb_autocorrMat(dataEmp,tStep);
     
    % Construct stacked autocorrelation matrix
    nDim  = nVars*tStep;
    sigma = zeros(nDim,nDim);
    I      = eye(tStep);
    for ii = 2:tStep+1
        repl  = [zeros(ii-1,tStep-ii+1);I(ii:end,ii:end)];
        repl  = [repl,zeros(tStep,ii-1)]; %#ok<AGROW>
        sigma = sigma + kron(repl,c(:,:,ii));
    end
    sigma = sigma + sigma';
    sigma = sigma + kron(I,c(:,:,1));
    
    % Make a copula with the given marginals                   
    dist   = dist(:);                           % nvar*tSteps x 1 nb_distribution object
    copula = nb_copula(dist','sigma',sigma);
    Y      = random(copula,1,draws);            % 1 x nvar*tSteps x draws 
    Y      = reshape(Y,[1,nVars,tStep,draws]); % 1 x nvar x tSteps x draws 
    Y      = permute(Y,[3,2,4,1]);              % tSteps x nvar x draws
    mY     = mean(Y,3);
    mY     = bsxfun(@plus,mY,dataM);            % Add mean
    
    % Revert differenced data
    if inputs.check
        if any(~statInd) 
            histData       = obj.data(end-nLags,~statInd);
            mY(:,~statInd) = nb_undiff(mY(:,~statInd),histData,1);
        end
    end

    % Preallocate data
    dataOut = nan(obj.numberOfObservations+periods,obj.numberOfVariables);
    dataOut(1:obj.numberOfObservations,~indV)        = obj.data(:,~indV);
    dataOut(1:obj.numberOfObservations+periods,indV) = [obj.data(1:realEnd-nLags,indV);mY];
    
    % Extrapolate the wanted variable
    obj.data                 = dataOut;   
    obj.endDate              = obj.startDate + size(obj.data,1) - 1;
    
end

%==========================================================================
function obj = arExtrapolate(obj,toDateT,indV,inputs)

    indVars = find(indV);
    nVars   = length(indVars);

    % Find the number of extrapolating period
    if nb_iswholenumber(toDateT)
        periods = toDateT;
    else
        periods = toDateT - obj.endDate;
    end

    % Set up model for estimation
    variables         = obj.variables;
    options           = nb_arima.template();
    options.data      = obj;
    options.MA        = 0;
    options.maxAR     = 10;
    options.constant  = inputs.constant;
    options.doTests   = false;
    options.dependent = {'Var1'};
    
    % Preallocate data
    dataOut = nan(obj.numberOfObservations+periods,obj.numberOfVariables);
    dataOut(1:obj.numberOfObservations,~indV) = obj.data(:,~indV);
    
    % Find the balanced dataset for each variable
    for ii = 1:nVars
        
        % Set individual variable setting 
        vars                     = variables(indVars(ii));
        endDateVar               = obj.getRealEndDate('nb_date','any',vars);
        options.estim_start_date = obj.getRealStartDate('default','any',vars);
        options.estim_end_date   = toString(endDateVar);
        options.dependent        = vars;
        extra                    = obj.endDate - endDateVar;
        
        if extra + periods > 0
            % Formulate, estimate and forecast model
            model  = nb_arima(options);
            model  = estimate(model);
            model  = solve(model);
            model  = forecast(model,periods + extra);
            fcst   = getForecast(model,endDateVar+1,true);

            % Assign forecast + history back to output
            dataOut(:, indVars(ii)) = fcst;
            
        else
            dataOut(:, indVars(ii)) = getVariable(obj,variables(indVars(ii)));
        end
        
    end

    % Extrapolate the wanted variable
    obj.data                 = dataOut;
    obj.endDate              = obj.startDate + size(obj.data,1) - 1;

end

%==========================================================================
function obj = varExtrapolate(obj,toDateT,indV,inputs)

    indVars = find(indV);

    % Find the number of extrapolating period
    if nb_iswholenumber(toDateT)
        periods = toDateT;
    else
        periods = toDateT - obj.endDate;
    end

    % Set up model for estimation
    variables         = obj.variables;
    options           = nb_var.template();
    options.data      = obj;
    options.constant  = inputs.constant;
    options.doTests   = false;
    options.dependent = variables;
    
    % Preallocate data
    dataOut = nan(obj.numberOfObservations+periods,obj.numberOfVariables);
    dataOut(1:obj.numberOfObservations,~indV) = obj.data(:,~indV);
    
    % Set individual variable setting 
    vars          = variables(indVars);
    endDateVarAny = obj.getRealEndDate('nb_date','any',vars);
    endDateVarAll = obj.getRealEndDate('nb_date','all',vars);
    extra         = endDateVarAny - endDateVarAll;
    if extra + periods == 0
        return
    end
    
    if endDateVarAny == endDateVarAll
        condDB = [];
    else
        condDB = window(obj,endDateVarAll+1,endDateVarAny);
    end
    options.estim_end_date = toString(endDateVarAll);
    options.dependent      = vars;
    options.modelSelection = 'lagLength';
    options.maxLagLength   = 3;
    
    % Formulate, estimate and forecast model
    model = nb_var(options);
    model = estimate(model);
    if isempty(condDB)
        model = solve(model);
        model = forecast(model,periods + extra,'condDB',condDB);
        fcst  = getForecast(model,endDateVarAll+1,true);
    else
        error([mfilename ':: Extrapolating with VAR models when the sample is not balanced is not yet supported.'])
    end
    
    % Assign forecast + history back to output
    dataOut(:, indVars) = fcst;

    % Extrapolate the wanted variable
    obj.data                 = dataOut;
    obj.endDate              = obj.startDate + size(obj.data,1) - 1;
    obj.numberOfObservations = size(obj.data,1);

end
