function [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD] = nb_midasFunc(y,x,constant,AR,type,nSteps,stdType,nExo,varargin)
% Syntax:
%
% beta = nb_midasFunc(y,x)
% [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD] = nb_midasFunc(y,x,...
%                constant,type,nSteps,stdType,nExo,varargin)
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
%              regressors should already be added. If type is set to  
%              something else than 'unrestricted', the nExo input must be 
%              set. 
%
% - constant : true or false. If true a constant is included.
%
% - AR       : true or false. Indicate that you are estimating a AR
%              specification of the MIDAS model.
%
% - type     : The type of MIDAS model to estimate. Either; 'unrestricted' 
%              'beta' or 'almon'. If set to 'beta' or 'almon' NLS is used,
%              otherwise OLS is used.
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
%              Caution: Only applies to method set to 'unrestricted',
%                       otherwise the inverse fischer information matrix is
%                       used.
%
% - nExo     : Number of exogenous variables excluding the lags.
%
% Optional inputs:
%
% - 'draws'         : Number of draws from the parameter distribution when
%                     bootsrapping the standard error of the parameters. 
%
% - 'optimizer'     : Either 'fmincon'(default) | 'fminunc' | 'fminsearch'
%
% - 'covrepair'     : Give true to repair the covariance matrix of the 
%                     estimated parameters if found to not be positive 
%                     definite. Default is false, i.e. to throw an error if 
%                     the covariance matrix is not positive definite.
%
% - 'opt'           : A struct returned by the optimset function.
%
% Caution : Only used if NLS is used.
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
    
    yLag = y;
    Y    = nb_mlead(y,nSteps);
    
    % Parse optional inputs for NLS
    default = {'draws',           1000,       @nb_isScalarNumber;...
               'opt',             [],         {@isstruct,'||',@isempty};...
               'covrepair',       true,       @islogical;...
               'optimizer',       'fminunc',  {{@nb_ismemberi,{'fmincon','fminunc','fminsearch'}}};...
               'polyLags',        [],         @(x)nb_isScalarInteger(x,0);...
               'waitbar',         false,      {@islogical,'||',@(x)isa(x,'nb_waitbar5')}};
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
            
            [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD] = doOLS(inputs,Y,yLag,x);
                
        case 'beta'
            
            % Set up for NLS
            func    = @(x,y)nb_betaLag(x,y);
            betaHyp = [ones(1,nSteps);ones(1,nSteps);ones(1,nSteps)*4]; % Initial values
            betaHyp = repmat(betaHyp,nExo);
            ub      = inf(3*nExo,nSteps); % Upper bound
            lb      = [-inf(1,nSteps);ones(2,nSteps)*eps]; % Lower bound
            lb      = repmat(lb,nExo);
            
            % Do NLS
            [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD] = doNLS(inputs,func,betaHyp,ub,lb,Y,yLag,x);
            
        otherwise
            error([mfilename ':: Unsupported MIDAS type ''' type '''.'])   
    end
     
    
        
end

%==========================================================================
function [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD] = doOLS(inputs,Y,yLag,x)

    AR       = inputs.AR;
    constant = inputs.constant;
    nSteps   = inputs.nSteps;
    nExo     = inputs.nExo;
    
    % Construct the mapping matrix of polynominal lags
    nLags = size(x,2)/nExo;
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
            P = nLags;
        end
        X = nan(T,nExo*P);
        for t = 1:T 
            X(t,:) = transpose(Q*x(t,:)');
        end
        numCoeff = P*nExo + constant + AR;
        
    elseif strcmpi(inputs.type,'mean')
       
        X = nan(T,nExo);
        for ii = 1:nExo
           ind     = ii:nExo:nExo*nLags;
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
function [beta,stdBeta,tStatBeta,pValBeta,residual,sigma,betaD,sigmaD] = doNLS(inputs,func,betaHyp,ub,lb,Y,x)

    AR       = inputs.AR;
    constant = inputs.constant;
    nSteps   = inputs.nSteps;
    nExo     = inputs.nExo;
    if AR
        betaHyp = [zeros(1,nSteps);betaHyp];
        ub      = [ones(1,nSteps)-eps;ub];
        lb      = [-ones(1,nSteps)+eps;lb];
    end
    if constant
        betaHyp = [zeros(1,nSteps);betaHyp];
        ub      = [inf(1,nSteps);ub];
        lb      = [-inf(1,nSteps);lb];
    end
    
    if inputs.draws > 1
        draws = inputs.draws;
    else
        draws = 0;
    end
    
    % Waitbar
    if draws ~= 0
        [h,note,isWaitbar] = nb_bVarEstimator.openWaitbar(inputs.waitbar,(draws+1)*nSteps);
        status             = 1;
    else
        isWaitbar = false;
    end
    
    % Use NLS to estimate model
    numCoeff = constant + AR + 3;
    residual = nan(size(y,1)-AR,nSteps);
    T        = size(residual,1);
    sigma    = zeros(nSteps,nSteps);
    for ii = 1:nSteps
        
        if AR
            xi = [Y(1:end-ii+1,ii-1),x(1:end-ii+1,:)];
        else
            xi = x(1:end-ii+1,:);
        end
        yi = Y(1:end-ii+1,ii);
        
        [message,betaHyp(:,ii),~,~,~,residual(1:end-ii+1,ii)] = nb_nls(betaHyp(:,ii),ub(:,ii),lb(:,ii),inputs.opt,inputs.optimizer,...
            inputs.covrepair,@nb_midasResiduals,yi,xi,constant,func,nExo,AR); 
        if isWaitbar
            nb_bVarEstimator.notifyWaitbar(h,status,note);
            status = status + 1;
        end 
        if isempty(message)
            error(message);
        end
        sigma(ii,ii) = residual(1:end-ii+1,ii)'*residual(1:end-ii+1,ii)/(T - ii + 1 - numCoeff);
    end
    
    % Bootstrap parameters
    nLags       = size(x,2)/nExo;
    indScale    = constant+AR+1;
    indTheta    = constant+AR+2:size(betaHyp,1);
    indHyper    = [1:constant+AR,constant + AR + nExo*nLags + 1:constant + AR + nExo*(nLags + 3)];
    indNotHyper = constant + AR + 1:constant + AR + nExo*nLags;
    if draws > 1 
        
        error([mfilename ':: Bootstrapping a beta lag or almon lag MIDAS model is not yet finished. ',...
                         'Please set the draws option to 1 or use unrestricted MIDAS.'])
        
        betaD  = nan(constant + AR + nExo*(nLags + 3),nSteps,draws);
        sigmaD = zeros(nSteps,nSteps,draws);
        for ii = 1:nSteps

            ysim    = nb_midasBootstrap(betaHyp(:,ii),residual(1:end-ii+1,ii),x(1:end-ii+1,:),constant,func,nExo,AR,draws);
            kk      = 1;
            tries   = 1;
            betaSim = nan(size(betaHyp,1),1,draws);
            while kk <= draws

                [err,betaSimT,~,~,~,resid] = nb_nls(betaHyp(:,ii),ub(:,ii),lb(:,ii),inputs.opt,inputs.optimizer,...
                                               inputs.covrepair,@nb_midasResiduals,ysim(:,tries),x(1:end-ii+1,:),constant,func,nExo,AR);
                tries = tries + 1;
                if tries > size(ysim,3)
                    tries = 1;
                    ysim    = nb_midasBootstrap(betaHyp(:,ii),residual(1:end-ii+1,ii),x(1:end-ii+1,:),constant,func,nExo,AR,draws/10);
                end
                if ~isempty(err)
                    continue
                end
                betaSim(:,:,kk)  = betaSimT;
                sigmaD(ii,ii,kk) = resid'*resid/(size(resid,1) + 1 - numCoeff);
                if isWaitbar
                    nb_bVarEstimator.notifyWaitbar(h,status,note);
                end
                kk     = kk + 1;        
                status = status + 1;

            end

            betaD(indHyper,ii,:)    = betaSim;
            betaD(indNotHyper,ii,:) = bsxfun(@times,betaSim(indScale,:,:),func(permute(betaSim(indTheta,:,:),[2,1,3]),nLags));

        end
        beta      = mean(betaD,3);
        stdBeta   = std(betaD,0,3);
        tStatBeta = beta./stdBeta;
        T         = size(y,1);
        nEst      = size(betaHyp,1);
        
        % Get p-values.
        tStatBeta(isnan(tStatBeta)) = inf;
        pValBeta                    = nb_tStatPValue(tStatBeta,T-nEst);
        
        if isWaitbar
            nb_bVarEstimator.closeWaitbar(h);
        end
        
    else
        
        % No bootstrapping
        beta = nan(constant + AR + nExo*(nLags + 3),nSteps);
        for ii = 1:nSteps
            beta(indHyper,ii,:)    = betaHyp(:,ii);
            beta(indNotHyper,ii,:) = bsxfun(@times,betaHyp(indScale,ii),func(permute(betaHyp(indTheta,ii),[2,1,3]),nLags));
        end
        betaD     = nan(0,0,0,1);
        sigmaD    = nan(0,0,0,1);
        stdBeta   = nan(size(beta));
        tStatBeta = stdBeta;
        pValBeta  = stdBeta;
        
    end

end
