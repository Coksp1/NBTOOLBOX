function obj = updateAtEachContext(obj,varargin)
% Syntax:
%
% obj = updateAtEachContext(obj,varargin)
%
% Description:
%
% Update the forecast of th models given new context. Here only one 
% context is fetched at a time to produce forecast at this context.
% 
% Input:
%
% - obj        : A vector of nb_calculate_vintages objects.
%
% - 'parallel' : Use this string as one of the optional inputs to run the
%                estimation in parallel.
%
% - 'cores'    : The number of cores to open, as an integer. Default
%                is to open max number of cores available. Only an 
%                option if 'parallel' is given. 
%
% - 'waitbar'  : Use this string to give a waitbar during estimation. I.e.
%                when looping over model groups.
%
% - 'write'    : Use this option to write errors to a file instead of 
%                throwing the error.
%
% Output:
% 
% - obj        : A vector of nb_calculate_vintages objects.
% 
% See also:
% nb_calculate_vintages.update
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Set up file to write if asked for
    names               = getModelNames(obj);
    inputs              = nb_model_generic.parseOptional(varargin{:});
    inputs              = nb_logger.openLoggerFile(inputs,obj);
    inputsLoop          = inputs;
    inputsLoop.parallel = false; % Prevent parallel during inner loops
    inputsLoop.waitbar  = false; % Prevetn waitbar during inner loops
    
    % Update the model group(s)
    nobj = length(obj);
    if inputs.parallel && nobj > 1
        error('Running in parallel is not yet supported when updateAtEachContext is set to true.')
    elseif inputs.waitbar && nobj > 1
        
        % Initialize waitbar
        h                = nb_waitbar5([],'Update calculators',true);
        h.text1          = 'Starting...';
        h.maxIterations1 = nobj;
        notify           = nb_when2Notify(nobj);
        for ii = 1:nobj
            try
                obj(ii)       = updateOneCalculator(obj(ii),inputsLoop,h);
                obj(ii).valid = true;
            catch Err
                obj(ii).valid = false;
                message       = ['Error while updating calculator; ' names{ii} '::'];
                nb_logger.logging(nb_logger.ERROR,inputs,message,Err);   
            end
            if rem(ii,notify) == 0
                h.status1 = ii;
                h.text1   = ['Updating of Calculator '  int2str(ii) ' of ' int2str(nobj) ' finished.'];   
            end
        end
        delete(h);
        
    else
        
        inputs.waitbar = logical(inputs.waitbar);
        for ii = 1:nobj  
            try
                obj(ii)       = updateOneCalculator(obj(ii),inputsLoop,inputs.waitbar);
                obj(ii).valid = true;
            catch Err
                obj(ii).valid = false;
                message       = ['Error while updating calculator; ' names{ii} '::'];
                nb_logger.logging(nb_logger.ERROR,inputs,message,Err);  
            end
        end
        
    end
        
    % Close written file
    nb_logger.closeLoggerFile(inputs);

end

%==========================================================================
function obj = updateOneCalculator(obj,inputs,h)

    % Initial checks
    if ~isa(obj.options.dataSource.source,'nb_SMARTDataSource')
        error(['Error for ' obj.name, '; Cannot use ' class(obj.options.dataSource.source) ' as a data source, when updateAtEachContext is set to true.'])
    end
    numAllContexts = findContextDates(obj.options.dataSource.source);
    if numAllContexts == 0
        return
    end
    
    % Find the new contexts to run 
    allContexts = obj.options.dataSource.source.contextDates.contextDates;
    if ~nb_isempty(obj.results)
        cContexts     = size(obj.results.context,2);
        contexts2Loop = setdiff(allContexts,obj.results.data.dataNames);
        [~,loc]       = ismember(contexts2Loop,allContexts);
        loc           = loc';
    else
        contexts2Loop    = allContexts;
        loc              = 1:length(allContexts);
        cContexts        = 0;
        obj.results.data = nb_ts;
    end
    if isempty(loc)
        % No new contexts
        return
    end
    numContexts = size(loc,2);
    
    % Get the empirical model to forecast at this context
    model = set(obj.model,'transformations',obj.transformations,...
                          'fcstHorizon',0,...
                          'reporting',obj.reporting);
                                          
    % Waitbar
    if islogical(h)
        waitbar = h;
        h       = [];
    elseif isempty(h) && numContexts == 1
        waitbar = false;
    else
        waitbar = true;
    end
    if waitbar
        if isempty(h)
            h             = nb_waitbar5([],'Update calculators',true);
            deleteWaitbar = true;
        else
            deleteWaitbar = false;
        end
        h.text2          = 'Starting...';
        h.maxIterations2 = numContexts;
        notify           = nb_when2Notify(numContexts);
    end
                                          
    % Loop the fetching of each context and do calculation at each loop
    contextTS = getFirstContext(obj.options.dataSource.source,true);
    kk        = cContexts + 1;
    ii        = 0;
    valid     = true(1,numContexts);
    if loc(1) == 1
        context         = nb_ts(contextTS);
        [obj,valid(kk)] = updateAtOneContext(obj,model,context,inputs);
        kk              = kk + 1;
        loc             = loc(2:end);
        ii              = ii + 1;
        if waitbar
            if rem(ii,notify) == 0
                h.status2 = ii;
            end
        end
    end
    for index = loc
        contextTS       = updateContext(obj.options.dataSource.source,contextTS,index,true);
        [obj,valid(kk)] = updateAtOneContext(obj,model,nb_ts(contextTS),inputs);
        kk              = kk + 1;
        ii              = ii + 1;
        if waitbar
            if rem(ii,notify) == 0
                h.status2 = ii;
            end
        end
    end
    
    if waitbar && deleteWaitbar
        delete(h);
    end
    
    % Sort contexts of results and forecast, as some context may have
    % failed at some point 
    obj.contexts2Run   = contexts2Loop(~valid);
    
end

%==========================================================================
function [obj,valid] = updateAtOneContext(obj,model,context,inputs)

    if isa(obj.options.store2,'nb_store2Database')
        % Delete the results to save memory
        obj.results.data = nb_ts();
    end

    % Add dummy variables
    %context     = nb_model_vintages.addDummyVars(obj.options.dummyFuncs,context);
    
    % Get the date of this context
    contextDate = context.dataNames{1};
    
    % This will trigger set.dataOrig which will do transformations and reporting
    model           = set(model,'data',context); 
    doHandleMissing = handleMissing(model);
               
    % Get the estimation option for each model and context
    estOpt                    = getEstimationOptions(model);
    estOpt{1}.recursive_estim = true;
    estOpt{1}.context         = contextDate;
    if doHandleMissing
        estOpt{1}.recursive_estim_start_ind = model.options.data.getRealEndDate('nb_date','any') - model.options.data.startDate + 1;
        estOpt{1}.estim_end_ind             = estOpt{1}.recursive_estim_start_ind;
    else
        estOpt{1}.recursive_estim_start_ind = model.options.data.getRealEndDate('nb_date','all') - model.options.data.startDate + 1;
        estOpt{1}.estim_end_ind             = estOpt{1}.recursive_estim_start_ind;
    end
    name = {[obj.name, '(At context: ' contextDate ')']};

    % Estimate the model at this context 
    [res,estOpt] = nb_model_generic.loopEstimate(estOpt,name,inputs);
    if isempty(res)
        valid = false;
        return
    end
    
    % Get calculated
    obj   = getCalcFromResults(obj,res{1},estOpt{1},contextDate);
    valid = true;
    
    % Write calculations at this context to database
    obj.contexts2Write = {contextDate};
    obj                = write(obj,inputs);
    
end
