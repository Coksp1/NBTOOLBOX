function [res,options] = recursiveEstimationStepAhead(options,res)
% Syntax:
%
% [res,options] = nb_fmEstimator.recursiveEstimationStepAhead(options,res)
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
    if options.unbalanced
        Z    = tempData(:,indZ); % Observables may be leaded by one period!
        last = find(~all(isnan(Z),2),1,'last');
        Z    = Z(options.estim_start_ind:last,:);
    else
        Z = tempData(options.estim_start_ind:options.estim_end_ind,indZ); % Dependent is at least leaded by one period!
    end
    if ~options.unbalanced
        if any(isnan(Z(:)))% Check for balanced data
            error([mfilename ':: The data is unbalanced, set unbalanced option to true.'])
        end
    end
    
    % Check the sample
    if ~options.unbalanced
        options.estim_start_ind = options.estim_start_ind + options.nLags;
    end
    numCoeff                = max(15,size(options.factorsRHS,2) + options.constant + options.time_trend + 1);
    T                       = options.estim_end_ind - options.estim_start_ind + 1;
    [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,numCoeff,T);
    options.estim_end_ind   = options.estim_end_ind - 1;
    start                   = start - 1;
    
    % Estimate the factors
    %----------------------
    [~,sF2]       = size(res.F);
    numObs        = size(Z,2);
    optT          = options;
    optT.nFactors = sF2;
    lambda        = nan(sF2+1,numObs,iter);
    F             = nan(size(Z,1),sF2,iter);
    R             = nan(numObs,numObs,iter);
    residualObs   = nan(size(F,1),numObs,iter);
    kk            = 1;
    for tt = size(Z,1) - iter + 1:size(Z,1)
        resF                        = nb_fmEstimator.estimateFactors(optT,[],Z(ss(kk):tt,:),[]);
        lambda(:,:,kk)              = resF.lambda;
        F(ss(kk):tt,:,kk)           = resF.F;
        residualObs(ss(kk):tt,:,kk) = resF.obsResidual;
        R(:,:,kk)                   = resF.R;
        kk = kk + 1;
    end
    
    % Construct the leaded dependent variables
    %-------------------------------------------
    
    [~,indY] = ismember(options.dependent,options.dataVariables);
    y        = tempData(:,indY);
    if isempty(y)
        error([mfilename ':: The selected sample cannot be empty.'])
    end
    Y = nb_mlead(y,options.nStep,'varFast');
    Y = Y(options.estim_start_ind:options.estim_end_ind,:);
    
    % Estimate the forecast equation with OLS
    %-----------------------------------------
    
    % Intialize estimation output
    numDep    = size(y,2);
    numAll    = numDep*options.nStep;
    numC      = size(options.factorsRHS,2) + options.constant + options.time_trend;
    beta      = nan(numC,numAll,iter);
    stdBeta   = nan(numC,numAll,iter);
    sigma     = nan(numAll,numAll,iter);
    
    % We need to get the recursive estimates of the main eq
    indSTD = find(strcmpi(options.stdType,{'h','nw','w'}),1);
    if isempty(indSTD)
        stdM = 'h';
    else
        stdM = options.stdType;  
    end
    fLag  = nb_mlag(F,options.nLags,'varFast');
    fLead = nb_mlead(F,options.factorLead,'varFast');
    if options.current
        FRHS = [F,fLag,fLead];
    else
        FRHS = fLead;
    end
    FRHS     = FRHS(options.nLags+1:end-options.factorLead,:,:);
    T        = size(Y,1);
    residual = nan(T,numAll,iter);
    kk       = 1;
    for tt = start:T
        mm = 0;
        for ii = 1:numAll
            if rem(ii,numDep) == 1 || numDep == 1
                mm = mm + 1;
            end
            [beta(:,ii,kk),stdBeta(:,ii,kk),~,~,residual(ss(kk):tt-mm+1,ii,kk)] = nb_ols(Y(ss(kk):tt-mm+1,ii),FRHS(ss(kk):tt-mm+1,:,kk),options.constant,options.time_trend,stdM);
        end
        for ii = 1:numAll
            for jj = 1:numAll
                ee              = min( find(~isnan(residual(:,ii,kk)),1,'last'), find(~isnan(residual(:,jj,kk)),1,'last') );
                sigma(ii,jj,kk) = residual(1:ee,ii,kk)'*residual(1:ee,jj,kk)/(T - numCoeff);
            end
        end
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
        error([mfilename ':: Bootstrapped standard errors are not yet supported for the model class nb_fmsa during recursive estimation..'])
    else
        stdLambda = [];
    end
    if strcmpi(options.stdType,'none')
        stdBeta   = nan(numC,numAll,iter);
    end
    res.stdBeta   = stdBeta;
    res.stdLambda = stdLambda;
    
    % Correct estimation sample indexes to be consistent with forecasting
    options.estim_end_ind = options.estim_end_ind + 1;
    
    if options.unbalanced 
        % Expand beta and factorsRHS to be equal when observables are
        % leaded and not.
        if options.factorLead
            if options.current
                options.factorsRHS = [nb_cellstrlag(options.factorsRHS(1:options.nFactors),1), options.factorsRHS];
            else
                options.factorsRHS = [options.factors, options.factorsRHS];
            end
            numExo      = options.constant + options.time_trend;
            res.beta    = [res.beta(1:numExo,:,:); zeros(options.nFactors,numAll,iter); res.beta(numExo + 1:end,:,:)];
            res.stdBeta = [res.stdBeta(1:numExo,:,:); zeros(options.nFactors,numAll,iter); res.stdBeta(numExo + 1:end,:,:)]; 
        else
            options.factorsRHS = [options.factorsRHS, nb_cellstrlead(options.factorsRHS(end-options.nFactors+1:end),1)];
            res.beta           = [res.beta; zeros(options.nFactors,numAll,iter)];
            res.stdBeta        = [res.stdBeta; zeros(options.nFactors,numAll,iter)]; 
        end
    end
    
end
