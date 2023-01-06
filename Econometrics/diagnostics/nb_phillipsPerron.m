function [results,model] = nb_phillipsPerron(y,varargin)
% Syntax:
%
% results = nb_phillipsPerron(y)
% [results,model] = nb_phillipsPerron(y,varargin)
%
% Description:
%
% Phillips-Perron tests for unit roots.
% 
% Input:
% 
% - y               : An nb_ts object.
%
% Optional input:
%
% - 'bandWidth'     : The selected band width of the frequency zero
%                     spectrum estimation. Default is to use the
%                     Newey-West selection criterion.
%
% - 'bandWidthCrit' : Band with selection criterion. Either:
%
%                     > 'nw'   : Newey-West selection method. 
%                                Default. (Newey West,1994)
%
%                     > 'a'    : Andrews selection method.
%                                (Andrews, 1991)
%
% - 'freqZeroSpectrumEstimator' : 
%
%                     Either:
%
%                     > 'bartlett'  : Bartlett kernel function.
%                                     Default.
%
%                     > 'parzen'    : Parzen kernel function.
%
%                     > 'quadratic' : Quadratic Spectral kernel
%                                     function.
%
% - 'model'         : Either:
%
%   > 'ar'  : y(t) = rho*y(t-1) + e(t) (Default)
% 
%   > 'ard' : y(t) = alpha + rho*y(t-1) + e(t)
% 
%   > 'ts'  : y(t) = alpha + delta*t + rho*y(t-1) + e(t)
% 
% Output:
%
% - results : A struct with the estimation and test results
%             (See page 514 in Hamilton):
%
%   > Zt            : Zt test statistics. 
%
%   > ZtPValue      : P-value of the Zt test statistics. 
%
%   > ZtCritValue   : The Zt critical values for significance 
%                     level 0.1, 0.05 and 0.01. A 1 x 3 double.
%                     If Zdf > these critical values you can
%                     reject the null hypothesis of a unit root at  
%                     the given significance level.
%
% - model  : The estimated equation as a struct with fields results and
%            options. See the nb_olsEstimator.estimate function for more.
%
% See also:
% nb_unitRootTest
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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
    
    % Construct the needed variables
    %--------------------------------------------------------------
    if isnumeric(y)
        
        [T,N,P] = size(y);
        if P > 1
            error([mfilename ':: This function is not defined for multi-paged double objects.'])
        end
        
        dof = 11;
        if ~isempty(inputs.bandWidthCrit)      
            if T < 9 + dof
                error([mfilename ':: The input data must have at least ' int2str(9 + dof) ' periods.'])
            end 
        else
            if T < inputs.bandWidth + dof
                error([mfilename ':: The input data must have at least ' int2str(inputs.bandWidth + dof) ' periods.'])
            end 
        end
        
        startDate = '1';
        tempVars  = strcat('Var',strtrim(cellstr(int2str([1:N]')))); %#ok<NBRAK>
        iter      = N;
        ylag      = lag(y);
        ydiff     = [nan;diff(y)];
        y         = [y,ylag,ydiff];
        y         = y(2:T,:);
        yVars     = [tempVars, strcat(tempVars,'_lag1'),strcat('diff_',tempVars)];
        
    else
        
        if y.numberOfDatasets > 1
            error([mfilename ':: This function is not defined for multi-paged nb_ts objects.'])
        end

        dof = 11;
        if ~isempty(inputs.bandWidthCrit)
            if y.numberOfObservations < 9 + dof
                error([mfilename ':: The input data must have at least ' int2str(9 + dof) ' periods.'])
            end 
        else
            if y.numberOfObservations < inputs.bandWidth + dof
                error([mfilename ':: The input data must have at least ' int2str(inputs.bandWidth + dof) ' periods.'])
            end 
        end
        
        startDate = y.startDate.toString();
        tempVars  = y.variables;
        iter      = y.numberOfVariables;
        ylag      = lag(y);
        ylag      = addPostfix(ylag,'_lag1');
        ydiff     = diff(y);
        ydiff     = addPrefix(ydiff,'diff_');
        y         = [y,ylag,ydiff];
        fin       = y.numberOfObservations;
        yVars     = y.variables;
        y         = y.data;
        y         = y(2:fin,:);
        
    end
    
    % Set up the model and estimated the test equations
    %--------------------------------------------------------------
    model(iter).results = [];
    model(iter).options = [];
    for ii = 1:iter % Number of variables
    
        % Set the options for the estimation
        tempVar             = tempVars{ii};
        dependent           = {['diff_' tempVar]};
        exogenous           = {[tempVar '_lag1'],};
        
        tempOpt = nb_olsEstimator.template();
        tempOpt.constant      = constant;
        tempOpt.data          = y;
        tempOpt.dataStartDate = startDate;
        tempOpt.dataVariables = yVars;
        tempOpt.time_trend    = time_trend;
        tempOpt.dependent     = dependent;
        tempOpt.exogenous     = exogenous;
        tempOpt.doTests   = 0;
        
        % Estimate model
        [model(ii).results,model(ii).options] = nb_olsEstimator.estimate(tempOpt);
        
    end
    
    % Set up the test statistics
    %--------------------------------------------------------------
    T       = model(1).results.includedObservations;
    results = struct();
    ind     = find(strcmpi(inputs.model,{'ar','ard','ts'}),1);
    if isempty(ind)   
        error([mfilename ':: Unsupported type ' inputs.type])   
    end
    
    results(iter) = struct();
    for ii = 1:iter
    
        estResults = model(ii).results;
        k          = size(estResults.beta,1);
        beta       = estResults.beta(ind);
        stdBeta    = estResults.stdBeta(ind);
        residual   = estResults.residual;

        [Zt,bandWidth,HAC,resVar] = getTestStatistics(T,k,residual,beta,stdBeta,inputs.bandWidth,inputs.bandWidthCrit,inputs.freqZeroSpectrumEstimator);
        results(ii).Zt = Zt;
        
        if exist('nb_getUnitRootPValue.m','file')
            [results(ii).ZtPValue,results(ii).ZtCritValue] = nb_getUnitRootPValue(lower(inputs.model),'t1',T,results(ii).Zt);
        else
            results(ii).ZtPValue    = nan;
            results(ii).ZtCritValue = nan(1,3);
        end
        results(ii).bandWidth        = bandWidth;
        results(ii).bandWidthCrit    = inputs.bandWidthCrit;
        results(ii).HAC              = HAC;
        results(ii).residualVariance = resVar;
        results(ii).kernel           = inputs.freqZeroSpectrumEstimator;
        
    end
    
end

%==================================================================
% SUB
%==================================================================
function inputs = parseInput(varargin)

    inputs.bandWidth                 = 3;
    inputs.model                     = 'ar';
    inputs.bandWidthCrit             = '';
    inputs.freqZeroSpectrumEstimator = 'bartlett';

    for ii = 1:2:size(varargin,2)
        
        inputName  = varargin{ii};
        inputValue = varargin{ii + 1};
        
        switch lower(inputName)
            
            case 'bandwidth'
                
                if ~isnumeric(inputValue) || ~isscalar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a number.'])
                end
                
                inputs.bandWidth = inputValue;
                
            case 'model'
                
                if ~ischar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''ar'', ''ard'' or ''ts''.'])
                end
                
                ind = strcmpi(inputValue,{'ar','ard','ts'});
                if isempty(ind)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''ar'', ''ard'' or ''ts''.'])
                end
                
                inputs.model = inputValue;
                
            case 'bandwidthcrit'
                
                if ~ischar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''nw'', ''a'' or empty.'])
                end
                
                ind = strcmpi(inputValue,{'nw','a',''});
                if isempty(ind)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''nw'', ''a'' or empty.'])
                end
                
                inputs.bandWidthCrit = inputValue;
                
            case 'freqzerospectrumestimator'
                
                if ~ischar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a string.'])
                end
                
                inputs.freqZeroSpectrumEstimator = inputValue;
    
            otherwise
                
                error([mfilename ':: Bad optional input ' inputName])
                
        end
        
    end
    
end

function [Zt,bandWidth,HAC,resVar] = getTestStatistics(T,k,residual,beta,stdBeta,bandWidth,bandWidthCrit,freqZeroSpectrumEstimator)
% Get the phillips-peron test statistics
%
% (See Hamilton page 514 for the calculations)

    % Get gamma and lambda square 
    [lambdaSq,gamma,bandWidth] = nb_zeroSpectrumEstimation(residual,freqZeroSpectrumEstimator,bandWidth,bandWidthCrit);
    
    % Calaculate the test statistics
    lambda = sqrt(lambdaSq);
    s      = sqrt(residual'*residual/(T - k));
    Zt     = (sqrt(gamma(1)/lambdaSq))*(beta/stdBeta) - (T*(lambdaSq - gamma(1))*stdBeta)/(2*s*lambda);
    HAC    = lambdaSq;
    resVar = gamma(1);
    
end

