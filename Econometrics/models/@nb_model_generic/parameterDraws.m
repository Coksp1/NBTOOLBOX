function out = parameterDraws(obj,draws,method,output,stable,varargin)
% Syntax:
%
% out = parameterDraws(obj)
% out = parameterDraws(obj,draws,method,output,stable)
%
% Description:
%
% Make either posterior draws or bootstrapped draws from the distribution
% of the estimated parameters.
%
% Caution : Not yet supported for recursivly estimated models.
%
% Input:
% 
% - obj    : An object of a subclass of the nb_model_generic class.
%
% - draws  : Number of draws, as an integer. Default is 1000.
%
% - method : The selected method to make draws.
%
%     > 'asymptotic'         : Draw from the confidence set using
%                              the assumption of asymptotic normality.
%                              See the nb_mlEstimator.drawParameters
%                              for more on this option. Applies to models
%                              estimated with maximum likelihood.
% 
%     > 'bootstrap'          : Create artificial data to bootstrap
%                              the estimated parameters. Default
%                              for models estimated with classical
%                              methods.
%
%     > 'wildBootstrap'      : Create artificial data by wild 
%                              bootstrap, and then "draw" paramters
%                              based on estimation on these data. 
%                              Only an option for models estimated
%                              with classical methods.
% 
%     > 'blockBootstrap'     : Create artificial data by 
%                              non-overlapping block bootstrap,
%                              and then "draw" paramters based 
%                              on estimation on these data. 
%                              Only an option for models estimated
%                              with classical methods.
%
%     > 'mblockBootstrap'    : Create artificial data by 
%                              overlapping block bootstrap,
%                              and then "draw" paramters based 
%                              on estimation on these data. 
%                              Only an option for models estimated
%                              with classical methods.
%
%     > 'rblockBootstrap'    : Create artificial data by 
%                              overlapping random block length  
%                              bootstrap, and then "draw" paramters 
%                              based  on estimation on these data. 
%                              Only an option for models estimated
%                              with classical methods.
%
%     > 'wildBlockBootstrap' : Create artificial data by wild
%                              overlapping random block length  
%                              bootstrap. , and then "draw" paramters 
%                              based  on estimation on these data. 
%                              Only an option for models estimated
%                              with classical methods.
%
%     > 'copulaBootstrap'    : Uses a copula approach to draw residual 
%                              that are autocorrelated, Does not handle 
%                              heteroscedasticity. Only an option for 
%                              models estimated with classical methods.
% 
%     > 'posterior'          : Posterior draws. Only for models 
%                              estimated with bayesian methods.
%                              Default for models estimated with 
%                              bayesian methods.
% 
% - output : 'param' | 'solution' | 'object'. See output section for more
%            on this option.
%
% - stable : Give true if you want to discard the parameter draws 
%            that give rise to an unstable model. Default is false.
%
% Optional input:
%
% - 'parallel'     : Run in parallel. true or false.
%
% - 'cores'        : Number of cores to use. Default is to use all cores
%                    available.
%
% - 'newDraws'     : When out of parameter draws, this factor decides how
%                    many new draws are going to be made. Default is 0.1.
%                    I.e. 1/10 of the draws input. 
%
%                    Caution: When setting 'parallel' to true on MATLAB
%                             version later than R2017B this number will
%                             be the number of new draws, and not the
%                             factor!!! E.g. set it to 100. If it is given
%                             as a number less than 1, it will by default
%                             be set to 100.
%
% - 'initialDraws' : When drawing parameters this factor decides how many
%                    many draws that are produced before solving the model.
%                    Default is 1. I.e. it is equal to draws input. For
%                    VAR models with underidentification it may be a good
%                    idea to set this to a value > 1 as you may drop a
%                    lot of parameters when identification fails. Default
%                    is 1.
%
% Output:
% 
% - out         : The output depend on the input output:
%
%   > 'param'    : Default. A struct with the following fields:
%
%                  beta  : A nPar x nEq x draws double with the
%                          estimated parameters. 
%
%                  sigma : A nEq x nEq x draws double with the
%                          estimated covariance matrix.
%
%                  For factor models these fields are also returned:
%
%                  lambda  : Estimated coefficients of the observation
%                            equation. As a nFac x nObserables x draws
%                            double.
%
%                  R       : Estimated covariance matrix of the 
%                            observation equation. As a nFac x nFac x
%                            draws double.
%
%                  factors : Draws of the factors as a T x nFac x 
%                            draws double.
%
%   > 'solution' : Get the solution of the model for each draw from the 
%                  distribution of parameters. The output will be a struct
%                  with size 1 x draws. The struct will have the same 
%                  format as the solution property of the underlying 
%                  object. I.e. only one output!
%                   
%   > 'object'   : Get the draws as a 1 x draws nb_model_generic object. 
%                  Each element will be a model representing a given draw
%                  from the distribution of the parameters. I.e. only one 
%                  output!
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 5
        stable = false;
        if nargin < 4
            output = 'param';
            if nargin < 3
                method = '';
                if nargin < 2
                    draws = [];
                end
            end
        end
    end

    if isempty(draws)
        draws = 1000;
    end
       
    if numel(obj) > 1
        error([mfilename ':: It is only possible to make draws from the distribution of parameters for one model at a time.'])
    end
    
    options = obj.estOptions(end);
    options = nb_defaultField(options,'recursive_estim',false);
    model   = obj.solution;
    if ~issolved(obj)
        error([mfilename ':: The model must be solved before using this method. See solve.'])
    end
    if options.recursive_estim
        error([mfilename ':: This method is not yet supported for recursivly estimed models.'])
    end
    
    % Check the inputs
    if strcmpi(options.estimType,'bayesian')
        if isempty(method)
            method = 'posterior';
        elseif ~strcmpi(method,'posterior')
            error([mfilename ':: method ''posterior'' is the only supported method for bayesian models.']) 
        end
    else
        if isempty(method)
            method = 'bootstrap';
        elseif strcmpi(method,'posterior')
            error([mfilename ':: method ''posterior'' is only supported for bayesian models.']) 
        end
    end 
    
    if ~nb_isScalarInteger(draws)
        error([mfilename ':: The draws input must be an integer.'])
    end
    
    if ~ischar(output)
        error([mfilename ':: The output input must be a string.'])
    end
    
    if ~islogical(stable)
        error([mfilename ':: The stable input must be either true or false.'])
    end
    
    % Interpret optional inputs
    default = {'cores',             [],         {@nb_isScalarInteger,'&&',{@gt,0},'||',@isempty};...
               'newDraws',          0.1,        {@isnumeric,'&&',@isscalar,'&&',{@gt,0}};...
               'initialDraws',      1,          {@isnumeric,'&&',@isscalar,'&&',{@gt,0}};...
               'parallel',          false,      @islogical};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    inputs.draws  = draws;
    inputs.method = lower(method);
    inputs.output = lower(output);
    inputs.stable = stable;
    
    % Use the same seed when returning the "random" numbers
    %--------------------------------------------------------------
    seed          = 2.0719e+05;
    defaultStream = RandStream.getGlobalStream;
    savedState    = defaultStream.State;
    s             = RandStream.create('mt19937ar','seed',seed);
    RandStream.setGlobalStream(s);
    
    % Then we do the draws
    if inputs.parallel
        out = doParallel(obj,inputs);
    else
    
        try
            switch lower(method)
                case {'bootstrap','wildbootstrap','blockbootstrap','mblockbootstrap','rblockbootstrap','wildblockbootstrap','copulabootstrap'}
                    
                    if isfield(model,'G') && ~strcmpi(model.class,'nb_arima')% Factor model
                        % Factor models are much more complicated animals to 
                        % bootstrap, as also the factors needs to be bootstraped.
                        out = bootstrapParamFactorModel(obj,inputs);
                    else
                        out = bootstrapParam(obj,inputs);
                    end

                case {'posterior','asymptotic'}

                    out = posteriorParam(obj,inputs);

                otherwise
                    error([mfilename ':: Unsupported error band method; ' method '.'])
            end
        catch Err
            defaultStream.State = savedState;
            RandStream.setGlobalStream(defaultStream);
            rethrow(Err)
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
function out = bootstrapParam(obj,inputs)

    draws   = inputs.draws;
    method  = inputs.method;
    output  = inputs.output;
    stable  = inputs.stable;
    options = obj.estOptions;
    results = obj.results;
    model   = obj.solution;
    
    % Make waiting bar
    if ~strcmpi(output,'param') || stable
        
        if isfield(inputs,'waitbar')
            waitbar = inputs.waitbar;
        else
            waitbar = true;
        end

        index   = '';
        display = true;
        if inputs.parallel || ~waitbar % When parallel waitbar does not work!
            display = false;
            if isfield(inputs,'index')
                index = int2str(inputs.index);
            end
            h = [];
        else
            h                = nb_waitbar5([],'Bootstrap',true,false);
            h.maxIterations1 = draws;
            h.text1          = 'Drawing parameters (this could take some time)...'; 
        end
        
    end
    
    % Bootstrap coefficients
    if isfield(options,'missingData')
        bootstrapFunc = str2func('nb_missingEstimator.bootstrapModel');
    else
        bootstrapFunc = str2func([options.estimator '.bootstrapModel']);
    end
    [betaD,sigmaD,estOpt] = bootstrapFunc(model,options,results,method,draws*inputs.initialDraws);
    
    % Preallocate
    switch output
        case 'param'
            if ~stable
                out.beta = betaD;
                out.sigma = sigmaD;
                return
            end
        case 'solution'
            modelOut = repmat(model,1,draws);
        case 'object'
            objectOut = repmat(obj,1,draws);
        otherwise
            error([mfilename ':: Unsupported output type ' output])    
    end
    
    kk     = 0;
    ii     = 0;
    jj     = 0;
    func   = str2func([model.class, '.solveNormal']);
    res    = results;
    note   = nb_when2Notify(draws);
    betaA  = betaD;
    sigmaA = sigmaD;
    while kk < draws

        ii = ii + 1;
        
        % Assign the results struct the posterior draw (Only using the last
        % periods estimation if recursive estimation is done)
        try
            betaD(:,:,ii);
        catch %#ok<CTCH>            
            % Out of draws, so we need more!
            [betaD,sigmaD,~] = bootstrapFunc(model,options,results,method,ceil(draws*inputs.newDraws));
            ii               = 0;
            continue
        end
        
        jj = jj + 1;
         
        % Solve the model given the draw
        res.beta  = betaD(:,:,ii);
        res.sigma = sigmaD(:,:,ii);
        try
            if isfield(model,'identification')
                modelTemp = func(res,estOpt,model.identification);
            else
                modelTemp = func(res,estOpt);
            end
        catch %#ok<CTCH>
            continue 
        end

        if stable
            [~,~,modulus] = nb_calcRoots(modelTemp.A);
            if any(modulus > 1)
                continue 
            end
        end
            
        kk = kk + 1;
        if strcmpi(output,'param')
            betaA(:,:,kk)  = betaD(:,:,ii);
            sigmaA(:,:,kk) = sigmaD(:,:,ii);
        elseif strcmpi(output,'object')
            objectOut(kk).solution       = modelTemp;
            objectOut(ii).results.beta   = betaD(:,:,ii);
            objectOut(ii).results.sigma  = sigmaD(:,:,ii);
        else
            modelOut(kk) = modelTemp;
        end
         
        % Report current status
        report(inputs,h,index,kk,jj,display,note)
        
    end
    
    switch output  
        case 'param'
            out.beta  = betaA;
            out.sigma = sigmaA;
        case 'solution'
            out = modelOut;           
        case 'object'
            out = objectOut;
    end
    
    % Delete waiting bar
    if display
        delete(h);
    end

