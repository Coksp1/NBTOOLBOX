function [obj,weights,plotter] = combineForecast(obj,varargin)
% Syntax:
%
% obj = combineForecast(obj,varargin)
% [obj,weights,plotter] = combineForecast(obj,varargin)
%
% Description:
%
% Combine density or point forecast.
% 
% Input:
% 
% - obj             : An object of class nb_model_group
%
% Optional inputs:
%
% - 'startDate'     : Start date of the combination of forecast. I.e.
%                     the start date of which the weights are constructed.
%                     Default is to use the first shared forecast date.
%                     Must be given as a string or a nb_date object.
%
% - 'endDate'       : End date of the combination of forecast. I.e.
%                     the end date of which the weights are constructed.
%                     Default is to use the last shared forecast date.
%                     Must be given as a string or a nb_date object.
%
% - 'nSteps'        : The number of steps ahead forecast. The default is
%                     to take the minimum over the selected models.
%
% - 'type'          : A string with on of the following:
%                     - 'MSE'   : Mean squared error
%                     - 'RMSE'  : Root mean squared errors
%                     - 'ESLS'  : Exponetial of the sum of the log scores
%                     - 'EELS'  : Exponetial of the mean of the log scores
%                     - 'equal' : Use equal weights
%
% - 'draws'         : Number of draws from the combine density. Default is
%                     1000.
%
% - 'density'       : Give 1 (true) if you want to evaluate and produce
%                     density forecast. Default is not (0 or false).
%
%                     Caution: If you set this option to false the mean
%                              forecast is used to construct the point
%                              forecast from model which has produced
%                              density forecast.
%
% - 'perc'          : Error band percentiles. As a 1 x numErrorBand 
%                     double. E.g. [0.3,0.5,0.7,0.9]. Default is 0.9.
%                     Can be empty, i.e. no percentiles are reported.
%                     Only an options when 'density' is set to true.
% 
% - 'allPeriods'    : Give 1 (true) if you want to construct (density) 
%                     forecast for all recursive forecast (which may have  
%                     been produced by the models stored in this object). 
%                     Default is 0 (false), i.e. only to produce forecast 
%                     for the last period.
%
% - 'optimizeOpt'   : Give 1 (true), if you want to use optimized weights,
%                     instead of weights based on the formula;
%
%                     w(i) = score(i)/sum(score)
%
%                     Caution : Not yet finished!!!
%
% - 'fcstEval'      : See the forecast method of the nb_model_generic
%                     class.
%
% - 'varOfInterest' : As a string or a cellstr. Use this option if you want 
%                     to combine forecast for one or more variables.
%
% - 'check'         : Give true (1) to check that the domain is the same
%                     for all models. If they are not we need to simulate 
%                     "new" densities at a shared domain (using 1000
%                     bins). This could take a lot of time! To prevent this
%                     use the 'bins' option of the forecast method
%                     of the nb_model_generic. Default is false (The error
%                     may be hard to interpret if the domain is 
%                     conflicting). This may also lead to more
%                     severe density estimation errors!
%
% - 'saveToFile'    : Logical. Save densities and domains to files. One 
%                     file for each model. Default is false (do not).
%
% - 'rollingWindow' : Set it to a number if the combination weights are to 
%                     be calculated using a rolling window. Default is 
%                     empty, i.e. to calculate the weights recursivly using 
%                     the the full history at each recursive step.
%
% - 'parallel'      : Set to true to run forecast combination in parallel.
%
% - 'lambda'        : Give the value of the parameter of the exponential  
%                     decaying weights on past forecast errors when 
%                     constructing the score. If empty the weights on all 
%                     past forecast errors are equal.
%
% Output:
% 
% - obj         : An object of class nb_model_group where the combined
%                 forecast is saved in the property forecastOutput
%
% - weights     : A struct. Where each field store the weights at forecast
%                 horizon h. Each feild consist of a nDates x nModel x nVar
%                 nb_ts object.
%
% - plotter     : A 1 x h nb_graph_ts object, which you can call the graph
%                 method on to produce a graph of the weights over the
%                 recusive periods if allPeriods is set to true. 
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) ~= 1
        error([mfilename ':: When combining forecast the obj input can only consist of one nb_model_group object'])
    end
    
    % Use the same seed when returning the "random" numbers
    %--------------------------------------------------------------
    seed          = 2.0719e+05;
    defaultStream = RandStream.getGlobalStream;
    savedState    = defaultStream.State;
    s             = RandStream.create('mt19937ar','seed',seed);
    RandStream.setGlobalStream(s);
    
    % Parse the arguments
    %-------------------------------------------------------------- 
    default = {'bins',              [],         {@iscell,'||',@isempty};...
               'check',             false,      {{@ismember,[0,1]}};...
               'allPeriods',        false,      {{@ismember,[0,1]}};...
               'estimateDensities', true,       @nb_isScalarLogical;...
               'estDensity',        'kernel'    @nb_isOneLineChar;...
               'draws',             1000,       @nb_isScalarNumber;...
               'lambda',            [],         {@nb_isScalarNumber,'||',@isempty};...
               'startDate',         '',         {@ischar,'||',{@isa,'nb_date'},'||',@isempty};...
               'endDate',           '',         {@ischar,'||',{@isa,'nb_date'},'||',@isempty};...
               'fcstEval',          '',         {@iscellstr,'||',@ischar};...
               'density',           false,      {{@ismember,[0,1]}};...
               'nSteps',            [],         {@nb_isScalarInteger,'&&',{@gt,0},'||',@isempty};...
               'parallel',          false,      {{@ismember,[0,1]}};...
               'perc',              0.9,        {@isnumeric,'||',@isempty};...
               'optimizeOpt',       false,      {{@ismember,[0,1]}};...
               'type',              'MSE',      @ischar;...
               'varOfInterest',     '',         {@ischar,'||',@isempty};...
               'saveToFile',        false,      {{@ismember,[0,1]}};...
               'rollingWindow',     [],         {@isnumeric,'&&',@isscalar,'||',@isempty}}; 
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    if ischar(inputs.fcstEval)
        inputs.fcstEval = cellstr(inputs.fcstEval);
    end
    if ischar(inputs.endDate)
        inputs.endDate = nb_date.date2freq(inputs.endDate);
    end
    if ischar(inputs.startDate)
        inputs.startDate = nb_date.date2freq(inputs.startDate);
    end
    
    allPeriods = inputs.allPeriods;
    type       = inputs.type;
    startDate  = inputs.startDate;
    endDate    = inputs.endDate;
    nSteps     = inputs.nSteps;
    
    % Get the forecast output from each model (nb_model_generic) or 
    % model group (nb_model_group)
    %---------------------------------------------------------------
    modelsT = obj.models(:);
    if isprop(obj,'valid')
        modelsT = modelsT(obj.valid);
    end
    nobj = size(modelsT,1);
    if nobj == 0
        error('There are no valid models to combine.')
    end
    
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
    
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!! Check the frequency !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    % Get the all the unique variables of different models
    vars         = cell(1,nobj);
    nHor         = nan(1,nobj);
    startFcstObj = cell(1,nobj);
    nowcast      = zeros(1,nobj);
    for ii = 1:nobj
        vars{ii}         = forecastOutput{ii}.dependent;
        if isempty(forecastOutput{ii}.nSteps)
            nHor(ii) = 0;
        else
            nHor(ii) = forecastOutput{ii}.nSteps;
        end
        startFcstObj{ii} = forecastOutput{ii}.start;
        if isfield(forecastOutput{ii},'nowcast')
        	nowcast(ii)  = forecastOutput{ii}.nowcast;
        end
    end
    
    % Don't no why this may happend, but just to be robust to this case.
    indRemove = nHor == 0;
    if any(indRemove)
        vars           = vars(~indRemove);
        nHor           = nHor(~indRemove);
        startFcstObj   = startFcstObj(~indRemove);
        nowcast        = nowcast(~indRemove);
        names          = names(~indRemove);
        forecastOutput = forecastOutput(~indRemove);
        nobj           = size(forecastOutput,2);
        if nobj == 0
            error('There are no valid models to combine.')
        end
        
    end
    
    % Adjust for nowcasts
    if any(nowcast)
        if isempty(inputs.varOfInterest)
            error([mfilename ':: If some model produce nowcast the ''varOfInterest'' input must be given (With only one variable).'])
        else
            if ~iscellstr(inputs.varOfInterest)
                allVars = cellstr(inputs.varOfInterest);
            else
                allVars = inputs.varOfInterest;
            end
            if ~isscalar(allVars)
                error([mfilename ':: If some model produce nowcast the ''varOfInterest'' input must be given with only one variable.'])
            end
        end
        [forecastOutput,startFcstObj] = nb_model_group.adjustForecastGivenNowcast(nowcast,forecastOutput,startFcstObj,allVars,names);
    else
        if ~isempty(inputs.varOfInterest)
            if iscellstr(inputs.varOfInterest)
                allVars = inputs.varOfInterest;
            else
                allVars = {inputs.varOfInterest};
            end
        else
            allVars  = unique(nb_nestedCell2Cell(vars));
        end
    end
    nAllVars = length(allVars);
    
    % Check forecasting steps
    nHor = min(nHor);
    if ~isempty(nSteps)
        if nHor < nSteps
            error([mfilename ':: Some of the models has not produced forecast at horizon ' int2str(nSteps) '. Minimum is ' int2str(nHor) '.'])
        end
        nHor = nSteps;
    end
    
    % Get start dates of forecasts
    startFcst    = nb_date.union(startFcstObj{:});
    startFcst1   = nb_date.date2freq(startFcst{1});
    startFcstEnd = nb_date.date2freq(startFcst{end});
    nDates       = length(startFcst);
    if ~isempty(startDate)
        
        indS  = startDate - startFcst1 + 1;
        if indS < 1
            error([mfilename ':: The startDate input is before the union of start dates of the forecast from the models.'])
        elseif indS > nDates
            error([mfilename ':: The startDate input is after the union of end dates of the forecast from the models.'])
        end
        startFcst = startFcst(1,indS:end);
        
    end
    
    if ~isempty(endDate)
        
        indE  = startFcstEnd - endDate;
        if indE < 0
            error([mfilename ':: The endDate input is after the union of end dates of the forecast from the models.'])
        elseif indE > nDates
            error([mfilename ':: The endDate input is before the union of start dates of the forecast from the models.'])
        end
        startFcst = startFcst(1,1:end-indE);
        
    end
    if allPeriods
        nDates = length(startFcst);
    else
        nDates = 1;
    end
    
    % As the models may not chare the same forecasting periods, just assign
    % zero share to that model 
    indDates = cell(1,nobj);
    for ii = 1:nobj
        [~,indD]     = ismember(startFcstObj{ii},startFcst);
        indDates{ii} = indD;
    end
    
    % Then we calculate the forecast metric
    %--------------------------------------- 
    if ~inputs.optimizeOpt
        
        if ~strcmpi(type,'equal')

            scores = zeros(nHor,nAllVars,nDates,nobj); 
            for ii = 1:nobj

                indD = indDates{ii};
                if isempty(indD)
                    % Assign zero share to this model, as it does not share
                    % any dates with the others
                    continue
                end
                if find(indD,1) > 1
                    start = startFcst{1};
                else
                    start = startFcst{indD(1)};
                end
                
                if find(indD,1,'last') < numel(indD)
                    finish = startFcst{end};
                else
                    finish = startFcst{indD(end)};
                end
                  
                try
                    score = nb_model_generic.constructScore(forecastOutput{ii},type,allPeriods,start,finish,nHor,inputs.rollingWindow,inputs.lambda);
                catch Err
                    name = names{ii};
                    if isempty(name)
                        name = ['model ' int2str(ii)];
                    end
                    error([mfilename ':: You need to produce forecast with the needed forecasting evaluation for the model '...
                                     'with name ' name '. Error:: ' Err.message])
                end

                % Fix so that nowcast for variables are ordered properly
                %score      = reorderDue2Nowcast(forecastOutput{ii},score,nHor);
                [ind,indV] = ismember(vars{ii},allVars);
                indV       = indV(ind);
                if allPeriods
                    indD(indD==0)          = [];
                    scores(:,indV,indD,ii) = score(:,ind,:);
                else
                    scores(:,indV,:,ii) = score(:,ind,:);
                end

            end

        else

            % Here we just use equal weights
            scores = zeros(nHor,nAllVars,nDates,nobj); 
            for ii = 1:nobj
                indD          = indDates{ii};
                indD(indD==0) = [];
                if isempty(indD)
                    % Assign zero share to this model, as it does not share
                    % any dates with the others
                    continue
                end
                [ind,indV] = ismember(vars{ii},allVars);
                indV       = indV(ind);
                if allPeriods
                    scores(:,indV,indD,ii) = 1;
                else
                    scores(:,indV,:,ii) = 1;
                end
            end

        end    
        
    end
        
    % Then we need to construct the weights
    %--------------------------------------
    if inputs.optimizeOpt
        error([mfilename ':: The optimizeOpt option is not yet supported'])
    else       
        sumScores = sum(scores,4);
        weights   = bsxfun(@rdivide,scores,sumScores);
    end
       
    % Now we combine the densities or point forecast
    %-----------------------------------------------
    if inputs.density
        
        % Create wait bar (This could take some time)
        maxIter = 2;
        if ~isempty(inputs.fcstEval)
            maxIter = maxIter + 1;
        end
        if inputs.check
            maxIter = maxIter + nobj;
        end
        
        h = nb_waitbar([],['Combine Forecast of ' int2str(nobj) ' models'],maxIter,false);
        if inputs.check
            h.text = 'Check for conflicting domains...'; 
        else
            h.text = 'Construct the combined density...'; 
        end
        
        % Get the combined density
        %--------------------------------------------------------- 
        if inputs.check
            % Here we assume that the domains can be not conflicting
            [combinedDensity,int] = checkDomainAndCombineDensities(h,inputs,nHor,allPeriods,startFcst,nDates,indDates,forecastOutput,vars,allVars,weights,names);
        else
            % Here we assume that the domains are not conflicting
            [combinedDensity,int] = combineDensities(allPeriods,startFcst,nDates,indDates,forecastOutput,vars,allVars,weights);
        end
        
    else % Point
        
        combFcst = zeros(nHor,nAllVars,nDates);
        for ii = 1:nobj
            
            [ind,indV] = ismember(allVars,vars{ii});
            indD       = indDates{ii};
            if isempty(indD) || isempty(ind)
                % Assign zero share to this model, as it does not share
                % any wanted dates with the others
                continue
            end
            
            if allPeriods
                indDFO = 1:size(forecastOutput{ii}.data,4); 
                indDFO = indDFO(indD~=0);
            else
                indD   = nDates;
                indDFO = find(indD,1,'last'); 
            end
            indD(indD==0) = [];
            
            % Get the mean/median forecast 
            % data has size nHor x nVars x nPerc + 1 x nPer, where nPerc is
            % zero for point forecast
            indV                 = indV(ind);
            modelFcst            = forecastOutput{ii}.data(1:nHor,indV,end,indDFO);
            modelFcst            = permute(modelFcst,[1,2,4,3]); % nSteps x nVars x nPeriods
            weightedFcst         = modelFcst.*weights(:,ind,indD,ii);
            combFcst(:,ind,indD) = combFcst(:,ind,indD) + weightedFcst;
            
        end
        combFcst = permute(combFcst,[1,2,4,3]);
        
    end
    
    % Then we need to simulate from the densities
    %--------------------------------------------
    if inputs.density
        
        draws    = inputs.draws;
        h.text   = ['Simulate ' int2str(draws) ' draws from the comined density...']; 
        h.status = h.status + 1;
        Y        = nb_simulateFromDensity(combinedDensity,int,draws);
        Y        = permute(Y,[1,2,4,3]);
        combFcst = mean(Y,3);
        nPer     = size(Y,4);
        if ~isempty(inputs.perc)
            
            % Calculate actual percentiles
            perc = nb_interpretPerc(inputs.perc,false);
            
            % Get the percentiles
            %.....................
            nPerc = size(perc,2);
            fData = nan(nHor,nAllVars,nPerc+1,nPer);
            for ii = 1:nPerc
                fData(:,:,ii,:) = prctile(Y,perc(ii),3);
            end
            fData(:,:,end,:) = combFcst; 
            combFcst         = fData;
            
        else
            fData                = nan(nHor,nAllVars,draws+1,nPer);
            fData(:,:,1:draws,:) = Y;
            fData(:,:,end,:)     = combFcst; 
            combFcst             = fData;
            perc                 = [];
        end

    else
        perc  = [];
        draws = 1;
    end
    
    if inputs.density
        h.status = h.status + 1;
    end
    
    % Evaluate the density or point forecast
    %---------------------------------------
    evaluation = [];
    if allPeriods && ~isempty(inputs.fcstEval)
        
        if inputs.density
            h.text   = 'Evaluate forecast...'; 
        end
        
        % Get the actual data to evaluate against
        start    = nb_date.date2freq(startFcst{1});
        finish   = nb_date.date2freq(startFcst{end-1});
        histData = getHistory(obj,allVars);
        try
            histData = reorder(histData,allVars);
        catch %#ok<CTCH>
            error([mfilename ':: Could not get the historical data on all the variables of the model group.'])
        end
        if finish > histData.endDate
            actual = window(histData,start);
            per    = (finish - histData.endDate) + 1;
        else
            actual = window(histData,start,finish);
            per    = 1;
        end
        actual = [actual.data;nan(per,size(actual.data,2))];
        actual = nb_splitSample(actual,nHor);
        
        % Then do the evaluation
        if inputs.density
            meanFcst   = permute(combFcst(:,:,end,:),[1,2,4,3]); % nSteps x nVars x nPeriods
            for ii = 1:nDates
                evaluationT = nb_evaluateDensity(inputs.fcstEval,actual(:,:,ii),combinedDensity(:,:,ii),int(:,:,ii),meanFcst(:,:,ii),Y(:,:,:,ii));
                try
                    evaluation = [evaluation,evaluationT]; %#ok<AGROW>
                catch %#ok<CTCH>
                    evaluation = evalFcstT;
                end
            end
        else
            typeOfEval = inputs.fcstEval;
            meanFcst   = permute(combFcst,[1,2,4,3]); % nSteps x nVars x nPeriods
            for ii = 1:nDates
                for jj = 1:length(typeOfEval)
                    evaluationT.(upper(typeOfEval{jj})) = nb_evaluateForecast(typeOfEval{jj},actual(:,:,ii),meanFcst(:,:,ii));
                end
                try
                    evaluation = [evaluation,evaluationT]; %#ok<AGROW>
                catch %#ok<CTCH>
                    evaluation = evalFcstT;
                end
            end
        end
        
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
        
        density    = {evaluation.density}; %#ok<NASGU>
        domain     = {evaluation.int}; %#ok<NASGU>
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
    
    if inputs.density
        h.status = h.status + 1;
    end
    
    % Delete wait bar
    %----------------
    if inputs.density
        delete(h)
    end
    
    % Store the ouput in the property forecastOuput, so this model group 
    % can be combined with other groups as well 
    %-------------------------------------------------------------------
    if allPeriods
        startFcstOut = startFcst;
    else
        startFcstOut = startFcst(end);
    end
    inputs.function = 'combineForecast';
    obj.forecastOutput = struct(...
      'data',           combFcst,...
      'variables',      {allVars},...
      'dependent',      {allVars},...
      'nSteps',         nHor,...
      'type',           'unconditional',...
      'start',          {startFcstOut},...
      'nowcast',        0,...
      'missing',        [],...
      'evaluation',     evaluation,...
      'method',         [],...
      'draws',          draws,...
      'parameterDraws', 1,...
      'perc',           perc,...
      'inputs',         inputs,...
      'saveToFile',     0);
  
    % Construct weights output 
    if nargout > 1
        
        if allPeriods
            startG = startFcst{1};
        else
            startG = startFcst{end};
        end
        
        modelNames    = nb_getModelNames(modelsT{:});
        weightsForOut = permute(weights,[3,4,2,1]); % nDates x nModel x nVar x nHor
        weights       = struct; 
        for ii = 1:nHor
            weightsObj = nb_ts(weightsForOut(:,:,:,ii),allVars,startG,modelNames);
            weights.(['Horizon' int2str(ii)]) = weightsObj;           
        end
        
        % Construct weights graph output
        if nargout > 2
           
            plotter(nHor) = nb_graph_ts;
            for ii = 1:nHor
                plotter(ii).resetDataSource(weights.(['Horizon' int2str(ii)]));
                set(plotter(ii),'plotType','stacked','sumTo',1);
            end
            
        end
        
    end
    
    % Set seed back to old
    %------------------------------------------------------------------
    defaultStream.State = savedState;
    RandStream.setGlobalStream(defaultStream);

