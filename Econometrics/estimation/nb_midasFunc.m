function [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD,t,tPerc,k] = ...
    nb_midasFunc(y,x,constant,AR,type,nSteps,stdType,nExo,nLags,varargin)
% Syntax:
%
% beta = nb_midasFunc(y,x)
% [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD,t,tPerc,k] = ...
%       nb_midasFunc(y,x,constant,type,nSteps,stdType,nExo,nLags,varargin)
%
% Description:
%
% Estimate MIDAS model.
%
% y = x*f(beta) + eps, eps ~ N(0,eps'*eps/nobs) (1)
%
% Input:
% 
% - y        : A double matrix of size nobs x 1 of the dependent 
%              variable of the regression(s). 
%
% - x        : A double matrix of size nobs x nxvar of the right  
%              hand side variables of all equations of the 
%              regression. These are of a higher frequency than y. Lags of
%              regressors should already be added. The nExo input must be 
%              set.
%
%              The order of the regressors must be;
%              var1_lag1, var2_lag1, var1_lag2, var2_lag2, var1_lag3
%              i.e. they can have different number of lags. See the 
%              nLags input!
%
% - constant : true or false. If true a constant is included.
%
% - AR       : true or false. Indicate that you are estimating a AR
%              specification of the MIDAS model.
%
% - type     : The type of MIDAS model to estimate. Either; 'unrestricted' 
%              'lasso', 'ridge','beta', 'legendre', 'mean' or 'almon'. If  
%              set to 'beta' profiling is used, if set to 'lasso' it is 
%              estimated using nb_lasso, if set to 'ridge' it is 
%              estimated using nb_ridge, otherwise OLS (nb_ols) is used.
%
% - nSteps   : Add leads to make the MIDAS models able to produce direct 
%              forecast longer than 1 period forward. Default is 1. Must be
%              an integer larger than 0.
%
% - stdType  : - 'w'    : Will return White heteroskedasticity
%                         robust standard errors. 
%              - 'nw'   : Will return Newey-West heteroskedasticity
%                         and autocorrelation robust standard errors.
%                          
%                         To estimate the covariance matrix of the
%                         estimated parameters the bartlett kernel is 
%                         used with the bandwidth set to 
%                         floor(4(T/100)^(2/9)) as Eviews also uses.
%
%              - 'h'    : Will return homoskedasticity only
%                         robust standard errors. Default.
%
% - nExo     : Number of exogenous variables excluding the lags.
%
% - nLags    : Either a scalar integer with the number of lags of all the
%              regressors, or a vector of integers with length nExo with 
%              the number of lags of each regressor. Default is 1!
%
% Optional inputs:
%
% - 'draws'                : Number of draws from the parameter  
%                            distribution when bootsrapping the standard  
%                            error of the parameters. Not supported for 
%                            type set to 'lasso'. 
%
% - 'polyLags'             : The number of polynomial lags to use when type 
%                            is set to 'legendre' or 'almon'. Either as a  
%                            scalar integer or a vector of integers with 
%                            length nExo.
%
% - 'optimset'              : Optimization options. As a struct. See 
%                             nb_lasso.optimset. Only use when type input  
%                             is set to 'lasso'.
%
% - 'regularization'        : The value of t in the LASSO minimization  
%                             problem. Default is inf. For more see the
%                             nb_lasso function.
%
%                             Or the value of k in the RIDGE minimization  
%                             problem. For more on this input, and its
%                             default value see the function nb_ridge.
% 
%                             Must be a scalar number greater or equal to 
%                             0. Only use when type input is set to 
%                             'lasso' or 'ridge'. 
%
% - 'regularizationPerc'    : Instead of setting the L1 or L2    
%                             regularization of the problem, you can use   
%                             this option to set the L1 or L2  
%                             regularization as a percentage of 
%                             unrestricted MIDAS. Must be set to a 
%                             scalar double in (0,1). If not empty, the   
%                             'regularization' input is ignored!
%
%                             This input sets the 'tPerc' input to the 
%                             nb_lasso function, and sets the 'cPerc'
%                             input to the nb_ridge function.
%
% - 'regularizationMode'    : If set to 'lagrangian', the 'regularization'
%                             input is taken as the lambda (multiplier)
%                             of the lagrangian of the LASSO problem. For
%                             more details see nb_lasso.
%
% - 'restrictConstant'      : Restrict estimate of constant term to OLS 
%                             estimate. true or false. Default is true.
%                             Applies only to type set to 'lasso' or 
%                             'ridge'.
%
% - 'remove'                : Rows to remove from the estimation problem.
%                             As a nobs x 2 logical array. The first 
%                             column specifies the rows of the dependent
%                             variable that includes data points needed to
%                             be removed, while the second column included
%                             the rows of the regressors in X that has
%                             observations to remove. With these two 
%                             columns the removed rows of the estimation
%                             problem for each forecast horizon can be
%                             calculated. Elements to remove should be set  
%                             to false.
%
% Output: 
% 
% - beta       : A nxvar x nSteps matrix with the estimated parameters.
%
% - stdBeta    : A nxvar x nSteps matrix with the standard deviation of the
%                estimated paramteres. 
%
% - tStatBeta  : A nxvar x nSteps matrix with t-statistics of the 
%                estimated paramteres. 
%
% - pValBeta   : A nxvar x nSteps matrix with the p-values of the  
%                estimated paramteres. 
%
% - residual   : Residual from the estimated equation. As an 
%                nobs x nSteps matrix. 
%
% - sigma      : Covariance matrix of estimated residuals. Will be a
%                diagonal matrix with size nSteps x nSteps.
%
% - betaD      : The bootstrapped parameters of the model. As a nxvar x 
%                nSteps x draws double.
%
% - sigmaD     : The bootstrapped covariances of the residuals of the 
%                model. Assumed to be diagonal. As a nSteps x nSteps x 
%                draws double.
%
% - t          : When 'regularizationPerc' input is set, this gives the 
%                implied value of 'regularization', otherwise it will 
%                just return the value provided to the input 
%                'regularization'. Returned as a 1 x nSteps double (i.e. 
%                may be expanded from scalar to vector if nSteps > 1). [] 
%                is returned if type is not set to 'lasso' nor 'ridge'.
%
%                For ridge estimation it will return c, and not k of the
%                minimization problem stated in nb_ridge!
%
% - tPerc      : When 'regularizationPerc' is not provided, this will 
%                return the percentage of unrestricted estimation implied 
%                by the 'regularization' input, otherwise it will just 
%                return the value provided to the 'regularizationPerc' 
%                input. Returned as a 1 x neq double. [] is returned if 
%                type is not set to 'lasso' nor 'ridge'.
%
% - k          : See the output k of the nb_ridge function 
%
% See also
% nb_midasEstimator, nb_midas, nb_lasso, nb_lasso.optimset, nb_ridge, 
% nb_ols 
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 8
        nLags = 1;
        if nargin < 7
            nExo = [];
            if nargin < 6
                stdType = 'h';
                if nargin < 5
                    nSteps = 1;
                    if nargin < 4
                        AR = false;
                        if nargin < 3
                            type = 'unrestricted';
                        end
                    end
                end
            end
        end
    end
    if isempty(nExo)
        error('nExo cannot be empty or not provided!')
    end
    
    yLag = y;
    Y    = nb_mlead(y,nSteps);
    
    % Parse optional inputs for NLS
    default = {'draws',                 1000,  @nb_isScalarNumber;...
               'polyLags',              [],    @(x)nb_iswholenumber(x);...
               'optimset',              [],    @(x)or(isstruct(x),isempty(x));...
               'regularization',        [],    @(x)or(isnumeric(x),isempty(x));...
               'regularizationPerc',    [],    @(x)or(isnumeric(x),isempty(x));...
               'regularizationMode',    [],    @(x)or(nb_isOneLineChar(x),isempty(x));...
               'restrictConstant',      [],    @nb_isScalarLogical;...
               'remove',                [],    @(x)or(islogical(x),isempty(x))};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    inputs.AR       = AR;
    inputs.constant = constant;
    inputs.type     = type;
    inputs.nSteps   = nSteps;
    inputs.stdType  = stdType;
    inputs.nExo     = nExo;
    
    % Correct data if we are add an AR term
    switch lower(type)
        
        case {'almon','legendre','mean','unrestricted','lasso','ridge'}
            
            [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD,t,tPerc,k] = ...
                doOLSOrLASSO(inputs,Y,yLag,x,nLags);
                
        case 'beta'
            
            [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD] = ...
                doProfiling(inputs,Y,yLag,x,nLags);

            t     = [];
            tPerc = [];
            k     = [];
            
        otherwise
            error([mfilename ':: Unsupported MIDAS type ''' type '''.'])   
    end
     
    
        
end

%==========================================================================
function [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD,t,tPerc,k] = ...
    doOLSOrLASSO(inputs,Y,yLag,x,nLags)

    AR       = inputs.AR;
    constant = inputs.constant;
    nSteps   = inputs.nSteps;
    nExo     = inputs.nExo;
    
    % Construct the mapping matrix of polynominal lags
    if strcmpi(inputs.type,'almon')
        Q = nb_almonPoly(inputs.polyLags,nLags,nExo); 
    elseif strcmpi(inputs.type,'legendre')
        Q = nb_legendrePoly(inputs.polyLags,nLags,nExo); 
    else
        inputs.polyLags = 1;
    end
    
    % Construct the regressors
    T = size(Y,1);
    if any(strcmpi(inputs.type,{'almon','legendre'}))
      
        P = inputs.polyLags;
        if isempty(P)
            sP = sum(nLags);
        else
            sP = sum(P);
        end
        X        = transpose(Q*x');
        numCoeff = sP + constant + AR;
        
    elseif strcmpi(inputs.type,'mean')
       
        X = nan(T,nExo);
        for ii = 1:nExo
           ind     = nb_getMidasIndex(ii,nLags,nExo);
           X(:,ii) = mean(x(:,ind),2);
        end
        numCoeff = nExo + constant + AR;
        
    else % Unrestricted or LASSO
        X        = x;
        numCoeff = size(x,2) + constant + AR;
    end

    % Preallocation
    draws = inputs.draws;
    if draws > 1
        betaD  = nan(numCoeff,nSteps,draws);
        sigmaD = zeros(nSteps,nSteps,draws);
    else
        betaD  = nan(0,0,0,1);
        sigmaD = nan(0,0,0,1);
    end

    if any(strcmpi(inputs.type,{'lasso','ridge'}))
        tin = inputs.regularization;
        if isempty(tin)
            tin = inf(1,nSteps);
        elseif isscalar(tin)
            tin = tin(1,ones(1,nSteps));
        elseif ~(isvector(tin) && length(tin) == nSteps)
            error(['The ''regularization'' input (regularization coefficient) ' ...
                'must have as many elements as the number of forecasting steps ',...
                'of the MIDAS model, i.e. ', int2str(nSteps) '.'])
        end
        tinPerc = inputs.regularizationPerc;
        if isempty(tinPerc)
            tinPerc = nan(1,nSteps);
        elseif isscalar(tinPerc)
            tinPerc = tinPerc(1,ones(1,nSteps));
        elseif ~(isvector(tinPerc) && length(tinPerc) == nSteps)
            error(['The ''regularizationPerc'' input (regularization as percent of ',...
                'unrestricted estimation) must have as many elements as the ',...
                'number of forecasting steps of the MIDAS model, i.e. ',...
                int2str(nSteps) '.'])
        end
    end
    if strcmpi(inputs.type,'lasso')
        if isempty(inputs.regularizationMode)
            inputs.regularizationMode = 'normal';
        end
    end

    beta      = nan(numCoeff,nSteps);
    stdBeta   = beta;
    tStatBeta = beta;
    pValBeta  = beta;
    sigma     = zeros(nSteps,nSteps);
    residual  = nan(size(Y,1) - 1,nSteps);
    t         = nan(1,nSteps);
    tPerc     = nan(1,nSteps);
    k         = nan(1,nSteps);
    for ii = 1:nSteps
        
        if AR
            if ii == 1
                Xii = [yLag(1:end-ii),X(1:end-ii,:)];
            else
                Xii = [Y(1:end-ii,ii-1),X(1:end-ii,:)];
            end
        else
            Xii = X(1:end-ii,:);
        end
        Yii = Y(1:end-ii,ii);

        if ~isempty(inputs.remove)
            remThisStep = lead(inputs.remove(:,1),ii);
            remThisStep = remThisStep(1:end-ii) & inputs.remove(1:end-ii,2);
            YiiCovid    = Yii(~remThisStep);
            XiiCovid    = Xii(~remThisStep,:);
            if constant
                XiiCovid = [ones(size(XiiCovid,1),1),XiiCovid]; %#ok<AGROW>
            end
            Yii = Yii(remThisStep);
            Xii = Xii(remThisStep,:);
        end

        if strcmpi(inputs.type,'lasso')
            [beta(:,ii),exitflag,res,~,t(ii),tPerc(ii)] = ...
                nb_lasso(Yii,Xii,tin(ii),constant,inputs.optimset,...
                'tPerc',tinPerc(ii),...
                'restrictConstant',inputs.restrictConstant,...
                'mode',inputs.regularizationMode);
            if exitflag < 0
                nb_interpretExitFlag(exitflag,'nb_lasso',[' Failed during ',...
                    'LASSO estimation of MIDAS model at forecasting step ',...
                    int2str(nSteps)])
            end
        elseif strcmpi(inputs.type,'ridge')
            [beta(:,ii),res,~,t(ii),tPerc(ii),k(ii)] = ...
                nb_ridge(Yii,Xii,tin(ii),constant,...
                'cPerc',tinPerc(ii),...
                'restrictConstant',inputs.restrictConstant);
        else
            if constant
                Xii = [ones(size(Xii,1),1),Xii]; %#ok<AGROW>
            end
            [beta(:,ii),stdBeta(:,ii),tStatBeta(:,ii),pValBeta(:,ii),...
                res] = nb_ols(Yii,Xii,false,false,inputs.stdType);
        end

        if isempty(inputs.remove)
            residual(1:end-ii+1,ii) = res;
        else
            resAll                  = nan(size(remThisStep));
            resAll(remThisStep)     = res;
            resAll(~remThisStep)    = YiiCovid - XiiCovid*beta(:,ii);
            residual(1:end-ii+1,ii) = resAll;              
        end

        % Estimate the covariance matrix
        sigma(ii,ii) = res'*res/(size(res,1) - numCoeff);

        % Bootstrap
        if draws > 1 && ~any(strcmpi(inputs.type,{'lasso','ridge'}))
            residSim = nb_bootstrap(res,draws,'bootstrap');
            residSim = permute(residSim,[3,2,1]);
            ysim     = bsxfun(@plus,Xii*beta(:,ii),residSim);
            for dd = 1:draws
                [betaD(:,ii,dd),~,~,~,resid] = nb_ols(ysim(:,dd),Xii,false,false);
                sigmaD(ii,ii,dd)             = resid'*resid/(size(resid,1) - numCoeff);
            end
        end

    end

    if ~any(strcmpi(inputs.type,{'lasso','ridge'}))
        t     = [];
        tPerc = [];
    end
    if ~strcmpi(inputs.type,'ridge')
        k = [];
    end

end

%==========================================================================
function [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD] = doProfiling(inputs,Y,yLag,X,nLags)

    AR       = inputs.AR;
    constant = inputs.constant;
    nSteps   = inputs.nSteps;
    nExo     = inputs.nExo;
    
    % Preallocation
    numCoeff = AR + constant + nExo + 1;
    draws = inputs.draws;
    if draws > 1
        betaD  = nan(numCoeff,nSteps,draws);
        sigmaD = zeros(nSteps,nSteps,draws);
    else
        betaD  = nan(0,0,0,1);
        sigmaD = nan(0,0,0,1);
    end

    beta      = nan(numCoeff,nSteps);
    stdBeta   = beta;
    tStatBeta = beta;
    pValBeta  = beta;
    sigma     = zeros(nSteps,nSteps);
    residual  = nan(size(Y,1) - 1,nSteps);
    T         = size(residual,1);
    for ii = 1:nSteps
        
        if AR
            if ii == 1
                Xii = [yLag(1:end-ii),X(1:end-ii,:)];
            else
                Xii = [Y(1:end-ii,ii-1),X(1:end-ii,:)];
            end
        else
            Xii = X(1:end-ii,:);
        end
        Yii = Y(1:end-ii,ii);

        if ~isempty(inputs.remove)
            remThisStep = lead(inputs.remove(:,1),ii);
            remThisStep = remThisStep(1:end-ii) & inputs.remove(1:end-ii,2);
            YiiCovid    = Yii(~remThisStep);
            XiiCovid    = Xii(~remThisStep,:);
            if constant
                XiiCovid = [ones(size(XiiCovid,1),1),XiiCovid]; %#ok<AGROW>
            end
            Yii = Yii(remThisStep);
            Xii = Xii(remThisStep,:);
        end
        
        [beta(:,ii),res,X_tilda] = nb_betaProfiling(Yii,Xii,constant,AR,nExo,nLags);
        
        if isempty(inputs.remove)
            residual(1:end-ii+1,ii) = res;
        else
            Q       = nb_betaPoly(beta(end,ii),nLags,nExo); 
            X_tilda = transpose(Q*XiiCovid(:,constant + AR + 1:end)');
            X_tilda = [XiiCovid(:,1:constant + AR),X_tilda]; %#ok<AGROW>

            resAll                  = nan(size(remThisStep));
            resAll(remThisStep)     = res;
            resAll(~remThisStep)    = YiiCovid - X_tilda*beta(1:end-1,ii);
            residual(1:end-ii+1,ii) = resAll;              
        end

        % Estimate the covariance matrix
        sigma(ii,ii) = res'*res/(size(res,1) - numCoeff);

        % Bootstrap
        if draws > 1
            
            % Simulate and estimate model for each simulation
            residSim = nb_bootstrap(res,draws,'bootstrap');
            residSim = permute(residSim,[3,2,1]);
            ysim     = bsxfun(@plus,X_tilda*beta(1:end-1,ii),residSim);
            for dd = 1:draws
                [betaD(:,ii,dd),resid] = nb_betaProfiling(ysim(:,dd),Xii,constant,AR,nExo,nLags,beta(end,ii),1);
                sigmaD(ii,ii,dd)       = resid'*resid/(size(resid,1) - numCoeff);
            end
            stdBeta(:,ii)         = std(betaD(:,ii,:),0,3);
            tStatBeta(1:end-1,ii) = abs(beta(1:end-1,ii))./stdBeta(1:end-1,ii);
            try
                pValBeta(1:end-1,ii) = nb_tStatPValue(tStatBeta(1:end-1,ii),T - ii + 1 - numCoeff);
            catch %#ok<CTCH>
               error('t-statistic not valid. Probably due to colinearity or missing observations?!') 
            end
        end

    end

end