end

%==========================================================================
function out = bootstrapParamFactorModel(obj,inputs)

    model = obj.solution;
    if strcmpi(model.class,'nb_fmsa')
        out = bootstrapParamStepAheadFactorModel(obj,inputs);
        return
    end
    
    draws   = inputs.draws;
    method  = inputs.method;
    output  = inputs.output;
    stable  = inputs.stable;
    options = obj.estOptions;
    results = obj.results;
    
    % Make waiting bar
    if ~strcmpi(output,'param') || stable
        
        if isfield(inputs,'waitbar')
            waitbar = inputs.waitbar;
        else
            waitbar = true;
        end

        index   = '';
        display = true;
        if inputs.parallel || ~waitbar % When parallel waitbar does not work!
            display = false;
            if isfield(inputs,'index')
                index = int2str(inputs.index);
            end
            h       = [];
        else
            h                = nb_waitbar5([],'Bootstrap',true,false);
            h.maxIterations1 = draws;
            h.text1          = 'Drawing parameters (this could take some time)...'; 
        end
        
    end
    
    % Only allow one identification per posterior draws?
    if isfield(model,'identification')
        model.identification.draws = 1;
    end
   
    % Get the function to use to solve the model
    func = str2func([model.class, '.solveNormal']);

    % Make the parameter draws
    %..........................
    if isfield(options,'factorsLags')
        maxLag = max(options.factorsLags,max(options.nLags));
    else
        maxLag = options.nLags;
    end
    options.stdType   = method;
    options.stdReplic = draws*inputs.initialDraws;
    [betaDraws,lambdaDraws,sigmaDraws,RDraws,factorDraws] = nb_fmEstimator.bootstrapModel(options,results,size(model.A,3));   

    % Get the initial values of the drawn factors
    factorDraws = factorDraws(end-maxLag+1:end,:,:);
    [s1,s2,s3]  = size(factorDraws);
    factorDraws = reshape(factorDraws,[1,s1*s2,s3]);
    factorDraws = permute(factorDraws,[2,1,3]);

    if iscell(betaDraws)
        nEqs    = size(betaDraws,2);
        betaD   = cell(1,nEqs);
        sigmaD  = cell(1,nEqs);
    end

    switch output
        case 'param'
            if ~stable
                out.beta    = betaD;
                out.sigma   = sigmaD;
                out.lambda  = lambdaDraws;
                out.R       = RDraws;
                out.factors = factorDraws;
                return
            end
        case 'solution'
            modelOut = repmat(model,1,draws);
        case 'object'
            objectOut = repmat(obj,1,draws);
        otherwise
            error([mfilename ':: Unsupported output type ' output])    
    end
    
    kk      = 0;
    ii      = 0;
    jj      = 0;
    res     = results;
    note    = nb_when2Notify(draws);
    betaA   = betaD;
    sigmaA  = sigmaD;
    lambdaA = lambdaDraws;
    RA      = RDraws;
    factorA = factorDraws;
    while kk < draws

        ii = ii + 1;
        
        if ii > draws
            % Draw new bootstraped parameters and factors
            options.stdReplic = draws*inputs.newDraws;
            [betaDraws,lambdaDraws,sigmaDraws,RDraws,factorDraws] = nb_fmEstimator.bootstrapModel(options,results,size(model.A,3)); 
            factorDraws = factorDraws(end-maxLag+1:end,:,:);
            [s1,s2,s3]  = size(factorDraws);
            factorDraws = reshape(factorDraws,[1,s1*s2,s3]);
            factorDraws = permute(factorDraws,[2,1,3]);
            ii          = 0;
            continue
        end

        jj = jj + 1;
        
        res.beta   = betaDraws(:,:,ii);
        res.sigma  = sigmaDraws(:,:,ii);
        res.lambda = lambdaDraws(:,:,ii);
        res.R      = RDraws(:,:,ii);

        % Solve the model given the draw
        try
            if isfield(model,'identification')
                modelTemp = func(res,options,model.identification);
            else
                modelTemp = func(res,options);
            end
        catch %#ok<CTCH>
            continue 
        end

        if stable
            [~,~,modulus] = nb_calcRoots(modelTemp.A);
            if any(modulus > 1)
                continue 
            end
        end

        kk = kk + 1;

        if strcmpi(output,'param')
            betaA(:,:,kk)   = betaD(:,:,ii);
            sigmaA(:,:,kk)  = sigmaD(:,:,ii);
            lambdaA(:,:,kk) = lambdaDraws(:,:,ii);
            RA(:,:,kk)      = RDraws(:,:,ii);
            factorA(:,:,kk) = factorDraws(:,:,ii);
        elseif strcmpi(output,'object')
            objectOut(kk).solution       = modelTemp;
            objectOut(ii).results.beta   = betaD(:,:,ii);
            objectOut(ii).results.sigma  = sigmaD(:,:,ii);
            objectOut(ii).results.lambda = lambdaDraws(:,:,ii);
            objectOut(ii).results.R      = RDraws(:,:,ii);
        else
            modelOut(kk) = modelTemp;
        end

        % Report current status
        report(inputs,h,index,kk,jj,display,note)

    end
    
    switch output  
        case 'param'
            out.beta    = betaA;
            out.sigma   = sigmaA;
            out.lambda  = lambdaA;
            out.R       = RA;
            out.factors = factorA;
        case 'solution'
            out = modelOut;   
        case 'object'
            out = objectOut;
    end
    
    % Delete waiting bar
    if display
        delete(h);
    end
        
