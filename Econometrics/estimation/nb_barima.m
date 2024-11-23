function results = nb_barima(y,p,i,q,sp,sq,constant,z,x,varargin)
% Syntax:
%
% results = nb_barima(y,p,i,q)
% results = nb_barima(y,p,i,q,sp,sq,constant,z,x,varargin)
%
% Description:
%
% Estimate a ARIMA(p,i,q) or ARIMAX(p,i,q) model using bayesian estimation.
% 
% y(t) = b*z + u(t)
% u(t) = lambda*u(t-1) + c*x + eps(t)
%
% Input:
% 
% - y         : A nobs x 1 double vector with the time-series.
% 
% - p         : The AR degree. As a number.
%
% - i         : The degree of integration. I.e. the number of times 
%               the time-series have to be differenced.
%
% - q         : The MA degree. As a number. 
%
% - sp        : Seasonal autoregressive (SAR) component. E.g. 0 to exclude,
%               4 for quarterly data, 12 for monthly.
%
% - sq        : Seasonal moving average (SMA) component. E.g. 0 to exclude,
%               4 for quarterly data, 12 for monthly.
%
% - constant  : Give 1 if a constant should be included, otherwise 
%               0. Default is 1.
%
% - z         : Exogenous regressors in the observation equation. As a 
%               nobs x nvars. Defualt is [].
%
% - x         : Exogenous regressors in the transition equation. As 
%               a nobs x mvars. Defualt is [].
%
% Optional inputs:
%
% - 'covrepair'     : Give true to repair the covariance matrix of the 
%                     estimated parameters if found to not be positive 
%                     definite. Default is false, i.e. to throw an error if 
%                     the covariance matrix is not positive definite.
%
% - 'filter'        : Give true if you want to run the kalman filter to 
%                     estimate the residual. Otherwise give 1. Default is
%                     false.
%
% - 'optimizer'     : See the output from the nb_getOptimizers('arima').
%
% - 'options'       : Inputs given to the optimset function. If no 
%                     optional inputs are given default settings are 
%                     used. Must be given as a struct or a cell array.
%                     If given as a cell array it is given to the
%                     optimset function. struct is recommended. See
%                     nb_getDefaultOptimset.
%
% - 'prior'         : A struct returned by nb_arima.priorTemplate or [].
%
% - 'stabilityTest' : true or false. If true, stability is forced on the
%                     model during estimation. Default is true.
% 
% - 'test'          : true or false. If true an error will be trown if the
%                     model is not stable. Default is true.
%
% Output:
% 
% - results : A struct consiting of:
%
%             > beta       : The estimated coefficients. Order; constant,  
%                            AR, MA, SAR, SMA, x, z.
%             
%             > stdBeta    : The standard deviation of the estimated  
%                            coefficients. Order; constant, AR, MA, SAR,  
%                            SMA then exogenous.
%
%             > tStatBeta  : The t-statistics of the estimated  
%                            coefficients. Order; constant, AR, MA, SAR,  
%                            SMA then exogenous.
%
%             > pValBeta   : The p-values of the estimated coefficients. 
%                            Order; constant, AR, MA, SAR, SMA then  
%                            exogenous.
%
%             > sigma      : Estimated std of the residual.
%
%             > omega      : Covariance matrix of the estimated 
%                            coefficients including the residual std.
%                            Order; constant, AR, MA, SAR, SMA, exogenous
%                            then residual std.
%
%             > likelihood : The log likehood.
%
%             > residual   : The filter estimate of the residual. 
%                            As a nsample x 1 double. Only if the
%                            filter input is set to 1.
%
%             > X          : Will be empty.
%
%             > y          : The model dependent variable. As a
%                            nsample x 1 double.
%
%             > u          : The residual from the observation equation.
%                            If no constant and z is empty this will
%                            be equal to y.
%
%             > z          : The exogenous variables included in the 
%                            observation equation.
%
%             > x          : The exogenous variables included in the 
%                            transition equation.
%
% See also:
% nb_getDefaultOptimset, nb_getOptimizers
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 9
        x = [];
        if nargin < 8
            z = [];
            if nargin < 7
                constant = 1;
                if nargin < 6
                    sq = 0;
                    if nargin < 5
                        sp = 0;
                    end
                end
            end
        end
    end

    [T,dim2] = size(y);
    if dim2 > 1
        error([mfilename ':: The y input must be an nobs x 1 double.'])
    end
    
    default = {'stabilityTest',   true,       @islogical;...
               'test',            true,       @islogical;...
               'options',         {},         {@iscell,'||',@isstruct};...
               'prior',           [],         {@isempty,'||',@isstruct};...
               'filter',          true,       @islogical;...
               'covrepair',       true,       @islogical;...
               'optimizer',       'fminunc',  {{@nb_ismemberi,{'fmincon','fminunc','fminsearch'}}};...
               'remove',          [],         @(x)or(islogical(x),isempty(x))};
           
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    test      = inputs.test;
    options   = inputs.options;
    filter    = inputs.filter;
    covrepair = inputs.covrepair;
    optimizer = inputs.optimizer;
    stability = inputs.stabilityTest;
    prior     = inputs.prior;
    if isempty(prior)
        prior = nb_arima.priorTemplate();
    end
    
    %==============================================================
    % Transformation
    %==============================================================
    for hh = 1:i
        y = diff(y);
    end
        
    if isempty(z)
        z = nan(size(y,1),0);
    end
    
    %==============================================================
    % Estimation
    %==============================================================

    % Uses the Hannan-Rissanen algorithm to initialize paramter 
    % estimates
    %--------------------------------------------------------------
    r = p + q;
    if r > T
        error(['The sample is to short to use the Hannan-Rissanen algorithm to '...
            'initalize the coefficent to be estimated.'])
    end
    results      = nb_hrarima(y,1,0,0,constant,test,z,x);
    betaForSetup = results.beta;
    sigma        = results.sigma;
    
    % Prior mean on regression coefficients
    numParSetup = size(betaForSetup,1);
    nExoPar     = numParSetup - 1 - constant;
    priorSeas   = [];
    if sp 
        priorSeas = [priorSeas;0];
    end
    if sq 
        priorSeas = [priorSeas;0];
    end
    priorMean = [betaForSetup(1:constant + 1);zeros(r-1,1);priorSeas;zeros(nExoPar,1);sigma];
    init      = priorMean;
    if isfield(prior,'ARcoeff') && ~isempty(prior.ARcoeff)
        priorMean(constant + 1) = prior.ARcoeff;
    end

    % Run a stability check of initial estimates
    absr = abs(roots([1,-init(constant + 1:constant + p)']));
    if any(absr >= 1) 
        % Set a prior that pushes against stability
        if stability
            priorMean(constant + 1) = 0; 
            init(constant + 1)      = 0.9;
        end
    end

    % Prior std
    a_bar_AR    = prior.a_bar_AR;
    a_bar_MA    = prior.a_bar_MA;
    a_bar_sigma = prior.a_bar_sigma;
    a_bar_exo   = prior.a_bar_exo;
    priorSTD    = nan(size(priorMean,1),1);
    kk          = 1;
    if constant
        priorSTD(kk) = a_bar_exo;
        kk           = kk + 1;
    end
    for ii = 1:p
        priorSTD(kk) = a_bar_AR/ii;
        kk           = kk + 1;
    end 
    for ii = 1:q
        priorSTD(kk) = a_bar_MA/ii;
        kk           = kk + 1;
    end 
    if sp
        priorSTD(kk) = a_bar_exo;
        kk           = kk + 1;
    end
    if sq
        priorSTD(kk) = a_bar_exo;
        kk           = kk + 1;
    end
    for ii = 1:nExoPar
        priorSTD(kk) = a_bar_exo;
        kk           = kk + 1;
    end 
    priorSTD(end) = a_bar_sigma;

    % Set up prior distributions
    priorDist = cell(size(priorMean,1),1);
    for ii = 1:size(priorMean,1)-1
        priorDist{ii} = @(x)nb_distribution.normal_lpdf(x,priorMean(ii),priorSTD(ii));
    end 
    priorDist{end} = @(x)nb_distribution.gamma_lpdf(x,priorMean(end),priorSTD(end)^2);
    
    % Estimate the parameters by maximum likelihood
    if strcmpi(optimizer,'nb_abc')
        error('The nb_abc optimizer is not supported for a model of class nb_arima.')
    end
    if iscell(options)
        if size(options,2) > 0
            options = optimset(options{:});
        else
            options = struct('Display','off'); % Use default options
        end
    elseif ~isstruct(options)
        options = struct('Display','off'); % Use default options
    end
    options = nb_getDefaultOptimset(options,optimizer);
    
    % Construct variables
    if isempty(z)
        X = x;
    elseif isempty(x)
        X = z;
    else
        X = [x,z];
    end
    nExoT = size(x,2);
    yt    = y';
    Xt    = X';
    yEst  = yt;
    XEst  = Xt;
    if ~isempty(inputs.remove)
        % Set observations to nan to drop them from kalman filter
        % estimation, and exogenous set to their mean
        XEstM          = mean(XEst,2);
        indRem         = ~inputs.remove(1+i:end);
        yEst(:,indRem) = nan;
        XEst(:,indRem) = XEstM(:,ones(1,sum(indRem)));
        kalmanFunc     = @nb_kalmanlikelihood_missing;
    else
        kalmanFunc = @nb_kalmanlikelihood;
    end
    
    % Posterior to minimize
    posteriorFunc = @(x)evalPosterior(x,kalmanFunc,@nb_arimaStateSpace,yEst,XEst,p,q,sp,sq,constant,nExoT,stability,priorDist);

    % Minimize the minus the log likelihood 
    UB              = inf(size(init,1),1);
    LB              = -UB;
    LB(end)         = 0; % Lower bound on residual variance
    [estPar,post,H] = nb_callOptimizer(optimizer,posteriorFunc,init,LB,UB,options,...
                        ':: Estimation of the ARIMA model failed.');
    loglik          = kalmanFunc(estPar,@nb_arimaStateSpace,yEst,XEst,1,p,q,sp,sq,constant,nExoT,stability);
    
    % Standard deviation of the estimated paramteres (estPar)
    H = H(1:end-1,1:end-1); % Skip std on residual!!! 
    if rcond(H) < eps^(0.9) && ~covrepair
        error('nb_mlarima:invalidHessian',['Standard error of parameters ',...
            'cannot be calulated. Hessian is badly scaled.'])
    else
        omega     = H\eye(size(H,1));
        stdEstPar = sqrt(diag(omega));
        if any(~isreal(stdEstPar))
            if covrepair
                omega     = nb_covrepair(omega,false);
                stdEstPar = sqrt(diag(omega));
            else
                error('nb_mlarima:invalidHessian',['Standard error of ',...
                    'parameters are not real, something went wrong...'])
            end
        end
    end
    
    % Report results
    results         = struct();
    results.beta    = estPar(1:end-1);
    results.stdBeta = stdEstPar;
    if any(isnan(stdEstPar))
        results.tStatBeta = nan(size(stdEstPar));
        results.pValBeta  = nan(size(stdEstPar));
    else
        results.tStatBeta = estPar(1:end-1)./stdEstPar;
        results.pValBeta  = nb_tStatPValue(results.tStatBeta,T - r);
    end
    results.sigma      = estPar(end);
    results.likelihood = -loglik;
    results.posterior  = -post;
    results.omega      = omega; 
    if test && ~stability
        absr = abs(roots([1,-results.beta(constant + 1:constant + p)']));
        if any(absr >= 1)
            error('nb_mlarima:invalidRoots',[mfilename ':: The roots of ',...
                'the ARIMA(' int2str(p) ',' int2str(i) ',' int2str(q) ') '...
                'Lag operator polynominal is outside the unit circle. ',...
                'Cannot estimate this model.'])
        end
    end
    
    if filter
        [u,results.residual] = nb_kalmanfilter(@nb_arimaStateSpace,yt,Xt,...
            estPar,p,q,sp,sq,constant,nExoT);
        u = u(:,1);
    else
        results.residual = [];
        u                = [];
    end
    results.X = [];
    results.y = y;
    results.u = u;
    results.z = z;
    results.x = x;
      
end

%==========================================================================
function fval = evalPosterior(par,kalmanFunc,model,y,z,p,q,sp,sq,constant,nExoT,stability,priorDist)
    loglik          = kalmanFunc(par,model,y,z,1,p,q,sp,sq,constant,nExoT,stability);
    logPriorDensity = evaluatePrior(priorDist,par);
    fval            = (loglik - logPriorDensity);
end

%==========================================================================
function logPriorDensity = evaluatePrior(priorDist,par)
    logPriorDensity = nan(size(par));
    for ii = 1:size(par,1)
        logPriorDensity(ii) = priorDist{ii}(par(ii));
    end
    logPriorDensity = sum(logPriorDensity);
    if ~isfinite(logPriorDensity)
        logPriorDensity = -1e10;
    end
end
