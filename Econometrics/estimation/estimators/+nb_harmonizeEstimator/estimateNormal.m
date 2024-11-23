function results = estimateNormal(options,y,endInd)
% Syntax:
%
% results = nb_harmonizeEstimator.estimateNormal(options,y,endInd)
%
% Description:
%
% Estimate model.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get historical data
    startD    = nb_date.date2freq(options.dataStartDate);
    startEst  = startD + (options.estim_start_ind - 1);
    hist      = nb_ts(y,'',startEst,options.variables);
    
    % Get conditional forecast
    fcst = nb_ts(options.condDB,'',hist.endDate + 1,options.condDBVariables);
    
    % Run all models used to harmonize forecasts
    for ii = 1:length(options.harmonizers)
        if strcmpi(options.algorithm,'lossFunc')
            fcst = runModelLossFunc(options,options.harmonizers{ii},hist,fcst,ii);
        else
            fcst = runModelVAR(options.dataVariables,options.frequencies,...
                options.harmonizers{ii},options.calibrateR{ii},hist,fcst,options.nLags,ii);
        end
    end
    results.forecast   = double(fcst);
    results.start      = endInd + 1;
    results.forecasted = fcst.variables; 
   
end

%==========================================================================
function fcst = runModelVAR(dataVariables,frequencies,harmonizers,calibrateR,hist,fcst,nLags,numModel)

    % Get options from model settings
    variablesInVAR = {};
    restricted     = cell(1,length(harmonizers));
    for ii = 1:length(harmonizers)
        restricted{ii} = harmonizers(ii).restricted;
        variablesInVAR = [variablesInVAR,nb_rowVector(harmonizers(ii).variables)]; %#ok<AGROW>
    end
    variablesInVAR = unique(variablesInVAR);
    
    % Checks
    gErr  = ['Error for model ' int2str(numModel) ': '];
    test1 = ismember(restricted,variablesInVAR);
    if any(test1)
        error([gErr,'The following variables are being restricted and also a ',...
            'variable that is part of another restriction. That is not possible; ',...
            toString(restricted(test1))]);
    end
    calibrateRVars = calibrateR(1:2:end);
    if ~iscellstr(calibrateRVars)
        error([gErr 'The calibrateR input must have every second element as a one line char.'])
    end
    test2 = ismember(calibrateRVars,[restricted,variablesInVAR]);
    if any(~test2)
        allVars = [restricted,variablesInVAR];
        error([gErr,'The following variables given as elements to the calibrateR ',...
            'option are neither restricted or part of the VAR model; ',...
            toString(allVars(~test2))]);
    end
    
    % Split data into hist and forecast, if restrictions are not mixed
    % we estimate only on one frequency!
    ind  = ismember(dataVariables,variablesInVAR);
    freq = unique(frequencies(ind));
    if isscalar(freq) && fcst.frequency ~= freq
        histT = convert(hist,freq);
        fcstT = convert(fcst,freq);
    else
        histT = hist;
        fcstT = fcst;
    end
    
    try
    
        % Prior
        prior = nb_var.priorTemplate('glp');

        % Create VAR model
        t                          = nb_var.template();
        t.calibrateR               = calibrateR;
        t.data                     = histT;
        t.dependent                = variablesInVAR';
        t.draws                    = 1;
        t.measurementEqRestriction = get(harmonizers);
        t.nLags                    = nLags;
        t.prior                    = prior;
        obj.model                  = nb_var(t);

        % Estimate, Solve and forecast
        obj.model = estimate(obj.model);
        obj.model = solve(obj.model);
        obj.model = forecast(obj.model,fcstT.numberOfObservations,'condDB',fcstT,'kalmanFilter',true);
        
    catch Err
        nb_error(gErr,Err)
    end

    % Report harmonized forecast
    fcstOut = getForecast(obj.model,obj.model.forecastOutput.start{1},true);
    fcstOut = window(fcstOut,fcstT.startDate);
    if hist.frequency ~= fcstOut.frequency
        fcstOut = convert(fcstOut,hist.frequency,'none','interpolateDate','end');
    end
    sd                  = (fcstOut.startDate - fcst.startDate) + 1; 
    ed                  = (fcstOut.endDate - fcst.endDate); 
    [~,loc]             = ismember(fcstOut.variables,fcst.variables);
    fcst(sd:end-ed,loc) = fcstOut;

