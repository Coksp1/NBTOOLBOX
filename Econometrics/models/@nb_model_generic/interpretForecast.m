function [obj,lik,normDiff] = interpretForecast(obj,varargin)
% Syntax:
%
% [obj,lik,normDiff] = interpretForecast(obj,varargin)
%
% Description:
%
% 
%
% Input:
% 
% - obj        : A vector of nb_model_generic objects. 
% 
% Optional input:
%
% - 'cores'          : The number of cores to open, as an integer. Default
%                      is to open max number of cores available. Only an 
%                      option if 'parallel' is set to true. 
%
% - 'fcstDB'         : A nSteps x nVars nb_ts object. These are the
%                      forecast to interpreted by the model represented
%                      by obj.
%
% - 'model'          : A nb_model_generic object that produces some
%                      forecast to be interpreted by the model represented 
%                      by obj. The forecast method is used to produce these
%                      forecast.
%
% - 'nSteps'         : Number of forecasting steps. As a 1x1 double.  
%                      Default is 8 if the 'model' options is given, 
%                      otherwise this option does not apply.
%
% - 'optimizer'      : The optimizer used to solve the problem. Default is
%                      'fmincon'. Use the nb_getOptimizers method to get
%                      optimizer to select from.
%
% - 'optimset'       : Set options for forecast matching. See the 
%                      nb_getDefaultOptimset function. Which fields that 
%                      are important depend on the 'optimizer' input. 
%
% - 'parallel'       : Give true if you want to do the forecast in 
%                      parallel. I.e. spread models to different threads.
%                      Default is false. Default is 1.
%
% - 'parameters'     : To use parameters to intepret the forecast, you 
%                      need to list it using this input. As a 1 x nParam
%                      cellstr. Caution: You must assign some prior
%                      distributions using the setPrior method to be able
%                      to utilize this input. It is also only supported
%                      if obj is of class nb_dsge.
%
% - 'periods'        : The number of periods that you let innovations from 
%                      the model represented by obj be active. 
%
% - 'startDate'      : The start date of forecast. Must be a string or an
%                      object of class nb_date. Is empty the estim_end_date
%                      + 1 will be used. This option only applies if 
%                      the 'model' option is provided.
%
% - 'varOfInterest'  : A char with the variable to produce the forecast of.
%                      Default is '', i.e. all variables. Can also be given
%                      a cellstr with the variables to forecast. Variables
%                      provided which is not part of the model will be
%                      discarded and no error will be given! 
%
% - 'varsToMatch'     : If the 'model' input is given these are the
%                       variables that are matched, otherwise these are
%                       taken from the 'fcstDB' option.
%
% - 'scale'           : Sets the relative weight between the concern to 
%                       match the forecast from the alternative model, and 
%                       the likelihood of the innovation that are used to 
%                       match those restrictions. norm(fcst - fcstA)  
%                       + scale*logFunc, where logFunc is either the minus
%                       log likelihood or the minus the log posterior. A 
%                       number greater than or equal to 0. Default is 0.
%
% - 'weights'         : A nb_ts object with same timespan and variables as
%                       'fcstDB' or the forecast output from the 'model'
%                       input. Each row should sum to 1, and will be
%                       used to weight the concern of matching the
%                       different forecast. Default is equal weights.
%
% See also:
% nb_model_generic.forecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ': This function only applies to scalar ' class(obj) ' object.'])
    end
    if ~issolved(obj)
        error([mfilename ':: The model must be solved. See the solve method.'])
    end
    
    % Parse optional inputs
    default = {'cores',          [],              @(x)nb_isScalarNumber(x,0);...
               'fcstDB',         [],              @(x)isa(x,'nb_ts');...
               'model',          [],              @(x)isa(x,'nb_model_generic');...
               'nSteps',         8,               @(x)nb_isScalarInteger(x,0);...
               'optimizer',      'fmincon',       @ischar;...
               'optimset',       struct(),        @isstruct;...
               'parallel',       false,           @nb_isScalarLogical;...
               'parameters',     {},              @iscellstr;...
               'periods',        1,               @(x)nb_isScalarNumber(x,0);...
               'scale',          0,               @(x)nb_isScalarNumberClosed(x,0);...
               'startDate',      '',              {{@isa,'nb_date'},'||',@ischar,'||',@isempty};...
               'varOfInterest',  {},              @iscellstr;...
               'varsToMatch',    {},              @iscellstr;...
               'weights',        [],              @(x)isa(x,'nb_ts')};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    if isempty(inputs.model) && isempty(inputs.fcstDB)
        error([mfilename ':: Both the ''model'' and the ''fcstDB'' inputs cannot be empty.'])
    end
    
    % Get the forecast to interpret
    if isempty(inputs.model)
        fcstData  = double(inputs.fcstDB);
        startDate = inputs.fcstDB.startDate;
        fcstVars  = inputs.fcstDB.variables;
        nSteps    = inputs.fcstDB.numberOfObservations;
    else
        if isempty(inputs.nSteps)
            error([mfilename ':: The ''nSteps'' input cannot be empty if ''model'' input is provided.']) 
        end
        if isempty(inputs.varsToMatch)
            error([mfilename ':: The ''varsToMatch'' input cannot be empty if ''model'' input is provided.']) 
        end
        if isempty(inputs.startDate)
            error([mfilename ':: The ''startDate'' input cannot be empty if ''model'' input is provided.']) 
        end
        nSteps    = inputs.nSteps;
        fcstVars  = inputs.varsToMatch;
        startDate = inputs.startDate;
        mFcst     = forecast(inputs.model,nSteps,...
                      'startDate',startDate,...    
                      'varOfInterest',fcstVars);
        fcstData  = mFcst.forecastOutput.data;          
    end
    
    % Decide the weights
    if isempty(inputs.weights)
        w       = 1/length(fcstVars);
        weights = ones(nSteps*length(fcstVars),1)*w;
    else
        startDate = nb_date.date2freq(startDate);
        if inputs.weights.startDate ~= startDate
            error([mfilename ':: The weights input must have same startDate ',...
                'as the start date of the forecast to interpret (' toString(startDate) ').'])
        end
        test = ismember(fcstVars,inputs.weights.variables);
        if any(~test)
            error([mfilename ':: The follwoing variables are missing in the ''weights'' input; ',...
                   toString(fcstVars(~test))])
        end
        weights = window(inputs.weights,'','',fcstVars);
        weights = reorder(weights,fcstVars); %  Secure same order!
        weights = double(weights);
        weights = weights(:);
    end
        
    % Get the covariance matrix of the shocks
    nRes = length(obj.solution.res); 
    if isempty(obj.solution.vcv)
        vcv = eye(nRes);
    elseif isempty(obj.solution.C)
        vcv = obj.solution.vcv(:,:,end);
    else
        vcv = obj.solution.vcv(:,:,end);
    end
    vcvInv = vcv\eye(size(vcv,1));
    
    % Inital condition set to zero
    init = zeros(inputs.periods*nRes,1);
    
    % Lower and upper bounds
    std = sqrt(diag(vcv));
    lb  = -4*std;
    lb  = repmat(lb,[inputs.periods,1]);
    ub  = 4*std;
    ub  = repmat(ub,[inputs.periods,1]);
    
    % Parameter changes?
    if ~isempty(inputs.parameters)
        if ~isa(obj,'nb_dsge')
            error([mfilename ':: Chaning parameters are only allows for nb_dsge models.'])
        end
        obj        = set(obj,'silent',true);
        prior      = obj.options.prior;
        [test,loc] = ismember(inputs.parameters,prior(:,1)');
        if any(~test)
            error([mfilename ':: The following parameters are not assign a prior; ',...
                   toString(inputs.parameters(~test))])
        end
        [plb,pub] = nb_statespaceEstimator.getBounds(obj.options);
        if any(strcmpi(inputs.optimizer,{'nb_abc','bee_gate'}))
            [plb,pub] = nb_estimator.getBounds(obj.options.prior,plb,pub);
        end
        pInit = vertcat(prior{loc,2});
        prior = prior(loc,[1,3:4]);
        lb    = [lb;plb];
        ub    = [ub;pub];
        init  = [init;pInit];
    else
        prior = [];
    end
    
    % Objective to minimize
    periods = inputs.periods;
    scale   = inputs.scale;
    fh      = @(e)matchFcst(e,obj,fcstData,startDate,fcstVars,nSteps,...
                            periods,vcv,vcvInv,scale,prior,weights);
    
    % Do the minimization
    eEst = nb_callOptimizer(inputs.optimizer,fh,init,lb,ub,inputs.optimset,...
            ':: Intepreting the forecast failed.');
        
    % Report
    [lik,normDiff,obj] = calculateLossFunc(eEst,obj,fcstData,startDate,...
                            fcstVars,nSteps,periods,vcv,vcvInv,prior,weights);
    
end

%==========================================================================
function fVal = matchFcst(e,obj,fcstData,startDate,fcstVars,nSteps,periods,...
            vcv,vcvInv,scale,prior,weights)

    [lik,normDiff] = calculateLossFunc(e,obj,fcstData,startDate,fcstVars,...
                        nSteps,periods,vcv,vcvInv,prior,weights);
    
    % Report objective value
    fVal = normDiff + scale*lik;
    
end

%==========================================================================
function [lik,normDiff,mFcst] = calculateLossFunc(e,obj,fcstData,startDate,...
            fcstVars,nSteps,periods,vcv,vcvInv,prior,weights)

    % Resolve model
    if ~isempty(prior)
        
        % Solve model with the current parameters
        nParam = size(prior,1);
        p      = e(end-nParam+1:end);
        e      = e(1:end-nParam);
        obj    = assignParameters(obj,'param',prior(:,1)','value',p');
        obj    = solve(obj);
        
        % Calculate log prior
        logPrior = 0;
        for ii = 1:nParam
            hyperParam = prior{ii,3};
            logPrior   = logPrior + log(prior{ii,2}(p(ii),hyperParam{:}));
        end
        
    end
    
    % Fill in the innovations to estimate
    nRes           = length(obj.solution.res);  
    E              = zeros(nSteps,nRes);
    E(1:periods,:) = reshape(e,[periods,nRes]);
    condDB         = nb_ts(E,'',startDate,obj.solution.res);
    
    % Produce a forecast
    mFcst     = forecast(obj,nSteps,...
                  'condDB',condDB,...
                  'startDate',startDate,...    
                  'varOfInterest',fcstVars);
    fcstObj   = mFcst.forecastOutput.data; 
    
    % Calculate the log likelihood (up to a constant)
    lik = 0;
    for ii = 1:periods
        lik = lik + log(det(vcv)) + E(ii,:)*vcvInv*E(ii,:)';
    end
    if ~isempty(prior)
       lik = lik - logPrior;
    end
    
    % Calculate the deviation
    normDiff = norm((fcstObj(:) - fcstData(:)).*weights);

end
