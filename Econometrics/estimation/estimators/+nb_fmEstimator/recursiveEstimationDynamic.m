function [res,options] = recursiveEstimationDynamic(options,res)
% Syntax:
%
% [res,options] = nb_fmEstimator.recursiveEstimationDynamic(options,res)
%
% Description:
%
% Recursive estimation algorithm of dynamic factor models with 
% factors estimated by principal components.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nLags      = options.nLags;
    maxLag     = max(max(nLags),options.factorsLags);
    startInd   = options.estim_start_ind + maxLag;
    endInd     = options.estim_end_ind;
    constant   = options.constant;
    time_trend = options.time_trend;
    
    % Get the data to estimate the model
    tempData = options.data;
    [~,indY] = ismember(options.dependent,options.dataVariables);
    y        = tempData(startInd:endInd,indY);
    if isempty(y)
        error([mfilename ':: The selected sample cannot be empty.'])
    end
    [~,indZ]  = ismember(options.observables,options.dataVariables);
    Z         = tempData(startInd:endInd,indZ); 
    XX        = [y,Z];
    if any(isnan(XX(:)))% Check for balanced data
        error([mfilename ':: The data is unbalanced, which is not yet supported.'])
    end
    
    numExo = 0;
    for ii = 1:size(options.exogenous,2)
        nExo = length(options.exogenous{ii});
        if nExo > numExo
            numExo = nExo;
        end
    end
    
    numFact = 0;
    for ii = 1:size(options.factorsRHS,2)
        nf = length(options.factorsRHS{ii});
        if nf > numFact
            numFact = nf;
        end
    end
    
    % Check the sample
    numCoeff = max(numExo + numFact + constant + time_trend + maxLag*3,10);
    T        = size(y,1);
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
    numObs        = size(Z,2);
    optT          = options;
    optT.nFactors = sF2;
    T             = size(y,1);
    lambda        = nan(sF2+1,numObs,iter);
    F             = nan(T,sF2,iter);
    R             = nan(numObs,numObs,iter);
    residualObs   = nan(T,numObs,iter);
    kk            = 1;
    for tt = start:T
        resF                        = nb_fmEstimator.estimateFactors(optT,[],Z(ss(kk):tt,:),[]);
        lambda(:,:,kk)              = resF.lambda;
        F(ss(kk):tt,:,kk)           = resF.F;
        residualObs(ss(kk):tt,:,kk) = resF.obsResidual;
        R(:,:,kk)                   = resF.R;
        kk = kk + 1;
    end
    
    % Get STD method
    indSTD = find(strcmpi(options.stdType,{'h','nw','w'}),1);
    if isempty(indSTD)
        stdM = 'h';
    else
        stdM = options.stdType;  
    end
    
    % Restrict the regressors of each equation
    %----------------------------------------------
    [~,restrictions] = nb_fmEstimator.getAllDynamicRegressors(options);
    allExo           = nb_fmEstimator.getAllDynamicRegressors(options,'onlyExo');
    
    % Check for constant regressors, which we do not allow
    [~,indX] = ismember(allExo,options.dataVariables);
    X        = tempData(startInd+maxLag:endInd,indX);
    if any(all(diff(X,1) == 0,1))
        error([mfilename ':: One or more of the selected exogenous variables is/are constant. '...
                         'Use the constant option instead.'])
    end

    % Check the degrees of freedom
    numCoeff = size(X,2) + size(F,2)*maxLag + options.constant + options.time_trend;
    if options.contemporaneous
        numCoeff = numCoeff + size(F,2);
    end
    dof      = size(X,1) - options.requiredDegreeOfFreedom - numCoeff - maxLag*2;
    if dof < 0
        needed = options.requiredDegreeOfFreedom + numCoeff + maxLag*2;
        error([mfilename ':: The sample is too short for estimation with the selected options. '...
                         'At least ' int2str(options.requiredDegreeOfFreedom) ' degrees of freedom are required. '...
                         'Which require a sample of at least ' int2str(needed) ' observations.'])
    end
    
    % Estimate model by ols
    %----------------------------
    start      = start - maxLag;
    T          = T - maxLag;
    numDep     = size(y,2);
    numAll     = numDep+size(F,2);
    beta       = nan(numCoeff,numAll,iter);
    stdBeta    = nan(numCoeff,numAll,iter);
    constant   = options.constant;
    time_trend = options.time_trend;
    residual   = nan(T,numAll,iter);
    kk         = 1;
    vcv        = nan(numAll,numAll,iter);
    Flag       = nb_mlag(F,maxLag,'varFast');
    Flag       = Flag(maxLag+1:end,:,:);
    F          = F(maxLag+1:end,:,:);
    y          = y(maxLag+1:end,:);
    for tt = start:T
        Flagt       = Flag(ss(kk):tt,:,kk);
        Ft          = F(ss(kk):tt,:,kk);
        Xt          = X(ss(kk):tt,:);
        if options.contemporaneous
            Xt = [Xt,Ft,Flagt]; %#ok<AGROW>  
        else
            Xt = [Xt,Flagt]; %#ok<AGROW>
        end
        yt          = [y(ss(kk):tt,:),Ft];
        [beta(:,:,kk),stdBeta(:,:,kk),~,~,residual(ss(kk):tt,:,kk)] = nb_olsRestricted(yt,Xt,restrictions,constant,time_trend,stdM);
        resid       = residual(ss(kk):tt,:,kk);
        vcv(:,:,kk) = resid'*resid/(size(resid,1) - numCoeff);
        kk          = kk + 1;  
    end

    % Get estimation results
    %--------------------------------------------------
    res.beta        = beta;
    res.residual    = residual;
    res.sigma       = vcv;
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
        error([mfilename ':: Bootstrapped standard errors are not yet supported for the model class nb_fmdyn  during recursive estimation.'])
    else
        stdLambda = [];
    end
    if strcmpi(options.stdType,'none')
        stdBeta   = nan(numC,numDep,iter);
    end
    res.stdBeta   = stdBeta;
    res.stdLambda = stdLambda;
    
end
