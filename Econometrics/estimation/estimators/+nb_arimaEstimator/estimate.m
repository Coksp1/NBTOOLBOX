function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_arimaEstimator.estimate(options)
%
% Description:
%
% Estimate a ARIMA model with a selected algorithm.
% 
% Input:
% 
% - options  : A struct on the format given by nb_arimaEstimator.template.
%              See also nb_arimaEstimator.help.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : The return model options.
%
% See also:
% nb_arimaEstimator.print, nb_arimaEstimator.help, 
% nb_arimaEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end
            
    % Get the estimation options
    if isempty(options.data)
        error([mfilename ':: Cannot estimate without data.'])
    end
    options = nb_defaultField(options,'removeZeroRegressors',false);
    options = nb_defaultField(options,'transition',[]);
    options = nb_defaultField(options,'covidAdj',{});
    options = nb_defaultField(options,'nStep',0);
    options = nb_defaultField(options,'estim_types',{});

    % Estimate
    if options.recursive_estim

        % When we are doing recursive estimation we don't
        % need the fancy printouts, so we write the 
        % estimation more compact
        [results,options] = recursiveEstimation(options);
        tempDep           = options.dependent;
        [~,indY]          = ismember(tempDep,options.dataVariables);
        
    else % Normal estimation

        % Find the variable of interest
        tempDep = options.dependent;
        if length(tempDep) ~= 1
            error([mfilename ':: The dependent field of the options property must have length 1 for ARIMA models.'])
        end
        tempExo  = cellstr(options.exogenous);
        tempData = options.data;
        
        % Get model
        if isnan(options.AR)
            maxAR = options.maxAR;
        else
            maxAR = options.AR;
        end
        if isnan(options.MA)
            maxMA = options.maxMA;
        else
            maxMA = options.MA;
        end
        sp     = 0;
        maxSAR = 0;
        if options.SAR > 0
            maxSAR = 1;
            sp     = options.SAR;
        end
        sq     = 0;
        maxSMA = 0;
        if options.SMA > 0
            maxSMA = 1;
            sq     = options.SMA;
        end

        % Get data
        [testY,indY] = ismember(tempDep,options.dataVariables);
        [testZ,indZ] = ismember(tempExo,options.dataVariables);
        if any(~testY)
            error(['Some of the dependent variable are not found to be ',...
                'in the dataset; ' toString(tempDep(~testY))])
        end
        if any(~testZ)
            error(['Some of the exogenous variable are not found to be ',...
                'in the dataset; ' toString(tempExo(~testZ))])
        end
        y             = tempData(:,indY);
        z             = tempData(:,indZ);
        [options,y,z] = nb_estimator.testSample(options,y,z);

        % Check the sample
        numCoeff = maxAR + maxMA + maxSAR + maxSMA + options.constant;
        T        = size(y,1);
        sample   = T - options.requiredDegreeOfFreedom - numCoeff - options.integration - options.AR - options.MA*2 + 2;
        needed   = options.requiredDegreeOfFreedom + numCoeff + options.integration + options.AR + options.MA*2 + 2;
        if sample < 1
            error(['The sample is too short for estimation. At least ',...
                int2str(options.requiredDegreeOfFreedom) ' degrees of ',...
                'freedom are required. Which require a sample of at least ',...
                int2str(needed) ' observations.'])
        end
        
        if options.removeZeroRegressors
            ind  = ~all(abs(z) < eps);
        else
            ind  = true(1,size(z,2));
        end
        
        if ~isempty(options.transition)
            if size(options.transition,2) ~= size(z,2)
                error(['The transition options must match the number of ',...
                    'exogenous variables (' int2str(size(z,2)) ').'])
            end
            x    = z(:,options.transition);
            indX = ind(options.transition);
            z    = z(:,~options.transition);
            ind  = ind(~options.transition);
        else
            x    = nan(size(z,1),0);
            indX = false(1,0);
        end

        % Ignore some covid dates?
        indCovid = nb_estimator.applyCovidFilter(options,y);
        
        % Estimate the model
        %--------------------------------------------------
        p    = options.AR;
        i    = options.integration;
        q    = options.MA;
        mRes = nb_arimaFunc(y,p,i,q,sp,sq,...
            'alpha',        options.alpha,...
            'constant',     options.constant,...
            'covrepair',    options.covrepair,...
            'criterion',    options.criterion,...
            'exo',          z(:,ind),...
            'texo',         x(:,indX),...
            'filter',       true,...
            'maxAR',        options.maxAR,...  
            'maxMA',        options.maxMA,...
            'method',       options.algorithm,...
            'optimizer',    options.optimizer,...
            'options',      options.optimset,...
            'prior',        options.prior,...
            'stabilityTest',options.stabilityTest,...
            'test',         false,...
            'remove',       indCovid);

        options.AR          = mRes.AR;
        options.integration = mRes.i;
        options.MA          = mRes.MA;

        % Get estimation results
        %--------------------------------------------------
        results  = struct();
        numCoeff = options.AR + options.MA + maxSAR + maxSMA + options.constant + size(z,2) + size(x,2);
        if options.removeZeroRegressors
            numEq                     = size(y,2);
            indA                      = [true(1,numCoeff - size(x,2) - size(z,2)), indX, ind];
            results.beta              = zeros(numCoeff,numEq);
            results.beta(indA,:)      = mRes.beta;
            results.stdBeta           = nan(numCoeff,numEq);
            results.stdBeta(indA,:)   = mRes.stdBeta; 
            results.tStatBeta         = nan(numCoeff,numEq);
            results.tStatBeta(indA,:) = mRes.tStatBeta;
            results.pValBeta          = nan(numCoeff,numEq);
            results.pValBeta(indA,:)  = mRes.pValBeta;
        else
            results.beta      = mRes.beta;
            results.stdBeta   = mRes.stdBeta; 
            results.tStatBeta = mRes.tStatBeta;
            results.pValBeta  = mRes.pValBeta;
        end
        
        numCoeff           = size(results.beta,1);
        T                  = size(mRes.residual,1);
        results.residual   = mRes.residual;
        results.u          = mRes.u;
        results.sigma      = mRes.sigma;
        results.predicted  = mRes.y;
        results.regressors = mRes.X;

        results.includedObservations = size(results.residual,1);
        
        % Get residual from measurement error
        uRes = nb_arimaEstimator.getMeasurementEqRes(options,sq,sp,...
            mRes.beta,mRes.y,mRes.z,mRes.x);
        
        % Store numerically estimated Hessian
        if isfield(mRes,'omega')
            results.omega = mRes.omega;
        end
        
        % Get aditional test results
        %--------------------------------------------------
        if options.doTests
            results.logLikelihood   = mRes.likelihood;
            results.aic             = nb_infoCriterion('aic',results.logLikelihood,T,numCoeff+1);
            results.sic             = nb_infoCriterion('sic',results.logLikelihood,T,numCoeff+1);
            results.hqc             = nb_infoCriterion('hqc',results.logLikelihood,T,numCoeff+1);
            results.fTest           = nan;
            results.fProb           = nan; 
            results.dwtest          = nb_durbinWatson(mRes.residual);
            results.archTest        = nb_archTest(mRes.residual,round(options.nLagsTests));
            results.autocorrTest    = nb_autocorrTest(mRes.residual,round(options.nLagsTests));
            results.normalityTest   = nb_normalityTest(mRes.residual,numCoeff);
            [results.SERegression,results.sumOfSqRes] = nb_SERegression(mRes.residual,numCoeff);
            [results.rSquared,results.adjRSquared]    = nb_rSquared(mRes.y,mRes.residual,numCoeff);
            
        end
        
        % Adjust estimation start date (data will be lagged and diff)
        endInd = options.estim_end_ind;
        start  = endInd - T + 1;
        options.estim_start_ind = start;
        
        % Add the residual to the data, used by forcast methods (Forward
        % one period, as this will be the starting values when doing 
        % forecast)
        tempData = options.data;
        MAterms  = options.MA + options.SMA;
        if MAterms > 0
            reslag                = nb_mlag(mRes.residual,MAterms-1); 
            [s1,s2]               = size(tempData);
            tempData              = [tempData,nan(s1,MAterms)];
            tt                    = start:endInd;
            tempData(tt,s2+1:end) = [mRes.residual,reslag];
            namesOfRes            = nb_cellstrlag({'U'},MAterms);
            namesOfRes            = strcat('E_',namesOfRes);
            options.dataVariables = [options.dataVariables,namesOfRes];
        end
        
        % Add the u to the data, used by forcast methods (Forward
        % one period, as this will be the starting values when doing 
        % forecast)
        ARterms  = options.AR + options.SAR;
        if ARterms > 0
            ulag                  = nb_mlag(uRes,ARterms-1);
            [s1,s2]               = size(tempData);
            tempData              = [tempData,nan(s1,ARterms)];
            tt                    = start:endInd;
            U                     = [uRes,ulag];
            tempData(tt,s2+1:end) = U;%(ARterms+options.integration+1:end,:);
            namesOfU              = [{'U'},nb_cellstrlag({'U'},ARterms-1)];
            options.dataVariables = [options.dataVariables,namesOfU];
        end
        options.data = tempData;
        
    end
    
    % Add the possibly differenced data to the sample, used by forecast 
    % methods
    tempData = options.data;
    i        = options.integration;
    if i >0
        y        = tempData(:,indY);
        diffY    = nan(size(y,1),i);
        diffName = cell(1,i);
        for jj = 1:i
            y            = [nan;diff(y)];
            diffY(:,jj)  = y;
            diffName{jj} = ['diff' int2str(jj) '_' tempDep{1}];
            
        end
        tempData              = [tempData,diffY];
        options.dependent{1}  = ['diff' int2str(i) '_' tempDep{1}];
        options.dataVariables = [options.dataVariables,diffName];
    end

    % Assign output
    options.data        = tempData;
    results.elapsedTime = toc(tStart);
    
    options.estimator = 'nb_arimaEstimator';
    if strcmpi(options.algorithm,'bayesian')
        options.estimType = 'bayesian';
    else
        options.estimType = 'classic';
    end

