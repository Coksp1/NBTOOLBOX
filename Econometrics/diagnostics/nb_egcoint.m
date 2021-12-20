function [results,model] = nb_egcoint(y,varargin)
% Syntax:
%
% results         = nb_egcoint(y)
% [results,model] = nb_egcoint(y,varargin)
%
% Description:
%
% Engle-Granger cointegration test. Using Dickey-Fuller test for 
% unit root of the  residual from the cointegration equation
% y1 = X*a + Y2*b + e.
%
% All the variables in the input y vil be included in the 
% cointegration test equation.
% 
% Input:
% 
% - y               : An nb_ts object.
%
% Optional input:
%
% - 'dependent'     : The variable which are decleared as the 
%                     left-hand side variable of the cointegration 
%                     test equation. As a string.
%
% - 'test'          : Either:
%
%                     > 'adf' : Dickey-Fuller test.
%
% - 'nLags'         : Sets the number of lags of the estimated 
%                     residual model to base the test upon. Default 
%                     is 0. ('adf')
%
% - 'maxLags'       : Sets the maximum number of lags used by the
%                     lag length criteria. Default is 10. ('adf')
%
% - 'lagLengthCrit' : Lag length selection criterion ('adf'). 
%                     Either:
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
% - 'model'         : y1 = X*a + Y2*b + e ('c' is default):
%
%                     > 'nc'  : No constant or trend in X.
% 
%                     > 'c'   : Constant but no trend in X.
% 
%                     > 'ct'  : Constant and linear trend in X.
% 
%                     > 'ctt' : Constant, linear trend, and 
%                               quadratic trend in X.
% 
% Output:
% 
% - results : A struct with the estimation and test results: 
% 
%   > rhoTTest      : T-statisticts of the estimated coefficient 
%                     of the lag. ('adf')
%
%   > rhoPValue     : P-value of the estimated coefficient of the 
%                     lag. Compared to the critical values for the 
%                     (spurious regression adjusted) Dickey-Fuller 
%                     Test. ('adf')
%
%   > rhoCritValue  : The rhoTTest critical values for significance 
%                     level 0.1, 0.05 and 0.01. A 1 x 3 double.
%                     If rhoTTest > these critical values you can
%                     reject the null hypothesis of a unit root (of
%                     the residual) at the given significance 
%                     level. ('adf')
%
%   > cointVec      : The cointegrated vector. Will include the 
%                     a as well. I.e. [a,b].
%
% - model  : The estimated equation as 1 x 2 struct. See the output
%            of the nb_olsEstimator function for more on these.
%
%            > model(1) : OLS estimation of the cointegration eq.
%
%            > model(2) : OLS estimation of the residual unit root
%                         test eq.
%
% See also:
% nb_cointTest
%
% Written by Kenneth Sæterhagen Paulsen
 
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    opt = parseInput(varargin{:});
    if isempty(opt.dependent)
        opt.dependent = y.variables(1);
    end
    
    % Get the cointegration test eq. options
    %--------------------------------------------------------------
    switch lower(opt.model)
        
        case 'nc'
            
            constant      = 0;
            time_trend    = 0;
            time_trend_sq = 0;
            
        case 'c'
            
            constant      = 1;
            time_trend    = 0;
            time_trend_sq = 0;
            
        case 'ct'
            
            constant      = 1;
            time_trend    = 1;
            time_trend_sq = 0;
            
        case 'ctt'
            
            constant      = 1;
            time_trend    = 1;
            time_trend_sq = 1;
            
        otherwise
            error([mfilename ':: The model ' opt.model ' is not supported.'])
    end
    
    exogenous = setdiff(y.variables,opt.dependent);
    
    % Add quadratic time trend if wanted
    if time_trend_sq
        
        exogenous = ['time_trend^2',exogenous];
        y         = addVariable(y,y.startDate,(1:y.numberOfObservations).^2,'time_trend^2');
        
    end
    
    % Estimate the cointegration test eq.
    %--------------------------------------------------------------
    opt1               = nb_olsEstimator.template();
    opt1.constant      = constant;
    opt1.time_trend    = time_trend;
    opt1.dependent     = opt.dependent;
    opt1.exogenous     = exogenous;
    opt1.data          = y.data;
    opt1.dataStartDate = y.startDate.toString();
    opt1.dataVariables = y.variables;
        
    [results1,options1] = nb_olsEstimator.estimate(opt1);
    model.results       = results1;
    model.options       = options1;
    
    % Estimate the unit root test equation
    %--------------------------------------------------------------
    residual = nb_olsEstimator.getResidual(results1,options1);
    switch lower(opt.test)
        
        case 'adf'
            
            [results,model(2)] = nb_adf(residual,...
                                    'nLags',        opt.nLags,...
                                    'maxLags',      opt.maxLags,...
                                    'lagLengthCrit',opt.lagLengthCrit);
              
            T = model(2).results.includedObservations;   
            k = size(exogenous,2);
            if time_trend_sq
                k = k - 1;
            end
            
            % Get the critical value of the test statistic 
            if exist('nb_getCointPValue.m','file')
                [results.rhoPValue,results.rhoCritValue] = nb_getCointPValue(opt.model,'t1',T,k,results.rhoTTest);   
            else
                results.rhoPValue    = nan;
                results.rhoCritValue = nan(1,3);
            end   
            results = rmfield(results,{'Zdf','ZdfPValue','ZdfCritValue'});
            
            % Add the cointegrating vector to the results
            results.cointVec      = results1.beta;
            results.stdCointVec   = results1.stdBeta;
            results.tStatCointVec = results1.tStatBeta;
            results.pValCointVec  = results1.pValBeta;
            
            %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            % To do:
            %
            % Robust test statistics when z and u are correlated.
            % See page 608-610 in Hamilton (1994).
            %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            
        otherwise
            
            error([mfilename ':: Unsupported test ' opt.test '.'])
            
    end
    
