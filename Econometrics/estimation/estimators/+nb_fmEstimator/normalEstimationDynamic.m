function [res,options] = normalEstimationDynamic(options,res)
% Syntax:
%
% [res,options] = nb_fmEstimator.normalEstimationDynamic(options,res)
%
% Description:
%
% Estimation algorithm of dynamic factor models with pre-estimated factors
% by principal components.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    maxLag   = max(max(options.nLags),options.factorsLags);
    startInd = options.estim_start_ind + maxLag;
    endInd   = options.estim_end_ind;
    
    % Get the data to estimate the forecast equation
    %numDep   = length(options.dependent);
    tempData = options.data;
    [~,indY] = ismember(options.dependent,options.dataVariables);
    y        = tempData(startInd:endInd,indY);
    if isempty(y)
        error([mfilename ':: The selected sample cannot be empty.'])
    end
    [~,indF] = ismember(options.factors,options.dataVariables);
    F        = tempData(startInd:endInd,indF);
    y        = [y,F];
    
    % Get STD method
    indSTD = find(strcmpi(options.stdType,{'h','nw','w'}),1);
    if isempty(indSTD)
        stdM = 'h';
    else
        stdM = options.stdType;  
    end
    
    % Restrict the regressors of each equation
    %----------------------------------------------
    [allRegressors,restrictions] = nb_fmEstimator.getAllDynamicRegressors(options);
    
    % Check for constant regressors, which we do not allow
    [~,indX] = ismember(allRegressors,options.dataVariables);
    X        = tempData(startInd:endInd,indX);
    if any(all(diff(X,1) == 0,1))
        error([mfilename ':: One or more of the selected exogenous variables is/are constant. '...
                         'Use the constant option instead.'])
    end

    % Check the degrees of freedom
    numCoeff = size(X,2) + options.constant + options.time_trend;
    T        = size(X,1);
    dof      = T - options.requiredDegreeOfFreedom - numCoeff - maxLag*2;
    if dof < 0
        needed = options.requiredDegreeOfFreedom + numCoeff + maxLag*2;
        error([mfilename ':: The sample is too short for estimation with the selected options. '...
                         'At least ' int2str(options.requiredDegreeOfFreedom) ' degrees of freedom are required. '...
                         'Which require a sample of at least ' int2str(needed) ' observations.'])
    end
    
    % Estimate model by ols
    %----------------------------
    [beta,stdBeta,~,~,residual,XX] = nb_olsRestricted(y,X,restrictions,options.constant,options.time_trend,stdM);
    
    % Estimate the covariance matrix
    %-------------------------------
    sigma     = residual'*residual/(T - numCoeff);
    predicted = y - residual;
    
    % Get aditional test results
    %--------------------------------------------------
    if options.doTests

        [numCoeff,numEq]       = size(beta);
        [rSquared,adjRSquared] = nb_rSquared(y,residual,numCoeff);
        logLikelihood          = nb_olsLikelihood(residual);

        if (numCoeff == 1 && options.constant) || ~options.constant
            fTest = nan(1,numEq);
            fProb = nan(1,numEq);   
        else
            fTest = (rSquared/(numCoeff - 1))./((1 - rSquared)/(T - numCoeff));
            fProb = nb_fStatPValue(fTest', numCoeff - 1, T - numCoeff)';
        end

        aic           = nb_infoCriterion('aic',logLikelihood,T,numCoeff);
        sic           = nb_infoCriterion('sic',logLikelihood,T,numCoeff);
        hqc           = nb_infoCriterion('hqc',logLikelihood,T,numCoeff);
        dwtest        = nb_durbinWatson(residual);
        archTest      = nb_archTest(residual,round(options.nLagsTests));
        autocorrTest  = nb_autocorrTest(residual,round(options.nLagsTests));
        normalityTest = nb_normalityTest(residual,numCoeff);
        [SERegression,sumOfSqRes] = nb_SERegression(residual,numCoeff);

    end
    
    % Get estimation results
    %--------------------------------------------------
    res.beta          = beta;
    res.fTest         = fTest;
    res.fProb         = fProb;
    res.residual      = residual;
    res.sigma         = sigma;
    res.predicted     = predicted;
    res.regressors    = XX;
    res.rSquared      = rSquared;
    res.adjRSquared   = adjRSquared;
    res.logLikelihood = logLikelihood;
    res.logLikelihood = logLikelihood;
    res.aic           = aic;
    res.sic           = sic;
    res.hqc           = hqc;
    res.dwtest        = dwtest;
    res.archTest      = archTest;
    res.autocorrTest  = autocorrTest;
    res.normalityTest = normalityTest;
    res.SERegression  = SERegression;
    res.sumOfSqRes    = sumOfSqRes;

    % Now we need to bootstrap the standard deviation of the estimated
    % parameters
    %------------------------------------------------------------------
    if isempty(indSTD) && ~strcmpi(options.stdType,'none') 
        [beta,lambdaDraws] = nb_fmEstimator.bootstrapModel(options,res);
        stdBeta            = std(beta,0,3);
        stdLambda          = std(lambdaDraws,0,3);      
    else
        stdLambda = [];
    end
    res.stdBeta   = stdBeta;
    res.stdLambda = stdLambda;
    
end