end

%==========================================================================
% SUB
%==========================================================================
function [combinedDensity,int] = checkDomainAndCombineDensities(h,inputs,nHor,allPeriods,startFcst,nDates,indDates,forecastOutput,vars,allVars,weights,names)

    if ~allPeriods
        nDates = 1;
    end

    nobj       = length(forecastOutput);
    minDomain  = inf(nobj,nHor,length(allVars),nDates);
    maxDomain  = -inf(nobj,nHor,length(allVars),nDates);  
    sizeDomain = nan(nobj,length(allVars),nDates); 
    nowcast    = zeros(1,nobj);
    for ii = 1:nobj

        evalFcst             = forecastOutput{ii}.evaluation;
        varsOfModel          = vars{ii};
        [ind,indVarsOfModel] = ismember(varsOfModel,allVars);
        if allPeriods
            iter          = indDates{ii};
            iter(iter==0) = [];
            kk            = 1;
        else
            iter  = 1;
            kk    = find(strcmpi(startFcst{end},forecastOutput{ii}.start));
            if isempty(kk)
                continue
            end
        end

        % Get the domain and density stored in object or in a file
        if forecastOutput{ii}.saveToFile || forecastOutput{ii}.inputs.saveToFile
            density = evalFcst(1).density; 
            loaded  = load(density,'domain');
            domain  = loaded.domain;
        else
            domain = {evalFcst.int}; 
        end

        % Check the domains from the different models
        if ~isempty(forecastOutput{ii}.missing) 
            nowcast(ii) = max(sum(forecastOutput{ii}.missing,1));
        end
        
        for jj = iter

            for ll = find(ind)
                
                indVar = indVarsOfModel(ll);
                if allPeriods
                    hasWeight = weights(:,indVar,jj,ii) > eps^(1/3);
                else
                    hasWeight = weights(:,indVar,1,ii) > eps^(1/3);
                end
                
                domainPer = domain{kk}{ll};
                if size(domainPer,1) == 1
                    domainPer = domainPer(ones(1,nHor),:);
                elseif size(domainPer,1) > nHor
                    % In this case we are secured with dealing with only
                    % one variable
                    if isempty(forecastOutput{ii}.missing) 
                        % Missing method used, but no variable that where 
                        % missing are stored, i.e. removed in nb_forecast
                        % from the forecastOutput property
                        domainPer = domainPer(end-nHor+1:end,:);
                    else
                        missing   = sum(forecastOutput{ii}.missing(:,ll));
                        sInd      = nowcast(ii)  - missing;
                        domainPer = domainPer(sInd+1:sInd+nHor,:);
                    end
                end
                minDomain(ii,hasWeight,indVar,jj) = min(domainPer(hasWeight,:),[],2)';
                maxDomain(ii,hasWeight,indVar,jj) = max(domainPer(hasWeight,:),[],2)';
                sizeDomain(ii,indVar,jj)          = size(domainPer,2);
            end
            kk = kk + 1;

        end
  
    end
    
    % Check if they are conflicting
    conflicting = 0;
    for ii = 1:length(allVars)
       
        for jj = 1:nDates
            
            for hh = 1:nHor
                minDT = minDomain(:,hh,ii,jj);
                minDT = minDT(~isnan(minDT));
                if numel(unique(minDT)) ~= 1
                    conflicting = 1;
                    break
                end
            end
            
            sizeDT = sizeDomain(:,ii,jj);
            sizeDT = sizeDT(~isnan(sizeDT));
            if numel(unique(sizeDT)) ~= 1
                conflicting = 1;
                break
            end
            
        end

    end
    
    if ~conflicting
        [combinedDensity,int] = combineDensities(allPeriods,startFcst,nDates,indDates,forecastOutput,vars,allVars,weights);
        h.status = h.status + nobj;
        return
    end
    
    % Update status of wait bar
    h.status = h.status + 1;
    
    % If they are found to be conflicting we need to simulate
    % from the densities and do kernel density estimation at
    % the combine domain
    %--------------------------------------------------------
    
    % Get combined start and end of domain of each variable at all
    % periods
    minDomainVar = findDomain('min',minDomain);
    maxDomainVar = findDomain('max',maxDomain);

    % Create a second waitbar to loop over models, as this stage will take
    % some time
    h.text = ['Estimate and combine densities of model ' int2str(1) ' of ' int2str(nobj) '...'];

    % Simulate and estimate the densities given the new domain
    nAllVars        = length(allVars);
    combinedDensity = repmat({0},[1,nAllVars,nDates]);
    int             = cell(1,nAllVars,nDates);
    for ii = 1:nobj

        evalFcst             = forecastOutput{ii}.evaluation;
        varsOfModel          = vars{ii};
        [ind,indVarsOfModel] = ismember(varsOfModel,allVars);
        locVarsOfModel       = indVarsOfModel > 0;
        indVarsOfModel       = indVarsOfModel(ind);
        nVarsOfModel         = size(indVarsOfModel,2);
        if allPeriods
            iter          = indDates{ii};
            iter(iter==0) = [];
        else
            iter  = 1;
            if isempty(kk)
                return
            end
        end
        
        % Get the domain and density stored in object or in a file
        if forecastOutput{ii}.saveToFile || forecastOutput{ii}.inputs.saveToFile
            density = evalFcst(1).density; 
            loaded  = load(density);
            density = loaded.density;
            domain  = loaded.domain;
        else
            density = {evalFcst.density}; 
            domain  = {evalFcst.int}; 
        end

        % Simulate from the densities of this model
        if ~allPeriods
            ind = strcmpi(startFcst{end},forecastOutput{ii}.start);
            if any(ind)
                density = density(ind);
                domain  = domain(ind);
            else
                continue
            end
        else
            ind = ismember(forecastOutput{ii}.start,startFcst);
            if any(ind)
                density = density(ind);
                domain  = domain(ind);
            else
                continue
            end
        end
        nPer          = size(density,2);
        densityForSim = [density{:}];
        if iscell(densityForSim{1})
            kernelEst = false;
        else
            kernelEst = true;
            
            % In this we are dealing with a kernel density, and we need
            % to simulate from it, brfore we can re-estimate it on the 
            % new domain
            densityForSim = reshape(densityForSim,1,[],nPer);
            densityForSim = densityForSim(:,locVarsOfModel,:);
            domainForSim  = [domain{:}];
            domainForSim  = reshape(domainForSim,1,[],nPer);
            domainForSim  = domainForSim(:,locVarsOfModel,:);
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
                        missing = sum(forecastOutput{ii}.missing(:,locVarsOfModel));
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

        end
            
        % Get combined density for each forecast period
        kk = 1;
        for jj = iter

            if allPeriods
                weightsT = weights(:,:,jj,ii);
            else
                weightsT = weights(:,:,1,ii);
            end

            % Weight the different models
            for ll = 1:nVarsOfModel

                % Get the new combined domain, if not already found
                indVar = indVarsOfModel(ll);
                if isempty(int{1,indVar,jj})
                    maxim      = ceil(maxDomainVar(:,indVar,jj)*100)/100;
                    minim      = floor(minDomainVar(:,indVar,jj)*100)/100;
                    delta      = (maxim - minim)*0.10;
                    maxim      = maxim + delta;
                    minim      = minim - delta;
                    bins       = (maxim - minim)/999; % Default is to store 1000 points of the density 
                    domainComb = nan(nHor,1000);
                    for hh = 1:nHor
                        domainComb(hh,:) = minim(hh):bins(hh):maxim(hh);
                    end
                    int{1,indVar,jj} = domainComb;
                end

                if kernelEst
                    % Then we do kernel density estimation
                    empDens    = permute(Y(:,ll,kk,:),[1,4,2,3]); % nHor x nSim x 1 x 1
                    densityVar = nb_ksdensity(empDens,int{1,indVar,jj}); 
                else
                    densityVar = nan(nHor,1000);
                    domainThis = int{1,indVar,jj};
                    for hh = 1:nHor
                        dist             = nb_distribution('type',densityForSim{jj}{hh}{1},'parameters',densityForSim{jj}{hh}{2});
                        densityVar(hh,:) = pdf(dist,domainThis(hh,:));
                    end
                end

                % Add to the combined density
                weightsTM = weightsT(:,indVar);
                weightsTM = weightsTM(:,ones(1,length(densityVar))); % Same as repmat
                try
                    combinedDensity{:,indVar,jj} = combinedDensity{:,indVar,jj} + weightsTM.*densityVar;
                catch %#ok<CTCH>
                    error([mfilename ':: Domain mismatch between models. Please see the bins options of the forecast '...
                                     'method of the nb_model_generic class, or set the check option to this method to true.'])
                end

            end
            
            kk = kk + 1;

        end
        
        % Update status of wait bar
        if ii ~= nobj
            h.status = h.status + 1;
            h.text   = ['Estimate and combine densities of model ' int2str(ii+1) ' of ' int2str(nobj) '...'];
        end

    end
 