end

%==================================================================
% SUB
%==================================================================
function inputs = parseInput(varargin)

    inputs.dependent                 = '';
    inputs.nLags                     = 1;
    inputs.model                     = 'c';
    inputs.lagLengthCrit             = '';
    inputs.maxLags                   = 10;
%     inputs.bandWidth                 = 3;
%     inputs.bandWidthCrit             = '';
%     inputs.freqZeroSpectrumEstimator = 'bartlett';
    inputs.test                      = 'adf';

    if rem(length(varargin),2) ~= 0
        error([mfilename ':: Optional inputs must come in pairs.'])
    end
    
    for ii = 1:2:size(varargin,2)
        
        inputName  = varargin{ii};
        inputValue = varargin{ii + 1};
        
        switch lower(inputName)
            
%             case 'bandwidth'
%                 
%                 if ~isnumeric(inputValue) || ~isscalar(inputValue)
%                     error([mfilename ':: The input ' inputName ' must be set to a number.'])
%                 end
%                 
%                 inputs.bandWidth = inputValue;
                  
%             case 'bandwidthcrit'
%                 
%                 if ~ischar(inputValue)
%                     error([mfilename ':: The input ' inputName ' must be set to a string. Either ''aic'', ''bic'' or ''hqc''.'])
%                 end
%                 
%                 ind = strcmpi(inputValue,{'nw','a',''});
%                 if isempty(ind)
%                     error([mfilename ':: The input ' inputName ' must be set to a string. Either ''nw'', ''a'' or empty.'])
%                 end
%                 
%                 inputs.bandWidthCrit = inputValue;
%                 
%             case 'freqzerospectrumestimator'
%                 
%                 if ~ischar(inputValue)
%                     error([mfilename ':: The input ' inputName ' must be set to a string.'])
%                 end
%                 
%                 inputs.freqZeroSpectrumEstimator = inputValue;
            
            case 'dependent'
                
                if ~ischar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a string.'])
                end
                
                inputs.dependent = {inputValue};

            case 'nlags'
                
                if ~isnumeric(inputValue) || ~isscalar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a number.'])
                end
                
                inputs.nLags = round(inputValue);
                
            case 'model'
                
                if ~ischar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''nc'', ''c'', ''ct'' or ''ctt''.'])
                end
                
                ind = strcmpi(inputValue,{'nc','c','ct','ctt'});
                if isempty(ind)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''nc'', ''c'', ''ct'' or ''ctt''.'])
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
    
            case 'test'
                
                if ~ischar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Only ''adf'' is supported.'])
                end
                
                ind = strcmpi(inputValue,{'adf'});
                if isempty(ind)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Only ''adf'' is supported.'])
                end
                
                inputs.test = inputValue;
                
            otherwise
                
                error([mfilename ':: Bad optional input ' inputName])
                
        end
        
    end
    
end
