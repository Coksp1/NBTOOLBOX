function [res,options] = recursiveEstimation(options,y,X,mfvar,missing)
% Syntax:
%
% [res,options] = nb_bVarEstimator.recursiveEstimation(options,y,X,...
%                                   mfvar,missing)
%
% Description:
%
% Estimate B-VAR model recursivly.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    options = nb_defaultField(options,'parallel',false);
    options = nb_defaultField(options,'cores',[]);
    if options.empirical || options.hyperLearning
        error([mfilename ':: Empirical bayesian or hyper learning is not supported for recursivly ',...
                         'estimated VARs. Estimate the model over the full sample first ',...
                         'then assume these estimated hyperparameters as fixed when ',...
                         'estimating the model recursivly.'])
    end

    % Shorten sample
    if missing || mfvar
        if isempty(options.estim_start_ind)
            options.estim_start_ind = 1;
        end
        if isempty(options.estim_end_ind)
            options.estim_end_ind = size(y,1);
        end
        if ~isfield(options,'indObservedOnly')
            options.indObservedOnly = false(1,size(y,2));
        end
        sample = options.estim_start_ind:options.estim_end_ind;
        y      = y(sample,:);
        X      = X(sample,:);
        if any(isnan(X(:)))
            test = any(isnan(X),1);
            error([mfilename ':: The estimation data on some of the exogenous variables are ',...
                   'missing for the selected sample; ' toString(options.exogenous(test))])
        end
        numCoeff = options.nLags*(size(y,2) - sum(options.indObservedOnly)) + size(X,2) + options.constant + options.time_trend;
    else
        yFull         = y;
        XFull         = X;
        [options,y,X] = nb_estimator.testSample(options,y,X);
        testData      = [y,X];
        if any(isnan(testData(:)))
            error([mfilename ':: The estimation data is not balanced.'])
        end
        numCoeff = size(X,2) + options.constant + options.time_trend;
    end
    
    % Get stochastic volatility prior
    if options.prior.SVD
        options = nb_bVarEstimator.getSVDPrior(options,y);
    end
    
    % Check the sample
    T                       = size(y,1);
    [start,iter,ss,options] = nb_estimator.checkDOFRecursive(options,numCoeff,T);

    % Check if we need have a block_exogenous model
    %----------------------------------------------
    restrictions = {};
    if isfield(options,'block_exogenous')
        if ~isempty(options.block_exogenous)
            restrictions = nb_estimator.getBlockExogenousRestrictions(options);
        end
    end
    
    % Create waiting bar window
    waitbar = false;
    note    = inf;
    if options.waitbar
        if options.parallel
            waitbar = true; 
        else
            h = nb_estimator.openWaitbar(options,iter);
            if ~isempty(h)
                waitbar = true;       
                h.lock  = 2;
                note    = nb_when2Notify(iter);
            else
                h = false;
            end
        end
    else
        h = false;
    end

    % Estimate the model recursively
    %--------------------------------------------------
    numObs = size(y,2);
    iter   = T - start + 1;
    if mfvar || missing
        
        if options.prior.LR
            error([mfilename ':: Prior for the long run is not supported for Mixed frequency VARs or VARs with missing observations.'])
        end
        if options.empirical
            error([mfilename ':: Empirical bayesian is not supported for Mixed frequency VARs ',...
                             'or VARs with missing observations.'])
        end
        
        nLags = options.nLags;
        if mfvar
              
            % Add one extra state variable here, if only 'end' mapping
            % is used
            [H,freq,extra] = nb_mlEstimator.getMeasurementEqMFVAR(options,1);
            
            % Store the mixing options in the prior
            mixing = nb_bVarEstimator.getMixing(options);
            numDep = numObs - sum(options.indObservedOnly);
        else
            % Add one extra state variable here
            numDep = numObs;
            H      = [eye(numDep),zeros(numDep,numDep*(options.nLags))]; 
            extra  = true;
            freq   = [];
            mixing = [];
        end
        if ~nb_isempty(options.measurementEqRestriction)
            [H,y,mixing]            = nb_bVarEstimator.applyMeasurementEqRestriction(H,y,options,mixing);
            options.indObservedOnly = mixing.indObservedOnly;
            numObs                  = size(y,2);
        end
        
        nStates = size(H,2);
        
        sizes = struct(...
            'numCoeff',numCoeff,...
            'numDep',numDep,...
            'numObs',numObs,...
            'iter',iter,...
            'nStates',nStates,...
            'ss',ss,...
            'start',start,...
            'T',T,...
            'nLags',options.nLags);
        
        % Find number of missing observations for each variable
        missingPer = nan(1,numObs);
        for ii = 1:numObs
            missingPer(ii) = T - find(~isnan(y(:,ii)),1,'last');
        end
        
        if options.parallel
            [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doBayesianMFParallel(options,y,X,restrictions,waitbar,freq,H,mixing,sizes,missingPer);
        else
            [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doBayesianMFNormal(options,y,X,restrictions,waitbar,note,freq,H,mixing,sizes,missingPer);
        end 
        
    %======================================================================
    else % Not missing or mixed-frequency
    %======================================================================
    
        if options.empirical
            error('Emprirical bayesian is not yet supported for recursive estimation.')
        end
        if ~nb_isempty(options.measurementEqRestriction)
            error(['Cannot apply the measurementEqRestriction option for ',...
                   'the prior; ' options.prior.type])
        end
    
        numDep = numObs;
        sizes  = struct(...
            'numCoeff',numCoeff,...
            'numDep',numDep,...
            'iter',iter,...
            'ss',ss,...
            'start',start,...
            'T',T);
        nLags = options.nLags + 1;
        if options.parallel
            [beta,stdBeta,sigma,stdSigma,posterior] = doBayesianParallel(options,y,X,yFull,XFull,restrictions,waitbar,sizes);
        else
            [beta,stdBeta,sigma,stdSigma,posterior] = doBayesianNormal(options,y,X,yFull,XFull,restrictions,h,note,sizes);
        end 
        R = [];
    
    end
    
    % Save the posterior draws to a .mat file
    if options.saveDraws
        posterior          = [posterior{:}];
        options.pathToSave = nb_saveDraws(options.name,posterior);
    else
        options.pathToSave = '';
    end
    
    % Delete the waitbar
    if waitbar 
        if ~options.parallel
            nb_estimator.closeWaitbar(h);
        end
    end
    
    % Get estimation results
    %--------------------------------------------------
    res           = struct();
    res.beta      = beta;
    res.stdBeta   = stdBeta;
    res.sigma     = sigma;
    res.stdSigma  = stdSigma;
    res.R         = R;
    
    % Report filtering/estimation dates
    if mfvar || missing

        tempDep  = cellstr(options.dependent);
        if isfield(options,'block_exogenous')
           tempDep = [tempDep,options.block_exogenous];
        end
        
        dataStart           = nb_date.date2freq(options.dataStartDate);
        res.filterStartDate = toString(dataStart + options.estim_start_ind - 1 + options.nLags);
        res.filterEndDate   = toString(dataStart + options.estim_end_ind - 1);
        res.realTime        = false;

        if extra
            H   = H(:,1:numDep*nLags,:);
            ys  = ys(:,1:numDep*nLags,:);
            ys0 = ys0(:,1:numDep*nLags,:);
        end
        if mfvar || ~nb_isempty(options.measurementEqRestriction)
            % Get the low frequency smoothed variables
            [ys,allEndo] = nb_bVarEstimator.getAllMFVariablesRec(options,ys,H,tempDep,ss,start);
        else
            allEndo = [tempDep,nb_cellstrlag(tempDep,options.nLags-1)];
        end
        res.smoothed.variables = struct('data',ys,'startDate',res.filterStartDate,'variables',{allEndo});
        res.smoothed.shocks    = struct('data',nan(size(ys,1),0,size(ys,3)),'startDate',res.filterStartDate,'variables',{{}});
        res.ys0                = ys0;
        
    end
    
end

%==========================================================================
function [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doBayesianMFNormal(options,y,X,restrictions,h,note,freq,H,mixing,sizes,missing)

    if options.prior.SVD
        obsSVD = options.prior.obsSVD;
    else
        obsSVD = 0;
    end

    nLags      = options.nLags;
    ys         = nan(sizes.T - sizes.nLags,sizes.nStates,sizes.iter);
    ys0        = nan(1,sizes.nStates,sizes.iter);
    beta       = nan(sizes.numCoeff,sizes.numDep,sizes.iter);
    sigma      = nan(sizes.numDep,sizes.numDep,sizes.iter);
    stdBeta    = nan(size(beta));
    stdSigma   = nan(size(sigma));
    R          = nan(sizes.numObs,1,sizes.iter);
    posterior  = cell(1,sizes.iter);
    ss         = sizes.ss;
    waitbar    = ~islogical(h); % Then h is a waitbar
    kk         = 1;
    iter       = sizes.iter;
    for tt = sizes.start:sizes.T
        if size(H,3) > 1
            % Time-varying measurement equations
            HT = H(:,:,ss(kk):tt);
        else
            HT = H;
        end
        tts  = tt-sizes.nLags;
        yOne = nb_estimator.correctForMissing(y(ss(kk):tt,:),missing);
        [betaD,sigmaD,R(:,:,kk),ys(ss(kk):tts,:,kk),~,posterior{kk}] = ...
            nb_bVarEstimator.doBayesianMF(options,h,nLags,restrictions,yOne,X(ss(kk):tt,:),freq,HT,mixing,obsSVD - ss(kk) + 1);
        [beta(:,:,kk),stdBeta(:,:,kk),sigma(:,:,kk),stdSigma(:,:,kk)] = takeMean(betaD,sigmaD);
        ys0(:,:,kk) = ys(tts,:,kk);
        if waitbar 
            nb_estimator.notifyWaitbar(h,kk,iter,note)
        end
        kk = kk + 1;
    end

end

%==========================================================================
function [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doBayesianMFParallel(options,y,X,restrictions,waitbar,freq,H,mixing,sizes,missing)

    if options.prior.SVD
        obsSVD = options.prior.obsSVD;
    else
        obsSVD = 0;
    end

    % Do we want a waitbar?
    if waitbar
        [waitbar,D] = nb_parCheck();
        if waitbar
            h      = nb_waitbar([],'Recursive estimation',sizes.iter,false,false);
            h.text = 'Working...';
            afterEach(D,@(x)nb_updateWaitbarParallel(x,h));
        end
    end
    
    % Open parallel pool if not already open
    ret = nb_openPool(options.cores);

    % Do the recursive estimation
    nLags      = options.nLags;
    ysC        = cell(sizes.iter,1);
    beta       = nan(sizes.numCoeff,sizes.numDep,sizes.iter);
    sigma      = nan(sizes.numDep,sizes.numDep,sizes.iter);
    R          = nan(sizes.numObs,1,sizes.iter);
    stdBeta    = nan(size(beta));
    stdSigma   = nan(size(sigma));
    posterior  = cell(1,sizes.iter);
    tt         = sizes.start:sizes.T;
    ss         = sizes.ss;
    parfor kk = 1:sizes.iter
        if size(H,3) > 1
            % Time-varying measurement equations
            HT = H(:,:,ss(kk):tt(kk));
        else
            HT = H;
        end
        yOne = y;
        yOne = nb_estimator.correctForMissing(yOne(ss(kk):tt(kk),:),missing);
        XOne = X;
        [betaD,sigmaD,R(:,:,kk),ysC{kk},~,posterior{kk}] = nb_bVarEstimator.doBayesianMF(...
            options,false,nLags,restrictions,yOne,XOne(ss(kk):tt(kk),:),freq,HT,mixing,obsSVD - ss(kk) + 1);    
        [beta(:,:,kk),stdBeta(:,:,kk),sigma(:,:,kk),stdSigma(:,:,kk)] = takeMean(betaD,sigmaD);
        if waitbar 
            send(D,1); % Update waitbar
        end
    end
    
    % Close parallel pool only if it where open locally
    nb_closePool(ret);
    
    % Convert smoothed estimates to double
    ys  = nan(sizes.T-sizes.nLags,sizes.nStates,sizes.iter);
    ys0 = nan(1,sizes.nStates,sizes.iter);
    for ii = 1:sizes.iter
        ys(ss(ii):tt(ii)-sizes.nLags,:,ii) = ysC{ii};
        ys0(:,:,ii)                        = ys(tt(ii)-sizes.nLags,:,ii);
    end
    
    if waitbar
        delete(h);
    end
    
end

%==========================================================================
function [beta,stdBeta,sigma,stdSigma,posterior] = doBayesianNormal(options,y,X,yFull,XFull,restrictions,h,note,sizes)

    if options.prior.SVD
        obsSVD = options.prior.obsSVD;
    else
        obsSVD = 0;
    end

    beta      = nan(sizes.numCoeff,sizes.numDep,sizes.iter);
    sigma     = nan(sizes.numDep,sizes.numDep,sizes.iter);
    stdBeta   = nan(size(beta));
    stdSigma  = nan(size(sigma));
    posterior = cell(1,sizes.iter);
    ss        = sizes.ss;
    nLags     = options.nLags + 1;
    waitbar   = ~islogical(h); % Then h is a waitbar
    kk        = 1;
    iter      = sizes.iter;
    for tt = sizes.start:sizes.T 
        [betaD,sigmaD,~,posterior{kk}] = nb_bVarEstimator.doBayesian(...
        	options,h,nLags,restrictions,y(ss(kk):tt,:),X(ss(kk):tt,:),...
            yFull(ss(kk):tt+nLags,:),XFull(ss(kk):tt+nLags,:),obsSVD - ss(kk) + 1);
        [beta(:,:,kk),stdBeta(:,:,kk),sigma(:,:,kk),stdSigma(:,:,kk)] = takeMean(betaD,sigmaD);
        if waitbar 
            nb_estimator.notifyWaitbar(h,kk,iter,note)
        end
        kk = kk + 1;                
    end 
    
end

%==========================================================================
function [beta,stdBeta,sigma,stdSigma,posterior] = doBayesianParallel(options,y,X,yFull,XFull,restrictions,waitbar,sizes)

    if options.prior.SVD
        obsSVD = options.prior.obsSVD;
    else
        obsSVD = 0;
    end

    % Do we want a waitbar?
    if waitbar
        [waitbar,D] = nb_parCheck();
        if waitbar
            h      = nb_waitbar([],'Recursive estimation',sizes.iter,false,false);
            h.text = 'Working...';
            afterEach(D,@(x)nb_updateWaitbarParallel(x,h));
        end
    end
    
    % Open parallel pool if not already open
    ret = nb_openPool(options.cores);

    % Do the recursive estimation
    beta      = nan(sizes.numCoeff,sizes.numDep,sizes.iter);
    sigma     = nan(sizes.numDep,sizes.numDep,sizes.iter);
    stdBeta   = nan(size(beta));
    stdSigma  = nan(size(sigma));
    posterior = cell(1,sizes.iter);
    nLags     = options.nLags + 1;
    tt        = sizes.start:sizes.T;
    ss        = sizes.ss;
    parfor kk = 1:sizes.iter
        
        yOne     = y;
        XOne     = X;
        yFullOne = yFull;
        XFullOne = XFull;
        [betaD,sigmaD,~,posterior{kk}] = nb_bVarEstimator.doBayesian(...
        	options,false,nLags,restrictions,yOne(ss(kk):tt(kk),:),XOne(ss(kk):tt(kk),:),...
            yFullOne(ss(kk):tt(kk)+nLags,:),XFullOne(ss(kk):tt(kk)+nLags,:),obsSVD - ss(kk) + 1);
        [beta(:,:,kk),stdBeta(:,:,kk),sigma(:,:,kk),stdSigma(:,:,kk)] = takeMean(betaD,sigmaD);
        if waitbar 
            send(D,1); % Update waitbar
        end               
    end 
    
    % Close parallel pool only if it where open locally
    nb_closePool(ret);
    
    if waitbar
        delete(h);
    end
    
end

%==========================================================================
function [beta,stdBeta,sigma,stdSigma] = takeMean(betaD,sigmaD)

    beta     = mean(betaD,3);
    stdBeta  = std(betaD,0,3);
    sigma    = mean(sigmaD,3);
    stdSigma = std(sigmaD,0,3);

end