end

%==========================================================================
function fcst = runModelLossFunc(options,harmonizer,hist,fcst,numModel)

    if length(harmonizer) > 1
        error(['Each cell of the harmonizers option can only contain one ',...
            'nb_SMARTHarmonizeLossFunc object.'])
    end
    
    % Do we deal with ragged-edge
    if isfield(options,'endHist')
        endHist = options.endHist;
    else
        endHist = [];
    end
    
    % Get options from model settings
    variablesOfExpr = nb_harmonizeEstimator.getVariablesFromLossFunc(harmonizer);
    variablesOfRest = nb_harmonizeEstimator.getVariablesFromRestrictions(harmonizer);
    variables       = unique([variablesOfExpr,variablesOfRest]);
    
    % Get the data on the variables that are part of the expressions
    histT = keepVariables(hist,variables);
    fcstT = keepVariables(fcst,variables);
    fcstT = window(fcstT,'',fcstT.getRealEndDate('nb_date','all'));
    
    % If restrictions are not mixed we estimate only on one frequency!
    ind  = ismember(options.dataVariables,fcstT.variables);
    freq = unique(options.frequencies(ind));
    if isscalar(freq) && fcstT.frequency ~= freq
        histT   = convert(histT,freq);
        fcstT   = convert(fcstT,freq);
        if ~isempty(endHist)
            endHist = convert(endHist,freq);
        end
    end
    xInit = vec(double(fcstT));
    
    % Get the original frequency of each of the variables
    [~,locFreqOrig] = ismember(fcstT.variables,options.dataVariables);
    freqOrig        = options.frequencies(locFreqOrig);
    
    % Get the different options
    lossFuncs    = harmonizer.lossFunc;
    restrictions = harmonizer.restrictions;
    weights      = harmonizer.weights;
    mapping      = harmonizer.mapping;
    freqs        = harmonizer.frequency;
    if isempty(freqs)
        freqs = repmat(fcstT.frequency,[1,length(lossFuncs)]);
    end
    freqsRest = harmonizer.frequencyRestrictions;
    if isempty(freqsRest)
        freqsRest = repmat(fcstT.frequency,[1,length(restrictions)]);
    end
    
    % Which values are known?
    fcstKnown        = nb_ts(true(size(fcstT)),'',fcstT.startDate,fcstT.variables);
    ind              = ismember(fcstKnown.variables,variablesOfExpr);
    fcstKnown(:,ind) = 0;
    if isa(endHist,'nb_date')
        if size(endHist,2) ~= length(options.condDBVariables)
            error(['The userData property of the condDB option does not ',...
                'store a nb_date object with a length equal to the number of ',...
                'variables stored in the condDB option. Is ' int2str(size(endHist,2)),...
                ', but should have been ' int2str(length(options.condDBVariables))])
        end
        for ii = 1:length(variablesOfExpr)
            locSF = strcmpi(variablesOfExpr{ii},options.condDBVariables);
            if (endHist(locSF) >= fcstKnown.startDate)
                fcstKnown = setValue(fcstKnown,variablesOfExpr{ii},1,fcstKnown.startDate,endHist(locSF));
            end
        end
    end
    indKnown = vec(double(fcstKnown));
    
    % Set up the minimization problem
    setDefault = false;
    if nb_isempty(options.optimset)
        setDefault = true;
    end
    opt = nb_getDefaultOptimset(options.optimset,options.optimizer);
    if isfield(opt,'Display') 
        if setDefault
            opt.Display = 'iter';
        end
    end
    
    % Parse loss functions
    numLoss                   = length(lossFuncs);
    lossFuncParsed(1,numLoss) = struct('out',[],'nInp',[]);
    for ii = 1:numLoss
        [str,out,nInp]     = nb_shuntingYardAlgorithm(lossFuncs{ii},sort(histT.variables),false);
        if ~isempty(str)
            error([mfilename ':: Error while parsing expression:: ' expr ':: ' str])
        end
        lossFuncParsed(ii).out  = out;
        lossFuncParsed(ii).nInp = nInp;
    end
    
    % Evaluate the loss function at the initial forecast
    histMT             = nb_math_ts(histT);
    fcstMT             = nb_math_ts(fcstT);
    [fVals2Match,wVec] = evaluateLoss(histMT,fcstMT,variables,...
        lossFuncParsed,freqs,freqOrig,mapping,weights);
    
    % Parse restrictions
    numRest                       = length(restrictions);
    restrictionsParsed(1,numRest) = struct('out',[],'nInp',[]);
    for ii = 1:numRest
        [str,out,nInp]     = nb_shuntingYardAlgorithm(restrictions{ii},sort(histT.variables),false);
        if ~isempty(str)
            error([mfilename ':: Error while parsing expression:: ' expr ':: ' str])
        end
        restrictionsParsed(ii).out  = out;
        restrictionsParsed(ii).nInp = nInp;
    end
    
    % Create function handles for the minimization 
    func       = @(x)minFunc(x,fVals2Match,indKnown,xInit,histMT,fcstMT.startDate,...
        variables,lossFuncParsed,freqs,freqOrig,mapping,weights);
    constrFunc = @(x)constraintFunc(x,indKnown,xInit,histMT,fcstMT.startDate,...
        variables,restrictionsParsed,freqsRest,mapping,freqOrig);

    % Do the harmonization by minimizing the loss function
    x = nb_callOptimizer(options.optimizer,func,xInit(~indKnown),[],[],opt,...
            [':: Harmonization failed for the model ' int2str(numModel) '.'],...
            'NONLCON',constrFunc);
    xOut            = xInit;
    xOut(~indKnown) = x;    
        
    % Report harmonized forecast
    fcstOut = fromX2Fcst(xOut,fcstT);
    fcstOut = window(fcstOut,fcstT.startDate);
    if hist.frequency ~= fcstOut.frequency
        fcstOut = convert(fcstOut,hist.frequency,'none','interpolateDate','end');
    end
    sd                  = (fcstOut.startDate - fcst.startDate) + 1; 
    ed                  = (fcst.endDate - fcstOut.endDate); 
    [~,loc]             = ismember(fcstOut.variables,fcst.variables);
    fcst(sd:end-ed,loc) = fcstOut;

