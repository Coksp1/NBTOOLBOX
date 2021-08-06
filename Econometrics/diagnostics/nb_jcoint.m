function [results,models] = nb_jcoint(y,varargin)
% Syntax:
%
% results          = nb_jcoint(y)
% [results,models] = nb_jcoint(y,varargin)
%
% Description:
%
% Johansen cointegration test. 
%
% All the variables in the input y vil be included in the 
% cointegration test equation.
%
% There are still some unfinished business here!!!!
% 
% Input:
% 
% - y         : An nb_ts object or a nobs x nVars double.
%
% Optional input:
%
% - 'model'         : (1-L)y(t) = A*B'*y(t-1) + D*x
%                       + B1*(1-L)y(t-1) + ... + Bq*(1-L)y(t-q)
%                       + e(t)
%
%                     Form of A*B'*y(t-1) + D*x
%
%                     > 'H2'  : A*B'*y(t-1). There are no intercepts 
%                               or trends in the cointegrating 
%                               relations and there are no trends 
%                               in the data. This model is only
%                               appropriate if all series have zero 
%                               mean. Default.
%
%                     > 'H1*' : A*(B'*y(t-1) + c0). There are 
%                         	    intercepts in the cointegrating 
%                               relations and there are no trends
%                               in the data. This model is 
%                               appropriate for nontrending data 
%                               with nonzero mean.
%
%                     > 'H1'  : A*(B'*y(t-1) + c0) + c1. There are 
%                               intercepts in the cointegrating 
%                               relations and there are linear 
%                               trends in the data. This is a model 
%                               of "deterministic cointegration," 
%                               where the cointegrating relations 
%                               eliminate both stochastic and 
%                               deterministic trends in the data. 
%                               This is the default value.
%
%                     > 'H*'  : A*(B'*y(t-1) + c0 + d0*t) + c1. 
%                               There are intercepts and linear 
%                               trends in the cointegrating 
%                               relations and there are linear
%                               trends in the data. This is a model 
%                               of "stochastic cointegration," 
%                               where the cointegrating relations 
%                               eliminate stochastic but not 
%                               deterministic trends in the data.
%
%                     > 'H'  : A*(B'*y(t-1) + c0 + d0*t) + c1 + d1*t. 
%                              There are intercepts and linear 
%                              trends in the cointegrating 
%                              relations and there are quadratic
%                              trends in the data. Unless quadratic 
%                              trends are actually present in the 
%                              data, this model may produce good 
%                              in-sample fits but poor 
%                              out-of-sample forecasts.
%
%   'hypo'         : String. Either ('trace' is default): 
%   
%                    > 'trace' : The alternative hypothesis is
%                                H(num). Statistics are:
%
%                               -T*[log(1-lambda(h+1)) + ... + 
%                               log(1-lambda(num))]
%
%                    > 'maxeig'. The alternative hypothesis is
%                                H(h+1).
%
%                                -T*log(1-lambda(h+1))               
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
%                     > ''     : Manually set lag length. Default
% 
% - 'mlresults'     : Give 1 if you want to report the maximal 
%                     likelihood estimates. 
%
% Output:
% 
% - results  : A struct with the estimation and test results: 
% 
%              Test results:
%
%              > lambda    : Eigenvalues. 1 x h double.*
%
%              > eigVec    : The corresponding eigenvectors.
%
%              > testStat  : Test-statistic. 1 x h double.*
%
%              > pValue    : P-values. 1 x h double.*
% 
%              > critValue : Critical values. 3 x h double.* 1%
%                            5% and 10%.               
%
%              *h = Max number of possible cointegrated relations.
%
% - models   : The estimated equation as 1 x 2 struct. See the results
%              output of the nb_olsEstimator.estimate function for more
%              on this output.
%
%              > models(1) : OLS estimation of the differenced eq.
%
%              > models(2) : OLS estimation of the laged level eq.
%
% See also:
% nb_cointTest
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    opt = parseInput(varargin{:});
    
    % Initialize estimators
    %--------------------------------------------------------------
    options1 = nb_olsEstimator.template;
    options2 = nb_olsEstimator.template;
    
    % Create lag variables
    %--------------------------------------------------------------
    if isa(y,'nb_ts')
    
        num           = y.numberOfVariables;
        vars          = y.variables;
        ylag          = lag(y,1);
        ylag          = addPostfix(ylag,'_lag1');
        ydiff         = diff(y,1);
        ydiff         = addPrefix(ydiff,'diff_');
        ylagdiff      = lag(ydiff,1);
        ylagdiff      = addPostfix(ylagdiff,'_lag1');
        y             = [y,ylag,ydiff,ylagdiff];
        y             = y(3:end,:);
        data          = y.data;
        dataStartDate = toString(y.startDate + 2);
        dataVars      = y.variables;
        
    else
        
        [num,svars]   = size(y);
        vars          = strcat('Var',strtrim(cellstr(int2str([1:svars]')))); %#ok<NBRAK>
        dataVars      = vars;
        ylag          = lag(y,1);
        dataVars      = [dataVars,strcat(vars,'_lag1')];
        ydiff         = diff(y,1);
        dataVars      = [dataVars,strcat('diff_',vars)];
        ylagdiff      = lag(ydiff,1);
        dataVars      = [dataVars,strcat('diff_', vars,'_lag1')];
        y             = [y,ylag,ydiff,ylagdiff];
        y             = y(3:num,:);
        data          = y;
        dataStartDate = '3';
        
    end
    
    % Get start estimation index
    if ~isempty(opt.lagLengthCrit)
        estStartInd = opt.maxLags + 1;
    else
        estStartInd = opt.nLags;
    end
    
    % Get the cointegration test eq. options
    %--------------------------------------------------------------
    endo1 = strcat('diff_',vars);
    endo2 = strcat(vars,'_lag1');
    exo   = strcat('diff_',vars,'_lag1');
    switch lower(opt.model)
        
        case 'h2'
        
            cons1       = 0;
            cons2       = 0;
            time_trend1 = 0;
            time_trend2 = 0;

        case 'h1*'

            % Restricted constant
            cons1       = 0;
            cons2       = 1;
            time_trend1 = 0;
            time_trend2 = 0;

        case 'h1'

            % Unrestricted constant
            cons1       = 1;
            cons2       = 0;
            time_trend1 = 0;
            time_trend2 = 0;

        case 'h*'

            % Restricted linear term and unrestricted constant
            cons1       = 1;
            cons2       = 0;
            time_trend1 = 0;
            time_trend2 = 1;

        case 'h'

            % Unrestricted constant, linear term
            cons1       = 1;
            cons2       = 0;
            time_trend1 = 1;
            time_trend2 = 0;
            
        otherwise
            error([mfilename ':: The model ' opt.model ' is not supported.'])
    end
    
    % Estimate the first step equations
    %--------------------------------------------------------------
    if isempty(opt.lagLengthCrit)
        modelSelection = '';
    else
        modelSelection = 'lagLength';
    end

    options1.constant        = cons1;
    options1.criterion       = opt.lagLengthCrit;
    options1.time_trend      = time_trend1;
    options1.dependent       = endo1;
    options1.exogenous       = exo;
    options1.data            = data;
    options1.dataStartDate   = dataStartDate;
    options1.dataVariables   = dataVars;
    options1.modelSelection  = modelSelection;
    options1.nLags           = opt.nLags-1;
    options1.maxLagLength    = opt.maxLags;
    options1.estim_start_ind = estStartInd;
        
    [results1,options1] = nb_olsEstimator.estimate(options1);
    
    tempNLags = options1.nLags;
    if tempNLags == -1
        error([mfilename ':: Test failed. All regressors removed in the first step of the johansen test. Choose the lag length manually.'])
    end
    
    options2.constant        = cons2;
    options2.time_trend      = time_trend2;
    options2.dependent       = endo2;
    options2.exogenous       = exo;
    options2.data            = data;
    options2.dataStartDate   = dataStartDate;
    options2.dataVariables   = dataVars;
    options2.nLags           = tempNLags;
    options2.estim_start_ind = estStartInd;
        
    [results2,options2] = nb_olsEstimator.estimate(options2);
    
    nLags = options2.nLags + 1; 
    
    % Assign output of the estimated models
    models(1).results = results1;
    models(2).results = results2;
    models(1).options = options1;
    models(2).options = options2;
    
    % Second step: Calculate canonical correlations
    %--------------------------------------------------------------
    u = results1.residual;
    v = results2.residual;
    T = size(u,1);
    
    omegaUU = u'*u/T;
    omegaVV = v'*v/T;
    omegaUV = u'*v/T;
    omegaVU = omegaUV';
    omega   = (omegaVV\omegaVU)*(omegaUU\omegaUV);
    
    % Calculate the eigenvalues/eigenvectors (and order them from
    % greates to smallest)
    [eigVec,lambda] = eig(omega);
    lambda          = diag(lambda);
    [lambdaS,~]     = sort(lambda,'descend');
    
    % Max number of cointegrated vectors to test for is 10.
    numC = min(10,num);
    
    % Calculate the log likelihood
    lambda1 = log(abs(1 - lambdaS(1:numC)));

    % Compute statistics for cointegration ranks r = 0, ..., num-1:
    switch lower(opt.hypo)

        case 'trace' 
            
            % -T*[log(1-lambda(h+1)) + ... + log(1-lambda(num))]
            testStat = -T*flipud(cumsum(flipud(lambda1)));

        case 'maxeig' 

            % -T*log(1-lambda(h+1))
            testStat = -T*lambda1;

    end
    
    % Compute p-value
    testStat         = testStat';
    if false%exist('nb_getJCointPValue.m','file')
        [pValue,critVal] = nb_getJCointPValue(opt.model,opt.hypo,testStat);
    else
        pValue  = nan;
        critVal = nan(1,3);
    end
    
    % Assign output
    results               = struct();
    results.lambda        = lambda;
    results.eigVec        = eigVec;
    results.testStat      = testStat;
    results.pValue        = pValue;
    results.critValue     = critVal;
    results.lagLength     = nLags;
    results.lagLengthCrit = opt.lagLengthCrit;
    results.model         = opt.model;
    results.hypo          = opt.hypo;
    
    % Third step: ML estimation
    %
    % Not finished!!!!
    %--------------------------------------------------------------
%     if opt.mlResults
%     
%         eigVec = eigVec(:,ind); 
% 
%         % eigVec diagonalizes omegaVV
%         U      = eigVec'*omegaVV*eigVec; 
%         eigVec = bsxfun(@rdivide,eigVec,sqrt(diag(U))');
%         
%         P = model(1).results.beta(1+cons1:end,:);
%         if cons1
%             p = model(1).results.beta(1,:);
%         else
%             p = zeros(1,size(P,2));
%         end
%         F = model(2).results.beta(1+cons2:end,:);
%         if cons2
%             f = model(2).results.beta(1,:);
%         else
%             f = zeros(1,size(F,2));
%         end
%         
%         % Get ML estimates of:
%         %
%         % diff_y = rho1*diff_y_lag1 + ... + rhop*diff_y_lagp
%         %          alpha + rho0*y_lag1 + e
%         rho0  = cell(1,num - 1);
%         rho   = cell(1,num - 1);
%         alpha = cell(1,num - 1);
%         vcv   = cell(1,num - 1);
%         rhoT  = nan(num*nLags,num);
%         for h = 1:num - 1
%             
%             rho0T = omegaUV*eigVec(:,1:h)*eigVec(:,1:h)';
%             for ii = 1:nLags
%                 ind         = (1:num) + num*(ii-1);
%                 rhoTT       = P(ind,:)' - rho0T*F(ind,:)';
%                 rhoT(ind,:) = rhoTT'; 
%             end
%             
%             alpha{h} = (p' - rho0T*f')';
%             res      = u - v*rho0T;
%             T        = size(res,1);
%             vcv{h}   = res'*res/T;
%             rho0{h}  = rho0T;
%             rho{h}   = rhoT;
%             
%         end
%         
%         % Assign output
%         results.rho0  = rho0;
%         results.rho   = rho;
%         results.alpha = alpha;
%         results.vcv   = vcv;
%         
%     end
    
end

%==================================================================
% SUB
%==================================================================
function inputs = parseInput(varargin)

    inputs.nLags         = 1;
    inputs.model         = 'h2';
    inputs.lagLengthCrit = '';
    inputs.maxLags       = 10;
    inputs.hypo          = 'trace';
    inputs.mlResults     = 1;

    if rem(length(varargin),2) ~= 0
        error([mfilename ':: Optional inputs must come in pairs.'])
    end
    
    for ii = 1:2:size(varargin,2)
        
        inputName  = varargin{ii};
        inputValue = varargin{ii + 1};
        
        switch lower(inputName)
            
            case 'nlags'
                
                if ~isnumeric(inputValue) || ~isscalar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a number.'])
                end
                
                inputs.nLags = inputValue;
                
            case 'mlresults'
                
                if ~isnumeric(inputValue) || ~islogical(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to 1 (true) or 0 (false).'])
                end
                
                inputs.mlResults = inputValue;
                
            case 'model'
                
                if ~ischar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''h2'', ''h1*'', ''h1'', ''h*'' or ''h''.'])
                end
                
                ind = strcmpi(inputValue,{'h2','h1*','h1','h*','h'});
                if isempty(ind)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''h2'', ''h1*'', ''h1'', ''h*'' or ''h''.'])
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
    
            case 'hypo'
                
                if ~ischar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''trace'' or ''maxeig''.'])
                end
                
                ind = strcmpi(inputValue,{'trace','maxeig'});
                if isempty(ind)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''trace'' or ''maxeig''.'])
                end
                
                inputs.hypo = inputValue;    
                
            otherwise
                
                error([mfilename ':: Bad optional input ' inputName])
                
        end
        
    end
    
end

