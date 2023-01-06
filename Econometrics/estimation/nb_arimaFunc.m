function results = nb_arimaFunc(y,p,i,q,sp,sq,varargin)
% Syntax:
%
% results = nb_arimaFunc(y)
% results = nb_arimaFunc(y,p,i,q,sp,sq,varargin)
%
% Description:
%
% Estimate a ARIMA(p,i,q) model to a time-series represented as a
% double.
%
% y(t) = b*exo + u(t)
% u(t) = lambda*u(t-1) + c*texo + eps(t)
%
% 
% If the p, i or q are given by nan values they are being selected
% by this function.
%
% i is found by the adf unit root test. I.e. the first degree of
% integration which reject the null of a unit root.
%
% p and q are found by the minimizing the model selection criterion
% provided by the 'criterion' input. Default is to use the 
% corrected Akaike information criterion. ('aicc')
%
% Input:
%
% - y         : A nobs x 1 double vector with the time-series.
% 
% - p         : The AR degree. As a number. Provide nan if you want
%               to use a model selection criterion to find it.
%
% - i         : The degree of integration. I.e. the number of times 
%               the time-series have to be differenced. Provide nan 
%               if you want to use a unit root test to find it. 
%               Will use the Augmented Dickey-Fuller test for unit
%               root.
%
% - q         : The MA degree. As a number. Provide nan if you want
%               to use a model selection criterion to find it.
%
% - sp        : Seasonal autoregressive (SAR) component. E.g. 0 to exclude,
%               4 for quarterly data, 12 for monthly. Only an option if 
%               'method' is set to 'ml'.
% 
% - sq        : Seasonal moving average (SMA) component. E.g. 0 to exclude,
%               4 for quarterly data, 12 for monthly. Only an option if 
%               'method' is set to 'ml'.
%
% Optional inputs:
%
% - 'constant'  : Give 1 to include constant, otherwise give 0.
%                 Default is 0.
%
% - 'criterion' : The criterion to use when selecting between ARIMA
%                 models. See the function nb_infoCriterion for 
%                 more. Default is 'aicc'.
%
% - 'exo'       : Exogenous regressors in the observation equation. As a 
%                 nobs x nvars. Defualt is [].
%
% - 'texo'      : Exogenous regressors in the transition equation. As 
%                 a nobs x mvars. Defualt is [].
%
% - 'maxAR'     : Maximal number of AR coefficient. Default is 3.
%
% - 'maxMA'     : Maximal number of MA coefficient. Default is 3.
%
% - 'method'    : Either:
%
%                 > 'ml' : Maximum likelihood
%
%                 > 'hr' : Hannan-Rissanen algorithm. Default.
%                          (Same as OLS if only AR terms are included)
% 
% - 'optimizer' : See the output from the nb_getOptimizers('arima').
%
% - 'filter'    : Give 1 if you want to run the kalman filter to 
%                 estimate the residual. Otherwise give 0. Default 
%                 is not to run filter. Only for 'ml'.
%
% - 'alpha'     : The significance level used by the ADF test for unit 
%                 root when i is set to empty. Default is 0.05.
%
% - 'test'      : Test for roots outside the unit circle. Default is true. 
%                 Must be true or false.
%
% - 'options'   : Inputs given to the optimset function. If no 
%                 optional inputs are given default settings are 
%                 used. Must be given as a struct or a cell array.
%                 If given as a cell array it is given to the
%                 optimset function. struct is recommended. See
%                 nb_getDefaultOptimset.
%
% - 'covrepair' : See help on nb_mlarima. Only an option if 'method' is
%                 set to 'ml'.
%
% Output:
% 
% - results : A struct consiting of:
%
%             > beta       : The estimated coefficients. Order; constant,  
%                            AR, MA, (SAR, SMA then exogenous).
%             
%             > stdBeta    : The standard deviation of the estimated  
%                            coefficients. Constant, AR 
%                            coefficients then MA coefficients.
%
%             > tStatBeta  : The t-statistics of the estimated  
%                            coefficients. Constant, AR 
%                            coefficients then MA coefficients.
%
%             > pValBeta   : The p-values of the estimated  
%                            coefficients. Constant, AR 
%                            coefficients then MA coefficients.
%
%             > likelihood : The log likehood.
%
%             > i          : The degree of integration.
%
%             > residual   : The estimated residual. As a
%                            nsample x 1 double. 
%
%             > X          : The model regressors. As a 
%                            nsample x nlags double. Is empty
%                            if 'method' is set to 'ml'
%
%             > y          : The model dependent variable. As a
%                            nsample x 1 double.
%
%             > u          : See same output of nb_mlarima or nb_hrarima.
%
%             > z          : See same output of nb_mlarima or nb_hrarima.
%
%             > AR         : Number of AR terms.
%
%             > MA         : Number of MA terms.
%
% See also:
% nb_getDefaultOptimset, nb_getOptimizers
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 6
        sq = 0;
        if nargin < 5
            sp = 0;
            if nargin < 4
                q = nan;
                if nargin < 3
                    i = nan;
                    if nargin < 2
                        p = nan;
                    end
                end
            end
        end
    end
    
    [T,dim2,dim3] = size(y);
    if dim2 > 1 || dim3 > 1
        error([mfilename ':: The y input must be an nobs x 1 x 1 double.'])
    end
    
    % Parse optional inputs
    %--------------------------------------------------------------
    default = {'alpha',           0.05,       {@nb_isScalarNumber,'&&',{@gt,0},'&&',{@lt,1}};...
               'constant',        true,       {{@ismember,[0,1]}};...
               'covrepair',       true,       @islogical;...
               'criterion',       'aicc',     {{@nb_ismemberi,{'aic','aicc','maic','sic','msic','hqc','mhqc',''}}};...
               'exo',             [],         {@isnumeric,'&&',@(x)nb_sizeEqual(x,[T,nan]),'||',@isempty};...
               'texo',            [],         {@isnumeric,'&&',@(x)nb_sizeEqual(x,[T,nan]),'||',@isempty};...
               'filter',          true,       @islogical;...
               'maxAR',           3,          {@nb_isScalarInteger,'&&',{@gt,0},'&&',{@le,13}};...
               'maxMA',           3,          {@nb_isScalarInteger,'&&',{@gt,0},'&&',{@le,5}};...
               'method',          'hr',       {{@nb_ismemberi,{'hr','ml'}}};...
               'optimizer',       'fminunc',  {{@nb_ismemberi,{'fminunc','fminsearch','fmincon'}}}
               'options',         {},         @iscell;...
               'test',            true,       @islogical};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    if isempty(inputs.criterion)
        inputs.criterion = 'aicc';
    end
    if strcmpi(inputs.method,'hr')
       if sp > 0 || sq > 0
           error([mfilename ':: If seasonal AR or MA terms are included in the model ''method'' must be set to ''ml''.'])
       end
    end
    
    % Test the degree of integration if wanted
    %--------------------------------------------------------------
    if isnan(i)    
        % Iterate until we find a stationary series
        i       = 0;
        results = nb_adf(y);
        while results.rhoPValue > inputs.alpha
            y       = diff(y);
            results = nb_adf(y);
            i       = i + 1;
        end
    elseif i > 0
        for jj = 1:i
            y = diff(y);
        end
    end
    
    if isempty(inputs.exo)
        inputs.exo = nan(size(y,1),0);
    else
        inputs.exo = inputs.exo(1+i:end,:);
    end

    % Estimate the models and find the best fit
    %--------------------------------------------------------------
    if isnan(p) || isnan(q)
        results = findPQ(inputs,p,q,0,sp,sq,y,T); 
    else
        
        switch lower(inputs.method)
            case 'ml'  
                results = nb_mlarima(y,p,0,q,sp,sq,inputs.constant,inputs.exo,inputs.texo,...
                            'optimizer',    inputs.optimizer,...
                            'filter',       inputs.filter,...
                            'options',      inputs.options,...
                            'test',         inputs.test,...
                            'covrepair',    inputs.covrepair);
            case 'hr'
                results = nb_hrarima(y,p,0,q,inputs.constant,inputs.test,inputs.exo,inputs.texo);
            otherwise
                error([mfilename ':: Unsupported estimation method ' inputs.method])
        end
        results.AR  = p;
        results.MA  = q;
        results.SAR = sp;
        results.SMA = sq;
        
    end
    
    % Assign some more outputs.
    results.i        = i;
    results.constant = inputs.constant;
      
