function [modelGroup,plotter,errorReport] = modelSelection(obj)
% Syntax:
%
% modelGroup                       = modelSelection(obj);
% [modelGroup,plotter]             = modelSelection(obj);
% [modelGroup,plotter,errorReport] = modelSelection(obj)
%
% Description:
%
% Select models based on their forecasting properties.
% 
% - 'class' == 'nb_var':
% This function will test combinations of the variables in the data 
% and with different lag length.
%
% This code is inspired by a script made by Martin Blomhoff Holm, 
% Norges Bank 03/06/2014
% 
% - 'class' == 'nb_arima'
% This function will test combinations of AR and MA terms.
%
% Caution: This code will not produce the final combined forecast,
%          use the combineForecast method of nb_model_group class on the   
%          output to produce these forecast.
%
% Output:
% 
% - modelGroup        : A cell array with size 1xM, with the best models
%                       at different horizons. See the 'nHor' option.
%
%                       Caution : If the 'setUpOnly' option is set to true
%                                 this output is a 1 x num vector of 
%                                 nb_var models.
%
% - plotter           : A graph showing the most selected variables in the
%                       final selection of models. Shown in a histogram.
%                       Use the graph method on the returned object to plot
%                       it on the screen. An object of class nb_graph_cs.
%
% See also:
% nb_model_group.combineForecast, nb_getCombinations
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This method is only supported for scalar nb_model_selection_group objects.'])
    end
    
    % Get the data without the transformed and reported variables!
    data          = obj.dataOrig;
    varOfInterest = obj.options.varOfInterest;
    if iscellstr(varOfInterest)
        varOfInterest = varOfInterest{1};
    end
    modelVarOfInterest = obj.options.modelVarOfInterest;
    if iscellstr(modelVarOfInterest)
        modelVarOfInterest = modelVarOfInterest{1};
    end
    
    options                 = rmfield(obj.options, {'data', 'varOfInterest', 'modelVarOfInterest'});
    options.transformations = obj.transformations;
    options.reporting       = obj.reporting;
    
    methods = {'bootstrap','wildBootstrap','blockBootstrap',...
               'mBlockBootstrap','rBlockBootstrap','wildBlockBootstrap',...
               'posterior','asymptotic',''}; 
    default = {'algorithm',                     'hr',       {{@nb_ismemberi,{'hr','ml'}}};...
               'bins',                          [],         {@isempty,'||',@iscell};...
               'class',                         'nb_var',   {{@nb_ismemberi,{'nb_var','nb_arima'}}};...
               'constant',                      true,       {{@ismember,[0,1]}};...
               'cores',                         [],         {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,0},'||',@isempty};...
               'crit',                          10,         {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,0}};...
               'draws',                         1,          {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,0}};...
               'endDate',                       '',         {{@isa,'nb_date'},'||',@ischar};...
               'estim_end_date',                '',         {{@isa,'nb_date'},'||',@ischar};...
               'estim_start_date',              '',         {{@isa,'nb_date'},'||',@ischar};...
               'maxAR',                         3,          {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,0},'&&',{@lt,13}};...  
               'maxMA',                         3,          {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,-1},'&&',{@lt,6}};...  
               'method',                        '',         {{@nb_ismemberi,methods}};...
               'missingMethod',                 '',         {{@nb_ismemberi,{'forecast','ar'}},'||',@isempty};...
               'nHor',                          1,          {@nb_iswholerow,'&&',@isrow,'&&',@(x)all(gt(x,0))};...
               'nLags',                         4,          {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,0},'&&',{@lt,13}};...
               'nSteps',                        8,          {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,0}};...
               'nVarMax',                       6,          {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,-1},'&&',{@lt,9}};...
               'nVarMin',                       0,          {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,-1},'&&',{@lt,9}};...
               'page',                          [],         {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,0},'||',@isempty};...
               'parameterDraws',                1,          {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,0}};...
               'parallel',                      false,      {{@ismember,[0,1]}};...
               'real_time_estim',               false,      {{@ismember,[0,1]}};...
               'recursive_estim',               false,      {{@ismember,[0,1]}};...
               'requiredDegreeOfFreedom',       3,          {@nb_iswholenumber};...
               'reporting',                     {},         {@iscell,'||',@isempty};...
               'rollingWindow',                 [],         {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,0},'||',@isempty};...
               'SAR',                           false,      {{@ismember,[0,1]}};...
               'score',                         'RMSE',     {{@nb_ismemberi,{'RMSE','MSE','MAE','MEAN','STD','ESLS','EELS'}}};...
               'scoreHor',                      '',         {{@nb_ismemberi,{'','mean'}}};...
               'SMA',                           false,      {{@ismember,[0,1]}};...
               'setUpOnly',                     false,      {{@ismember,[0,1]}};...
               'shift',                         [],         {{@isa, 'nb_dataSource'}, '||', @isempty};...
               'stabilityTest',                 true,       {{@ismember,[0,1]}};...
               'recursive_estim_start_date',    '',         {{@isa,'nb_date'},'||',@ischar};...
               'recursiveDetrending',           false,      @nb_isScalarLogical;...
               'time_trend',                    0,          {{@ismember,[0,1]}};...
               'transformations',               {},         {@iscell,'||',@isempty};...
               'variables',                     {},         {@iscellstr,'||',@isempty};...
               'waitbar',                       true,       {{@ismember,[0,1]}}};
           
    [inputs,message] = nb_parseInputs(mfilename,default,options);
    if ~isempty(message)
        error(message)
    end
    
    if inputs.recursive_estim && ~inputs.real_time_estim
        if ~isempty(inputs.missingMethod) && isempty(inputs.recursive_estim_start_date)
            error([mfilename ':: When the ''missingMethod'' option is non-empty the ''recursive_estim_start_date'' option must be provided!'])
        end
    end
    
    % Remove created variables when the recursiveDetrending
    % option is used.
    if inputs.recursiveDetrending
        if isempty(inputs.transformations)
            error([mfilename ':: You need to call the createVariables method if you use the recursiveDetrending option.'])
        end
    end
    
    if strcmpi(inputs.class,'nb_var')
    
        exoProj = '';
        
        % Get all possible combinations of variables
        %-------------------------------------------
        if isempty(inputs.variables)
            vars = data.variables;
        else
            vars = inputs.variables;
        end
        ind  = ismember(vars, cellstr(modelVarOfInterest));
        vars = vars(~ind);
        if inputs.nVarMax > length(vars)
            inputs.nVarMax = length(vars);
        end
        if inputs.nVarMin > inputs.nVarMax
            error([mfilename ':: The ''nVarMin'' input must be less than or equal to the ''nVarMax'' input.'])
        end
        lags = 1:inputs.nLags;

        if inputs.nVarMax > 0

            varMin           = max(1,inputs.nVarMin);
            [num,varsR,lags] = nb_getCombinations(varMin,inputs.nVarMax,vars,lags);

            % Add also the variable of interest
            for ii = 1:size(varsR,2)
                varsR{ii} = [modelVarOfInterest,varsR{ii}];
            end
        else
            num   = 0;
            varsR = {};
            lags  = {};
        end

        % Add AR models
        if inputs.nVarMin == 0
            varsR = [repmat({{modelVarOfInterest}},1,inputs.nLags),varsR];
            lags  = [num2cell(1:inputs.nLags),lags];
            num   = num + inputs.nLags;
        end

        if num > 1000
            error([mfilename ':: It is not possible to run more than 1000 models! You try to run ' int2str(num) '!'])
        end

        % Initilialize models
        %------------------------------------------------------
        t                             = nb_var.template(num);
        t.constant                    = inputs.constant;
        t.data                        = data;
        t.dependent                   = varsR;
        t.estim_end_date              = inputs.estim_end_date;
        t.estim_start_date            = inputs.estim_start_date;
        t.missingMethod               = inputs.missingMethod;
        t.nLags                       = lags;
        t.requiredDegreeOfFreedom     = inputs.requiredDegreeOfFreedom;
        t.page                        = inputs.page;
        t.real_time_estim             = inputs.real_time_estim;
        t.recursive_estim             = inputs.recursive_estim;
        t.recursive_estim_start_date  = inputs.recursive_estim_start_date;
        t.rollingWindow               = inputs.rollingWindow;
        t.time_trend                  = inputs.time_trend;
        models                        = nb_model_generic.initialize('nb_var',t);
        
    elseif strcmpi(inputs.class,'nb_arima')
        
        exoProj = 'ar';
        if isempty(inputs.variables)
            exo  = {};
        else
            exo = inputs.variables;
        end
        vars = [modelVarOfInterest,exo];
        if inputs.nVarMax > length(exo)
            inputs.nVarMax = length(exo);
        end
        if inputs.nVarMin > inputs.nVarMax
            error([mfilename ':: The ''nVarMin'' input must be less than or equal to the ''nVarMax'' input.'])
        end
        
        if strcmpi(inputs.algorithm,'ml')
            inputs.method = 'asymptotic';
        else
            inputs.method = 'bootstrap';
        end
        SAR = 0;
        SMA = 0;
        if data.frequency == 4 || data.frequency == 12
            if inputs.SAR
                SAR = [SAR,data.frequency];
            end
            if inputs.SAR
                SMA = [SMA,data.frequency];
            end
        end
        
        if inputs.nVarMax > 0 && ~isempty(exo)
            varMin                   = max(0,inputs.nVarMin);
            [num,exoR,AR,MA,SAR,SMA] = nb_getCombinations(varMin,inputs.nVarMax,exo,1:inputs.maxAR,0:inputs.maxMA,SAR,SMA);
        else
            [num,~,AR,MA,SAR,SMA] = nb_getCombinations(1,1,{modelVarOfInterest},1:inputs.maxAR,0:inputs.maxMA,SAR,SMA);
            exoR                  = {};
        end
        
        if num > 1000
            error([mfilename ':: It is not possible to run more than 1000 models! You try to run ' int2str(num) '!'])
        end
        
        t                             = nb_arima.template(num);
        t.algorithm                   = inputs.algorithm;           
        t.constant                    = inputs.constant;
        t.covrepair                   = true;
        t.data                        = data;
        t.dependent                   = {modelVarOfInterest};
        t.estim_end_date              = inputs.estim_end_date;
        t.estim_start_date            = inputs.estim_start_date;
        t.exogenous                   = exoR;
        t.AR                          = AR;
        t.MA                          = MA;
        t.SAR                         = SAR;
        t.SMA                         = SMA;
        t.integration                 = 0;
        t.page                        = inputs.page;
        t.real_time_estim             = inputs.real_time_estim;
        t.recursive_estim             = inputs.recursive_estim;
        t.recursive_estim_start_date  = inputs.recursive_estim_start_date;
        t.rollingWindow               = inputs.rollingWindow;
        models                        = nb_model_generic.initialize('nb_arima',t);
         
    else
        error([mfilename ':: Unsupported class ' inputs.class])
    end

    % Are we doing recursive de-trending?
    %--------------------------------------
    if inputs.recursiveDetrending
        
        modelsRec(1,length(models)) = nb_model_recursive_detrending();
        for ii = 1:numel(models)
            modelsRec(ii) = nb_model_recursive_detrending(models(ii),...
                'recursive_start_date',inputs.recursive_estim_start_date,...
                'recursive_end_date',inputs.estim_end_date);
        end
        models = modelsRec;
        
        % Add reporting
        %------------------------
        if ~isempty(inputs.reporting)
            models = set(models,'reporting',inputs.reporting);
            % There is no need to call check reporting as that will be taken 
            % care of when calling createVariables!
        end
        
        % Do data transformations recursivly
        %-----------------------------------
        if ~isempty(inputs.transformations)
            h = nb_waitbar([],'Recursive detrending',numel(models));
            for ii = 1:numel(models)
                models(ii) = createVariables(models(ii),inputs.transformations,inputs.nSteps);
                h.status   = h.status + 1;
            end
        end
        delete(h)
        
        % Test for data
        ind = hasVariables(models(1),vars);
        if any(~ind)
           error([mfilename ':: Some of the selected ''variables'' are not part of the data input; ' toString(vars(~ind))]) 
        end
        
    else
        
        % Set data transformations
        %------------------------
        if ~isempty(inputs.transformations)
            for ii = 1:numel(models)
                models(ii) = setTransformations(models(ii),inputs.transformations,inputs.nSteps);
            end
        end
        
        % Add reporting
        %------------------------
        if ~isempty(inputs.reporting)
            for ii = 1:numel(models)
                models(ii) = setReporting(models(ii),inputs.reporting);
            end
        end
        
        % Here we update the data to include both created variables and
        % reported variables
        if ~isempty(inputs.transformations) || ~isempty(inputs.reporting)
            for ii = 1:numel(models)
                models(ii).dataOrig = data;
            end
        end
        
        % Test for data
        ind = ismember(vars,models(1).options.data.variables);
        if any(~ind)
           error([mfilename ':: Some of the selected ''variables'' are not part of the data input; ' toString(vars(~ind))]) 
        end
        
    end
    
    % Return models if wanted
    if inputs.setUpOnly
        modelGroup = models;
        plotter    = [];
        return
    end
    
    % Convert from scoring rule to fcst evaluation
    %----------------------------------------------
    options = {'MSE',    'SE';...
               'RMSE',   'SE';...
               'MAE',    'ABS';...
               'STD',    'DIFF';...
               'MEAN',   'DIFF';...
               'ESLS',   'LOGSCORE';...
               'EELS',   'LOGSCORE'};
    ind      = strcmpi(inputs.score,options(:,1));
    fcstEval = options(ind,2);       
           
    % Estimate, solve and forecast
    %--------------------------------
    if inputs.parallel
        estInputs = {'parallel'};
        ret       = nb_openPool(inputs.cores);
    else
        estInputs = {'waitbar'};
    end
    models = estimate(models,'write','remove',estInputs{:});
    if inputs.recursiveDetrending
        startFcst = '';
    else
        if ~isempty(inputs.recursive_estim_start_date)
            if strcmpi(inputs.class,'nb_arima')
                startFcst = nb_date.date2freq(inputs.recursive_estim_start_date) + inputs.maxMA + 1;
            else
                startFcst = nb_date.date2freq(inputs.recursive_estim_start_date) + 1;
            end
        else
            startFcst = '';
        end
    end
    models = solve(models);
    models = forecast(models,inputs.nSteps,'write','remove','waitbar',...
                      'parallel',       inputs.parallel,...
                      'bins',           inputs.bins,...
                      'fcstEval',       fcstEval,...
                      'varOfInterest',  varOfInterest,...
                      'startDate',      startFcst,...
                      'endDate',        inputs.endDate,...
                      'saveToFile',     true,...
                      'draws',          inputs.draws,...
                      'method',         inputs.method,...
                      'parameterDraws', inputs.parameterDraws,...
                      'exoProj',        exoProj,...
                      'stabilityTest',  inputs.stabilityTest);

    if inputs.parallel
        nb_closePool(ret);
    end    
    
    % Evaluate the models based on the score
    %----------------------------------------
    nObj  = numel(models);
    score = nan(inputs.nSteps,nObj);
    for ii = 1:numel(models)
        fcst = models(ii).forecastOutput;
        if isempty(fcst.data)
            error([mfilename ':: The forecast returned empty. Most like cause is that the model does not forecast ' varOfInterest])
        end
        if models(ii).forecastOutput.nowcast
            fcst.data    = fcst.data(1:end-1,:,:);
            fcst.missing = [];
            fcst.nowcast = false;
        end
        score(:,ii) = nb_model_generic.constructScore(fcst,inputs.score,false,startFcst,inputs.endDate);
    end
    
    % Pick the top models
    %---------------------
    if inputs.crit > nObj
        crit = nObj;
    else
        crit = inputs.crit;
    end
    
    if strcmpi(inputs.scoreHor,'mean')
    
        [~,ind] = sort(nanmean(score(inputs.nHor,:),1),'descend');
        ind     = ind(1:crit);
        
        % Create a model group object
        groupOptions                    = inputs;
        groupOptions.data               = obj.dataOrig;
        groupOptions.varOfInterest      = varOfInterest;
        groupOptions.modelVarOfInterest = modelVarOfInterest;
        modelGroup                      = {nb_model_selection_group(models(ind), groupOptions)};
        
    else
        
        nHor       = inputs.nHor;
        modelGroup = cell(1,length(nHor));
        for ii = 1:length(nHor)

            % Find the best performing models
            [~,ind] = sort(score(nHor(ii),:),'descend');
            ind     = ind(1:crit);

            % Create a model group object
            groupOptions                    = inputs;
            groupOptions.data               = obj.dataOrig;
            groupOptions.varOfInterest      = varOfInterest;
            groupOptions.modelVarOfInterest = modelVarOfInterest;
            groupOptions.nHor               = nHor(ii);
            modelGroup{ii}                  = nb_model_selection_group(models(ind), groupOptions);

        end
        
    end
    
    if nargout > 1
        
        if strcmpi(inputs.class,'nb_var')
           % Create histogram of variable importance
           counter = zeros(length(nHor),length(vars));
           for ii = 1:length(nHor)  
               models = modelGroup{ii}.models;
               for jj = 1:crit
                   counter = counter + ismember(vars,models{jj}.dependent.name);
               end
           end

           % Create graph object
           horText = strtrim(cellstr(int2str(nHor')))';
           data    = nb_cs(counter,'',horText,vars);
           plotter = nb_graph_cs(data);
           plotter.set('plotType','grouped');
        else
            
            if ~isempty(exo)
                
                % Create histogram of variable importance
                counter = zeros(length(nHor),length(exo));
                for ii = 1:length(nHor)
                    models = modelGroup{ii}.models;
                    for jj = 1:crit
                        counter = counter + ismember(exo,models{jj}.dependent.name);
                    end
                end
                
                % Create graph object
                horText = strtrim(cellstr(int2str(nHor')))';
                data    = nb_cs(counter,'',horText,exo);
                plotter = nb_graph_cs(data);
                plotter.set('plotType','grouped');
                
            else
                plotter = nb_graph_cs(nb_cs.nan(1,1,1));
            end
            
        end
       
    end
    
    if nargout > 2
        errorReport = struct('initialized', num, 'succeeded', nObj);
    end
    
end