end

%==========================================================================
function out = bootstrapParamStepAheadFactorModel(obj,inputs)

    draws   = inputs.draws;
    method  = inputs.method;
    output  = inputs.output;
    model   = obj.solution;
    options = obj.estOptions;
    results = obj.results;
    iter    = size(model.A,3);
    func    = str2func([model.class, '.solveNormal']);
    
    % Make waiting bar
    if ~strcmpi(output,'param')
        
        if isfield(inputs,'waitbar')
            waitbar = inputs.waitbar;
        else
            waitbar = true;
        end

        index   = '';
        display = true;
        if inputs.parallel || ~waitbar % When parallel waitbar does not work!
            display = false;
            if isfield(inputs,'index')
                index = int2str(inputs.index);
            end
            h       = [];
        else
            h                = nb_waitbar5([],'Bootstrap',true,false);
            h.maxIterations1 = draws;
            h.text1          = 'Drawing parameters (this could take some time)...'; 
        end
        
    end

    % Make the parameter draws
    %..........................
    options.stdType   = method;
    options.stdReplic = draws;
    [betaDraws,lambdaDraws,sigmaDraws,RDraws,factorDraws] = nb_fmEstimator.bootstrapModel(options,results,iter);   

    % Get the initial values of the drawn factors
    maxLag      = options.nLags;
    factorDraws = factorDraws(end-maxLag:end,:,:);
    [s1,s2,s3]  = size(factorDraws);
    factorDraws = reshape(factorDraws,[1,s1*s2,s3]);
    factorDraws = permute(factorDraws,[2,1,3]);
       
    switch output
        case 'param'
            out.beta    = betaD;
            out.sigma   = sigmaD;
            out.lambda  = lambdaDraws;
            out.R       = RDraws;
            out.factors = factorDraws;
            return
        case 'solution'
            modelOut = repmat(model,1,draws);
        case 'object'
            objectOut = repmat(obj,1,draws);
        otherwise
            error([mfilename ':: Unsupported output type ' output])    
    end
    
    % Loop through the parameter draws and produce density forecast
    res  = results;
    note = nb_when2Notify(draws);
    for ii = 1:draws

        res.beta   = betaDraws(:,:,ii);
        res.sigma  = sigmaDraws(:,:,ii);
        res.lambda = lambdaDraws(:,:,ii);
        res.R      = RDraws(:,:,ii);

        % Solve the model given the draw
        modelTemp = func(res,options);
        if strcmpi(output,'object')
            objectOut(ii).solution       = modelTemp;
            objectOut(ii).results.beta   = betaDraws(:,:,ii);
            objectOut(ii).results.sigma  = sigmaDraws(:,:,ii);
            objectOut(ii).results.lambda = lambdaDraws(:,:,ii);
            objectOut(ii).results.R      = RDraws(:,:,ii);
        else
            modelOut(ii) = modelTemp;
        end

        % Report current status
        report(inputs,h,index,kk,jj,display,note)

    end

    switch output  
        case 'solution'
            out = modelOut;   
        case 'object'
            out = objectOut;
    end
    
    % Delete the waitbar.
    if display
        delete(h);
    end
                       
