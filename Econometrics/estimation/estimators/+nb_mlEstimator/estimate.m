function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_mlEstimator.estimate(options)
%
% Description:
%
% Estimate a model with maximum likelihood using a Kalman filter.
% 
% Input:
% 
% - options  : A struct on the format given by nb_mlEstimator.template.
%              See also nb_mlEstimator.help.
% 
% Output:
% 
% - result  : A struct with the estimation results.
%
% - options : The return model options, can change when for example using
%             the 'modelSelection' otpions.
%
% See also:
% nb_mlEstimator.print, nb_mlEstimator.help, nb_mlEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end
    options = nb_defaultField(options,'covrepair',false);
    options = nb_defaultField(options,'class','nb_var');
    options = nb_defaultField(options,'modelSelection','');
    options = nb_defaultField(options,'modelSelectionFixed',[]);
    options = nb_defaultField(options,'seasonalDummy',[]);
    
    % Are we dealing with a VAR?
    %-------------------------------------------------------
    options.exogenous = cellstr(options.exogenous);
    VAR               = false;
    if any(strcmpi(options.class,{'nb_var','nb_mfvar'}))
        VAR = true;
    end
    if strcmpi(options.class,'nb_mfvar')
        % The nb_missingEstimator does not make sense for nb_mfvar, but we 
        % want to indicated that we are dealing with missing observation
        % when producing forecast.
        options.missingMethod = 'kalman'; 
        options               = nb_mlEstimator.interpretMeasurementError(options);
    else
        options.missingMethod = 'kalman';
    end

    % Get the estimation options
    %------------------------------------------------------
    tempDep = cellstr(options.dependent);
    if isempty(tempDep)
        error([mfilename ':: No dependent variables selected, please assign the dependent field of the options property.'])
    end
    
    if isempty(options.data)
        error([mfilename ':: Cannot estimate without data.'])
    end

    if isempty(options.modelSelectionFixed)
        fixed = false(1,length(options.exogenous));
    else
        fixed = options.modelSelectionFixed;
        if ~islogical(fixed)
            fixed = logical(options.modelSelectionFixed);
        end
    end
    options.modelSelectionFixed = fixed;
    
    % Get the estimation data
    %------------------------------------------------------
    if ~isempty(options.estim_types) 
        error([mfilename ':: Only time-series is supported for the nb_mlEstimator'])
    end

    % Add seasonal dummies
    if ~isempty(options.seasonalDummy)
        options = nb_olsEstimator.addSeasonalDummies(options); 
    end
    
    % Add lags or find best model
    if ~isempty(options.modelSelection)

        if isfield(options,'class')
            options.class = '';
        end
        if strcmpi(options.class,'nb_mfvar')
            error([mfilename ':: Model selection is not supported for MF-VAR models'])
        else
            minLags = [];
            if strcmpi(options.class,'nb_var')
                minLags = 0; 
            end
            options = nb_olsEstimator.modelSelectionAlgorithm(options,minLags);
        end

    else
        if ~all(options.nLags == 0) 
            options = nb_olsEstimator.addLags(options);
        end
    end

    % Get the block exogenous restrictions
    options.restrictions = {};
    if isfield(options,'block_exogenous')
        if ~isempty(options.block_exogenous)
            tempDep              = [tempDep,options.block_exogenous];
            options.restrictions = nb_estimator.getBlockExogenousRestrictions(options);
        end
    end
    
    % Get data
    [test,indY] = ismember(tempDep,options.dataVariables);
    if any(~test)
        error([mfilename ':: The variables ' toString(tempDep(~test)) ' is not found to be in the data.'])
    end
    y = options.data(:,indY);
    if isempty(y)
        error([mfilename ':: The selected sample cannot be empty.'])
    end
    if ~isfield(options,'indObservedOnly')
        options.indObservedOnly = false(1,size(y,2));
    end
    
    [test,indX] = ismember(options.exogenous,options.dataVariables);
    if any(~test)
        error([mfilename ':: The exogenous variables ' toString(options.exogenous(~test)) ' is not found to be in the data.'])
    end
    X = options.data(:,indX);
    
    if ~VAR
        if size(X,2) == 0 && ~options.constant && ~options.time_trend
            error([mfilename ':: You must select some regressors.'])
        end
    end

    % Check for constant regressors, which we do not allow
    if any(all(diff(X,1) == 0,1))
        error([mfilename ':: One or more of the selected exogenous variables is/are constant. '...
                         'Use the constant option instead.'])
    end
    
    % Get estimation sample
    %--------------------------------------------------
    if isempty(options.estim_start_ind)
        options.estim_start_ind = 1;
    end
    if isempty(options.estim_end_ind)
        options.estim_end_ind = size(y,1);
    end
    sample = options.estim_start_ind:options.estim_end_ind;
    y      = y(sample,:);
    X      = X(sample,:);
    
    % Do the estimation
    %======================================================================
    if options.recursive_estim

        if ~isempty(options.estim_types)
            error([mfilename ':: Recursive estimation is only supported for time-series.'])
        end
        
        % Check the sample
        T      = size(y,1);
        numDep = size(y,2) - sum(options.indObservedOnly);
        numExo = size(X,2);
        if VAR
            numCoeff = options.constant + options.time_trend + options.nLags*numDep + numExo;
        else
            numCoeff = options.constant + options.time_trend + numExo;
        end
        [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,numCoeff,T);
         
        % Create waiting bar window
        waitbar = false;
        if options.waitbar
            if options.parallel
                waitbar = true; 
            else
                h = nb_estimator.openWaitbar(options,iter);
                if ~isempty(h)
                    waitbar = true;       
                    h.lock  = 2;
                    note    = nb_when2Notify(iter);
                end
            end
        else
            h = false;
        end
        
        % Find number of missing observations for each variable
        missingPer = nan(1,numDep);
        for ii = 1:numDep
            missingPer(ii) = T - find(~isnan(y(:,ii)),1,'last');
        end
        nNow = max(missingPer);
        
        % Estimate the model recursively by maximum likelihood
        %--------------------------------------------------
        beta    = nan(numCoeff,numDep,iter);
        stdBeta = nan(numCoeff,numDep,iter);
        sigma   = nan(numDep,numDep,iter);
        omega   = nan(numCoeff*numDep,numCoeff*numDep,iter);
        pD      = nan(numDep,numDep,nNow,iter);
        kk      = 1;
        init    = [];
        switch lower(options.class)
            case 'nb_mfvar'
                
                H       = nb_mlEstimator.getMeasurementEqMFVAR(options);
                nStates = size(H,2);
                ys      = nan(T,nStates,iter);
                ys0     = nan(1,nStates,iter);
                
                if options.parallel
                    
                    [beta,stdBeta,resid,sigma,omega,ys,ys0,pD] = mfvarInParallel(options,y,X,waitbar,H,beta,stdBeta,sigma,omega,pD,ss,start,missingPer);
                    
                else
                
                    resid = nan(T,numDep,iter);
                    for tt = start:T

                        if size(H,3) > 1
                            % Time-varying measurement equations
                            HT = H(:,:,ss(kk):tt);
                        else
                            HT = H;
                        end
                        yOne = nb_estimator.correctForMissing(y(ss(kk):tt,:),missingPer);
                        [beta(:,:,kk),stdBeta(:,:,kk),~,~,sigma(:,:,kk),resid(ss(kk):tt,:,kk),...
                            ys(ss(kk):tt,:,kk),~,omega(:,:,kk),pD(:,:,:,kk)] = nb_mlEstimator.mfvarEstimator(yOne,X(ss(kk):tt,:),options,HT,init);

                        % Get initial values for next iteration
                        ys0(:,:,kk) = ys(tt,:,kk);
                        betaInit    = beta(:,:,kk)';
                        sigmaInit   = nb_reduceCov(sigma(:,:,kk));
                        init        = [betaInit(:);sigmaInit];

                        % Notify waitbar
                        if waitbar 
                            nb_estimator.notifyWaitbar(h,kk,iter,note)
                        end
                        kk = kk + 1;

                    end
                    
                    % Delete the waitbar
                    if waitbar 
                        nb_estimator.closeWaitbar(h);
                    end
                    
                end
                
            case 'nb_var'

                ys    = nan(T,numDep*options.nLags,iter);
                ys0   = nan(1,numDep*options.nLags,iter);
                resid = nan(T,numDep,iter);
                for tt = start:T
                    yOne = nb_estimator.correctForMissing(y(ss(kk):tt,:),missingPer);
                    [beta(:,:,kk),stdBeta(:,:,kk),~,~,sigma(:,:,kk),resid(ss(kk):tt,:,kk),...
                        ys(ss(kk):tt,:,kk),~,omega(:,:,kk),pD(:,:,:,kk)] = nb_mlEstimator.varEstimator(...
                        yOne,X(ss(kk):tt,:),options,init);
                    
                    % Get initial values for next iteration
                    ys0(:,:,kk) = ys(tt,:,kk);
                    betaInit    = beta(:,:,kk)';
                    sigmaInit   = nb_reduceCov(sigma(:,:,kk));
                    init        = [betaInit(:);sigmaInit]; 
                    
                    % Notify waitbar
                    if waitbar 
                        nb_estimator.notifyWaitbar(h,kk,iter,note)
                    end
                    kk = kk + 1;
                    
                end
                
                % Delete the waitbar
                if waitbar 
                    nb_estimator.closeWaitbar(h);
                end
                
            otherwise
                error([mfilename 'Cannot set ''estim_method'' to ''ml'' for the class ' option.class ' class.'])
        end 
        
        % Get estimation results
        %--------------------------------------------------
        res          = struct();
        res.beta     = beta;
        res.stdBeta  = stdBeta;
        res.sigma    = sigma;
        res.omega    = omega;
        res.residual = resid;
        res.ys0      = ys0; 
        res.pD       = pD;
        
    %======================
    else % Not recursive
    %======================
    
        % Shorten sample
        numCoeff = size(X,2) + options.constant;
        N        = size(X,1);
        nb_estimator.checkDOF(options,numCoeff,N);

        % Estimate model by maximum likelihood
        %--------------------------------------------------
        switch lower(options.class)
            case 'nb_mfvar'
                H     = nb_mlEstimator.getMeasurementEqMFVAR(options);
                [beta,stdBeta,tStatBeta,pValBeta,sigma,resid,ys,lik,omega,pD] = nb_mlEstimator.mfvarEstimator(y,X,options,H,[]);
            case 'nb_var'
                [beta,stdBeta,tStatBeta,pValBeta,sigma,resid,ys,lik,omega,pD] = nb_mlEstimator.varEstimator(y,X,options,[]);
            otherwise
                error([mfilename 'Cannot set ''estim_method'' to ''ml'' for the class ' option.class ' class.'])
        end 
     
        % Get estimation results
        %--------------------------------------------------
        res            = struct();
        res.beta       = beta;
        res.stdBeta    = stdBeta;
        res.tStatBeta  = tStatBeta;
        res.pValBeta   = pValBeta;
        res.residual   = resid;
        res.sigma      = sigma;
        res.omega      = omega;
        res.pD         = pD;
        nDep           = size(y,2);
        yObs           = ys(:,1:nDep);
        res.predicted  = yObs(:,~options.indObservedOnly) - resid;
        
        % Get aditional test results
        %--------------------------------------------------
        if options.doTests
        
            T = size(resid,1);
            
            [numCoeff,numEq]       = size(beta);
            [rSquared,adjRSquared] = nb_rSquared(yObs(:,~options.indObservedOnly),resid,numCoeff);
            logLikelihood          = nb_olsLikelihood(resid);

            if (numCoeff == 1 && options.constant) || ~options.constant || any(rSquared < 0)
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
            res.dwtest        = nb_durbinWatson(resid);
            res.archTest      = nb_archTest(resid,round(options.nLagsTests));
            res.autocorrTest  = nb_autocorrTest(resid,round(options.nLagsTests));
            res.normalityTest = nb_normalityTest(resid,numCoeff);
            [res.SERegression,res.sumOfSqRes]  = nb_SERegression(resid,numCoeff);

            % White test on each equation (also the block exogenous)
            nEq           = size(beta,2);
            res.whiteTest = nan(1,nEq);
            res.whiteProb = nan(1,nEq);

            % Full system 
            res.fullLogLikelihood = -lik;
            res.aicFull           = nb_infoCriterion('aic',res.fullLogLikelihood,T,numCoeff);
            res.sicFull           = nb_infoCriterion('sic',res.fullLogLikelihood,T,numCoeff);
            res.hqcFull           = nb_infoCriterion('hqc',res.fullLogLikelihood,T,numCoeff);
            
        end
        
    end

    % Report filtering/estimation dates
    dataStart           = nb_date.date2freq(options.dataStartDate);
    res.filterStartDate = toString(dataStart + options.estim_start_ind - 1);
    res.filterEndDate   = toString(dataStart + options.estim_end_ind - 1);
    res.realTime        = false;
    
    if strcmpi(options.class,'nb_mfvar')
        if options.recursive_estim
            [ys,allEndo,exo] = nb_bVarEstimator.getAllMFVariablesRec(options,ys,H,tempDep,ss,start);
        else
            [ys,allEndo,exo] = nb_bVarEstimator.getAllMFVariables(options,ys,H,tempDep);
        end
    else
        allEndo = [tempDep,nb_cellstrlag(tempDep,options.nLags-1)];
        exo     = strcat('E_',tempDep);
    end
    res.smoothed.variables = struct('data',ys,'startDate',res.filterStartDate,'variables',{allEndo});
    res.smoothed.shocks    = struct('data',resid,'startDate',res.filterStartDate,'variables',{exo});
    
    % Assign generic results
    res.includedObservations = size(y,1);
    res.elapsedTime          = toc(tStart);
    res.y                    = y;
    res.X                    = X;
    
    % Assign results
    results = res;
    options.estimator = 'nb_mlEstimator';
    options.estimType = 'classic';

