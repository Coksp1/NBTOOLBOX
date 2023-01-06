function [res,options] = normalEstimationFAVAR(options,res)
% Syntax:
%
% [res,options] = nb_fmEstimator.normalEstimationFAVAR(options,res)
%
% Description:
%
% Estimation algorithm of factor augmented VAR models with pre-estimated 
% factors by principal components.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    maxLag   = options.nLags;
    startInd = options.estim_start_ind + maxLag;
    endInd   = options.estim_end_ind;

    % Get the variables of the model
    %-------------------------------------------
    tempData = options.data;
    [~,indY] = ismember(options.dependent,options.dataVariables);
    y        = tempData(startInd:endInd,indY);
    if isempty(y)
        error([mfilename ':: The selected sample cannot be empty.'])
    end
    [~,indF] = ismember(options.factors,options.dataVariables);
    F        = tempData(startInd:endInd,indF);
    [~,indF] = ismember(options.factorsRHS,options.dataVariables);
    FRHS     = tempData(startInd:endInd,indF);
    [~,indX] = ismember(options.exogenous,options.dataVariables);
    X        = tempData(startInd:endInd,indX); % Lagged dependent variables are included here!

    % Check for constant regressors, which we do not allow
    if any(all(diff(X,1) == 0,1))
        error([mfilename ':: One or more of the selected exogenous variables is/are constant. '...
                         'Use the constant option instead.'])
    end
    
    % Estimate the forecast equation with OLS
    %-----------------------------------------
    
    % Check the degrees of freedom
    numCoeff = size(X,2) + size(FRHS,2) + options.constant + options.time_trend;
    dof      = size(FRHS,1) - 2 - options.requiredDegreeOfFreedom - numCoeff;
    if dof < 0
        needed = options.requiredDegreeOfFreedom + numCoeff + 2;
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
    
    [beta,stdBeta,~,~,residual,XX] = nb_ols([y,F],[X,FRHS],options.constant,options.time_trend,stdM);

    % Estimate the covariance matrix
    %-------------------------------
    numCoeff = size(beta,1);
    T        = size(residual,1);
    sigma    = residual'*residual/(T - numCoeff);
    yF       = [y,F];

    % Get estimation results
    %--------------------------------------------------
    res.beta       = beta;
    res.residual   = residual;
    res.sigma      = sigma;
    res.predicted  = yF - residual;
    res.regressors = XX;

    % Get aditional test results
    %--------------------------------------------------
    if options.doTests
        
        [numCoeff,numEq]       = size(beta);
        [rSquared,adjRSquared] = nb_rSquared(yF,residual,numCoeff);
        logLikelihood          = nb_olsLikelihood(residual);

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
        res.dwtest        = nb_durbinWatson(residual);
        res.archTest      = nb_archTest(residual,round(options.nLagsTests));
        res.autocorrTest  = nb_autocorrTest(residual,round(options.nLagsTests));
        res.normalityTest = nb_normalityTest(residual,numCoeff);
        [res.SERegression,res.sumOfSqRes]  = nb_SERegression(residual,numCoeff);

        % Full system 
        res.fullLogLikelihood = nb_olsLikelihood(residual,'full');
        res.aicFull           = nb_infoCriterion('aic',res.fullLogLikelihood,T,numCoeff);
        res.sicFull           = nb_infoCriterion('sic',res.fullLogLikelihood,T,numCoeff);
        res.hqcFull           = nb_infoCriterion('hqc',res.fullLogLikelihood,T,numCoeff);

    end
        
    % Now we need to bootstrap the standard deviation of the estimated
    % parameters
    %------------------------------------------------------------------
    if isempty(indSTD) && ~strcmpi(options.stdType,'none') 
        [betaDraws,lambdaDraws] = nb_fmEstimator.bootstrapModel(options,res);
        stdBeta   = std(betaDraws,0,3);
        stdLambda = std(lambdaDraws,0,3);
    else
        stdLambda = [];
    end
    res.stdBeta   = stdBeta;
    res.stdLambda = stdLambda;

end