end

%==========================================================================
function out = posteriorParam(obj,inputs)

    draws   = inputs.draws;
    output  = inputs.output;
    stable  = inputs.stable;
    options = obj.estOptions;
    model   = obj.solution;
    if isa(obj,'nb_dsge')
       if isNB(obj)
           options.parser.object = set(obj,'silent',true);
       end
    end

    % Make waiting bar
    if strcmpi(inputs.method,'asymptotic')
        figName = 'Asymptotic distribution draws';
    else
        if ~isfield(options,'pathToSave')
            error([mfilename ':: No estimation is done, so can''t draw from the posterior.'])
        end
        posterior = nb_loadDraws(options.pathToSave);
        if strcmpi(posterior.type,'priorPredictive')
            figName = 'Prior draws';
        else
            figName = 'Posterior draws';
        end
    end
    
    h = false;
    if ~strcmpi(output,'param') || stable
        
        if isfield(inputs,'waitbar')
            waitbar = inputs.waitbar;
        else
            waitbar = true;
        end
        index   = '';
        display = true;
        if inputs.parallel || ~waitbar % When parallel waitbar does not work!
            display = false;
            if isfield(inputs,'index')
                index = int2str(inputs.index);
            end
        else
            h                = nb_waitbar5([],figName,true,false);
            h.text1          = 'Load (and make new) draws...';
            h.maxIterations1 = draws;
            h.lock           = 2;
        end
        
    end
    
    % Make the posterior draws
    asymptotic = false;
    if strcmpi(inputs.method,'asymptotic')
        drawFunc       = str2func([options.estimator '.drawParameters']);
        [betaD,sigmaD] = drawFunc(obj.results,options,draws*inputs.initialDraws,'end');
        asymptotic     = true;            
    else
        if inputs.parallel
            betaD  = posterior.betaD;
            sigmaD = posterior.sigmaD;
        else
            [betaD,sigmaD] = nb_drawFromPosterior(posterior,draws*inputs.initialDraws,h);
        end
    end
    
    switch output
        case 'param'
            if ~stable
                out.beta  = betaD;
                out.sigma = sigmaD;
                return
            end
        case 'solution'
            modelOut = repmat(model,1,draws);
        case 'object'
            objectOut = repmat(obj,1,draws);
        otherwise
            error([mfilename ':: Unsupported output type ' output])    
    end
    
    res = obj.results;
    if isfield(res,'estimationIndex')
        estInd  = res.estimationIndex;
        estInd2 = 1; 
    else
        estInd  = true(size(betaD,1),1);
        estInd2 = true(size(betaD,2),1);
        res     = struct('beta',[],'sigma',[]);
    end
    
    kk     = 0;
    ii     = 0;
    jj     = 0;
    func   = str2func([model.class, '.solveNormal']);
    note   = nb_when2Notify(draws);
    betaA  = betaD;
    sigmaA = sigmaD;
    while kk < draws

        ii = ii + 1;
       
        % Assign posterior draw
        try
            res.beta(estInd,estInd2) = betaD(:,:,ii);
            res.sigma                = sigmaD(:,:,ii);
        catch %#ok<CTCH>
            % Draw more
            if asymptotic
                [betaD,sigmaD] = drawFunc(obj.results,options,draws*inputs.newDraws,'end');
            else
                [betaD,sigmaD] = nb_drawFromPosterior(posterior,draws*inputs.newDraws,h);
            end
            ii = 0;
            continue;
        end
        
        jj = jj + 1;

        % Solve the model given the draw
        try
            if isfield(model,'identification')
                modelTemp = func(res,options,model.identification);
            else
                modelTemp = func(res,options);
            end
        catch %#ok<CTCH>
           continue 
        end

        if stable
            [~,~,modulus] = nb_calcRoots(modelTemp.A);
            if any(modulus > 1)
                continue 
            end
        end

        kk = kk + 1;
        if strcmpi(output,'param')
            betaA(:,:,kk)  = betaD(:,:,ii);
            sigmaA(:,:,kk) = sigmaD(:,:,ii);
        elseif strcmpi(output,'object')
            objectOut(kk).solution                     = modelTemp;
            objectOut(kk).results.beta(estInd,estInd2) = betaD(:,:,ii);
            objectOut(kk).results.sigma                = sigmaD(:,:,ii);
        else
            modelOut(kk) = modelTemp;
        end

        % Report current status
        report(inputs,h,index,kk,jj,display,note)

    end
    
    switch output  
        case 'param'
            out.beta  = betaA;
            out.sigma = sigmaA;
        case 'solution'
            out = modelOut;           
        case 'object'
            out = objectOut;
    end
    
    % Delete the waitbar.
    if display
        delete(h);
    end
       
