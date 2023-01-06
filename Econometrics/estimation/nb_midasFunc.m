function [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD] = nb_midasFunc(y,x,constant,AR,type,nSteps,stdType,nExo,nLags,varargin)
% Syntax:
%
% beta = nb_midasFunc(y,x)
% [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD] = nb_midasFunc(y,x,...
%                constant,type,nSteps,stdType,nExo,nLags,varargin)
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
%              'beta', 'legendre', 'mean' or 'almon'. If set to 'beta' 
%              profiling is used, otherwise OLS is used.
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
% - 'draws'    : Number of draws from the parameter distribution when
%                bootsrapping the standard error of the parameters. 
%
% - 'polyLags' : The number of polynomial lags to use when type is set
%                to 'legendre' or 'almon'. Either as a scalar integer or
%                a vector of integers with length nExo.
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
% See also
% nb_midasEstimator, nb_midas 
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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
    default = {'draws',           1000,       @nb_isScalarNumber;...
               'polyLags',        [],         @(x)nb_iswholenumber(x)};
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
        
        case {'almon','legendre','mean','unrestricted'}
            
            [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD] = doOLS(inputs,Y,yLag,x,nLags);
                
        case 'beta'
            
            [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD] = doProfiling(inputs,Y,yLag,x,nLags);
            
%             % Set up for NLS
%             func    = @(x,y)nb_betaLag(x,y);
%             betaHyp = [ones(1,nSteps);ones(1,nSteps);ones(1,nSteps)*4]; % Initial values
%             betaHyp = repmat(betaHyp,nExo);
%             ub      = inf(3*nExo,nSteps); % Upper bound
%             lb      = [-inf(1,nSteps);ones(2,nSteps)*eps]; % Lower bound
%             lb      = repmat(lb,nExo);
%             
%             % Do NLS
%             [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD] = doNLS(inputs,func,betaHyp,ub,lb,Y,yLag,x,nLags);
            
        otherwise
            error([mfilename ':: Unsupported MIDAS type ''' type '''.'])   
    end
     
    
        
end

%==========================================================================
function [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD] = doOLS(inputs,Y,yLag,x,nLags)

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
        
    else % Unrestricted
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
        if constant
            Xii = [ones(size(Xii,1),1),Xii]; %#ok<AGROW>
        end
        Yii = Y(1:end-ii,ii);
        [beta(:,ii),stdBeta(:,ii),tStatBeta(:,ii),pValBeta(:,ii),residual(1:end-ii+1,ii)] = nb_ols(Yii,Xii,false,false,inputs.stdType);

        % Estimate the covariance matrix
        sigma(ii,ii) = residual(1:end-ii+1,ii)'*residual(1:end-ii+1,ii)/(T - ii + 1 - numCoeff);

        % Bootstrap
        if draws > 1
            residSim = nb_bootstrap(residual(1:end-ii+1,ii),draws,'bootstrap');
            residSim = permute(residSim,[3,2,1]);
            ysim     = bsxfun(@plus,Xii*beta(:,ii),residSim);
            for dd = 1:draws
                [betaD(:,ii,dd),~,~,~,resid] = nb_ols(ysim(:,dd),Xii,false,false);
                sigmaD(ii,ii,dd)             = resid'*resid/(T - ii + 1 - numCoeff);
            end
        end

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
        
        [beta(:,ii),residual(1:end-ii+1,ii),X_tilda] = nb_betaProfiling(Yii,Xii,constant,AR,nExo,nLags);
        
        % Estimate the covariance matrix
        sigma(ii,ii) = residual(1:end-ii+1,ii)'*residual(1:end-ii+1,ii)/(T - ii + 1 - numCoeff);

        % Bootstrap
        if draws > 1
            
            % Simulate and estimate model for each simulation
            residSim = nb_bootstrap(residual(1:end-ii+1,ii),draws,'bootstrap');
            residSim = permute(residSim,[3,2,1]);
            ysim     = bsxfun(@plus,X_tilda*beta(1:end-1,ii),residSim);
            for dd = 1:draws
                [betaD(:,ii,dd),resid] = nb_betaProfiling(ysim(:,dd),Xii,constant,AR,nExo,nLags,beta(end,ii),1);
                sigmaD(ii,ii,dd)       = resid'*resid/(T - ii + 1 - numCoeff);
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
