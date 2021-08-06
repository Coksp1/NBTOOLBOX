function [res,options] = normalEstimationStepAhead(options,res)
% Syntax:
%
% [res,options] = nb_fmEstimator.normalEstimationStepAhead(options,res)
%
% Description:
%
% Estimation algorithm of steap ahead factor models with pre-estimated 
% factors by principal components.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~options.unbalanced
        options.estim_start_ind = options.estim_start_ind + options.nLags;
    end
    options.estim_end_ind = options.estim_end_ind - max(1,options.factorLead-1);

    % Get the data to estimate the forecast equation
    tempData = options.data;
    [~,indY] = ismember(options.dependent,options.dataVariables);
    y        = tempData(:,indY);
    if isempty(y)
        error([mfilename ':: The selected sample cannot be empty.'])
    end

    % Construct the leaded dependent variables
    %-------------------------------------------
    Y        = nb_mlead(y,options.nStep,'varFast'); 
    Y        = Y(options.estim_start_ind:options.estim_end_ind,:);
    [~,indF] = ismember(options.factorsRHS,options.dataVariables);
    FRHS     = tempData(options.estim_start_ind:options.estim_end_ind,indF);
    
    % Estimate the forecast equation with OLS
    %-----------------------------------------
    
    % Check the degrees of freedom
    numCoeff = size(FRHS,2) + options.constant + options.time_trend;
    dof      = size(FRHS,1) - options.requiredDegreeOfFreedom - numCoeff;
    if dof < 0
        needed = options.requiredDegreeOfFreedom + numCoeff;
        error([mfilename ':: The sample is too short for estimation with the selected options. '...
                         'At least ' int2str(options.requiredDegreeOfFreedom) ' degrees of freedom are required. '...
                         'Which require a sample of at least ' int2str(needed) ' observations.'])
    end
    
    indSTD = find(strcmpi(options.stdType,{'h','nw','w'}),1);
    if isempty(indSTD)
        stdM = 'h';
    else
        stdM = options.stdType;  
    end
    
    numDep   = size(y,2);
    numAll   = numDep*options.nStep;
    numC     = size(options.factorsRHS,2) + options.constant + options.time_trend;
    beta     = nan(numC,numAll);
    stdBeta  = nan(numC,numAll);
    sigma    = nan(numAll,numAll);
    T        = size(Y,1);
    residual = nan(T,numAll);
    kk       = 0;
    for ii = 1:numAll
        if rem(ii,numDep) == 1 || numDep == 1
            kk = kk + 1;
        end
        [beta(:,ii),stdBeta(:,ii),~,~,residual(1:T-kk+1,ii)] = nb_ols(Y(1:T-kk+1,ii),FRHS(1:T-kk+1,:),options.constant,options.time_trend,stdM);
    end
    
    % Estimate the covariance matrix
    %-------------------------------
    numCoeff = size(beta,1);
    T        = size(residual,1);
    for ii = 1:numAll
        for jj = 1:numAll
            tt           = T - max(ceil(ii/numDep),ceil(jj/numDep)) + 1;
            sigma(ii,jj) = residual(1:tt,ii)'*residual(1:tt,jj)/(T - numCoeff);
        end
    end

    % Get estimation results
    %--------------------------------------------------
    res.beta      = beta;
    res.residual  = residual;
    res.sigma     = sigma;
    res.predicted = Y - residual;
    
    % Get aditional test results
    %--------------------------------------------------
    if options.doTests
        
        [numCoeff,numEq] = size(beta);
        rSquared         = nan(1,numAll);
        adjRSquared      = nan(1,numAll);
        logLikelihood    = nan(1,numAll);
        dwtest           = nan(1,numAll);
        archTest         = nan(1,numAll);
        autocorrTest     = nan(1,numAll);
        normalityTest    = nan(1,numAll);
        SERegression     = nan(1,numAll);
        sumOfSqRes       = nan(1,numAll);
        
        for ii = 1:numAll 
            [rSquared(ii),adjRSquared(ii)]    = nb_rSquared(Y(1:T-ii+1,ii),residual(1:T-ii+1,ii),numCoeff);
            logLikelihood(ii)                 = nb_olsLikelihood(residual(1:T-ii+1,ii));
            dwtest(ii)                        = nb_durbinWatson(residual(1:T-ii+1,ii));
            archTest(ii)                      = nb_archTest(residual(1:T-ii+1,ii),round(options.nLagsTests));
            autocorrTest(ii)                  = nb_autocorrTest(residual(1:T-ii+1,ii),round(options.nLagsTests));
            normalityTest(ii)                 = nb_normalityTest(residual(1:T-ii+1,ii),numCoeff);
            [SERegression(ii),sumOfSqRes(ii)] = nb_SERegression(residual(1:T-ii+1,ii),numCoeff);
        end
        
        if (numCoeff == 1 && options.constant) || ~options.constant
            res.fTest = nan(1,numEq);
            res.fProb = nan(1,numEq);   
        else
            res.fTest = (rSquared/(numCoeff - 1))./((1 - rSquared)/(T - numCoeff));
            res.fProb = nb_fStatPValue(res.fTest', numCoeff - 1, T - numCoeff);
        end

        res.rSquared      = rSquared;
        res.adjRSquared   = adjRSquared;
        res.logLikelihood = logLikelihood;
        res.aic           = nb_infoCriterion('aic',logLikelihood,T,numCoeff);
        res.sic           = nb_infoCriterion('sic',logLikelihood,T,numCoeff);
        res.hqc           = nb_infoCriterion('hqc',logLikelihood,T,numCoeff);
        res.dwtest        = dwtest;
        res.archTest      = archTest;
        res.autocorrTest  = autocorrTest;
        res.normalityTest = normalityTest;
        res.SERegression  = SERegression;
        res.sumOfSqRes    = sumOfSqRes;
    
    end
    
    % Now we need to bootstrap the standard deviation of the estimated
    % parameters
    %------------------------------------------------------------------
    if isempty(indSTD) && ~strcmpi(options.stdType,'none') 
        [betaDraws,lambdaDraws] = nb_fmEstimator.bootstrapModel(options,res);
        stdBeta                 = std(betaDraws,0,3);
        stdLambda               = std(lambdaDraws,0,3);
    else
        stdLambda = [];
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
            res.beta    = [res.beta(1:numExo,:,:); zeros(options.nFactors,numAll); res.beta(numExo + 1:end,:,:)];
            res.stdBeta = [res.stdBeta(1:numExo,:,:); zeros(options.nFactors,numAll); res.stdBeta(numExo + 1:end,:,:)]; 
        else
            options.factorsRHS = [options.factorsRHS, nb_cellstrlead(options.factorsRHS(end-options.nFactors+1:end),1)];
            res.beta           = [res.beta; zeros(options.nFactors,numAll)];
            res.stdBeta        = [res.stdBeta; zeros(options.nFactors,numAll)]; 
        end
    end
    
end