end

%==========================================================================
function out = doParallel(obj,inputs)
% Draw parameters in parallel.

    draws = inputs.draws;
    switch inputs.method
        case {'bootstrap','wildbootstrap','blockbootstrap','mblockbootstrap','rblockbootstrap','wildblockbootstrap','copulabootstrap'}
            if isfield(obj.solution,'G') % Factor model
                funcStr = 'bootstrapParamFactorModel';
            else
                funcStr = 'bootstrapParam';
            end
        case 'posterior'
            funcStr = 'posteriorParam';
        otherwise
            error([mfilename ':: Unsupported method; ' inputs.method '.'])
    end

    numCores = [];
    if isfield(inputs,'cores')
        numCores = inputs.cores;
    end
    
    % Open workers
    ret        = nb_openPool(numCores);
    [useNew,D] = nb_parCheck();
    if useNew % For newer versions than R2017B
    
        % Create waitbar and create notify function
        h      = nb_waitbar([],'Drawing parameters (parallel)...',inputs.draws,false,false);
        h.text = 'Working...';
        afterEach(D,@(x)nb_updateWaitbarParallel(x,h));
        
        % Produce the irfs in parallel, each worker gets some number of
        % draws to do.
        funcUsed     = {str2func(funcStr)};
        method       = funcUsed(:,ones(1,inputs.draws));
        models       = cell(1,inputs.draws);
        draws        = inputs.draws;
        inputs.draws = 1;
        if inputs.newDraws < 1
            inputs.newDraws = 100;
        end
        objs   = obj(:,ones(1,draws));
        inputs = inputs(:,ones(1,draws));
        for ii = 1:draws
            meth       = method{ii};
            models{ii} = meth(objs(ii),inputs(ii));
            send(D,1); % Update waitbar!
        end
          
    else % Old version using files to report instead
        
        cores = nb_poolSize();
        if draws < cores
            cores = 1;
        end

        % Create a manual input file
        pathToSave = nb_userpath('gui');
        if exist(pathToSave,'dir') ~= 7
            try
                mkdir(pathToSave)
            catch %#ok<CTCH>
                error(['The userpath specified is not valid for writing, which is needed in parallel mode. Your userptah is; ' nb_userpath])
            end
        end
        filename = [pathToSave,'\input_file_' nb_clock('vintagelong') '.txt'];
        writer   = fopen(filename,'w+');
        fclose(writer);
        fclose('all');
        inputs.filename = filename;

        % Preallocate inputs and outputs
        funcUsed         = {str2func(funcStr)};
        method           = funcUsed(:,ones(1,cores));
        inputs.waitbar   = false; % To turn off waitbar
        inputs           = inputs(:,ones(1,cores));
        writer           = nb_funcToWrite('param_worker','gui');
        for ii = 1:cores  
            inputs(ii).draws  = ceil(draws/cores);
            inputs(ii).index  = ii;
            inputs(ii).writer = writer; 
        end

        % Secure that the number of draws is produced
        sumDraws            = sum([inputs.draws]);
        diffDraws           = sumDraws - draws;
        inputs(cores).draws = inputs(cores).draws - diffDraws;

        % Produce the irfs in parallel, each worker gets some number of
        % draws to do.
        objs   = obj(:,ones(1,cores));
        models = cell(1,cores);
        parfor ii = 1:cores       
            meth       = method{ii};
            models{ii} = meth(objs(ii),inputs(ii));
        end

        % Close workers if open up locally
        delete(writer);
        clear writer;
        nb_closePool(ret);

        % Close files for writing
        fclose('all');
        
    end
    
    % Convert the output
    if strcmpi(inputs(1).output,'param')
        out    = struct;
        fields = fieldnames(models{1});
        for jj = 1:length(fields)
            field               = models{1}.(fields{jj});
            [s1,s2,num]         = size(field);
            newField            = nan(s1,s2,draws);
            newField(:,:,1:num) = field;
            for ii = 2:length(models)
                st                   = num + 1;
                field                = models{ii}.(fields{jj});
                num                  = num + size(field,3);
                newField(:,:,st:num) = field;
            end
            out.(fields{jj})     = newField;
        end
    else
        out = [models{:}];
    end
     
end

%==========================================================================
function report(inputs,h,index,kk,jj,display,note)
% Report status

    draws = inputs.draws;
    if ~display && ~isempty(index)
        [~,canceling] = nb_irfEngine.checkInputFile(inputs.filename);
        if canceling
            error([mfilename ':: User terminated'])
        end
        if rem(kk,note) == 0
            fprintf(inputs.writer.Value,['Finished with ' int2str(kk) ' replications in ' int2str(jj) ' tries of '...
                                         int2str(draws) ' on worker ' index '...\r\n']);
        end
    elseif display
        if h.canceling
            error([mfilename ':: User terminated'])
        end
        if rem(kk,note) == 0
            h.status1 = kk;
            h.text1   = ['Finished with ' int2str(kk) ' replications in ' int2str(jj) ' tries...'];
        end
    end

end