end

%==========================================================================
function [combinedDensity,int] = combineDensities(allPeriods,startFcst,nDates,indDates,forecastOutput,vars,allVars,weights)

    nAllVars        = length(allVars);
    combinedDensity = repmat({0},[1,nAllVars,nDates]);
    int             = cell(1,nAllVars,nDates);
    for ii = 1:length(forecastOutput)
        
        evalFcst             = forecastOutput{ii}.evaluation;
        varsOfModel          = vars{ii};
        [ind,indVarsOfModel] = ismember(varsOfModel,allVars);
        locVarsOfModel       = indVarsOfModel > 0;
        indVarsOfModel       = indVarsOfModel(ind);
        nVarsOfModel         = size(indVarsOfModel,2);
        if allPeriods
            iter          = indDates{ii};
            iter(iter==0) = [];
            kk            = find(indDates{ii},1); 
        else
            iter  = 1;
            kk    = find(strcmpi(startFcst{end},forecastOutput{ii}.start));
            if isempty(kk)
                continue
            end
        end

        % Get the domain and density stored in object or in a file
        if forecastOutput{ii}.saveToFile
            density = evalFcst(1).density; 
            loaded  = load(density);
            density = loaded.density;
            domain  = loaded.domain;
        else
            density = {evalFcst.density}; 
            domain  = {evalFcst.int}; 
        end

        % Get combined density for each forecast period
        for jj = iter

            densityPer = density{kk}(locVarsOfModel);
            domainPer  = domain{kk}(locVarsOfModel);
            if allPeriods
                weightsT = weights(:,:,jj,ii);
            else
                weightsT = weights(:,:,1,ii);
            end

            % Weight the different models
            for ll = 1:nVarsOfModel

                % Check if the variable has been nowcasted by the model, 
                % and if the variable has not been nowcast but some other 
                % variables of this model are we remove the first 
                % observation stored to the density
                if isfield(forecastOutput{ii},'missing')
                    if ~isempty(forecastOutput{ii}.missing)
                        if size(forecastOutput{ii}.data,1) < size(densityPer{ll},1) 
                            densityPer{ll} = densityPer{ll}(2:end,:); % Remove nowcast
                        end 
                    end
                end
                
                indVar    = indVarsOfModel(ll);
                weightsTM = weightsT(:,indVar);
                weightsTM = weightsTM(:,ones(1,length(densityPer{ll}))); % Same as repmat
                try
                    combinedDensity{:,indVar,jj} = combinedDensity{:,indVar,jj} + weightsTM.*densityPer{ll};
                catch %#ok<CTCH>
                    error([mfilename ':: Domain mismatch between models. Please see the bins options of the forecast '...
                                     'method of the nb_model_generic class, or set the check option to this method to true.'])
                end

                if ~isempty(int{1,indVar,jj})

                    % Test for conflictiong domains
                    if ~all(all(int{1,indVar,jj} == domainPer{ll}))
                        error([mfilename ':: Domain mismatch between models. Please see the bins options of the uncondForecast '...
                                     'method of the nb_model_generic class, or set the check option to this method to true.'])
                    end

                else
                    int{1,indVar,jj} = domainPer{ll};
                end

            end

            kk = kk + 1;

        end

    end

