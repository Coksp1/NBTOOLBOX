function [dec, plotter] = grouped_decomposition(obj,varargin)
% Syntax:
%
% [dec, plotter] = grouped_decomposition(obj,varargin)
%
% Description:
%
% Produce historical decomposition of a ECM model where contribution
% related to one variable is grouped automatically.
% 
% Input:
% 
% - obj      : An object of class nb_ecm.
%
% Optional input:
%
% - 'method' : One of
%                   
%   > 'shock_decomposition' : This uses the shock_decomposition method
%                             to do the decomposition, and then it
%                             aggregates all the contributions that 
%                             relates to one variable, e.g. aggregates the 
%                             contributions from different lags and the 
%                             lagged level of the endogenous variables.
%                             Default method.
%
%   > 'recursive_forecast'  : This method uses recursive forecasting to
%                             produce the decomposition. It creates a
%                             baseline recursive forecast. In this baseline 
%                             it condition on all right hand side 
%                             variables, where all level variable are kept 
%                             at 0 and all difference variables are kept
%                             at their mean. Then it sets one variable at 
%                             the time to its actual value, and produce 
%                             a recursive forecast in this case. The 
%                             contribution from this variable are then the 
%                             difference between this forecast compared to 
%                             the baseline (both being transformed using  
%                             the function specified by the 
%                             'transformation' input).
%
%                             This method are wrong for the first periods
%                             in the 'diff' transformation is used,
%                             but it converges to the correct solution 
%                             at the end. If 'level' is chosen it does
%                             not converge to the true solution!
%
% - 'transformation'  : Either 'level' (no transformation) or 'diff' 
%                       (difference). 
%
%                       Caution: If the dependent variable is in log
%                                'diff' will give the growth rate.
%
% - 'nLags'           : The number of lags used by the diff operator.
%                       Default is 1.
%
% - 'inputVars'       : true or false. Set it to true if you want to
%                       further decompose the ECM model into
%                       contribution of each input variable instead of
%                       each model variable. Use the  
%                       nb_modelData.createVariables to be able to do 
%                       this. Default is false. This will automatically 
%                       switch to the method 'recursive_forecast'!
%
%                       Caution: The the expressions are non-linear this
%                                will only be an "linear" approaximation
%                                of the contribution of each series. The
%                                approximation error will end up the 
%                                'Rest' variable.
%
% - 'seasonalPattern' : Set it to true if you want to keep the seasonal
%                       pattern in the level data when constructing the
%                       "steady state" values of the level variables.
%                       Used only when 'method' is set to 
%                       'recursive_forecast'. false is default.
%
% - 'modelCond'       : A nb_ecm object which has produced conditional
%                       forecast. 
%
% Output:
% 
% - dec     : The final decomposition as a nb_ts object with size 
%             nObs x (nEndo + nExo + 1). 'Rest' includes the residual.
%
% - plotter : A nb_graph_ts object that can produce a graph of the
%             decomposition. Use the graph method or the nb_graphPagesGUI
%             class.
%
% Examples:
% 
% \\NBTOOLBOX\Econometrics\test\test_nb_ecm.m
% \\NBTOOLBOX\Econometrics\test\test_nb_ecm_dec.m
%
% See also:
% nb_model_generic.shock_decomposition
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: The input must be a scalar nb_ecm model.'])
    end

    default = {'transformation',  [],                       {@isempty,'||',@nb_isOneLineChar};...
               'method',          'shock_decomposition',    @nb_isOneLineChar;...
               'modelCond',       [],                       @(x)isa(x,'nb_ecm');...
               'nLags',           1,                        @nb_isScalarInteger;...
               'inputVars',       false,                    @nb_isScalarLogical;...
               'seasonalPattern', false,                    @nb_isScalarLogical};...
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end

    if inputs.inputVars
        if isempty(obj.transformations)
            warning('nb_ecm:transformed_decomposition:MissingTransformations',[mfilename ':: You have not called the ',...
                    'createVariables so setting the ''createdVariables'' will not do anything.'])
            inputs.inputVars = false;
        else
            inputs.method = 'recursive_forecast';
        end
    end
    
    if isempty(inputs.transformation)
        trans = @(x)x; % No transformation!
    elseif ischar(inputs.transformation)
        switch lower(inputs.transformation)
            case 'diff'
                trans = @(x)nb_diff(x,inputs.nLags); % No transformation!
            case 'level'
                trans = @(x)x; % No transformation!
            otherwise
                error([mfilename ':: The ''transformation'' input must be a one line char. Either ''diff'' or ''idem''.'])
        end
    else
        error([mfilename ':: The ''transformation'' input must be a one line char.'])
    end
    
    if strcmpi(inputs.method,'recursive_forecast')
        if inputs.inputVars
            dec = useRecursiveForecastInputVars(obj,trans,inputs.seasonalPattern);
        else
            dec = useRecursiveForecast(obj,trans,inputs.seasonalPattern);
        end
    else
        dec = useShockDecomp(obj,trans,inputs.nLags);
    end
    dec.dataNames = obj.dependent.name(1);
    
    % Effect of conditional data on endogenous variable
    %--------------------------------------------------------------
    if ~isempty(inputs.modelCond)
       
        startFcst = nb_date.date2freq(obj.forecastOutput.start{end}) - obj.forecastOutput.nowcast;
        decFcst   = window(dec,startFcst);
        Ybase     = sum(decFcst.data,2);
        fcst      = getForecast(inputs.modelCond,inputs.modelCond.forecastOutput.start{end},true);
        fcst      = window(fcst,'',decFcst.endDate);
        YCond     = getVariable(fcst,obj.dependent.name{1});
        YCondT    = trans(YCond);
        diff      = YCondT(end-size(Ybase,1)+1:end) - Ybase;
        diff      = [zeros(decFcst.startDate - dec.startDate,1);diff];
        dec       = addVariable(dec,dec.startDate,diff,'condY');
        
    end
    
    % Plot if wanted
    %--------------------------------------------------------------
    if nargout > 1
        plotter = nb_graph_ts(dec);
        plotter.set('plotType','dec','noTitle',2);
    end
    