end

%==========================================================================
function fVal = minFunc(x,fVals2Match,indKnown,xInit,hist,startFcst,variables,lossFuncParsed,freqs,freqOrig,mapping,weights)
    xInit(~indKnown) = x;
    fcst             = fromX2FcstMath(xInit,startFcst,variables);
    [fVals,weights]  = evaluateLoss(hist,fcst,variables,lossFuncParsed,freqs,freqOrig,mapping,weights);
    fVal             = sum((abs(fVals - fVals2Match).*weights).^2);
end

%==========================================================================
function [fVals,weights] = evaluateLoss(hist,fcst,variables,lossFuncParsed,freqs,freqOrig,mapping,weights)
    
    fcstAndHistH = vertcat(hist,fcst);
    startFcstH   = fcst.startDate;
    for ii = 1:length(lossFuncParsed)
        if freqs(ii) ~= fcst.startDate.frequency
            [fcstAndHistL,startFcstL] = convertHistAndForecast(fcstAndHistH,fcst.startDate,freqs(ii),freqOrig,mapping);
            break;
        end
    end
    
    fValsC   = cell(1,ii);
    weightsC = cell(1,ii);
    for ii = 1:length(lossFuncParsed)
        if freqs(ii) ~= fcst.startDate.frequency
            fcstAndHist = fcstAndHistL;
            startFcst   = startFcstL;
        else
            fcstAndHist = fcstAndHistH;
            startFcst   = startFcstH;
        end
        fcstTemp     = evalExpr(lossFuncParsed(ii).out,lossFuncParsed(ii).nInp,fcstAndHist,variables);
        fValsC{ii}   = double(window(fcstTemp,startFcst));
        weightsC{ii} = repmat(weights(ii),[size(fValsC{ii},1),1]);
    end
    fVals   = vertcat(fValsC{:});
    weights = vertcat(weightsC{:});
    