end

%==========================================================================
% function score = reorderDue2Nowcast(forecastOutput,score,nHor)
% 
%     if isfield(forecastOutput,'missing')
%         if ~isempty(forecastOutput.missing)
%             nSteps  = forecastOutput.nSteps;
%             nowcast = max(sum(forecastOutput.missing,1));
%             scoreT  = nan(nHor,size(score,2),size(score,3));
%             for ii = 1:size(score,2) % Loop variables
%                 missing        = sum(forecastOutput.missing(:,ii));
%                 sInd           = nowcast - missing; % How many missing obs compared to maximum
%                 scoreT(:,ii,:) = score(sInd+1:sInd+nSteps,ii,:);
%             end
%             score = scoreT;
%         end
%     end
%     
% end

%==========================================================================
function domainVar = findDomain(type,modelDomains)

    typeFun                  = str2func(type);
    [~,nHor,nAllVars,nDates] = size(modelDomains);
    domainVar                = nan(nHor,nAllVars,nDates);
    for ii = 1:nAllVars    
        for jj = 1:nDates
            
%             med   = median(modelDomains(:,:,ii,jj),1,'omitnan');
%             scale = 1./med;
%             trans = bsxfun(@times,modelDomains(:,:,ii,jj),scale);
%             test  = abs(trans - med) > 10;
%             
%             if any(test(:))
%                 for hh = 1:nHor
%                     domainVar(hh,ii,jj) = typeFun(modelDomains(~test(:,hh),hh,ii,jj),[],1)';
%                 end
%             else
                domainVar(:,ii,jj) = typeFun(modelDomains(:,:,ii,jj),[],1)';
%             end
            
        end
    end
    
end