end

%==========================================================================
function results = findPQ(inputs,p,q,i,sp,sq,y,T)
    
    if isnan(p)
        iterAR = 1:inputs.maxAR;
        numAR  = inputs.maxAR;
    else
        iterAR = p;
        numAR  = 1;
    end
    if isnan(q)
        iterMA = 0:inputs.maxMA;
        numMA  = inputs.maxMA + 1;
    else
        iterMA = q;
        numMA  = 1;
    end
    if sp > 0
        numSAR = 1;
    else
        numSAR = 0;
    end
    if sq > 0
        numSMA = 1;
    else
        numSMA = 0;
    end

    models = nan(numAR,numMA);
    
    switch lower(inputs.method)
        
        case 'ml'
            
            % Waitbar
            h = nb_waitbar([],'Find best ARIMA model',numAR*numMA,false);
            h.text = 'Estimating...';
    
            hh = 1;
            for ar = iterAR

                kk = 1;
                for ma = iterMA

                    try
                        results(hh,kk) = nb_mlarima(y,ar,i,ma,sp,sq,inputs.constant,inputs.exo,inputs.texo,...
                            'optimizer',    inputs.optimizer,...
                            'filter',       false,...
                            'options',      inputs.options,...
                            'test',         inputs.test,...
                            'covrepair',    inputs.covrepair); %#ok<AGROW>
                        models(hh,kk)  = nb_infoCriterion(inputs.criterion,results(hh,kk).likelihood,T,ar + ma + numSAR + numSMA + 1,0);
                    catch Err

                        if strcmpi(Err.identifier,'nb_mlarima:invalidRoots')
                            % The specified model is not stationary
                            models(hh,kk) = inf;
                        else
                            models(hh,kk) = inf;
                            disp(Err.message); 
                        end

                    end
                    
                    % Update waitbar
                    h.status = inputs.maxMA*(hh-1) + kk;

                    kk = kk + 1;
                    
                end
                
                hh = hh + 1;

            end
            
            delete(h);
            
        case 'hr'
            
            hh = 1;
            for ar = iterAR

                kk = 1;
                for ma = iterMA

                    try
                        results(hh,kk) = nb_hrarima(y,ar,i,ma,inputs.constant,inputs.test,inputs.exo,inputs.texo); %#ok<AGROW>
                        models(hh,kk)  = nb_infoCriterion(inputs.criterion,results(hh,kk).likelihood,T,ar + ma + numSAR + numSMA + 1,0);
                    catch Err

                        if strcmpi(Err.identifier,'nb_hrarima:invalidRoots')
                            % The specified model is not stationary
                            models(hh,kk) = inf;
                        else
                            models(hh,kk) = inf;
                            warning('nb_arimaFunc:invalidRoots','%s',Err.message); 
                        end

                    end
                    
                    kk = kk + 1;

                end
                
                hh = hh + 1;

            end
            
        otherwise
            
            error([mfilename ':: Unsupported estimation method ' method])
            
    end   
    
    % Select the model that fit the data best
    %--------------------------------------------------------------
    if all(models(:) == inf)
        error([mfilename ': No appropriate model found.'])
    end
    
    pisnan = false;
    if isnan(p)
        [models,p] = min(models,[],1);
        pisnan     = true;
        pind       = p;
    else
        pind = 1;
    end
    if isnan(q)
        [~,qind] = min(models,[],2);
        if pisnan
            p    = p(qind);
            pind = p;
        end
        q = qind - 1;
    else
        qind = 1;
    end
    
    results     = results(pind,qind);
    results.AR  = p;
    results.MA  = q;
    results.SAR = sp;
    results.SMA = sq;
    
    % Get filtered estimates of the residual if wanted (will slow
    % down the code to much in the loop, so we do it only once)
    if inputs.filter && strcmpi(inputs.method,'ml')
        results = kalmanFilter(results,p,q,sp,sq,inputs.constant,inputs.exo,inputs.texo);
    end
    
end

%==========================================================================
function results = kalmanFilter(results,p,q,sp,sq,constant,exo,texo)

    if isempty(exo)
        X = texo;
    elseif isempty(texo)
        X = exo;
    else
        X = [texo,exo];
    end
    nExoT = size(texo,2);

    % Get initalial values of the kalman filter
    par               = [results.beta;results.sigma];
    [u,res]           = nb_kalmanfilter(@nb_arimaStateSpace,results.y',X',par,p,q,sp,sq,constant,nExoT);
    results.residual  = res(:,1);
    results.u         = u(:,end);
    
end
