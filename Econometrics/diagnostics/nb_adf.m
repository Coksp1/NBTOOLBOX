function [results,output] = nb_adf(y,varargin)
% Syntax:
%
% results = nb_adf(y)
% [results,ouput] = nb_adf(y,varargin)
%
% Description:
%
% Augmented Dickey-Fuller tests for unit root. I.e. testing the
% null hypothesis of a unit root.
% 
% Input:
% 
% - y : A nb_ts object or a double (nobs x nvars).
%
% Optional input:
%
% - 'nLags'         : Sets the number of lags of the estimated 
%                     model to base the test upon. Default is 0.
%
% - 'maxLags'       : Sets the maximum number of lags used by the
%                     lag length criteria. Default is 10.
%
% - 'lagLengthCrit' : Lag length selection criterion. Either:
%
%                     > 'aic'  : Akaike information criterion
%
%                     > 'aicc' : Corrected Akaike information 
%                                criterion
%
%                     > 'maic' : Modified Akaike information 
%                                criterion 
%
%                     > 'sic'  : Schwarz information criterion
%
%                     > 'msic' : Modified Schwarz information 
%                                criterion 
%
%                     > 'hqc'  : Hannan-Quinn information criterion
%
%                     > 'mhqc' : Modified Hannan-Quinn information 
%                                criterion 
%
%                     > ''     : Manually set lag length.
%
% - 'model'         : Either ('ar' is default):
%
%   > 'ar'  : y(t) = beta(1)*y(t-1) + beta(2)*(1-L)y(t-1) + ... + 
%                    beta(p+1)*(1-L)y(t-p) + e(t)
% 
%   > 'ard' : y(t) = beta(1) + beta(2)*y(t-1) +   
%                    beta(3)*(1-L)y(t-1) + ... + 
%                    beta(p+2)*(1-L)y(t-p) + e(t)
% 
%   > 'ts'  : y(t) = beta(1) + beta(2)*t + beta(3)*y(t-1) + 
%                    beta(4)*(1-L)y(t-1) + ... + 
%                    beta(p+3)*(1-L)y(t-p)  + e(t)
% 
% - 'method'       : One of;
%                     > 'standard' : The standard ADF test statistics.
%                     > 'badf'     : The backward ADF statistic sequence.
%                     > 'bsadf'    : The backward sup ADF statistic 
%                                    sequence.
%                     > 'gsadf'    : The generalized sup ADF statistic.
%                     > 'bgsadf'   : The backward generalized sup ADF 
%                                    statistic sequence.
%                     > 'sadf'     : The sup ADF statistic.
%
% - 'start'          : The start date of the recursive ADF testing.
%
% - 'draws'          : Number of draws to be used to construct the critical
%                      values and the p-values when the 'method' input is
%                      not set to 'standard'.
%
% Output:
% 
% > When 'method' == 'standard':
%
% - results : A struct with the estimation and test results:
%
%   > rhoTTest      : T-statisticts of the estimated coefficient 
%                     of the lag.
%
%   > rhoPValue     : P-value of the estimated coefficient of the 
%                     lag. Compared to the critical values for the 
%                     Dickey-Fuller Test.
%
%   > rhoCritValue  : The rhoTTest critical values for significance 
%                     level 0.1, 0.05 and 0.01. A 1 x 3 double.
%                     If rhoTTest > these critical values you can
%                     reject the null hypothesis of a unit root at  
%                     the given significance level.
%
%   > Zdf           : Dickey-Fuller rho test statistics. 
%
%   > ZdfPValue     : P-value of the Dickey-Fuller rho test 
%                     statistics. Compared to the critical values  
%                     for the Dickey-Fuller Test.
%
%   > ZdfCritValue  : The Zdf critical values for significance 
%                     level 0.1, 0.05 and 0.01. A 1 x 3 double.
%                     If Zdf > these critical values you can
%                     reject the null hypothesis of a unit root at  
%                     the given significance level.
%
% > When 'method' ~= 'standard':
%
%   > test      : The wanted test statistics. May be a vector depending on 
%                 the 'method' input.
%
%   > critValue : The critical values of the test for significance level 
%                 0.1, 0.05 and 0.01. A N x 3 double.. N may be > 1 
%                 depending on the 'method' input.
%
%   > pValue    : The p-value(s) of the test statistics. May be a vector  
%                 depending on the 'method' input.
%
% > In both cases:
%
% - ouput  : The estimated equation as a struct of size 1 x numberOfVars.
%            Each element consist of to fields; results and options.
%            See the output of nb_olsEstimator.estimate for more on these
%            output.
%
% See also:
% nb_unitRootTest
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    inputs = parseInput(varargin{:});

    % Get the model type to estimate
    %--------------------------------------------------------------
    switch lower(inputs.model)
        
        case 'ar'
            constant   = 0;
            time_trend = 0;
        
        case 'ard'
            constant   = 1;
            time_trend = 0;
            
        case 'ts' 
            constant   = 1;
            time_trend = 1;
            
    end
    
    nLags        = inputs.nLags - 1;
    maxLagLength = inputs.maxLags;
    criterion    = inputs.lagLengthCrit;
    
    % Construct the needed variables
    %--------------------------------------------------------------
    if isnumeric(y)
        
        [T,N,P] = size(y);
        if P > 1
            error([mfilename ':: This function is not defined for multi-paged double objects.'])
        end
        
        dof = 11;
        if ~isempty(criterion)
            if T < maxLagLength + dof
                error([mfilename ':: The input data must have at least ' int2str(maxLagLength + dof) ' periods.'])
            end 
        else
            if T < nLags + dof
                error([mfilename ':: The input data must have at least ' int2str(nLags + dof) ' periods.'])
            end 
        end
        
        startDate = '1';
        tempVars  = strcat('Var',strtrim(cellstr(int2str([1:N]'))))'; %#ok<NBRAK>
        iter      = N;
        ylag      = lag(y);
        ydiff     = [nan(1,size(y,2));diff(y)];
        ydifflag  = lag([nan(1,size(y,2));diff(y)]);
        y         = [y,ylag,ydiff,ydifflag];
        yOrg      = y;
        y         = y(3:T,:);
        yVars     = [tempVars, strcat(tempVars,'_lag1'),strcat('diff_',tempVars),strcat('diff_',tempVars,'_lag1')];
        
    else
        if y.numberOfDatasets > 1
            error([mfilename ':: This function is not defined for multi-paged nb_ts objects.'])
        end

        dof = 11;
        if ~isempty(criterion)
            if y.numberOfObservations < maxLagLength + dof
                error([mfilename ':: The input data must have at least ' int2str(maxLagLength + dof) ' periods.'])
            end 
        else
            if y.numberOfObservations < nLags + dof
                error([mfilename ':: The input data must have at least ' int2str(nLags + dof) ' periods.'])
            end 
        end
        
        
        startDate = y.startDate.toString();
        tempVars  = y.variables;
        iter      = y.numberOfVariables;
        ylag      = lag(y);
        ylag      = addPostfix(ylag,'_lag1');
        ydiff     = diff(y);
        ydiff     = addPrefix(ydiff,'diff_');
        ydifflag  = lag(diff(y));
        ydifflag  = addPrefix(ydifflag,'diff_');
        ydifflag  = addPostfix(ydifflag,'_lag1');
        y         = [y,ylag,ydiff,ydifflag];
        fin       = y.numberOfObservations;
        yVars     = y.variables;
        y         = y.data;
        yOrg      = y;
        y         = y(3:fin,:);
        
    end
    
    % Set up the model and estimated the test equations
    %--------------------------------------------------------------
    output(iter).results = [];
    output(iter).options = [];
    for ii = 1:iter
    
        % Set the options for the estimation
        tempVar      = tempVars{ii};
        dependent    = {['diff_' tempVar]};
        if isempty(criterion)
            modelSelection = '';
        else
            modelSelection = 'laglength';
        end
        
        if nLags <= 0 && isempty(modelSelection)
            exogenous           = {[tempVar '_lag1']};
            modelSelectionFixed = true;
            nLags               = 0;
        else
            exogenous           = {[tempVar '_lag1'],['diff_' tempVar '_lag1']};
            modelSelectionFixed = [true,false];
        end

        % Set up options
        tempOptions                     = nb_olsEstimator.template();
        tempOptions.constant            = constant;
        tempOptions.criterion           = criterion;        
        tempOptions.time_trend          = time_trend;
        tempOptions.data                = y;
        tempOptions.dataStartDate       = startDate;
        tempOptions.dataVariables       = yVars;
        tempOptions.dependent           = dependent;
        tempOptions.exogenous           = exogenous;
        tempOptions.maxLagLength        = maxLagLength - 1;
        tempOptions.modelSelection      = modelSelection;
        tempOptions.nLags               = nLags;
        tempOptions.modelSelectionFixed = modelSelectionFixed;
        tempOptions.doTests             = 0;
        
        % Adjust start period so the data is balanced for all estimations
        if ~isempty(modelSelection)
            tempOptions.estim_start_ind = maxLagLength;
        else
            tempOptions.estim_start_ind = nLags + 1;
        end
        
        if ~strcmpi(inputs.method,'standard')
            tempOptions.recursive_estim           = 1;
            tempOptions.recursive_estim_start_ind = inputs.start; 
        end
            
        % Estimate model
        [output(ii).results,output(ii).options] = nb_olsEstimator.estimate(tempOptions);
        
    end
    
    % Set up the test statistics
    %--------------------------------------------------------------
    ind = find(strcmpi(inputs.model,{'ar','ard','ts'}),1);
    T   = output(1).results.includedObservations;
    if isempty(ind)   
        error([mfilename ':: Unsupported type ' inputs.type])   
    end
    
    if strcmpi(inputs.method,'standard')
    
        results(iter) = struct('rhoTTest',[],'rhoPValue',[],'rhoCritValue',[],'Zdf',[],'ZdfPValue',[],'ZdfCritValue',[],'lagLength',[],'lagLengthCrit',[]);
        for ii = 1:iter

            estResults = output(ii).results;
            beta       = estResults.beta;
            stdBeta    = estResults.stdBeta;

            results(ii).rhoTTest = beta(ind,:)./stdBeta(ind,:);
            theta                = beta(ind + 1:end,:);
            results(ii).Zdf      = (T*beta(ind,:))./(1 - sum(theta,1));
            if exist('nb_getUnitRootPValue.m','file')
                [results(ii).rhoPValue,results(ii).rhoCritValue] = nb_getUnitRootPValue(lower(inputs.model),'t1',T,results(ii).rhoTTest);
                [results(ii).ZdfPValue,results(ii).ZdfCritValue] = nb_getUnitRootPValue(lower(inputs.model),'t2',T,results(ii).Zdf);
            else
                [results(ii).rhoCritValue,results(ii).rhoPValue] = cv_adf(results(ii).rhoTTest,T,inputs.draws,output(ii).options.nLags + 1,inputs.model);
                results(ii).ZdfPValue    = nan;
                results(ii).ZdfCritValue = nan(1,3);
            end
            results(ii).lagLength     = output(ii).options.nLags + 1;
            results(ii).lagLengthCrit = inputs.lagLengthCrit;

        end
        
    else
        
        results(iter) = struct('test',[],'pValue',[],'critValue',[],'lagLength',[],'lagLengthCrit',[]);
        switch lower(inputs.methods)
            
            case 'sadf'
                
                for ii = 1:iter
                    
                    % Construct test
                    estResults       = output(ii).results;
                    beta             = estResults.beta(ind,:);
                    stdBeta          = estResults.stdBeta(ind,:);
                    results(ii).test = max(beta./stdBeta);
                    
                    % Simulate critical values and p-values
                    [results(ii).critValue,results(ii).pValue] = cv_sadf(results(ii).test,output(1).options.recursive_estim_start_ind,T,inputs.draws,output(ii).options.nLags + 1,inputs.model);
                    
                end
 
            case 'badf'
                
                for ii = 1:iter
                    
                    % Construct test
                    estResults       = output(ii).results;
                    beta             = estResults.beta(ind,:);
                    stdBeta          = estResults.stdBeta(ind,:);
                    results(ii).test = beta./stdBeta;
                    
                    % Simulate critical values and p-values
                    [results(ii).critValue,results(ii).pValue] = cv_badf(results(ii).test,output(1).options.recursive_estim_start_ind,T,inputs.draws,output(ii).options.nLags + 1,inputs.model);
                    
                end
                
            case 'bsadf'
                
                for ii = 1:iter
                    
                    % Construct test
                    estResults       = output(ii).results;
                    beta             = estResults.beta(ind,:);
                    stdBeta          = estResults.stdBeta(ind,:);
                    results(ii).test = cummax(beta./stdBeta);
                    
                    % Simulate critical values and p-values
                    [results(ii).critValue,results(ii).pValue] = cv_bsadf(results(ii).test,output(1).options.recursive_estim_start_ind,T,inputs.draws,output(ii).options.nLags + 1,inputs.model);
                    
                end  
                
            case 'gsadf'
                
                % Construct test
                start  = output(1).options.recursive_estim_start_ind;
                r2     = start:1:T;
                r2     = r2';
                dim    = T - start + 1;
                bsadfs = zeros(dim,1); 
                for v = 1:1:size(r2,1)
                    swindow = start:1:r2(v);
                    r1      = r2(v) - swindow + 1;
                    rwadft  = zeros(size(swindow,2),1);
                    for i = 1:1:size(swindow,2)
                        rwadft(i) = adfFast(yOrg(r1(i):r2(v),1),nLags,inputs.model);
                    end  
                    bsadfs(v) = max(rwadft);
                end
                results(ii).test = max(bsadfs);
                
                % Simulate critical values and p-values
                [results(ii).critValue,results(ii).pValue] = cv_gsadf(results(ii).test,output(1).options.recursive_estim_start_ind,T,inputs.draws,output(ii).options.nLags + 1,inputs.model);
                
            case 'bgsadf'
                
                % Construct test
                start  = output(1).options.recursive_estim_start_ind;
                r2     = start:1:T;
                r2     = r2';
                dim    = T - start + 1;
                bsadfs = zeros(dim,1); 
                for v = 1:1:size(r2,1)
                    swindow = start:1:r2(v);
                    r1      = r2(v) - swindow + 1;
                    rwadft  = zeros(size(swindow,2),1);
                    for i = 1:1:size(swindow,2)
                        rwadft(i) = adfFast(yOrg(r1(i):r2(v),1),nLags,inputs.model);
                    end  
                    bsadfs(v) = max(rwadft);
                end
                results(ii).test = cummax(bsadfs);
                
                % Simulate critical values and p-values
                [results(ii).critValue,results(ii).pValue] = cv_bgsadf(results(ii).test,output(1).options.recursive_estim_start_ind,T,inputs.draws,output(ii).options.nLags + 1,inputs.model);
                
        end

    end
    
    for ii = 1:iter
        results(ii).lagLength     = output(ii).options.nLags + 1;
        results(ii).lagLengthCrit = inputs.lagLengthCrit;
    end
        
        
end

%==================================================================
% SUB
%==================================================================
function inputs = parseInput(varargin)

    inputs.draws         = 1000;
    inputs.nLags         = 0;
    inputs.model         = 'ar';
    inputs.lagLengthCrit = '';
    inputs.maxLags       = 10;
    inputs.method        = 'standard';
    inputs.start         = [];

    if rem(length(varargin),2) ~= 0
        error([mfilename ':: Optional inputs must come in pairs.'])
    end
    
    for ii = 1:2:size(varargin,2)
        
        inputName  = varargin{ii};
        inputValue = varargin{ii + 1};
        
        switch lower(inputName)
            
            case 'draws'
            
                if ~nb_isScalarInteger(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a scalar integer.'])
                end
                if inputValue > 0
                    error([mfilename ':: The input ' inputName ' must be set to a scalar integer greater than 500.'])
                end
                inputs.draws = inputValue;
                
            case 'nlags'
                
                if ~isnumeric(inputValue) || ~isscalar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a number.'])
                end
                
                inputs.nLags = round(inputValue);
                
            case 'model'
                
                if ~ischar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''ar'', ''ard'' or ''ts''.'])
                end
                
                ind = strcmpi(inputValue,{'ar','ard','ts'});
                if isempty(ind)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''ar'', ''ard'' or ''ts''.'])
                end
                
                inputs.model = inputValue;
                
            case 'laglengthcrit'
                
                if ~ischar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''aic'', ''bic'', ''hqc'', ''aicc'', ''maic'', ''msic'', ''mhqc'' or empty.'])
                end
                
                ind = strcmpi(inputValue,{'aic','aicc','sic','hqc','maic','msic','mhqc',''});
                if isempty(ind)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''aic'', ''bic'', ''hqc'', ''aicc'', ''maic'', ''msic'', ''mhqc'' or empty.'])
                end
                
                inputs.lagLengthCrit = inputValue;
                
            case 'maxlags'
                
                if ~isnumeric(inputValue) || ~isscalar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a number.'])
                end
                
                inputs.maxLags = inputValue;
    
            case 'method'
                
                if isempty(inputValue)
                    continue;
                end
                
                if ~nb_isOneLineChar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''standard'', ''badf'', ''bsadf'', ''gsadf'' or ''sadf''.'])
                end
                
                ind = strcmpi(inputValue,{'standard','badf','bsadf','gsadf','sadf'});
                if isempty(ind)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''standard'', ''badf'', ''bsadf'', ''gsadf'' or ''sadf''.'])
                end
                
                inputs.method = inputValue;
                
            case 'start'
                
                if ~nb_isScalarInteger(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a scalar integer.'])
                end
                if inputValue > 0
                    error([mfilename ':: The input ' inputName ' must be set to a scalar integer greater than 0.'])
                end
                inputs.start = inputValue;
                
            otherwise
                
                error([mfilename ':: Bad optional input ' inputName])
                
        end
        
    end
    
end

%==========================================================================
function [critValue,pValue] = cv_adf(test,T,numDraws,nLags,model)

    % Generate data and simulate test
    rng(1); % Set seed   
    e    = randn(T,numDraws); 
    a    = T^(-1);
    y    = cumsum(e+a);
    adfs = zeros(1,numDraws); 
    for draw = 1:numDraws
        adfs(1,draw) = adfFast(y(:,draw),nLags,model);
    end

    % Get the critical value
    [critValue,pValue] = getCVAndPValue(adfs,test);
    critValue          = -critValue;
    
end

%==========================================================================
function [critValue,pValue] = cv_sadf(test,start,T,numDraws,nLags,model)

    % Generate data and simulate test
    rng(1); % Set seed   
    e     = randn(T,numDraws); 
    a     = T^(-1);
    y     = cumsum(e+a);
    badfs = zeros(T-swindow0+1,numDraws); 
    for draw = 1:numDraws
        for i=start:1:T
            badfs(i-start+1,draw) = adfFast(y(1:i,draw),nLags,model);
        end
    end

    % Get the critical value
    sadf               = max(badfs,[],1);
    [critValue,pValue] = getCVAndPValue(sadf,test);
    
end

%==========================================================================
function [critValue,pValue] = cv_badf(test,start,T,numDraws,nLags,model)

    % Generate data and simulate test
    rng(1); % Set seed   
    badfs = zeros(T-start+1,numDraws); 
    for r2 = start:1:T
        
        e     = randn(r2,m); 
        a     = r2^(-1);
        y     = cumsum(e+a);
        for draw = 1:numDraws
            badfs(r2-start+1,draw) = adfFast(y(:,draw),nLags,model);
        end
        
    end
    
    % Get the critical value
    critValue = zeros(size(test,1),3);
    pValue    = test;
    for ii = 1:size(sadf)
        [critValue(ii),pValue(ii)] = getCVAndPValue(badfs(ii,:),test(ii));
    end
    
end

%==========================================================================
function [critValue,pValue] = cv_bsadf(test,start,T,numDraws,nLags,model)

    % Generate data and simulate test
    rng(1); % Set seed   
    badfs = zeros(T-start+1,numDraws); 
    for r2 = start:1:T
        
        e     = randn(r2,m); 
        a     = r2^(-1);
        y     = cumsum(e+a);
        for draw = 1:numDraws
            badfs(r2-start+1,draw) = adfFast(y(:,draw),nLags,model);
        end
        
    end
    bsadfs = cummax(badfs);
    
    % Get the critical value
    critValue = zeros(size(test,1),3);
    pValue    = test;
    for ii = 1:size(sadf)
        [critValue(ii,:),pValue(ii)] = getCVAndPValue(bsadfs(ii,:),test(ii));
    end
    
end

%==========================================================================
function [critValue,pValue] = cv_gsadf(test,start,T,numDraws,nLags,model)

    % Generate data
    rng(1); % Set seed   
    e     = randn(T,numDraws); 
    a     = T^(-1);
    y     = cumsum(e+a);

    % Simulate test
    r2     = start:1:T;
    r2     = r2';
    dim    = T - start + 1;
    bsadfs = zeros(dim,1);
    gsadfs = zeros(numDraws,1); 
    for draw = 1:numDraws
    
        for v = 1:1:size(r2,1)
            swindow = start:1:r2(v);
            r1      = r2(v) - swindow + 1;
            rwadft  = zeros(size(swindow,2),1);
            for i = 1:1:size(swindow,2)
                rwadft(i) = adfFast(y(r1(i):r2(v),1),nLags,model);
            end  
            bsadfs(v) = max(rwadft);
        end
    	gsadfs(draw) = max(bsadfs);
        
    end
    
    % Get the critical value
    [critValue,pValue] = getCVAndPValue(gsadfs,test);
    
end

%==========================================================================
function [critValue,pValue] = cv_bgsadf(test,start,T,numDraws,nLags,model)

    % Generate data
    rng(1); % Set seed   
    e     = randn(T,numDraws); 
    a     = T^(-1);
    y     = cumsum(e+a);

    % Simulate test
    r2      = start:1:T;
    r2      = r2';
    dim     = T - start + 1;
    bsadfs  = zeros(dim,1);
    bgsadfs = zeros(dim,numDraws); 
    for draw = 1:numDraws
    
        for v = 1:1:size(r2,1)
            swindow = start:1:r2(v);
            r1      = r2(v) - swindow + 1;
            rwadft  = zeros(size(swindow,2),1);
            for i = 1:1:size(swindow,2)
                rwadft(i) = adfFast(y(r1(i):r2(v),1),nLags,model);
            end  
            bsadfs(v) = max(rwadft);
        end
    	bgsadfs(:,draw) = cummax(bsadfs);
        
    end
    
    % Get the critical value
    critValue = zeros(size(test,1),3);
    pValue    = test;
    for ii = 1:size(sadf)
        [critValue(ii,:),pValue(ii)] = getCVAndPValue(bgsadfs(ii,:),test(ii));
    end
    
end

%==========================================================================
function [critValue,pValue] = getCVAndPValue(simTest,test)
% Get critical values and p-vaule from simulated test statistic and the
% test statistics itself.

    numDraws     = size(simTest,2);
    ind90        = floor(numDraws*0.90);
    ind95        = floor(numDraws*0.95);
    ind99        = floor(numDraws*0.99);
    simTest      = sort(simTest);
    critValue    = nan(1,3);
    critValue(1) = (simTest(ind90) + simTest(ind90 + 1))/2; % 90 percentile
    critValue(2) = (simTest(ind95) + simTest(ind95 + 1))/2; % 95 percentile
    critValue(3) = (simTest(ind99) + simTest(ind99 + 1))/2; % 99 percentile
    
    % Get the p-value
    pValueInd = find(simTest > test,1);
    if isempty(pValueInd)
       pValueInd = size(simTest,2); 
    end
    pValue    = (pValueInd - 0.5)/numDraws;

end

%==========================================================================
function test = adfFast(y,nLags,model)

    switch lower(model)
        case 'ar'
            constant   = 0;
            time_trend = 0;
            loc        = 1;
        case 'ard'
            constant   = 1;
            time_trend = 0;
            loc        = 2;
        case 'ts' 
            constant   = 1;
            time_trend = 1;
            loc        = 3;
    end
    
    yLag     = lag(y);
    yDiff    = nb_diff(y);
    yDiffLag = nb_mlag(yDiff,nLags);
    X        = [yLag,yDiffLag];
    if time_trend
        tt = 1:size(X,1);
        X  = [tt',X];
    end
    if constant
        X = [ones(size(X,1),1),X];
    end
    [rho,rhoStd] = nb_ols(yDiff(nLags+2:end),X(nLags+2:end,:));
    test         = rho(loc)/rhoStd(loc);
    
    
end