end

%==================================================================
% SUB
%==================================================================
function [res,options] = recursiveEstimation(options)

    % Get model
    p = options.AR;
    q = options.MA;
    i = options.integration;
    if isnan(p) || isnan(q) || isnan(i)
        error([mfilename ':: Recursive estimation can only be done if the number of AR and MA terms are given, '...
            'as well as the degree of integration. See options struct.'])
    end

    sp     = 0;
    maxSAR = 0;
    if options.SAR > 0
        maxSAR = 1;
        sp     = options.SAR;
    end
    sq     = 0;
    maxSMA = 0;
    if options.SMA > 0
        maxSMA = 1;
        sq     = options.SMA;
    end
    
    % Find the variable of interest
    tempDep = options.dependent;
    if length(tempDep) ~= 1
        error([mfilename ':: The dependent field of the options property must have length 1 for ARIMA models.'])
    end
    tempExo  = cellstr(options.exogenous);
    tempData = options.data;

    % Get data
    [testY,indY] = ismember(tempDep,options.dataVariables);
    [testZ,indZ] = ismember(tempExo,options.dataVariables);
    if any(~testY)
        error([mfilename ':: Some of the dependent variable are not found to be in the dataset; ' toString(tempDep(~testY))])
    end
    if any(~testZ)
        error([mfilename ':: Some of the exogenous variable are not found to be in the dataset; ' toString(tempExo(~testZ))])
    end
    y             = tempData(:,indY);
    z             = tempData(:,indZ);
    [options,y,z] = nb_estimator.testSample(options,y,z);
    startInd      = options.estim_start_ind;
    endInd        = options.estim_end_ind;
    
    % Check the sample
    numCoeff = options.AR + options.MA + maxSAR + maxSMA + options.constant + size(z,2);
    if options.MA > 0
        crit = numCoeff + options.integration + options.AR + options.MA*2 + 2;
    else
        crit = numCoeff;
    end
    T                       = size(y,1);
    [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,crit,T);
    
    % Create waiting bar window
    waitbar = false;
    if options.waitbar && iter ~= 1
        h       = nb_estimator.openWaitbar(options,iter);
        note    = nb_when2Notify(iter);
        waitbar = ~isempty(h);
    end
    
    % Store Hessian for ML estimation
    method     = options.algorithm;
    storeOmega = false;
    if strcmpi(method,'ml')
        omega      = nan(numCoeff,numCoeff,iter);
        storeOmega = true;
    end
    
    % Get the differenced data if the ARIMA is integrated
    yTrans = y;
    if i > 0
        for ii = 1:i
            yTrans = nb_diff(yTrans,1);
        end
    end
    
    % Split exogenous variables into those of the observation equation
    % and those of the transition equation.
    if ~isempty(options.transition)
        if size(options.transition,2) ~= size(z,2)
            error(['The transition options must match the number of exogenous variables (' int2str(size(z,2)) ').'])
        end
        x = z(:,options.transition);
        z = z(:,~options.transition);
    else
        x = nan(size(z,1),0);
    end

    % Ignore some covid dates?
    indCovid = nb_estimator.applyCovidFilter(options,y);
    
    % Estimate the model recursively
    %--------------------------------------------------
    MAterms  = q + sq;
    ARterms  = p + sp;
    beta     = zeros(numCoeff,1,iter);
    stdBeta  = nan(numCoeff,1,iter);
    vcv      = nan(1,1,iter);
    residual = nan(T,1,iter); % Needed to get starting values for recursive forecast
    resEnd   = nan(iter,MAterms);
    uEnd     = nan(iter,ARterms);
    kk       = 1;
    for tt = start:T
             
        if options.removeZeroRegressors
            ind  = ~all(abs(z(ss(kk):tt,:)) < eps,1);
            indX = ~all(abs(x(ss(kk):tt,:)) < eps,1);
            indA = [true(1,numCoeff - size(z,2) - size(x,2)), indX, ind];
        else
            ind   = true(1,size(z,2));
            indX  = true(1,size(x,2));
            indA  = true(1,numCoeff);
        end

        if ~isempty(indCovid)
            indCovidTT = indCovid(ss(kk):tt,:);
        else
            indCovidTT = [];
        end
        
        % Estimate ARIMA model
        mRes = nb_arimaFunc(y(ss(kk):tt,:),p,i,q,sp,sq,...
            'constant',     options.constant,...
            'covrepair',    options.covrepair,...
            'criterion',    options.criterion,...
            'exo',          z(ss(kk):tt,ind),...
            'texo',         x(ss(kk):tt,indX),...
            'filter',       true,...
            'method',       options.algorithm,...
            'optimizer',    options.optimizer,...
            'options',      options.optimset,...
            'prior',        options.prior,...
            'stabilityTest',options.stabilityTest,...
            'test',         false,...
            'remove',       indCovidTT);         
         
        % Store needed estimation results
        res                 = mRes.residual;
        s                   = tt - size(res,1) + 1;   
        beta(indA,:,kk)     = mRes.beta;
        stdBeta(indA,:,kk)  = mRes.stdBeta;  
        vcv(:,:,kk)         = mRes.sigma;
        residual(s:tt,:,kk) = res;   
        resEnd(kk,:)        = res(end-MAterms+1:end)';
        
        % Get initial condition for forecasting
        uEnd(kk,:) = nb_arimaEstimator.getMeasurementEqRes(options,sq,sp,...
            beta(:,:,kk),yTrans(tt-ARterms+1:tt,:),z(tt-ARterms+1:tt,:),...
            x(tt-ARterms+1:tt,:))';
        if storeOmega
            omega(indA,indA,kk) = mRes.omega;
        end
        
        % Report current state in the waitbar's message field
        if waitbar 
            nb_estimator.notifyWaitbar(h,kk,iter,note)
        end
        
        kk = kk + 1;
        
    end
    
    % Delete the waitbar
    if waitbar 
        nb_estimator.closeWaitbar(h);
    end
    
    % Add the residual to the data, used by forcast methods (Forward
    % one period, as this will be the starting values when doing 
    % forecast)
    if MAterms > 0
        tempData              = options.data;
        [s1,s2]               = size(tempData);
        tempData              = [tempData,nan(s1,MAterms)];
        tt                    = startInd-1+start:endInd;
        tempData(tt,s2+1:end) = fliplr(resEnd);
        namesOfRes            = nb_cellstrlag({'U'},MAterms);
        namesOfRes            = strcat('E_',namesOfRes);
        options.dataVariables = [options.dataVariables,namesOfRes];
    end
    
    % Add the u to the data, used by forcast methods (Forward
    % one period, as this will be the starting values when doing 
    % forecast)
    if ARterms > 0
        [s1,s2]               = size(tempData);
        tempData              = [tempData,nan(s1,ARterms)];
        tt                    = startInd-1+start:endInd;
        tempData(tt,s2+1:end) = fliplr(uEnd);
        namesOfU              = [{'U'},nb_cellstrlag({'U'},ARterms-1)];
        options.dataVariables = [options.dataVariables,namesOfU];
    end    
    options.data = tempData;
    
    % Get estimation results
    %--------------------------------------------------
    res           = struct();
    res.beta      = beta;
    res.stdBeta   = stdBeta;
    res.sigma     = vcv;
    res.residual  = residual;
    if storeOmega
        res.omega = omega;
    end
    
end
