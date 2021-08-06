function [res,options] = recursiveEstimationSingleEq(options,res)
% Syntax:
%
% [res,options] = nb_fmEstimator.recursiveEstimationSingleEq(options,res)
%
% Description:
%
% Recursive estimation algorithm of steap ahead factor models with  
% factors estimated by principal components.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the data to estimate the model
    tempData = options.data;
    [~,indZ] = ismember(options.observables,options.dataVariables);
    Z        = tempData(options.estim_start_ind:options.estim_end_ind,indZ); 
    if any(isnan(Z(:)))% Check for balanced data
        if ~options.unbalanced
            error([mfilename ':: The data is unbalanced, which is not yet supported.'])
        end
    end
    [~,indX]  = ismember(cellstr(options.exogenous),options.dataVariables);
    X         = tempData(options.estim_start_ind:options.estim_end_ind,indX);
    
    % Check the sample
    numCoeff = max(size(options.factorsRHS,2) + options.constant + options.time_trend,10);
    T        = size(X,1);
    if isempty(options.rollingWindow)
        
        if isempty(options.recursive_estim_start_ind)
            start = options.requiredDegreeOfFreedom + numCoeff;
            options.recursive_estim_start_ind = start + options.estim_start_ind - 1;
        else
            start = options.recursive_estim_start_ind - options.estim_start_ind + 1;
            if start < options.requiredDegreeOfFreedom + numCoeff
                error([mfilename ':: The start period (' int2str(options.recursive_estim_start_ind) ') of the recursive estimation is '...
                    'less than the number of degrees of fredom that is needed for estimation (' int2str(options.requiredDegreeOfFreedom + numCoeff + options.estim_start_ind - 1) ').'])
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
            
        if isempty(options.recursive_estim_start_ind)
            start = options.rollingWindow;
        else
            start = options.recursive_estim_start_ind;
        end
        if start < options.requiredDegreeOfFreedom + numCoeff
            error([mfilename ':: The rolling window length is to short. '...
                'At least ' int2str(options.requiredDegreeOfFreedom) ' degrees of freedom are required. '...
                'Which require a window of at least ' int2str(options.requiredDegreeOfFreedom + numCoeff) ' observations.'])
        end
        options.recursive_estim_start_ind = start + options.estim_start_ind - 1;
        iter = T - start + 1;
        if iter < 1
            error([mfilename ':: The rolling window length is longer than the estimation period.']);
        end
        ss = 1:iter;

    end
    options.estim_start_ind = options.estim_start_ind + options.nLags;
    
    % Estimate the factors
    %----------------------
    [~,sF2]       = size(res.F);
    numObs        = size(Z,2);
    optT          = options;
    optT.nFactors = sF2;
    lambda        = nan(sF2+1,numObs,iter);
    F             = nan(size(Z,1),sF2,iter);
    R             = nan(numObs,numObs,iter);
    residualObs   = nan(size(Z,1),numObs,iter);
    kk            = 1;
    for tt = size(Z,1) - iter + 1:size(Z,1)
        resF                        = nb_fmEstimator.estimateFactors(optT,[],Z(ss(kk):tt,:),[]);
        lambda(:,:,kk)              = resF.lambda;
        F(1:tt,:,kk)                = resF.F;
        residualObs(ss(kk):tt,:,kk) = resF.obsResidual;
        R(:,:,kk)                   = resF.R;
        kk = kk + 1;
    end

    % Construct the leaded dependent variables
    %-------------------------------------------
    [~,indY] = ismember(options.dependent,options.dataVariables);
    y        = tempData(options.estim_start_ind:options.estim_end_ind,indY);
    
    % Estimate the forecast equation with OLS
    %-----------------------------------------
    
    % We need to get the recursive factor estimates
    fLag = nb_mlag(F,options.nLags,'varFast');
    FRHS = [F,fLag];
    FRHS = FRHS(options.nLags+1:end,:,:);
    
    % We need to get the recursive estimates of the main eq
    indSTD = find(strcmpi(options.stdType,{'h','nw','w'}),1);
    if isempty(indSTD)
        stdM = 'h';
    else
        stdM = options.stdType;  
    end
    numDep   = size(y,2);
    numC     = size(X,2) + size(options.factorsRHS,2) + options.constant + options.time_trend;
    beta     = nan(numC,numDep,iter);
    stdBeta  = nan(numC,numDep,iter);
    residual = nan(T,numDep,iter);
    sigma    = nan(numDep,numDep,iter);
    kk       = 1;
    start    = start - options.nLags;
    for tt = start:T
        [beta(:,:,kk),stdBeta(:,:,kk),~,~,resid] = nb_ols(y(ss(kk):tt,:),[X(ss(kk):tt,:),FRHS(ss(kk):tt,:,kk)],options.constant,options.time_trend,stdM);
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
        error([mfilename ':: Bootstrapped standard errors are not yet supported for the model class nb_fm during recursive estimation.'])
    else
        stdLambda = [];
    end
    if strcmpi(options.stdType,'none')
        stdBeta   = nan(numC,numDep,iter);
    end
    res.stdBeta   = stdBeta;
    res.stdLambda = stdLambda;
    
end
