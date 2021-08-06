function plotter = curvature(obj,beta,varargin)
% Syntax:
%
% plotter = curvature(obj,beta,varargin)
%
% Description:
%
% Calculate curvature of posterior, likelihood and/or prior, wrt the 
% estimated parameters. Can be done in parallel.
% 
% Input:
% 
% - obj  : A scalar nb_dsge object.
%
% - beta : A nPar x 1 double with the point to evaluate the curvature. If
%          not provided the parameter values are found at obj.results.beta.
%          Be aware that only the parameters that has been selected a prior
%          will be analyzed! (If the model has been estimated using the
%          estimate method, the mode will be the default point of 
%          evaluation)
%
% Optional input:
%
% Any combination of:
%
% - 'prior'         : Give to evaluate the curvature of the prior, at the
%                     given point.
%
% - 'systemPrior'   : Give to evaluate the curvature of the system prior, 
%                     at the given point.
%
% - 'likelihood'    : Give to evaluate the curvature of the likelihood, at 
%                     the given point.
%
% - 'posterior'     : Give to evaluate the curvature of the posterior, at 
%                     the given point.
%
% If non of them are provided, all of them are plotted.
%
% Other inputs:
%
% - 'honourBounds'  : Give true to honour the lower and upper bounds
%                     of the priors when 'incrFactor' is set. Default is
%                     false.
%
% - 'incrFactor'    : Sets the width of the evaluation window. A smaller 
%                     number means wider window. The increment is 
%                     calculated as; incr = (ub - lb)/incrFactor, where
%                     ub is the upper bound and lb is the lower bound. 
%                     Then evaluation window is calculated as; 
%                     [beta - incr, beta + incr]. The number of points to
%                     evaluate in this window is set by the 'numEvalPoints'
%                     input. E.g. curvature(obj,beta,'incrFactor',10).
%                     Default is [], i.e. use [lb,ub] as the evaluation
%                     window.
%
%                     To set different increment factors for different
%                     parameters use a nPar x 1 double.
%
% - 'numEvalPoints' : Sets the number of evaluation points inside the 
%                     evaluation window. Defualt is 10. E.g. 
%                     curvature(obj,beta,'numEvalPoints',50)  
%
% - 'minObjective'  : Set all values less than this number to nan. Default
%                     is -1e10.
%
% - 'parallel'      : true or false. Default is false. It will run in
%                     parallel over the number of selected parameters,
%                     so number of parameters should be >> than number
%                     of selected workers to make it efficient.
%
% - 'parameters'    : A 1 x nPar cellstr with the estimated parameters 
%                     of interest.
%
% - 'subplot'       : Give to create a 4 x 4 subplot. Default is not.
%
% - 'takeLog'       : A nPar x 1 logical. Set element to true if you want
%                     to take log of the bound before calculation of the
%                     evaluation window. 
%
% - 'tolerance'     : If the posterior is above this number, it will be
%                     assign a nan value. Default is 1e9.
% 
% - 'waitbar'       : true or false. Default is false.
%
% - 'workers'       : Give the number of workers to use during parallel. 
%                     5 is max 5, if 'waitbar' is set to true. Otherwise  
%                     max is given by nb_availablePoolSize. Default is [],
%                     use the max amount of workers.
%
% Output:
% 
% - plotter : > Default   : A nPar x 1 nb_graph_data object. Use the graph
%                           method or the nb_graphMultiGUI class.
%
%             > 'subplot' : A nb_graph_data object. Use either the 
%                           graphSubPlots method or the nb_graphSubPlotGUI 
%                           class.
%
% See also:
% nb_dsge.setPrior, nb_model_generic.estimate, nb_dsge.curvatureEvaluator
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This method only handle a scalar nb_dsge object.'])
    end
    if ~issolved(obj)
        error([mfilename ':: Model must be solved. See the solve method.']) 
    end
    if nargin < 2
        beta = [];
    end

    [subplot,varargin]     = nb_parseOneOptionalSingle('subplot',false,true,varargin{:});
    [prior,varargin]       = nb_parseOneOptionalSingle('prior',false,true,varargin{:});
    [systemPrior,varargin] = nb_parseOneOptionalSingle('systemPrior',false,true,varargin{:});
    [likelihood,varargin]  = nb_parseOneOptionalSingle('likelihood',false,true,varargin{:});
    [posterior,varargin]   = nb_parseOneOptionalSingle('posterior',false,true,varargin{:});
    
    default = {'honourBounds',  false,           @nb_isScalarLogical;...
               'incrFactor',    [],              {@isnumeric,'||',@isempty};...
               'minObjective',  -1e10,           @nb_isScalarNumber;...
               'numEvalPoints', 10,              @(x)nb_isScalarInteger(x,5);...
               'parameters',    {},              {@iscellstr,'||',@isempty};...
               'parallel',      false,           @nb_isScalarLogical;...
               'takeLog',       false,           @islogical;...
               'tolerance',     1e9,             @(x)nb_isScalarNumber(x,0);...
               'waitbar',       false,           @nb_isScalarLogical;...
               'workers',       [],              {@(x)nb_isScalarInteger(x,0),'||',@isempty}};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    if nb_isempty(obj.options.prior)
        error([mfilename ':: You must set the prior field of the options property. See nb_dsge.setPrior.'])
    end
    keepInd = false(1,4);
    if prior
        keepInd(1) = true;
    end
    if systemPrior
        keepInd(2) = true;
    end
    if likelihood
        keepInd(3) = true;
    end
    if posterior
        keepInd(4) = true;
    end
    if all(~keepInd)
        keepInd = ~keepInd;
        if isempty(obj.options.systemPrior)
            keepInd(2) = false;
        end
        if isempty(obj.options.prior)
            keepInd(1) = false;
            keepInd(4) = false;
        end
    end
    warning('off','nb_estimator:needBounds');
    
    outOpt                        = getEstimationOptions(obj);
    [~,estStruct,lb,ub,~,options] = nb_dsge.getObjectiveForEstimation(outOpt{1});
    [lb,ub]                       = nb_estimator.getBounds(options.prior,lb,ub);
    
    warning('on','nb_estimator:needBounds');
    
    % Get the point of evaluation
    if isempty(beta)
        if nb_isempty(obj.results)
            error([mfilename ':: Could not locate the estimated mode/calibration as the results property is empty.'])
        else
            beta = obj.results.estimatedValues;
        end
    else
        beta = beta(:);
        if size(beta,1) ~= size(estStruct.estimated,1)
            error([mfilename ':: The beta input (' int2str(size(beta,1)) ') must match the number of parameters ',...
                             'that has been assign priors (' int2str(size(estStruct.estimated,1)) ').'])
        end
    end
    
    % Get the parameters of interest
    priorS = obj.options.prior;
    if iscell(priorS)
        paramNames = priorS(:,1)';
    else
        paramNames = fieldnames(priorS)';
    end
    locP = 1:size(beta,1);
    if ~isempty(inputs.parameters)
        if ~iscellstr(inputs.parameters)
            error([mfilename ':: The ''parameters'' input must be a cellstr.'])
        end
        indP       = ismember(paramNames,inputs.parameters);
        locP       = locP(indP);
        paramNames = paramNames(indP);
    end
    
    % Apply log to bounds.
    takeLog = inputs.takeLog;
    if isscalar(takeLog)
        takeLog = takeLog(ones(size(ub,1),1));
    else
        if ~nb_sizeEqual(takeLog,size(ub))
            error([mfilename, 'The takeLog input must be a ' int2str(size(ub,1)) ' x 1 logical, if not a scalar logical.'])
        end
    end
    if any(takeLog)
        takeLogLoc = find(takeLog);
        lbTakeLog  = lb(takeLog);
        ind        = lbTakeLog < 0;
        indZ       = lbTakeLog == 0;
        if any(ind)
            loc = strtrim(cellstr(int2str(takeLogLoc(ind))'));
            error([mfilename ':: Cannot take log of a negative lower bound. Case for elements ' toString(loc)])
        elseif any(indZ)
            lbTakeLog(indZ) = 0.0001;
        end
        lb(takeLog) = lbTakeLog;
    end
    lb(takeLog) = log(lb(takeLog));
    ub(takeLog) = log(ub(takeLog));
    
    % Get evalaution grids
    if ~isempty(inputs.incrFactor)    
        if ~isscalar(inputs.incrFactor)
            if ~nb_sizeEqual(inputs.incrFactor,size(ub))
                error([mfilename, 'The incrFactor input must be a ' int2str(size(ub,1)) ' x 1 double, if not a scalar number.'])
            end
        end
        incr   = (ub - lb)./inputs.incrFactor;
        low    = beta - incr;
        high   = beta + incr;
        
        % Honour the bounds
        if inputs.honourBounds
            indLB       = low < lb;
            low(indLB)  = lb(indLB);
            indUB       = high > ub;
            high(indUB) = ub(indUB);
        end
        
    else
        low  = lb;
        high = ub;
    end
    evalP            = nb_linespace(low,high,inputs.numEvalPoints + 1); 
    evalP(:,takeLog) = exp(evalP(:,takeLog));

    % Are we running stuff in parallel?
    if inputs.parallel
        [postD,likD,priorD,systD] = doParallel(inputs,beta,estStruct,evalP,locP);
    else
        [postD,likD,priorD,systD] = doNormal(inputs,beta,estStruct,evalP,locP);
    end
    postD(postD < inputs.minObjective) = nan;
    likD(likD < inputs.minObjective)   = nan;
    
    % Create plot
    domains = strcat('domain_',paramNames);
    numPar  = size(locP,2);
    if subplot
        
        data = nb_data;
        for ii = 1:numPar
            oneParam        = nan(inputs.numEvalPoints + 1,2,4);
            oneParam(:,1,:) = permute(evalP(:,ones(1,4)*locP(ii)),[1,3,2]);
            oneParam(:,2,1) = priorD(:,ii);
            oneParam(:,2,2) = systD(:,ii);
            oneParam(:,2,3) = -likD(:,ii);
            oneParam(:,2,4) = -postD(:,ii);
            dataT           = nb_data(oneParam,'',1,[domains(ii),paramNames(ii)]);
            data            = merge(data,dataT);
        end
        data.dataNames = {'Prior','System Prior','Likelihood','Posterior'};
        keep           = data.dataNames(keepInd);
        data           = window(data,'','','',keep);
        plotter        = nb_graph_data(data);
        plotter.set('variableToPlotX',strcat('domain_',paramNames),...
                    'variablesToPlot',paramNames);
                
    else
        
        plotter(numPar,1) = nb_graph_data;
        vars              = {'Domain','Prior','System prior','Likelihood','Posterior'};
        keepInd           = [false,keepInd];
        keep              = vars(keepInd);
        plotVarsL         = {};
        if any(strcmpi(keep,'likelihood'))
            plotVarsL = {'Likelihood'};
        end
        if any(strcmpi(keep,'posterior'))
            plotVarsL = [plotVarsL,{'Posterior'}];
        end
        plotVarsR         = {};
        if any(strcmpi(keep,'prior'))
            plotVarsR = {'Prior'};
        end
        if any(strcmpi(keep,'system prior'))
            plotVarsR = [plotVarsR,{'System prior'}];
        end
        
        for ii = 1:numPar 
            data        = nb_data([evalP(:,locP(ii)),priorD(:,ii),systD(:,ii),-likD(:,ii),-postD(:,ii)],'',1,vars);
            plotter(ii) = nb_graph_data(data);
            plotter(ii).set('title',paramNames{ii},...
                            'variableToPlotX','Domain',...
                            'variablesToPlot',plotVarsL,...
                            'variablesToPlotRight',plotVarsR,...
                            'verticalLine',beta(locP(ii)));
        end
        
    end

end

%==========================================================================
function [postD,likD,priorD,systD] = doNormal(inputs,beta,estStruct,evalP,locP)

    % Preallocate
    numPar = size(locP,2);
    priorD = nan(inputs.numEvalPoints+1,numPar);
    postD  = priorD;
    likD   = priorD;
    systD  = priorD;
    
    % Do we want waitbar?
    if inputs.waitbar
        h = nb_waitbar5([],'Evaluating the curvature');
        h.maxIterations1 = numPar;
        h.maxIterations2 = inputs.numEvalPoints + 1;
        if inputs.numEvalPoints < 50
            notify = 1;
        else
            notify = 10;
        end
    end
    
    % Evaluate the objective at the grid points
    kk = 1;
    for ii = locP
        
        betaT = beta;
        for ee = 1:inputs.numEvalPoints + 1
            betaT(ii) = evalP(ee,ii);
            [postD(ee,kk),likD(ee,kk),priorD(ee,kk),systD(ee,kk)] = nb_dsge.curvatureEvaluator(betaT,estStruct,inputs.tolerance);
            if inputs.waitbar
                if rem(ee,notify) == 0
                   h.status2 = ee; 
                end
            end
            
        end
        
        if inputs.waitbar
            h.status1 = kk; 
        end
        kk = kk + 1;
        
    end
    
    if inputs.waitbar
       delete(h); 
    end

end

%==========================================================================
function [postD,likD,priorD,systD] = doParallel(inputs,beta,estStruct,evalP,locP)

    % Preallocate
    numPar = size(locP,2);
    priorD = cell(1,numPar);
    postD  = priorD;
    likD   = priorD;
    systD  = priorD;

    % Open parallel pool
    %----------------------------------------
    maxWorker = nb_availablePoolSize();
    if isempty(inputs.workers)
        inputs.workers = maxWorker;
    else
        if inputs.workers > maxWorker
            error([mfilename ':: The number of selected workers (' int2str(inputs.workers) ') cannot exeed ' int2str(maxWorker) '.'])
        end
    end
    if inputs.workers > numPar
        inputs.workers = numPar;
    end
    
    ret = nb_openPool(inputs.workers);
    
    % Waitbar
    %------------------------------
    totalNum = (inputs.numEvalPoints + 1)*numPar;
    note     = nb_when2Notify(totalNum);
    if inputs.waitbar
        h = nb_waitbar([],'Evaluating the curvature (parallell)',totalNum);
        D = parallel.pool.DataQueue;
        afterEach(D,@(x)nUpdateWaitbar(x,h));
    else
        D = [];
    end

    % Metropolis - Hastings steps
    %------------------------------
    inputs = inputs(1,ones(1,numPar));
    evalP  = evalP(:,locP);
    parfor ww = 1:size(locP,2)
    
        priorDThread = nan(inputs(ww).numEvalPoints+1,1);
        postDThread  = priorDThread;
        likDThread   = priorDThread;
        systDThread  = priorDThread;
        
        betaT = beta;
        for ee = 1:inputs(ww).numEvalPoints + 1
            
            betaT(locP(ww)) = evalP(ee,ww);
            [postDThread(ee),likDThread(ee),priorDThread(ee),systDThread(ee)] = nb_dsge.curvatureEvaluator(betaT,estStruct,inputs(ww).tolerance);
            
            % Update waitbar
            if inputs(ww).waitbar
                if rem(ee,note) == 0 
                    send(D,note);
                elseif ee == inputs(ww).numEvalPoints + 1
                    send(D,rem(ee,note))
                end
            else
                if ee == inputs(ww).numEvalPoints + 1
                    disp(['Finished with all iterations for parameter ' int2str(locP(ww))]);
                end
            end
            
        end
        
        priorD{ww} = priorDThread;
        postD{ww}  = postDThread;
        likD{ww}   = likDThread;
        systD{ww}  = systDThread;

    end
    
    priorD = [priorD{:}];
    postD  = [postD{:}];
    likD   = [likD{:}];
    systD  = [systD{:}];
    
    if inputs(1).waitbar
        delete(h)
    end
    nb_closePool(ret);
    
end

%==========================================================================
function nUpdateWaitbar(note,h)
% Update one of the waiting bar
    h.status = h.status + note;
end