end

%==========================================================================
function dec = useRecursiveForecast(obj,trans,seasonalPattern)

    [startEst,endEst,nPer] = getDates(obj);

    % Rewrite the model solution in levels (and lags of the level) only
    sol = solveLevel(obj);
    AL  = sol.A;
    BL  = sol.B;
    CL  = sol.C;
  
    % Remove determenistic variables
    exo = sol.exo;
    if obj.options.constant
        ind = strcmpi(exo,'Constant');
        exo = exo(~ind);
    end
    if obj.options.time_trend
        ind = strcmpi(exo,'time_trend');
        exo = exo(~ind);
    end
    
    % Get historical data
    try
        exoHist = window(getHistory(obj,exo),startEst,endEst);
    catch Err
        if isforecasted(obj)
            exoHist   = window(getHistory(obj,exo),startEst);
            [ind,loc] = ismember(exo,obj.forecastOutput.variables);
            if any(~ind)
                error(['The data you condition on when producing forecast ',...
                    'must be contained in the ''data'' option of the ' class(obj),...
                    ' object or you need to set the ''output'' input to ''all'' ',...
                    'to the call to the forecast method, so the the forecast ',...
                    'of all the exogenous variables are returned..'])
            end
            startFcst = nb_date.date2freq(obj.forecastOutput.start{end}) - obj.forecastOutput.nowcast;
            exoFcst   = nb_ts(obj.forecastOutput.data(:,loc),'',startFcst,exo);
            exoHist   = append(exoHist,exoFcst);
        else
            rethrow(Err);
        end
    end
    exoHist = reorder(exoHist,exo);
    X       = double(exoHist)';
    
    exoVars = obj.exogenous.name;
    if obj.options.time_trend
        X       = [1:size(X,2);X];
        exoVars = ['Time-trend',exoVars];
    end
    
    if obj.options.constant
        X       = [ones(1,size(X,2));X];
        exoVars = ['Constant',exoVars];
    end
    
    % Index of each variable
    vars     = flip(sort(obj.endogenous.name),2);
    nVars    = length(vars);
    exoVars  = flip(sort(exoVars),2);
    nExoVars = length(exoVars);
    index    = cell(1,nVars+nExoVars); 
    exo      = obj.solution.exo;
    locs     = 1:length(exo);
    for ii = 1:length(vars)
        ind       = nb_contains(exo,vars{ii});
        index{ii} = locs(ind);
        exo       = exo(~ind); % Prevent double matching!
        locs      = locs(~ind);
    end
    
    for jj = 1:length(exoVars)
        ind          = nb_contains(exo,exoVars{jj});
        index{ii+jj} = locs(ind);
        exo          = exo(~ind); % Prevent matching a variable more than once!
        locs         = locs(~ind);
    end
    
    % Extrapolate with all level variables at their initial value
    if seasonalPattern
        lag = obj.options.data.frequency;
    else
        lag = 1;
    end
    XA = X(:,2:end);
    for ii = 5:nPer-1
        XA(:,ii) = XA(:,ii-lag);
    end       
    
    % set differenced variables to its mean
    m1          = obj.endogenous.number + obj.options.constant + obj.options.time_trend + obj.exogenous.number + 1;
    m2          = size(X,1);
    XM          = mean(X(m1:m2,:),2);
    XA(m1:m2,:) = XM(:,ones(1,nPer-1));
    
    % Remove constant term!
    if obj.options.constant
        XA(1,:) = 0; 
    end
    
    % Shock at zero
    E = zeros(1,nPer-1);
    
    % Compute baseline recursive forecast
    nLags  = size(AL,1) - 1;
    Y      = nan(nLags+1,nPer);
    Y(:,1) = (eye(size(AL,1)) - AL)\(BL*XA(:,1));
    YA     = nb_computeForecast(AL,BL,CL,Y,XA,E);
    YA     = YA(1,:)';
    YAT    = trans(YA);
    if size(YAT,1) > nPer-1
        YAT = YAT(2:end);
    end
    
    % Do the decomposition
    dec = nan(length(index),size(XA,2)); 
    for ii = 1:length(index)
        
       % Set all but "one" input variable to its actual value, the rest 
       % is set to 0 or mean dependent on the transformation
       XT              = XA;
       XT(index{ii},:) = X(index{ii},2:end);
       
       % Compute recursive forecast in this case
       Y(:,1) = (eye(size(AL,1)) - AL)\(BL*XT(:,1));
       YT     = nb_computeForecast(AL,BL,CL,Y,XT,E);
       YTT    = trans(YT(1,:)');
       if size(YTT,1) > nPer-1
           YTT = YTT(2:end);
       end 
       
       % Compare to the recursive forecast where all variables are set to
       % their initial value.
       dec(ii,:) = YTT - YAT;
       
    end
    
    % Calculate residual and convert to nb_ts
    dec = dec';
    if isforecasted(obj)
        nSteps = obj.forecastOutput.nSteps + obj.forecastOutput.nowcast;
        histY  = window(obj.options.data,startEst,endEst-nSteps,obj.dependent.name);
        histYD = double(histY);
        indV   = strcmp(obj.dependent.name,obj.forecastOutput.variables);
        fcstYD = obj.forecastOutput.data(:,indV,end,end);
        histYD = [histYD;fcstYD];
    else
        histY  = window(obj.options.data,startEst,endEst,obj.dependent.name);
        histYD = double(histY);
    end
    histYD = trans(histYD);
    if size(histYD,1) > nPer-1
       histYD = histYD(2:end);
    end
    rest = histYD - sum(dec,2);
    dec  = [dec,rest];  
    dec  = nb_ts(dec(2:end,:),'',startEst+2,[vars,exoVars,'Rest']);
    
end

%==========================================================================
function dec = useRecursiveForecastInputVars(obj,trans,seasonalPattern)

    [startEst,endEst,nPer] = getDates(obj);
    
    % Rewrite the model solution in levels (and lags of the level) only
    sol   = solveLevel(obj);
    AL    = sol.A;
    BL    = sol.B;
    CL    = sol.C;
    nLags = size(AL,1) - 1;
  
    % Get the variables to loop
    vars      = obj.options.data.variables;
    transVars = obj.transformations(:,1)';
    notTrans  = ~ismember(vars,transVars);
    depVar    = strcmpi(obj.dependent.name,vars);
    loopVars  = vars(notTrans & ~depVar);
    
    % Deterministic variables
    if obj.options.constant
        loopVars = ['Constant',loopVars];
    end
    if obj.options.time_trend
        loopVars = ['Time-trend',loopVars];
    end
    
    % Set all variables to their steady-state value
    XA = updateX(obj,[],loopVars,transVars,[],seasonalPattern);
    
    % Shock at zero
    E = zeros(1,nPer-1);
    
    % Compute baseline recursive forecast
    Y      = nan(nLags+1,nPer);
    Y(:,1) = (eye(size(AL,1)) - AL)\(BL*XA(:,1));
    YA     = nb_computeForecast(AL,BL,CL,Y,XA,E);
    YA     = YA(1,:)';
    YAT    = trans(YA);
    if size(YAT,1) > nPer-1
        YAT = YAT(2:end);
    end
    
    % Do the decomposition
    dec = nan(length(loopVars),size(XA,2)); 
    for ii = 1:length(loopVars)
        
       % Set all but "one" input variable to its actual value, the rest 
       % is set to 0 or mean dependent on the transformation
       XT = updateX(obj,ii,loopVars,transVars,XA,seasonalPattern);
       
       % Compute recursive forecast in this case
       Y(:,1) = (eye(size(AL,1)) - AL)\(BL*XT(:,1));
       YT     = nb_computeForecast(AL,BL,CL,Y,XT,E);
       
       YTT = trans(YT(1,:)');
       if size(YTT,1) > nPer-1
           YTT = YTT(2:end);
       end 
       
       % Compare to the recursive forecast where all variables are set to
       % their initial value.
       dec(ii,:) = YTT - YAT;
       
    end
    
    % Calculate residual and convert to nb_ts
    dec = dec';
    if isforecasted(obj)
        nSteps = obj.forecastOutput.nSteps;
        histY  = window(obj.options.data,startEst,endEst-nSteps,obj.dependent.name);
        histYD = double(histY);
        indV   = strcmp(obj.dependent.name,obj.forecastOutput.variables);
        fcstYD = obj.forecastOutput.data(:,indV,end,end);
        histYD = [histYD;fcstYD];
    else
        histY  = window(obj.options.data,startEst,endEst,obj.dependent.name);
        histYD = double(histY);
    end
    histYD = trans(histYD);
    if size(histYD,1) > nPer-1
       histYD = histYD(2:end);
    end
    rest = histYD - sum(dec,2);
    dec  = [dec,rest];  
    dec  = nb_ts(dec(2:end,:),'',startEst+2,[loopVars,'Rest']);
    
end

%==========================================================================
function XT = updateX(obj,ind,loopVars,transVars,XA,seasonalPattern)

    [startEst,endEst,nPer] = getDates(obj);
    if ~isempty(ind)
        loopVar = loopVars{ind};
        if strcmpi(loopVar,'Constant')
            XT      = XA;
            XT(1,:) = 1;
            return
        elseif strcmpi(loopVar,'Time-trend')
            XT      = XA;
            XT(2,:) = 1:size(XA,2);
            return
        end
    end
    
    % Max lags
    if iscell(obj.options.nLags)
        mLags = max([obj.options.nLags{:}]);
    else
        mLags = max(obj.options.nLags);
    end 
    if iscell(obj.options.exoLags)
        mELags = max([obj.options.exoLags{:}]);
    else
        mELags = max(obj.options.exoLags);
    end
    mLags = max(mLags,mELags);

    % Deterministic variables
    exo = obj.solution.exo;
    s   = 0;
    if obj.options.constant
        XC       = zeros(1,nPer-1);
        i        = strcmpi(exo,'Constant');
        exo      = exo(~i);
        loopVars = loopVars(2:end);
        s        = s + 1;
    else
        XC = nan(0,size(XA,2));
    end
    if obj.options.time_trend
        XTT      = 1:nPer-1;
        i        = strcmpi(exo,'time_trend');
        exo      = exo(~i);
        loopVars = loopVars(2:end);
        s        = s + 1;
    else
        XTT = nan(0,size(XA,2));
    end
    
    % Get the data without the created variables
    try
        data = window(obj.options.data,startEst-mLags,endEst);
    catch Err
        if isforecasted(obj)
            error([mfilename ':: The data you condition on when producing forecast must be contained in ',...
                             'the ''data'' option of the nb_ecm object.'])
        else
            rethrow(Err);
        end
    end
    data = deleteVariables(data,transVars);
    
    % Set the loopVar to its true level, while all other variables are set
    % to 0. 
    if ~isempty(ind)
        setVars = [loopVars(1:ind-s-1),loopVars(ind-s+1:end)];
    else
        setVars = loopVars;
    end
    data  = extMethod(data,'keepInitial',setVars,'',seasonalPattern,startEst+1);
    obj   = set(obj,'data',data); % This triggers createVariables!
    dataL = obj.options.data;     % Here created variables has been updated
    
    % Construct all the exogenous variables (lags and diff variables)
    dataEL = window(dataL,'','',obj.endogenous.name);
    dataD  = diff(dataEL);
    dataD  = addPrefix(dataD,'diff_');
    dataA  = merge(dataL,dataD);
    
    % Construct the lagged level variables
    dataLE  = window(dataL,'','',obj.endogenous.name);
    dataLag = addLags(dataLE,1);
    
    % Construct the lags of all the other variables
    dataAWL  = keepVariables(dataA,[strcat('diff_',obj.endogenous.name),obj.exogenous.name]);
    dataLag2 = addLags(dataAWL,mLags);
    
    % Get the final data
    dataF    = merge(dataLag,dataLag2);
    dataF    = window(dataF,startEst+1);
    XT       = double(dataF);
    [~,loc]  = ismember(exo,dataF.variables);
    XT       = XT(:,loc);
    XT       = [XC;XTT;XT'];
    
end

%==========================================================================
function dec = useShockDecomp(obj,trans,nLags)

    if isforecasted(obj)
        error([mfilename ':: To set method to ''shock_decomposition'' is not supported when model is forecasted.'])
    end
    
    % Package decomp
    vars     = flip(sort([obj.endogenous.name]),2);
    nVars    = length(vars);
    packages = cell(2,nVars); 
    exo      = obj.solution.exo;
    for ii = 1:length(vars)
        ind            = nb_contains(exo,vars{ii});
        packages{1,ii} = vars{ii};
        packages{2,ii} = exo(ind);
        exo            = exo(~ind); % Prevent double matching!
    end
    
    exoVars = obj.exogenous.name;
    if obj.options.time_trend
        exoVars = ['Time-trend',exoVars];
    end
    if obj.options.constant
        exoVars = ['Constant',exoVars];
    end
    exoVars   = flip(sort(exoVars),2);
    nExoVars  = length(exoVars);
    packagesE = cell(2,nExoVars); 
    for ii = 1:length(exoVars)
        ind             = nb_contains(exo,exoVars{ii});
        packagesE{1,ii} = exoVars{ii};
        packagesE{2,ii} = exo(ind);
        exo             = exo(~ind); % Prevent matching a variable more than once!
    end
    packages  = [packages,packagesE,{'Initial Conditions';'Initial Conditions'}];
    
    % Start
    startF = obj.options.data.startDate + (obj.estOptions.estim_start_ind - 1);
    diffT  = true;
    if ~nb_contains(func2str(trans),'diff')
        startF = startF + 1;
        diffT  = false;
    end
     
    % Do shock decomp
    decS  = shock_decomposition(obj,'packages',packages,'variables',obj.dependent.name,'startDate',startF);
    decS  = decS.Model1;
    Yhist = trans(double(sum(decS)));
    decS  = deleteVariables(decS,'Rest');
    
    % Do transformation  
    dec = trans(double(decS));
    dec = [dec,Yhist-sum(dec,2)];
    
    if diffT
        dec = nb_ts(dec,'',startF+nLags,[decS.variables,'Rest']);
    else
        dec = nb_ts(dec,'',startF,[decS.variables,'Rest']);
    end
    dec = window(dec,dec.startDate+1);
        
end

%==========================================================================
function [startEst,endEst,nPer] = getDates(obj)

    startEst = obj.options.data.startDate + (obj.estOptions.estim_start_ind - 1);
    if isforecasted(obj)
        endEst = nb_date.toDate(obj.forecastOutput.start{end},obj.options.data.frequency) + obj.forecastOutput.nSteps - 1;
    else
        endEst = obj.options.data.startDate + (obj.estOptions.estim_end_ind - 1);
    end
    nPer = endEst - startEst + 1;
    
end