end

%==========================================================================
function [beta,stdBeta,resid,sigma,omega,ys,ys0,pD] = mfvarInParallel(options,y,X,waitbar,H,beta,stdBeta,sigma,omega,pD,ss,start,missing)

    % Do we want a waitbar?
    iter = size(beta,3);
    T    = size(y,1);
    if waitbar
        [waitbar,D] = nb_parCheck();
        if waitbar
            h      = nb_waitbar([],'Recursive estimation',iter,false,false);
            h.text = 'Working...';
            afterEach(D,@(x)nb_updateWaitbarParallel(x,h));
        end
    end

    % Open parallel pool if not already open
    ret = nb_openPool(options.cores);

    % Preallocate
    tt   = start:T;
    ysC  = cell(iter,1);
    resC = cell(iter,1);
    
    % Initial estimation
    if size(H,3) > 1
        % Time-varying measurement equations
        HT = H(:,:,ss(1):tt(1));
    else
        HT = H;
    end
    yOne = nb_estimator.correctForMissing(y(ss(1):tt(1),:),missing);
    [beta(:,:,1),stdBeta(:,:,1),~,~,sigma(:,:,1),resC{1},...
        ysC{1},~,omega(:,:,1),pD(:,:,:,1)] = nb_mlEstimator.mfvarEstimator(yOne,X(ss(1):tt(1),:),options,HT,[]);

    % Get initial values used for all the other iterations                  
    betaInit    = beta(:,:,1)';
    sigmaInit   = nb_reduceCov(sigma(:,:,1));
    init        = [betaInit(:);sigmaInit];
    
    % Notify waitbar
    if waitbar 
        send(D,1); % Update waitbar
    end
    
    % Turn of display during optimization
    options.optimset.Display = 'off';
    
    % Run loop
    parfor kk = 2:iter

        if size(H,3) > 1
            % Time-varying measurement equations
            HT = H(:,:,ss(kk):tt(kk));
        else
            HT = H;
        end
        yOne = y;
        yOne = nb_estimator.correctForMissing(yOne,missing);
        XOne = X;
        
        [beta(:,:,kk),stdBeta(:,:,kk),~,~,sigma(:,:,kk),resC{kk},...
            ysC{kk},~,omega(:,:,kk),pD(:,:,:,kk)] = nb_mlEstimator.mfvarEstimator(yOne(ss(kk):tt(kk),:),XOne(ss(kk):tt(kk),:),options,HT,init);

        % Notify waitbar
        if waitbar 
            send(D,1); % Update waitbar
        end

    end

    % Close parallel pool only if it where open locally
    nb_closePool(ret);

    % Convert smoothed estimates to double
    nStates = size(H,2);
    ys      = nan(T,nStates,iter);
    ys0     = nan(1,nStates,iter);
    resid   = nan(T,size(beta,2),iter);
    for ii = 1:iter
        ys(ss(ii):tt(ii),:,ii)    = ysC{ii};
        ys0(:,:,ii)               = ys(tt(ii),:,ii);
        resid(ss(ii):tt(ii),:,ii) = resC{ii};
    end

    if waitbar
        delete(h);
    end

end
