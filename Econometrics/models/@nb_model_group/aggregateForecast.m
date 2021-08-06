function obj = aggregateForecast(obj,varargin)
% Syntax:
%
% obj = aggregateForecast(obj,varargin)
%
% Description:
%
% Aggregate forecast of subcomponents of a series.
%
% Caution: The model with the shortest forecast horizon will set the
%          forecast horizon of the aggregated series.
%
% Caution: A intersection of the dates from which the recursive forecast 
%          is made will be done.
%
% Caution: If type is set to 'density' consistent paths are sampled from
%          the marginal using a copula with an empirically estimated
%          autocorrelation matrix.
% 
% Input:
% 
% - obj         : An object of class nb_model_group
%
% Optional Inputs:
%
% - 'startDate'     : Start date of the aggregation of forecast. I.e.
%                     the start date of which the weights are constructed.
%                     Default is to use the first shared forecast date.
%                     Must be given as a string or a nb_date object.
%
% - 'endDate'       : End date of the aggregation of forecast. I.e.
%                     the end date of which the weights are constructed.
%                     Default is to use the last shared forecast date.
%                     Must be given as a string or a nb_date object.
%
% - 'nSteps'        : The number of steps ahead forecast. The default is
%                     to take the minimum over the selected models.
%
% - 'density'       : Give 1 (true) if you want to evaluate and produce
%                     density forecast. Default is not (0 or false).
%
%                     Caution: If the 'method' option is set to 'copula'
%                              the selected variables must be stationary.
%
%                     Caution: If you set this option to false the mean
%                              forecast is used to construct the point
%                              forecast from model which has produced
%                              density forecast.
%
% - 'method'        : Either:
%
%                     > 'copula' : Use a copula to draw consistent draws 
%                                  from each marginal distribution.
%                                  Default.
%
%                     > 'perfectcorr' : Make the assumption that the 
%                                       aggregated variables are perfectly  
%                                       correlated, and we can therefore  
%                                       just sum over the distribution 
%                                       using the chosen weights.
%
% - 'condLags'      : Number of lags included in the calcualtion of the 
%                     (auto)correlation matrix used when 'density' is set 
%                     to true and 'method' is set to 'copula'. I.e. the 
%                     number of periods to "condition on". This option 
%                     should only be used if the forecast densities to be 
%                     aggregated are not condition on information up until
%                     the time of the forecast. This is not the normal
%                     case, so default is 0.
%
% - 'nLags'         : Max number autocorrelation to include in the stacked
%                     autocorrelation matrix. Default is 5. If 0, only
%                     contemporaneous correlations are used. Only an option
%                     when 'density' is set to true and 'method' is set to 
%                     'copula'. If empty the full set of autocorrelations
%                     are used.
%                 
% - 'weights'       : The aggregation weights. As a 1 x nModels double, or  
%                     a T x nModels nb_ts object (time-varying weights).
%                     Default is equal weights.
% 
% - 'newVar'        : A string with the name of the aggregate series.         
%
% - 'variables'     : A cellstr with same length as obj.models. These are 
%                     the variables from the different models to aggregate. 
%                     Default is to take the first variables from the
%                     forecastOutput.variables list.
%
% - 'draws'         : Number of draws from the marginal distributions of
%                     the disaggregated models to base the new aggrgated 
%                     density forecast on. Default is 1000.
%
% - 'fcstEval'      : See the forecast method of the nb_model_generic 
%                     class.
%
% - 'perc'          : Error band percentiles. As a 1 x numErrorBand 
%                     double. E.g. [0.3,0.5,0.7,0.9]. Default is 0.9.
%                     Can be empty, i.e. no percentiles are reported, and
%                     all simulation are stored.
% 
% - 'parallel'      : When numel(obj) > 1 you may run the process in 
%                     parallel. true or false. 
%
%                     Caution: Cannot be provided if numel(obj) == 1.
%
% - 'cores'         : Number of cores to use when the process is ran in
%                     parallel. As a positive integer.
%
%                     Caution: Cannot be provided if numel(obj) == 1.
%
% - 'saveToFile'    : Logical. Save densities and domains to files. One 
%                     file for each model. Default is false (do not).
%
% - 'recursive'     : Calculate the correlation matrix recursivly when
%                     aggregating density forecast using the 'copula'
%                     method. true or false. Default is false.
%
% - 'rollingWindow' : If the correlation matrix should be calculated 
%                     recursivly with a rolling window. Default is [], i.e.
%                     to use the full sample to calculate the correlation
%                     matrix.
%
% - 'waitbar'       : true or false. Default is true. Not in parallel
%                     session.
%
% - 'weightsMethod' : Either 'actual', 'end', 'ar' or 'var'. This options 
%                     sets the way weights are recursivly extrapolated  
%                     when the 'weights' is set ot an object of class 
%                     nb_ts. See the 'method' input to the 
%                     recursiveExtrapolate method of the nb_ts class for 
%                     more on this option.
%
% - 'sigmaMethod'   : Either 'var' or 'correlation'. If set to 'var'
%                     the autocorrelation matrix is estimated using the
%                     theoretical conditional moments of the forecast
%                     from a VAR. If 'correlation' the autocorrelation 
%                     matrix is estimated based on the emprirical data 
%                     only. 'correlation' is default.
%
% Output:
% 
% - obj         : A nb_model_group object storing the aggregated forecast.
%
% See also:
% nb_model_group.combineForecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) ~= 1
        
        obj  = obj(:);
        nobj = size(obj,1);
        ind  = find(strcmpi('parallel',varargin),1);
        if ~isempty(ind)
            parallel = varargin{ind+1};
            varargin = [varargin(1:ind-1),varargin(ind+2:end)]; 
        else
            parallel = false;
        end
        ind  = find(strcmpi('cores',varargin),1);
        if ~isempty(ind)
            cores = varargin{ind+1};
            varargin = [varargin(1:ind-1),varargin(ind+2:end)]; 
        else
            cores = [];
        end
        
        if parallel
            
            ret = nb_openPool(cores);
        
            % Build a WorkerObjWrapper object to write to a worker specific
            % file
            w      = nb_funcToWrite('aggregateForecast_worker','gui');
            inputs = {varargin};
            inputs = inputs(:,ones(1,nobj));
            parfor ii = 1:nobj
                obj(ii) = aggregateForecast(obj(ii),inputs{ii}{:})
                fprintf(w.Value,['Aggregation of Forecast of Model Group '  int2str(ii) ' of ' int2str(nobj) ' finished.\r\n']); %#ok<PFBNS>
            end
            delete(w);
            clear w; % causes "fclose(w.Value)" to be invoked on the workers 
            nb_closePool(ret);
            
        else
            
            ind  = find(strcmpi('waitbar',varargin),1);
            if ~isempty(ind)
                waitbar  = varargin{ind+1};
                varargin = [varargin(1:ind-1),varargin(ind+2:end)]; 
            else
                waitbar  = false;
            end
            
            % Initialize waitbar
            if waitbar
                h                = nb_waitbar5([],'Estimation',true);
                h.text1          = 'Starting...';
                h.maxIterations1 = nobj;
                varargin         = [varargin,{'waitbar',h}];
            end
            
            for ii = 1:nobj
                
                obj(ii) = aggregateForecast(obj(ii),varargin{:});
                
                % Update waitbar
                h.status1 = ii;
                h.text1   = ['Aggregation of Forecast of Model Group '  int2str(ii) ' of ' int2str(nobj) ' finished.'];
                        
            end
            delete(h);
            
        end
        
        return
        
    end

    default = {'bins',              [],             {@iscell,'||',@isempty};...
               'density',           false,          @nb_isScalarLogical;...
               'estimateDensities', true,           @nb_isScalarLogical;...
               'estDensity',        'kernel'        @nb_isOneLineChar;...
               'weights',           [],             {@isnumeric,'&&',@isrow,'||',@isempty,'||',{@isa,'nb_ts'}};...
               'newVar',            '',             @nb_isOneLineChar;...
               'startDate',         '',             {@ischar,'||',{@isa,'nb_date'},'||',@isempty};...
               'endDate',           '',             {@ischar,'||',{@isa,'nb_date'},'||',@isempty};...
               'method',            'copula',       {{@nb_ismemberi,{'copula','perfectcorr'}}};...
               'variables',         {},             {@iscellstr,'||',@isempty};...
               'perc',              0.9,            {@isnumeric,'||',@isempty};...
               'fcstEval',          '',             @iscellstr;...
               'recursive',         false,          @nb_isScalarLogical;...
               'rollingWindow',     [],             {@(x)nb_isScalarNumber(x,0),'||',@isempty};...
               'nLags',             5,              {@(x)nb_isScalarInteger(x,-1),'||',@isempty};...
               'condLags',          0,              {@(x)nb_isScalarInteger(x,-1),'||',@isempty};...
               'nSteps',            [],             {@(x)nb_isScalarInteger(x,0),'||',@isempty};...
               'draws',             1000,           @(x)nb_isScalarInteger(x,0);...
               'waitbar',           true,           @isscalar;...
               'weightsMethod',     'end',          {{@nb_ismemberi,{'end','ar','var','actual'}}};...
               'sigmaMethod',       'correlation',  {{@nb_ismemberi,{'correlation','var'}}};...
               'sigmaShrink',       false,          {@nb_isScalarLogical,'||',@(x)nb_isScalarNumberClosed(x,0,1)};...
               'saveToFile',        false,          @nb_isScalarLogical};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    startDate        = inputs.startDate;
    endDate          = inputs.endDate;
    nSteps           = inputs.nSteps;
    if ~isempty(message)
        error(message)
    end

    if length(unique(inputs.variables)) ~= length(inputs.variables)
        error([mfilename ':: Cannot aggregate the same variable across models. See compareForecast!'])
    end
    
    % Use the same seed when returning the "random" numbers
    %--------------------------------------------------------------
    seed          = 2.0719e+05;
    defaultStream = RandStream.getGlobalStream;
    savedState    = defaultStream.State;
    s             = RandStream.create('mt19937ar','seed',seed);
    RandStream.setGlobalStream(s);
    
    % Get the forecast output from each model (nb_model_generic) or 
    % model group (nb_model_group)
    %---------------------------------------------------------------
    modelsT = obj.models(:);
    if isprop(obj,'valid')
        modelsT = modelsT(obj.valid);
    end
    nobj           = size(modelsT,1);
    forecastOutput = cell(1,nobj);
    names          = forecastOutput;
    for ii = 1:nobj
        forecastOutput{ii} = modelsT{ii}.forecastOutput;
        names{ii}          = modelsT{ii}.name;
        if nb_isempty(forecastOutput{ii})
            name = names{ii};
            if isempty(name)
                name = ['Model' int2str(ii)];
            end
            error([mfilename ':: You need to produce forecast using one of the forecast functions for the model with name ' name])
        end
    end
    
    % Check inputs
    if isempty(inputs.newVar)
        error([mfilename ':: The ''newVar'' input must be set to a non-empty string.'])
    end
    
    if isempty(inputs.variables)
        variables = cell(1,nobj);
        for ii = 1:nobj
            variables{ii} = forecastOutput{ii}.dependent{1};
        end
    else
        variables = inputs.variables;
        if length(variables) ~= nobj
            error([mfilename ':: The ''variables'' input must consist of at least ' int2str(nobj) ' variables, one for each model.'])
        end
    end
    
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!! Check the frequency !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    % Get the final output size
    nHor      = nan(1,nobj);
    startFcst = cell(1,nobj);
    nowcast   = false(1,nobj);
    for ii = 1:nobj
        nHor(ii)        = forecastOutput{ii}.nSteps;
        startFcst{ii}   = forecastOutput{ii}.start;
        if isfield(forecastOutput{ii},'nowcast')
        	nowcast(ii) = forecastOutput{ii}.nowcast;
        end
    end
    
    if any(nowcast)
        % Remove nowcast or long term forecast from point forecast stored 
        % by the object.
        for ii = 1:nobj
            if nowcast(ii)
                [forecastOutput(ii),startFcst(ii)] = nb_model_group.adjustForecastGivenNowcast(nowcast(ii),forecastOutput(ii),startFcst(ii),variables(ii),names(ii));
            end
        end
    end
    
    nHor = min(nHor);
    if ~isempty(nSteps)
        if nSteps > nHor
            error([mfilename ':: The ''nSteps'' input is larger than the shortest forecast horizon of the selected models.'])
        end
        nHor = nSteps;
    end
    
    startFcst    = nb_date.intersect(startFcst{:});
    nDates       = length(startFcst);
    startFcst1   = nb_date.date2freq(startFcst{1});
    startFcstEnd = nb_date.date2freq(startFcst{end});
    if ~isempty(startDate)
        
        indS  = startDate - startFcst1 + 1;
        if indS < 1
            error([mfilename ':: The startDate input is before the intersection of start dates of the forecast from the models.'])
        elseif indS > nDates
            error([mfilename ':: The startDate input is after the intersection of end dates of the forecast from the models.'])
        end
        startFcst = startFcst(1,indS:end);
        
    end
    
    if ~isempty(endDate)
        
        indE  = startFcstEnd - endDate;
        if indE < 0
            error([mfilename ':: The endDate input is after the intersection of end dates of the forecast from the models.'])
        elseif indE > nDates
            error([mfilename ':: The endDate input is before the intersection of start dates of the forecast from the models.'])
        end
        startFcst = startFcst(1,1:end-indE);
        
    end
    nDates = length(startFcst);
    
    % Get the weights
    weights    = inputs.weights;
    weightsInn = weights;
    if isa(weights,'nb_ts')
        
        [ind,loc] = hasVariable(weights,variables);
        if ~all(ind)
            error([mfilename ':: Could not find the following variables in the weights input; ' toString(variables(~ind))])
        end
        startFcstObj1 = nb_date.date2freq(startFcst{1});
        startFcstObjE = nb_date.date2freq(startFcst{end});
        if weights.frequency ~= startFcstObjE.frequency
            error([mfilename ':: The frequency of the dataset with the weights must be the same as that of the forecast.'])
        end
        if weights.endDate < startFcstObjE-1
            error([mfilename ':: The end date of the dataset with the weights cannot end before ' toString(startFcstObjE-1) '.'])
        end
        if weights.startDate > startFcstObj1-1
            error([mfilename ':: The start date of the dataset with the weights cannot start after ' toString(startFcstObj1-1) '.'])
        end
        weightsTS = window(weights,'',startFcstObjE-1);
        weights   = recursiveExtrapolate(weightsTS,'',nHor,startFcstObj1-1,'method',inputs.weightsMethod); % Extrapolate using random-walk
        weightsTS = window(weightsTS,startFcstObj1);
        weights   = realTime2RecCondData(weights,nHor,[],[],false); % nb_data object
        weights   = double(weights);
        weights   = weights(:,loc,:);
        
    else
        if isempty(weights)
            weights = ones(1,nobj)/nobj;
        else
            if size(weights,2) ~= nobj
                error([mfilename ':: The ''weights'' input must be a 1 x ' int2str(nobj) ' double.'])
            end
        end
        weightsTS = nb_ts(weights(ones(1,nDates),:),'',startFcst{1},variables);
    end
    inputs.weights = weights;
    
    % Aggregate the forecast
    %--------------------------------
    deleteH = true;
    h       = [];
    if inputs.density
        
        if ishandle(inputs.waitbar)
            deleteH          = false;
            h.text2          = 'Get the density forecast from the different models...';
        elseif inputs.waitbar
            h                = nb_waitbar5([],['Aggregate Forecast of ' int2str(nobj) ' models'],true); 
            h.text2          = 'Get the density forecast from the different models...';
        end
        
        draws = inputs.draws;
        perc  = inputs.perc;
        switch lower(inputs.method)
            case 'copula'
                h.maxIterations2 = length(startFcst) + 4;
                aggFcst          = aggregateDensities(obj,inputs,forecastOutput,variables,startFcst,names,nHor,h);
            case 'perfectcorr'
                h.maxIterations2 = nobj + 2;
                aggFcst          = naiveAggregateDensities(inputs,forecastOutput,variables,startFcst,names,nHor,h);
        end
          
    else
        
        % Aggregate point forecast.
        draws    = 1;
        perc     = [];
        aggFcst  = zeros(nHor,1,1,nDates);
        weightsT = permute(weights,[1,2,4,3]);
        for ii = 1:nobj

            [~,indS]     = ismember(startFcst,forecastOutput{ii}.start);
            [check,indV] = ismember(variables{ii},forecastOutput{ii}.variables);
            if ~any(check)
                name = names{ii};
                if isempty(name)
                    name = ['Model' int2str(ii)];
                end
                error([mfilename ':: The ' variables{ii} ' is not part of the model ' name])
            end
            
            mFcst = forecastOutput{ii}.data(1:nHor,indV,end,indS);
            if size(weights,3) > 1 
                aggFcst = aggFcst + weightsT(:,ii,:,:).*mFcst; % Time-varying weights
            else
                aggFcst = aggFcst + weightsT(ii)*mFcst;
            end
            
        end

    end
    
    % Evaluating the aggregated forecast
    %------------------------------------
    if ~isempty(h)
        h.status2 = h.status2 + 1;
        h.text2   = 'Evaluate the aggregated forecast...';
    end
    
    meanFcst   = [];
    evaluation = [];
    if ~isempty(inputs.fcstEval)
      
        % Get the actual data to evaluate against
        actualTS = [];
        allVars  = {inputs.newVar};
        start    = nb_date.date2freq(startFcst{1});
        finish   = nb_date.date2freq(startFcst{end-1});
        histData = getHistory(obj,allVars);
        try
            histData = reorder(histData,allVars);
            actual   = window(histData,start,finish);
            actual   = [actual.data;nan(1,size(actual.data,2))];
            actual   = nb_splitSample(actual,nHor);
        catch %#ok<CTCH>
            [actual,actualTS] = calculateAggragatedBasedOnWeights(obj,weights,weightsTS,variables,startFcst,nHor,inputs.newVar);
        end
        
        if isempty(actual)
            [actual,actualTS] = calculateAggragatedBasedOnWeights(obj,weights,weightsTS,variables,startFcst,nHor,inputs.newVar);
        end

        % Assign the historical observation to one of the aggregated models
        if ~isempty(actualTS)
            obj = mergeActual(obj,actualTS,inputs.newVar);
        end
        
        % Then do the evaluation
        if inputs.density
            aggFcstT = permute(aggFcst,[1,2,4,3]); % nSteps x nVars x draws x nPeriods 
            meanFcst = mean(aggFcst,4);            % nSteps x nVars x nPeriods
            for ii = 1:nDates
                if inputs.estimateDensities
                    evaluationT = nb_evaluateDensityForecast(inputs.fcstEval,actual(:,:,ii),aggFcstT(:,:,:,ii),meanFcst(:,:,ii),inputs);
                else
                    evaluationT = nb_evaluateDensity(inputs.fcstEval,actual(:,:,ii),[],[],meanFcst(:,:,ii),aggFcstT(:,:,:,ii));
                end
                try
                    evaluation = [evaluation,evaluationT]; %#ok<AGROW>
                catch %#ok<CTCH>
                    evaluation = evaluationT;
                end
            end
        else
            typeOfEval = inputs.fcstEval;
            meanFcst   = permute(aggFcst,[1,2,4,3]); % nSteps x nVars x nPeriods
            for ii = 1:nDates
                for jj = 1:length(typeOfEval)
                    evaluationT.(upper(typeOfEval{jj})) = nb_evaluateForecast(typeOfEval{jj},actual(:,:,ii),meanFcst(:,:,ii));
                end
                try
                    evaluation = [evaluation,evaluationT]; %#ok<AGROW>
                catch %#ok<CTCH>
                    evaluation = evaluationT;
                end
            end
        end
        
    end
    
    % Construct percentiles
    %--------------------------------------------
    if ~isempty(h)
        h.status2 = h.status2 + 1;
        h.text2   = 'Finishing...';
    end
    
    if inputs.density
        
        if isempty(meanFcst)
            meanFcst = mean(aggFcst,4);    
        end
        
        aggFcst = permute(aggFcst,[1,2,4,3]);
        nPer    = size(aggFcst,4);
        if ~isempty(inputs.perc)
            
            % Calculate actual percentiles
            perc = nb_interpretPerc(inputs.perc,false);
            
            % Get the percentiles
            %.....................
            nPerc = size(perc,2);
            fData = nan(nHor,1,nPerc+1,nPer);
            for ii = 1:nPerc
                fData(:,:,ii,:) = prctile(aggFcst,perc(ii),3);
            end
        else
            fData                = nan(nHor,1,draws+1,nPer);
            fData(:,:,1:end-1,:) = aggFcst;
        end
        fData(:,:,end,:) = permute(meanFcst,[1,2,4,3]); 
        aggFcst          = fData;

    else
        perc  = [];
        draws = 1;
    end
    
    % Some properties may be to memory intensive, so we can save does to 
    % files and store the path to the file instead
    %----------------------------------------------------------------------
    if isfield(inputs,'saveToFile')
        saveToFile = inputs.saveToFile;
    else
        saveToFile = false;
    end

    if saveToFile && inputs.density && ~nb_isempty(evaluation)
        
        density    = {evaluation.density}; 
        domain     = {evaluation.int};
        pathToSave = nb_userpath('gui');

        if exist(pathToSave,'dir') ~= 7
            try
                mkdir(pathToSave)
            catch %#ok<CTCH>
                error(['You are standing in a folder you do not have writing access to (' pathToSave '). Please switch user path!'])
            end
        end
        
        if isfield(inputs,'index')
            saveND  = ['\density_model_' int2str(inputs.index) '_' nb_clock('vintagelong')];
        else
            saveND  = ['density_' nb_clock('vintagelong')];
        end
        saveND = [pathToSave '\' saveND];
        save(saveND,'domain','density')

        % Assign output the filename (I think this is the fastest way to 
        % do it)
        nPer                    = size(evaluation,2);
        saveND                  = cellstr(saveND);
        saveND                  = saveND(:,ones(1,nPer));
        [evaluation(:).int]     = saveND{:};
        [evaluation(:).density] = saveND{:};
        
    end
    
    % Store the ouput in the property forecastOuput, so this model group 
    % can be combined with other groups as well 
    %-------------------------------------------------------------------
    inputs.function = 'aggregateForecast';
    inputs.weights  = weightsInn;
    obj.forecastOutput = struct(...
      'data',           aggFcst,...
      'variables',      {{inputs.newVar}},...
      'dependent',      {{inputs.newVar}},...
      'nSteps',         nHor,...
      'type',           'unconditional',...
      'start',          {startFcst},...
      'nowcast',        0,...
      'missing',        [],...
      'evaluation',     evaluation,...
      'method',         [],...
      'draws',          draws,...
      'parameterDraws', 1,...
      'perc',           perc,...
      'inputs',         inputs,...
      'saveToFile',     0);

    % Set seed back to old
    %------------------------------------------------------------------
    defaultStream.State = savedState;
    RandStream.setGlobalStream(defaultStream);
    
    if ~isempty(h) && deleteH
        delete(h)
    end

end

%==========================================================================
function [actual,actualTS] = calculateAggragatedBasedOnWeights(obj,weights,weightsTS,variables,startFcst,nSteps,newVar)
% If the historical values of the aggragated series is not stored in the
% data set of the individual model we create it.

    if length(unique(variables)) ~= length(variables)
        error([mfilename ':: It is not possible to aggregate the same variable from different models, and call it something else.'])
    end
    
    start = nb_date.date2freq(startFcst{1});
    if length(startFcst) < 2
        finish = start;
    else
        finish = nb_date.date2freq(startFcst{end-1});
    end
    histData = getHistory(obj,variables);
    try
        histData = reorder(histData,variables);
    catch %#ok<CTCH>
        error([mfilename ':: Could not get the historical data on all the variables of the model group.'])
    end
    weightsTS = window(weightsTS,'','',variables);
    weightsTS = reorder(weightsTS,variables);
    actual    = window(histData,start,finish);
    actualTS  = actual.*weightsTS;
    actualTS  = sum(actualTS,2);
    actualTS  = rename(actualTS,'variable','sum',newVar);
    actual    = [actual.data;nan(1,size(actual.data,2))];
    if size(weights,3) > 1
        actual = nb_splitSample(actual,nSteps);
        actual = sum(actual.*weights,2);
    else
        actual = actual*weights';
        actual = nb_splitSample(actual,nSteps);        
    end

end

%==========================================================================
function Y = aggregateDensities(obj,inputs,forecastOutput,variables,startFcst,names,nHor,waitbar)

    draws    = inputs.draws;
    iter     = length(startFcst);
    weights  = inputs.weights;
    nobj     = numel(forecastOutput);
    
    % Get the distributions to draw from
    dist(nHor,nobj,iter) = nb_distribution;
    for ii = 1:nobj

        [~,indS]     = ismember(startFcst,forecastOutput{ii}.start);
        [check,indV] = ismember(variables{ii},forecastOutput{ii}.dependent);
        if ~any(check)
            name = names{ii};
            if isempty(name)
                name = ['Model' int2str(ii)];
            end
            error([mfilename ':: The ' variables{ii} ' is not part of the model ' name])
        end

        % Get the marginal distribution at each forecasting step
        evalFcst = forecastOutput{ii}.evaluation;
        if forecastOutput{ii}.saveToFile
            density = evalFcst(1).density; 
            loaded  = load(density);
            density = loaded.density;
            domain  = loaded.domain;
        else
            density = {evalFcst.density}; 
            domain  = {evalFcst.int}; 
        end
        
        % Check if the variable has been nowcasted by the model, and if the
        % variable has not been nowcast but some other variables of this
        % model are we remove the first observation stored to the density
        startHor = 1;
        endHor   = nHor;
        if isfield(forecastOutput{ii},'missing')
            if nHor < size(density{1}{indV},1)
                if isempty(forecastOutput{ii}.missing) 
                    % Missing method used, but no variable that where 
                    % missing are stored, i.e. removed in nb_forecast
                    % from the forecastOutput property
                    mHor     = size(density{1}{indV},1);
                    startHor = mHor-nHor+1; % Remove nowcast
                    endHor   = mHor;
                else
                    % Here we either remove the history of variables with
                    % no missing observations, or we remove the last
                    % forecasts for the variables with missing observations
                    missing  = sum(forecastOutput{ii}.missing(:,indV));
                    sInd     = nowcast(ii) - missing;
                    startHor = sInd+1;
                    endHor   = sInd+nHor;
                end
            end
        end

        kk = 1;
        for jj = indS
            densityPer = density{jj}{indV};
            if iscell(densityPer)
                dd = 1;
                for hh = startHor:endHor
                    dist(dd,ii,kk) = nb_distribution('type',densityPer{hh}{1},'parameters',densityPer{hh}{2});
                    dd             = dd + 1;
                end
            else
                domainPer  = domain{jj}{indV};
                if size(domainPer,1) == 1
                    domainPer = domainPer(ones(1,size(densityPer,1)),:);
                end
                dd = 1;
                for hh = startHor:endHor
                    dist(dd,ii,kk) = nb_distribution('type','kernel','parameters',{domainPer(hh,:)',densityPer(hh,:)'});
                    dd             = dd + 1;
                end
            end
            kk = kk + 1;
        end

    end

    % Get (auto)correlation matrix 
    if ~isempty(waitbar)
        waitbar.status2 = waitbar.status2 + 1;
        waitbar.text2   = 'Estimate the correlation structure...';
    end
    sigma = constructSigma(obj,inputs,variables,startFcst,nHor,nobj);
           
    % Draw consistent draws across the different marginals
    if ~isempty(waitbar)
        waitbar.status2 = waitbar.status2 + 1;
        waitbar.text2   = 'Draw consistent draws across the different marginals...';
    end
    
    Y = zeros(nHor,1,iter,draws);
    if size(weights,1) > 1
        w = weights(:,:,:,ones(1,draws)); % Time-varying weights
    else
        w = weights(ones(1,nHor),:,ones(1,iter),ones(1,draws));
    end
    for ii = 1:iter

        distY       = dist(:,:,ii);                            % nHor x nvar nb_distribution object
        nVar        = size(distY,2);
        distY       = distY';                                  % nvar x nHor nb_distribution object
        distY       = distY(:);                                % nvar*nHor x 1 nb_distribution object
        copula      = nb_copula(distY','sigma',sigma(:,:,ii));
        Yper        = random(copula,1,draws);                  % 1 x nvar*nHor x draws 
        Yper        = reshape(Yper,[1,nVar,nHor,draws]);       % 1 x nvar x nHor x draws 
        Yper        = permute(Yper,[3,2,1,4]);                 % nHor x nvar x 1 x draws                    
        Y(:,:,ii,:) = sum(w(:,:,ii,:).*Yper,2);                % nHor x 1 x 1 x draws

        if ~isempty(waitbar)
            waitbar.status2 = waitbar.status2 + 1;
        end
        
    end

end

%==========================================================================
function sigmaCond = constructSigma(obj,inputs,variables,startFcst,nHor,nobj)
    
    nLags    = inputs.nLags;
    condLags = inputs.condLags;
    if isempty(condLags)
        condLags = 0;
    end
    rollingWindow = inputs.rollingWindow;
    nPeriods      = length(startFcst);
    nVars         = length(variables);
    nDim          = nVars*nHor;
    recursive     = inputs.recursive;
    sigmaMethod   = inputs.sigmaMethod;
    sigmaShrink   = inputs.sigmaShrink;
    
    if recursive

        sigmaCond = nan(nDim,nDim,nPeriods);
        if ~isempty(rollingWindow)
        
            for ii = 1:nPeriods
                startEst          = toString(nb_date.date2freq(startFcst{ii}) - (1 + rollingWindow));
                finishEst         = toString(nb_date.date2freq(startFcst{ii}) - 1);
                sigmaCond(:,:,ii) = constructSigmaOneIter(obj,startEst,finishEst,variables,nHor,condLags,nLags,nobj,sigmaMethod,sigmaShrink);
            end
            
        else 

            startEst  = getEstimationStartDate(obj);
            for ii = 1:nPeriods
                finishEst         = toString(nb_date.date2freq(startFcst{ii}) - 1);
                sigmaCond(:,:,ii) = constructSigmaOneIter(obj,startEst,finishEst,variables,nHor,condLags,nLags,nobj,sigmaMethod,sigmaShrink);
            end
            
        end
            
    else
        
        startEst  = getEstimationStartDate(obj);
        finishEst = startFcst{end-1};
        sigmaCond = constructSigmaOneIter(obj,startEst,finishEst,variables,nHor,condLags,nLags,nobj,sigmaMethod,sigmaShrink);
        sigmaCond = sigmaCond(:,:,ones(1,nPeriods));   
        
    end
    
end

function sigma = constructSigmaOneIter(obj,startEst,finishEst,variables,nHor,condLags,nLags,nobj,sigmaMethod,sigmaShrink)

    if strcmpi(sigmaMethod,'var')
        
        % Setup VAR model
        data                = getHistory(obj,variables);
        varT                = nb_var.template();
        varT.dependent      = variables;
        varT.data           = window(data,startEst,finishEst);
        varT.modelSelection = 'lagLength';
        
        % Estimate model an construct conditional correlation matrix
        varM  = nb_var(varT); 
        varM  = estimate(varM);
        varM  = solve(varM);
        sigma = theoreticalMoments(varM,...
                    'vars',      variables,...
                    'output',    'double',...
                    'type',      'correlation',...
                    'stacked',   true,...
                    'nLags',     nHor - 1);
    else
        
        
        % Get the variables to calculate the moments of
        histData    = getHistory(obj,variables);
        histData    = window(histData,startEst,finishEst);
        histData    = reorder(histData,variables);
        emp         = double(histData.data);
        sigmaUncond = nb_autocorrMat2(emp,nHor + condLags - 1,true,false);
        
        
%         sigmaUncond = empiricalMoments(obj,...
%                     'startDate', startEst,...
%                     'endDate',   finishEst,...
%                     'vars',      variables,...
%                     'output',    'double',...
%                     'shrink',    sigmaShrink,...
%                     'stacked',   true,...
%                     'type',      'correlation',...
%                     'nLags',     nHor + condLags - 1);
                
        if condLags > 0
            indC      = [true(1,nobj*condLags),false(1,nobj*(nHor + 1))];
            sigma11   = sigmaUncond(~indC,~indC);
            sigma12   = sigmaUncond(~indC,indC);
            sigma21   = sigmaUncond(indC,~indC);
            sigma22   = sigmaUncond(indC,indC);
            sigma     = sigma11 - (sigma12/sigma22)*sigma21;
        else
            sigma     = sigmaUncond;
        end        

    end
    
    if ~isempty(nLags)   

        if nLags > nHor
            error([mfilename ':: The ''nLags'' cannot be greater than ' int2str(nHor)])
        end
        start  = nobj*(nLags + 1) + 1;
        start2 = size(sigma,1) - nobj*(nLags + 1);
        for ii = 1:nHor
            ind                  = 1 + nobj*(ii-1):nobj*ii;
            ind2                 = size(sigma,1) - fliplr(ind) + 1;
            sigma(start:end,ind) = 0; 
            sigma(1:start2,ind2) = 0;
            start                = start + nobj;
            start2               = start2 - nobj;
        end

    end

end

%==========================================================================
function Y = naiveAggregateDensities(inputs,forecastOutput,variables,startFcst,names,nHor,waitbar)

    weights = inputs.weights;
    nDates  = length(startFcst);
    if size(weights,1) == 1
        weights = weights(ones(1,nHor),:,ones(1,nDates));    % Fixed weights
    end
    nobj       = length(forecastOutput);
    minDomain  = nan(nobj,nHor,nDates);
    maxDomain  = nan(nobj,nHor,nDates);   
    for ii = 1:nobj

        [~,indS]     = ismember(startFcst,forecastOutput{ii}.start);
        [check,indV] = ismember(variables{ii},forecastOutput{ii}.dependent);
        if ~any(check)
            name = names{ii};
            if isempty(name)
                name = ['Model' int2str(ii)];
            end
            error([mfilename ':: The ' variables{ii} ' is not part of the model ' name])
        end
        
        % Get the domain and density stored in object or in a file
        evalFcst = forecastOutput{ii}.evaluation;
        if forecastOutput{ii}.saveToFile
            density = evalFcst(1).density; 
            loaded  = load(density,'domain');
            domain  = loaded.domain;
        else
            domain = {evalFcst.int}; 
        end

        % Check the domains from the different models
        kk     = 1;
        domain = domain(indS);
        for jj = indS
            
            domainPer = domain{kk}{indV};
            if size(domainPer,1) == 1
                domainPer = domainPer(ones(1,nHor),:);
            elseif size(domainPer,1) > nHor
                if isempty(forecastOutput{ii}.missing) 
                    % Missing method used, but no variable that where 
                    % missing are stored, i.e. removed in nb_forecast
                    % from the forecastOutput property
                    domainPer = domainPer(end-nHor+1:end,:);
                else
                    missing   = sum(forecastOutput{ii}.missing(:,indV));
                    sInd      = nowcast(ii)  - missing;
                    domainPer = domainPer(sInd+1:sInd+nHor,:);
                end
            end
            for hh = 1:nHor
                minDomain(ii,hh,jj)  = min(domainPer(hh,1));
                maxDomain(ii,hh,jj)  = max(domainPer(hh,1));
            end
            kk = kk + 1;
            
        end
  
    end
      
    % Here we need to simulate from the densities and do kernel density 
    % estimation at the combine domain
    %--------------------------------------------------------
    
    % Get combined start and end of domain of each variable at all
    % periods
    minDomainVar = nan(nHor,nDates);
    maxDomainVar = nan(nHor,nDates);    
    for jj = 1:size(minDomain,3)
        minDomainVar(:,jj) = min(minDomain(:,:,jj),[],1);
        maxDomainVar(:,jj) = max(maxDomain(:,:,jj),[],1);
    end

    if ~isempty(waitbar)
        waitbar.status2 = waitbar.status2 + 1;
        waitbar.text2   = 'Draw consistent draws across the different marginals...';
    end
    
    % Simulate and estimate the densities given the new domain
    combinedDensity = repmat({0},[1,1,nDates]);
    int             = cell(1,1,nDates);
    for ii = 1:nobj

        [~,indS]     = ismember(startFcst,forecastOutput{ii}.start);
        [check,indV] = ismember(variables{ii},forecastOutput{ii}.dependent);
        if ~any(check)
            name = names{ii};
            if isempty(name)
                name = ['Model' int2str(ii)];
            end
            error([mfilename ':: The ' variables{ii} ' is not part of the model ' name])
        end
        
        % Get the domain and density stored in object or in a file
        evalFcst = forecastOutput{ii}.evaluation;
        if forecastOutput{ii}.saveToFile
            density = evalFcst(1).density; 
            loaded  = load(density);
            density = loaded.density;
            domain  = loaded.domain;
        else
            density = {evalFcst.density}; 
            domain  = {evalFcst.int}; 
        end

        % Simulate from the densities of this model
        density       = density(indS);
        domain        = domain(indS);
        nPer          = size(density,2);
        densityForSim = [density{:}];
        densityForSim = reshape(densityForSim,1,[],nPer);
        densityForSim = densityForSim(:,indV,:);
        domainForSim  = [domain{:}];
        domainForSim  = reshape(domainForSim,1,[],nPer);
        domainForSim  = domainForSim(:,indV,:);
        if isfield(forecastOutput{ii},'missing') 
            if size(densityForSim{1},1) > nHor
                % In this case we are only dealing with one variable!
                if isempty(forecastOutput{ii}.missing) 
                    % Missing method used, but no variable that where 
                    % missing are stored, i.e. removed in nb_forecast
                    % from the forecastOutput property
                    for hh = 1:size(densityForSim,3)
                        densityForSim{hh} = densityForSim{hh}(end-nHor+1:end,:); % Remove nowcast from density
                        if size(domainForSim{hh},1) > 1
                            domainForSim{hh} = domainForSim{hh}(end-nHor+1:end,:); % Remove nowcast from domain
                        end
                    end
                else 
                    % Here we either remove the history of variables with
                    % no missing observations, or we remove the last
                    % forecasts for the variables with missing observations
                    missing = sum(forecastOutput{ii}.missing(:,indV));
                    sInd    = nowcast(ii) - missing;
                    for hh = 1:size(densityForSim,3)
                        densityForSim{hh} = densityForSim{hh}(sInd+1:sInd+nHor,:);
                        if size(domainForSim{hh},1) > 1
                            domainForSim{hh} = domainForSim{hh}(sInd+1:sInd+nHor,:);
                        end
                    end

                end
            end
        end
        
        % Simulate from the density
        Y = nb_simulateFromDensity(densityForSim,domainForSim,inputs.draws); % A nHor x nVars x nPer x nDraws double.

        % Get aggregated density for each forecast period
        kk = 1;
        for jj = indS
            
            if ii == 1
                maxim     = ceil(maxDomainVar(:,jj)*100)/100;
                minim     = floor(minDomainVar(:,jj)*100)/100;
                delta     = (maxim - minim)*0.10;
                maxim     = maxim + delta;
                minim     = minim - delta;
                bins      = (maxim - minim)/999; % Default is to store 1000 points of the density 
                domainAgg = nan(nHor,1000);
                for hh = 1:nHor
                    domainAgg(hh,:) = minim(hh):bins(hh):maxim(hh);
                end
                int{1,1,jj} = domainAgg;
            end
            
            % Then we do kernel density estimation
            empDens    = permute(Y(:,1,kk,:),[1,4,2,3]); % nHor x nSim x 1 x 1
            densityVar = nb_ksdensity(empDens,int{1,1,jj}); 

            try
                combinedDensity{:,:,jj} = combinedDensity{:,:,jj} + weights(:,ii,kk).*densityVar;
            catch %#ok<CTCH>
                error([mfilename ':: Domain mismatch between models. Please see the bins options of the uncondForecast '...
                                 'method of the nb_model_generic class, or set the check option to this method to true.'])
            end
            kk = kk + 1;

        end
        
        if ~isempty(waitbar)
            waitbar.status2 = waitbar.status2 + 1;
        end
        
    end
    
    % Simulate from the aggregated density
    Y = nb_simulateFromDensity(combinedDensity,int,inputs.draws);
 
end

%==========================================================================
function obj = mergeActual(obj,actualTS,newVar)
    
    model = obj.models{1};
    cont  = true;
    level = 1;
    while cont         
        if isa(model,'nb_model_group')
            model = model.models{1};
            level = level + 1;
        else
            cont = false;
        end
    end

    opt = model.estOptions;
    for ii = 1:numel(opt)
        startData                = nb_date.date2freq(opt(ii).dataStartDate); 
        indS                     = (actualTS.startDate - startData) + 1;
        indE                     = (actualTS.endDate - startData) + 1;
        dataA                    = opt(ii).data;
        dataA                    = [dataA,nan(size(dataA,1),1,size(dataA,3))]; %#ok<AGROW>
        dataA(indS:indE,end,end) = double(actualTS);
        opt(ii).data             = dataA;
        opt(ii).dataVariables    = [opt(ii).dataVariables,newVar];
    end
    model = setEstOptions(model,opt);
    
    switch level
        case 1
            obj.models{1} = model;
        case 2
            obj.models{1}.models{1} = model;
        case 3
            obj.models{1}.models{1}.models{1} = model;
        case 4
            obj.models{1}.models{1}.models{1}.models{1} = model;
        case 5
            obj.models{1}.models{1}.models{1}.models{1}.models{1} = model;
        case 6
            obj.models{1}.models{1}.models{1}.models{1}.models{1}.models{1} = model;
        otherwise
            error([mfilename ':: Please contact a psychiatrist!'])
    end
            
    
end