end

%==========================================================================
function [C,Ceq] = constraintFunc(x,indKnown,xInit,hist,startFcst,variables,restrictionsParsed,...
    freqsRest,mapping,freqOrig)

    xInit(~indKnown) = x;
    fcst             = fromX2FcstMath(xInit,startFcst,variables);
    Ceq              = evaluateRest(hist,fcst,variables,restrictionsParsed,freqsRest,mapping,freqOrig);
    C                = [];
end

%==========================================================================
function fVals = evaluateRest(hist,fcst,variables,restrictionsParsed,freqsRest,mapping,freqOrig)
    
    fcstAndHistH = [hist;fcst];
    startFcstH   = fcst.startDate;
    for ii = 1:length(restrictionsParsed)
        if freqsRest(ii) ~= fcst.startDate.frequency
            [fcstAndHistL,startFcstL] = convertHistAndForecast(fcstAndHistH,fcst.startDate,freqsRest(ii),freqOrig,mapping);
            break;
        end
    end
    
    fValsC   = cell(1,ii);
    for ii = 1:length(restrictionsParsed)
        if freqsRest(ii) ~= fcst.startDate.frequency
            fcstAndHist = fcstAndHistL;
            startFcst   = startFcstL;
        else
            fcstAndHist = fcstAndHistH;
            startFcst   = startFcstH;
        end
        fcstTemp   = evalExpr(restrictionsParsed(ii).out,restrictionsParsed(ii).nInp,fcstAndHist,variables);
        fValsC{ii} = double(window(fcstTemp,startFcst));
    end
    fVals = vertcat(fValsC{:});
    
end

%==========================================================================
function fcst = fromX2Fcst(x,fcst2Match)
    siz  = size(fcst2Match);
    x    = reshape(x,siz);
    fcst = nb_ts(x,'',fcst2Match.startDate,fcst2Match.variables);
end

%==========================================================================
function fcst = fromX2FcstMath(x,startDate,variables)
    num  = length(variables);
    siz  = [size(x,1)/num,num]; 
    x    = reshape(x,siz);
    fcst = nb_math_ts(x,startDate);
end

%==========================================================================
function fcst = evalExpr(terms,nInp,fcst,variables)

    % Get the type of the different elements
    [terms,type] = nb_getTypes(terms,variables,fcst,false,nInp);
    
    % Evaluate the interpreted expression
    [fcst,str] = nb_evalExpression(terms,type,nInp);
    if ~isempty(str)
        error([mfilename ':: Error while evaluating expression ' expr ':: ' str])
    end
    
end

%==========================================================================
function [fcstAndHistL,startFcstL] = convertHistAndForecast(fcstAndHistH,startcstH,freq,freqOrig,mapping)

    indL                  = freqOrig == freq;
    fcstAndHistL1         = convert(fcstAndHistH(:,indL),freq,'discrete');
    fcstAndHistL2         = convert(fcstAndHistH(:,~indL),freq,mapping);
    fcstAndHistL          = nb_math_ts.nan(fcstAndHistL1.startDate,fcstAndHistL1.dim1,fcstAndHistL1.dim2 + fcstAndHistL2.dim2);
    fcstAndHistL(:,indL)  = fcstAndHistL1;
    fcstAndHistL(:,~indL) = fcstAndHistL2;
    startFcstL            = convert(startcstH,freq);
    
end
