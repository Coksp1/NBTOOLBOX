function obj = setSystemPrior(obj,varargin)
% Syntax:
%
% obj = setSystemPrior(obj,varargin)
%
% Description:
%
% Set system priors used for estimation.
% 
% The system priors implemented are described in the paper Andrle and  
% Benes (2013), "System Priors: Formulating Priors about DSGE Models'' 
% Properties"
%
% Input:
% 
% - obj   : A scalar object of class nb_dsge.
%
% Optional input:
%
% - 'irf'  : System priors on IRFs. A N x 4 cell, where the elements of 
%            each row are:
%            1. Name of the shock. 'E_X'
%            2. Name of the variable. 'X'
%            3. Horizon. E.g. 1.
%            4. Prior function as a function_handle. E.g. 
%               @(x)log(nb_distribution.normal_pdf(x,0,1)), i.e. it most
%               return the log prior density.
%
%               See nb_distribution.parametrization or 
%               nb_distribution.qestimation to back out the
%               hyperparameters of a distribution given some moments.
%
%            E.g. {'E_X','X',1,@(x)log(nb_distribution.normal_pdf(x,0,1))}
%
% - 'cov'  : System priors on the correlation matrix. A N x 4 cell, 
%            where the elements of each row are:
%            1. Name of the first variable.
%            2. Name of the second variable.
%            3. Number of periods to lag the 2. variable.
%            4. Same as 4 for 'irf'.
%
%            E.g. {'X','X',0,@(x)log(nb_distribution.invgamma_pdf(x,1,1))},
%            i.e. prior on the variance of 'X'.
%
% > 'corr' : Same as for 'cov', but now the system prior is on the
%            correlation matrix. (Be aware that the example above makes no
%            sence in this case as the contemporaneous correlation with 
%            itself is always 1!)
%
% > 'fevd' : System priors on forecast error variance decomposition. 
%            A N x 4 cell, where the format is as in the 'irf' case.
% 
% Output:
% 
% - obj   : A scalar object of class nb_dsge, where the systemPrior
%           options has been assign a function_handle that evaluates the
%           wanted priors.
%
% See also:
% nb_dsge.setPrior, nb_model_generic.estimate, nb_model_sampling.sample,
% nb_model_sampling.sampleSystemPrior
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nInp = length(varargin);
    if rem(nInp,2) ~= 0
        error([mfilename ':: The optional input must come in pairs.'])
    end
    
    funcs = cell(1,nInp/2);
    kk    = 1;
    for ii = 1:2:nInp
        
        type  = varargin{ii};
        prior = varargin{ii+1};
        switch lower(type)
            case 'irf'
                prior     = testIrfSystemPrior(obj,prior);
                funcs{kk} = @(parser,solution)irfSystemPrior(parser,solution,prior);
            case {'cov','covariance'}
                prior     = testMomentSystemPrior(obj,prior);
                funcs{kk} = @(parser,solution)momentSystemPrior(parser,solution,prior,'covariance');
            case {'corr','correlation'}
                prior     = testMomentSystemPrior(obj,prior);
                funcs{kk} = @(parser,solution)momentSystemPrior(parser,solution,prior,'correlation');
            case 'fevd'
                prior     = testIrfSystemPrior(obj,prior);
                funcs{kk} = @(parser,solution)fevdSystemPrior(parser,solution,prior);
            otherwise
                error([mfilename ':: Unsupported prior type ''' type '''.'])
        end
        kk = kk + 1;
        
    end
    
    % Set the full system prior
    obj.options.systemPrior = @(parser,solution)allSystemPriors(parser,solution,funcs);

end

%==========================================================================
function logSystemPrior = allSystemPriors(parser,solution,funcs)
    logSystemPrior = 0;
    for ii = 1:size(funcs,2)
        logSystemPrior = logSystemPrior + funcs{ii}(parser,solution);
    end
end

%==========================================================================
function priorOut = testIrfSystemPrior(obj,prior)

    if isempty(prior) || ~iscell(prior)
        error([mfilename ':: The priors given to type ''irf'' is not given as a non-empty cell.'])
    end

    if size(prior,2) ~= 4
        error([mfilename ':: The priors given to type ''irf'' must be a N x 4 cell.'])
    end

    if isa(obj,'nb_dsge')
        res = obj.exogenous.name;
    else
        res = obj.residuals.name;
    end
    resPrior  = prior(:,1);
    endo      = obj.dependent.name;
    endoPrior = prior(:,2);
    for ii = 1:size(prior,1)
        
        % Innovation
        if ~nb_isOneLineChar(prior{ii,1})
            error([mfilename ':: The first element of row ' int2str(ii) ' must be a one line char with ',...
                'the residual/innovation of the IRF to put the system prior on.'])
        end
        
        indRes = find(strcmpi(prior{ii,1},res));
        if isempty(indRes)
            error([mfilename ':: The first element of row ' int2str(ii) ' provided a residual/innovation not ',...
                'part of the model (' prior{ii,1} ').'])
        end
        prior{ii,1} = indRes;
        
        % Endogenous variable
        if ~nb_isOneLineChar(prior{ii,2})
            error([mfilename ':: The second element of row ' int2str(ii) ' must be a one line char with ',...
                'the endogenous variable of the IRF to put the system prior on.'])
        end
        
        indEndo = find(strcmpi(prior{ii,2},endo));
        if isempty(indEndo)
            error([mfilename ':: The second element of row ' int2str(ii) ' provided a endogneous variable not ',...
                'part of the model (' prior{ii,2} ').'])
        end
        prior{ii,2} = indEndo;
        
        % Period
        if ~nb_isScalarInteger(prior{ii,3}) 
            error([mfilename ':: The third element of row ' int2str(ii) ' must be a strictly positive integer.'])
        end
        if prior{ii,3} < 1
            error([mfilename ':: The third element of row ' int2str(ii) ' must be a strictly positive integer.'])
        end
        
        % Prior function
        if ~isa(prior{ii,4},'function_handle')
            error([mfilename ':: The fourth element of row ' int2str(ii) ' must be a function_handle with the system prior.'])
        end
        try
            prior{ii,4}(0);
        catch Err
            error([mfilename ':: The fourth element of row ' int2str(ii) ' where a function handle given the error:: ' Err.message])
        end

    end
    
    % Make it into struct, so we don't need to do to many stupid operations
    % at every evaluation of the system prior
    priorOut                      = struct();
    priorOut.res                  = resPrior;
    priorOut.endo                 = endoPrior;
    priorOut.indRes               = vertcat(prior{:,1});
    [priorOut.indResUnique,~,loc] = unique(priorOut.indRes);
    priorOut.indEndo              = vertcat(prior{:,2});
    priorOut.horizon              = vertcat(prior{:,3});
    priorOut.priorFuncs           = prior(:,4);
    
    % Get max number of periods for each shock
    numShocks = length(priorOut.indResUnique);
    maxHor    = nan(numShocks,1);
    for ii = 1:numShocks
        maxHor(ii) = max(priorOut.horizon(loc == ii));
    end
    priorOut.maxHor    = maxHor;
    priorOut.numShocks = numShocks;
    priorOut.numPriors = size(priorOut.horizon,1);
    
end

%==========================================================================
function logSystemPrior = fevdSystemPrior(parser,solution,prior)

    % Construct some options needed to call nb_varDecomp
    options.estimType  = ''; 
    inputs.perc        = [];
    inputs.method      = '';
    inputs.foundReplic = [];
    inputs.replic      = 1;
    inputs.horizon     = unique(prior.maxHor)';
    inputs.shocks      = unique(prior.res');
    inputs.variables   = unique(prior.endo');
    results            = struct(); 
    solution.endo      = parser.endogenous;
    solution.res       = parser.exogenous;
    solution.class     = 'nb_dsge';
    
    % Do the variance decomposition
    decomp = nb_varDecomp(solution,options,results,inputs);

    % Fetch the observations to be evaluated
    x = zeros(prior.numPriors,1); % Values to evaluate the priors at
    for ii = 1:prior.numPriors
        locRes  = strcmpi(prior.res{ii},inputs.shocks);
        locEndo = strcmpi(prior.endo{ii},inputs.variables);
        x(ii)   = decomp(prior.horizon(ii),locRes,locEndo);
    end
    
    % Evaluate the log prior distribution at the current IRFs
    logSystemPrior = 0;
    logPriorDens   = prior.priorFuncs;
    for ii = 1:prior.numPriors
        logSystemPrior = logSystemPrior + logPriorDens{ii}(x(ii));
    end
    if ~isfinite(logSystemPrior)
        logSystemPrior = -1e10;
    end
    
end

%==========================================================================
function logSystemPrior = irfSystemPrior(~,solution,prior)

    A = solution.A;
    C = solution.C(:,prior.indResUnique);
    e = zeros(prior.numShocks,1);
    x = zeros(prior.numPriors,1); % Values to evaluate the priors at
    for ii = 1:prior.numShocks

        % Set shock to one std (scaled by a parameter)
        e(ii) = 1;
        
        % IRFs
        y      = C*e;
        ind    = prior.indRes == prior.indRes(ii) & prior.horizon == 1;
        x(ind) = y(prior.indEndo(ind));
        for hh = 2:prior.maxHor(ii)
            y      = A*y;
            ind    = prior.indRes == prior.indRes(ii) & prior.horizon == hh;
            x(ind) = y(prior.indEndo(ind));
        end
        
        % Reset innovation
        e(ii) = 0;
        
    end
    
    % Evaluate the log prior distribution at the current IRFs
    logSystemPrior = 0;
    logPriorDens   = prior.priorFuncs;
    for ii = 1:prior.numPriors
        logSystemPrior = logSystemPrior + logPriorDens{ii}(x(ii));
    end
    if ~isfinite(logSystemPrior)
        logSystemPrior = -1e10;
    end
    
end

%==========================================================================
function priorOut = testMomentSystemPrior(obj,prior)

    if isempty(prior) || ~iscell(prior)
        error([mfilename ':: The priors given to type ''irf'' is not given as a non-empty cell.'])
    end

    if size(prior,2) ~= 4
        error([mfilename ':: The priors given to type ''irf'' must be a N x 4 cell.'])
    end

    endo = obj.dependent.name;
    for ii = 1:size(prior,1)
        
        % First endo var
        if ~nb_isOneLineChar(prior{ii,1})
            error([mfilename ':: The first element of row ' int2str(ii) ' must be a one line char with ',...
                'a endogenous variable of the model.'])
        end
        
        indEndo1 = find(strcmpi(prior{ii,1},endo));
        if isempty(indEndo1)
            error([mfilename ':: The first element of row ' int2str(ii) ' provided a endogenous variable not ',...
                'part of the model (' prior{ii,1} ').'])
        end
        prior{ii,1} = indEndo1;
        
        % Endogenous variable
        if ~nb_isOneLineChar(prior{ii,2})
            error([mfilename ':: The second element of row ' int2str(ii) ' must be a one line char with ',...
                'a endogenous variable of the model.'])
        end
        
        indEndo2 = find(strcmpi(prior{ii,2},endo));
        if isempty(indEndo2)
            error([mfilename ':: The second element of row ' int2str(ii) ' provided a endogenous variable not ',...
                'part of the model (' prior{ii,2} ').'])
        end
        prior{ii,2} = indEndo2;
        
        % Lag
        if ~nb_isScalarInteger(prior{ii,3}) 
            error([mfilename ':: The third element of row ' int2str(ii) ' must be a weakly positive integer.'])
        end
        if prior{ii,3} < 0
            error([mfilename ':: The third element of row ' int2str(ii) ' must be a weakly positive integer.'])
        end
        
        % Prior function
        if ~isa(prior{ii,4},'function_handle')
            error([mfilename ':: The fourth element of row ' int2str(ii) ' must be a function_handle with the system prior.'])
        end
        try
            prior{ii,4}(0);
        catch Err
            error([mfilename ':: The fourth element of row ' int2str(ii) ' where a function handle given the error:: ' Err.message])
        end

    end
    
    % Make it into struct, so we don't need to do to many stupid operations
    % at every evaluation of the system prior
    priorOut            = struct();
    priorOut.indEndo1   = vertcat(prior{:,1});
    priorOut.indEndo2   = vertcat(prior{:,2});
    priorOut.lag        = vertcat(prior{:,3});
    priorOut.priorFuncs = prior(:,4);
    
    % Get max number of lag and num priors
    priorOut.maxLags   = max(priorOut.lag);
    priorOut.numPriors = size(priorOut.lag,1);
    
end

%==========================================================================
function logSystemPrior = momentSystemPrior(~,solution,prior,type)

    % Calculate moments
    A     = solution.A;
    nEndo = size(A,1);
    C     = solution.C;
    nRes  = size(C,2);   
    try
        [~,c] = nb_calculateMoments(A,zeros(nEndo,0),C,eye(nRes),[],[],prior.maxLags,type);
    catch
        logSystemPrior = -1e10;
        return
    end
    
    % Evaluate the log prior distribution at the current IRFs
    logSystemPrior = 0;
    logPriorDens   = prior.priorFuncs;
    for ii = 1:prior.numPriors
        logSystemPrior = logSystemPrior + logPriorDens{ii}( c(prior.indEndo1(ii),prior.indEndo2(ii),prior.lag(ii)+1) );
    end
    if ~isfinite(logSystemPrior)
        logSystemPrior = -1e10;
    end
    
end
