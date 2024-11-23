function [res,options] = recursiveEstimationFAVAR(options,res)
% Syntax:
%
% [res,options] = nb_fmEstimator.normalEstimationFAVAR(options,res)
%
% Description:
%
% Recursive estimation algorithm of factor augmented VAR models with  
% factors estimated by principal components.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    maxLag   = options.nLags;
    startInd = options.estim_start_ind + maxLag;
    endInd   = options.estim_end_ind;

    % Get the data to estimate the model
    tempData = options.data;
    [~,indY] = ismember(options.dependent,options.dataVariables);
    y        = tempData(startInd:endInd,indY);
    T        = size(y,1);
    if isempty(y)
        error([mfilename ':: The selected sample cannot be empty.'])
    end
    [~,indZ]  = ismember(options.observables,options.dataVariables);
    Z         = tempData(startInd:endInd,indZ); 
    [~,indZR] = ismember(options.observablesFast,options.dataVariables);
    ZR        = tempData(startInd:endInd,indZR);
    [~,indX]  = ismember(options.exogenous,options.dataVariables);
    X         = tempData(startInd:endInd,indX); % Lagged dependent variables are included here!
    XX        = [y,Z,X];
    if any(isnan(XX(:)))% Check for balanced data
        error([mfilename ':: The data is unbalanced, which is not yet supported.'])
    end
    
    % Check for constant regressors, which we do not allow
    if any(all(diff(X,1) == 0,1))
        error([mfilename ':: One or more of the selected exogenous variables is/are constant. '...
                         'Use the constant option instead.'])
    end
    
    % Check the sample
    numCoeff = max(size(X,2) + size(options.factorsRHS,2) + options.constant + options.time_trend + maxLag,10);
    if isempty(options.rollingWindow)
    
        if isempty(options.recursive_estim_start_ind)
            start = options.requiredDegreeOfFreedom + numCoeff;
            options.recursive_estim_start_ind = start + startInd - 1;
        else
            start = options.recursive_estim_start_ind - startInd + 1;
            if start < options.requiredDegreeOfFreedom + numCoeff
                error([mfilename ':: The start period (' int2str(options.recursive_estim_start_ind) ') of the recursive estimation is '...
                    'less than the number of degrees of fredom that is needed for estimation (' int2str(options.requiredDegreeOfFreedom + numCoeff + startInd - 1) ').'])
            end
        end
        iter = T - start + 1;
        if iter < 1
            error([mfilename ':: The sample is too short for recursive estimation. '...
                'At least ' int2str(options.requiredDegreeOfFreedom) ' degrees of freedom are required. '...
                'Which require a sample of at least ' int2str(options.requiredDegreeOfFreedom + numCoeff) ' observations.'])
        end
        ss = ones(1,iter);
        
    else
        
        if isempty(tempOpt.recursive_estim_start_ind)
            start = tempOpt.rollingWindow;
        else
            start = tempOpt.recursive_estim_start_ind;
        end
        if start < options.requiredDegreeOfFreedom + numCoeff
            error([mfilename ':: The rolling window length is to short. '...
                'At least ' int2str(options.requiredDegreeOfFreedom) ' degrees of freedom are required. '...
                'Which require a window of at least ' int2str(options.requiredDegreeOfFreedom + numCoeff) ' observations.'])
        end
        options.recursive_estim_start_ind = start + startInd - 1;
        iter = T - start + 1;
        if iter < 1
            error([mfilename ':: The rolling window length is longer than the estimation period.']);
        end
        ss = 1:iter;
        
    end
    
    % Estimate the factors
    %----------------------
    [~,sF2]       = size(res.F);
    sy2           = size(y,2);
    numObs        = size(Z,2) + size(ZR,2);
    optT          = options;
    optT.nFactors = sF2;
    lambda        = nan(sF2+sy2+1,numObs,iter);
    F             = nan(T,sF2,iter);
    R             = nan(numObs,numObs,iter);
    residualObs   = nan(T,numObs,iter);
    kk            = 1;
    for tt = start:T
        resF                        = nb_fmEstimator.estimateFactors(optT,y(ss(kk):tt,:),Z(ss(kk):tt,:),ZR(ss(kk):tt,:));
        lambda(:,:,kk)              = resF.lambda;
        F(ss(kk):tt,:,kk)           = resF.F;
        residualObs(ss(kk):tt,:,kk) = resF.obsResidual;
        R(:,:,kk)                   = resF.R;
        kk = kk + 1;
    end

    % Estimate the VAR with OLS
    %-----------------------------------------
    
    % Intialize estimation output
    T         = T - maxLag;
    numDep    = size(y,2) + sF2;
    numC      = size(options.exogenous,2) + size(options.factorsRHS,2) + options.constant + options.time_trend;
    beta      = nan(numC,numDep,iter);
    stdBeta   = nan(numC,numDep,iter);
    residual  = nan(T,numDep,iter);
    sigma     = nan(numDep,numDep,iter);
    
    % We need to get the recursive FAVAR estimates
    indSTD = find(strcmpi(options.stdType,{'h','nw','w'}),1);
    if isempty(indSTD)
        stdM = 'h';
    else
        stdM = options.stdType;  
    end
    
    y     = y(:,:,ones(1,iter));
    yF    = [y,F];
    yF    = yF(maxLag+1:end,:,:);
    FRHS  = nb_mlag(F,maxLag,'varFast');
    X     = X(:,:,ones(1,iter));
    RHS   = [X,FRHS];
    RHS   = RHS(maxLag+1:end,:,:);
    kk    = 1;
    start = start - maxLag;
    for tt = start:T
        [beta(:,:,kk),stdBeta(:,:,kk),~,~,resid] = nb_ols(yF(ss(kk):tt,:,kk),RHS(ss(kk):tt,:,kk),options.constant,options.time_trend,stdM);
        sigma(:,:,kk)              = resid'*resid/(size(resid,1) - numC);
        residual(ss(kk):tt,:,kk)   = resid;
        kk = kk + 1; 
    end
    
    % Get estimation results
    %--------------------------------------------------
    res.beta        = beta;
    res.residual    = residual;
    res.sigma       = sigma;
    res.F           = F;
    res.R           = R;
    res.lambda      = lambda;
    res.obsResidual = residualObs;
    
    % Now we need to bootstrap the standard deviation of the estimated
    % parameters
    %------------------------------------------------------------------
    if isempty(indSTD) && ~strcmpi(options.stdType,'none') 
%         [betaDraws,lambdaDraws] = nb_fmEstimator.bootstrapModel(options,res);
%         stdBeta   = std(betaDraws,0,3);
%         stdLambda = std(lambdaDraws,0,3);
        error([mfilename ':: Bootstrapped standard errors are not yet supported for the model class nb_favar during recursive estimation.'])
    else
        stdLambda = [];
    end
    if strcmpi(options.stdType,'none')
        stdBeta   = nan(numC,numDep,iter);
    end
    res.stdBeta   = stdBeta;
    res.stdLambda = stdLambda;

end
