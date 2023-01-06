function [betaDraws,sigmaDraws,yD,pD] = drawParameters(results,options,draws,iter)
% Syntax:
%
% [betaDraws,sigmaDraws,yD,pD] = nb_mlEstimator.drawParameters(results,...
%                                               draws,iter)
%
% Description:
%
% Draw parameters using asymptotic normality assumption and numerically
% calculated Hessian from ML estimation. Do not draw from the distribution
% of the std of the residual.
%
% If the model include missing observation these are observations are
% re-estimated using the Kalman filter for each draw from the confidence
% set of the parameters.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        iter = 'end';
    end

    if ~isfield(results,'omega')
        error([mfilename ':: Cannot draw parameters from the model using asymptotic normality as long as ML '...
                         'estimation is not done. (May also be due to an outdated model object, in this case '...
                         'please try to re-estimate the model)'])
    end
    
    omega = results.omega;
    if strcmpi(iter,'end')
        iter = size(omega,3);
    end
    omega  = omega(:,:,iter);
    mode   = results.beta(:,:,iter)';
    [eq,c] = size(mode); 
    mode   = mode(:)';
    
    % Asume normal distribution on coefficients and constant std on
    % residual
    variance = diag(omega);
    dist     = nb_distribution.double2NormalDist(mode,variance);
    sigma    = nb_cov2corr(omega);
    copula   = nb_copula(dist,'sigma',sigma);
    
    % Make draws
    %----------------------
    betaDrawsV = random(copula,draws,1);           % draws x nCoeff*nEq x 1
    betaDrawsV = checkFailed(copula,betaDrawsV,options,eq);
    betaDraws  = reshape(betaDrawsV,[draws,eq,c]); % draws x nEq x nCoeff
    betaDraws  = permute(betaDraws,[3,2,1]);       % nCoeff x nEq x draws
    sigmaDraws = results.sigma(:,:,ones(1,draws)); % Constant std on residual
 
    % Make draws of missing values
    if nargout > 2
        
        % Get the data
        y = results.y';
        X = results.X';
        T = size(y,2);
        if options.time_trend
            X  = [1:T;X];
        end
        if options.constant
            X = [ones(1,T);X];
        end
        missingPer = nan(1,eq);
        for ii = 1:eq
            missingPer(ii) = T - find(~isnan(y(ii,:)),1,'last');
        end
        nNow = max(missingPer);
        
        if options.recursive_estim
            ind = 1:options.recursive_estim_start_ind + iter - 1;
            y   = y(:,ind);
            y   = nb_estimator.correctForMissing(y',missingPer)';
            X   = X(:,ind);
        end
        if nNow == 0
            y  = y(:,end);
            yD = y(:,:,ones(1,draws));
            pD = [];
            return
        end
        
        nDep      = size(y,1);
        nLags     = options.nLags;
        nExo      = size(X,1);
        nCoeffExo = nExo*nDep;
        
        % Restrictions
        if ~isempty(options.restrictions)
            restr    = ~reshape([options.restrictions{:}]',[],nDep)';
        else
            restr    = false(nDep^2*nLags,1);
        end
        restrVal = zeros(size(restr));      
        
        % Draw from the distribution of the missing observation by using
        % the Kalman filter
        betaDrawsV = permute(betaDrawsV,[2,1]);
        sig        = nb_reduceCov(results.sigma);
        sig        = sig(:,ones(1,draws));
        paramDraws = [betaDrawsV;sig];
        if strcmpi(options.class,'nb_mfvar')
            if isfield(options,'measurementErrorInd')
                measErrInd = [];
            else
                measErrInd = options.measurementErrorInd;
            end
            if isfield(results,'R')
                % Keep measurement error std constant
                paramDraws = [paramDraws;results.R(measErrInd,ones(1,draws))];
            end
            H         = nb_mlEstimator.getMeasurementEqMFVAR(options);
            yD        = nan(nDep,size(H,2),draws);
            pD        = nan(nDep,nDep,nNow,draws);
            ii        = 1;
            numFailed = 0;
            while ii <= draws
                try
                    [~,yD(:,:,ii),~,~,~,~,P] = nb_kalmansmoother_missing(@nb_mfvar.stateSpace,y,X,paramDraws(:,ii),nDep,nLags,nCoeffExo,restr,restrVal,measErrInd,H);
                    pD(:,:,:,ii)             = P(1:nDep,1:nDep,end-nNow+1:end);
                    ii                       = ii +1;
                catch Err
                    if numFailed > draws
                        rethrow(Err)
                    end
                end
            end
        else
            yD        = nan(size(y,2),nDep*nLags,draws);
            pD        = nan(nDep,nDep,nNow,draws);
            ii        = 1;
            numFailed = 0;
            while ii <= draws
                try
                    [~,yD(:,:,ii),~,~,~,~,P] = nb_kalmansmoother_missing(@nb_var.stateSpace,y,X,paramDraws(:,ii),nDep,nLags,nCoeffExo,restr,restrVal);
                    pD(:,:,:,ii)             = P(1:nDep,1:nDep,end-nNow+1:end);
                    ii                       = ii +1;
                catch Err
                    if numFailed > draws
                        rethrow(Err)
                    end
                end
            end
        end
        
    end
    
end

%==========================================================================
function betaDrawsV = checkFailed(copula,betaDrawsV,options,nDep)

    numCoeff  = size(betaDrawsV,2)/nDep;
    nExo      = length(options.exogenous);
    nExo      = nExo + options.constant + options.time_trend;
    nExoCoeff = nExo*nDep;
    nLags     = (numCoeff - nExo)/nDep;
    numRows   = (nLags - 1)*nDep;
    I         = eye(numRows);
    Z         = zeros(numRows,nDep);
    nDraws    = size(betaDrawsV,1);
    failed    = true(1,nDraws);
    for ii = 1:nDraws
        betaTemp = betaDrawsV(ii,nExoCoeff+1:end);
        betaTemp = reshape(betaTemp,[nDep,numRows + nDep]);
        A        = [betaTemp; I,Z];
        [~,~,m]  = nb_calcRoots(A);
        if all(m < 1)
            failed(ii) = false; 
        end
    end
    if any(failed)
        draws                = sum(failed);
        betaDrawsV(failed,:) = random(copula,draws,1); % draws x nCoeff*nEq x 1
        betaDrawsV(failed,:) = checkFailed(copula,betaDrawsV(failed,:),options,nDep);
    end

end
