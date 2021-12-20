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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    options = nb_defaultField(options,'parallel',false);
    options = nb_defaultField(options,'cores',[]);
    if options.empirical && ~strcmpi(options.prior.type,'glpMF')
        error([mfilename ':: Empirical bayesian is not supported for recursivly ',...
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
            [H,freq,extra] = nb_mlEstimator.getMeasurmentEqMFVAR(options,1);
            
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
        nStates = size(H,2);
        
        sizes = struct(...
            'numCoeff',numCoeff,...
            'numDep',numDep,...
            'numObs',numObs,...
            'iter',iter,...
            'nStates',nStates,...
            'ss',ss,...
            'start',start,...
            'T',T);
        
        switch lower(options.prior.type)
            
            case 'glpmf'
                
                if options.parallel
                    [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doGLPMFParallel(options,y,X,restrictions,waitbar,freq,H,mixing,sizes);
                else
                    [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doGLPMFNormal(options,y,X,restrictions,h,note,freq,H,mixing,sizes);
                end
            
            case 'minnesotamf'
                
                if options.parallel
                    [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doMinnesotaMFParallel(options,y,X,restrictions,waitbar,freq,H,mixing,sizes);
                else
                    [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doMinnesotaMFNormal(options,y,X,restrictions,h,note,freq,H,mixing,sizes);
                end
                
            case 'nwishartmf'
                
                if options.parallel
                    [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doNwishartMFParallel(options,y,X,restrictions,waitbar,H,mixing,sizes);
                else
                    [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doNwishartMFNormal(options,y,X,restrictions,h,note,H,mixing,sizes);
                end
                     
            case 'inwishartmf'
                
                if options.parallel
                    [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doInwishartMFParallel(options,y,X,restrictions,waitbar,H,mixing,sizes);
                else
                    [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doInwishartMFNormal(options,y,X,restrictions,h,note,H,mixing,sizes);
                end 
                
            otherwise
                error([mfilename ':: Unsupported prior type ' options.prior.type])
        end
        
    %======================================================================
    else % Not missing or mixed-frequency
    %======================================================================
    
        if options.empirical
            error([mfilename ':: Emprirical bayesian is not yet supported for recursive estimation.'])
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
        res.filterStartDate = toString(dataStart + options.estim_start_ind - 1);
        res.filterEndDate   = toString(dataStart + options.estim_end_ind - 1);
        res.realTime        = false;

        if extra
            H   = H(:,1:numDep*nLags,:);
            ys  = ys(:,1:numDep*nLags,:);
            ys0 = ys0(:,1:numDep*nLags,:);
        end
        if mfvar 
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
function [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doGLPMFNormal(options,y,X,restrictions,h,note,freq,H,mixing,sizes)

    draws      = options.draws;
    nLags      = options.nLags;
    constant   = options.constant;
    time_trend = options.time_trend;
    prior      = options.prior;
    ys         = nan(sizes.T,sizes.nStates,sizes.iter);
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
        [betaD,sigmaD,R(:,:,kk),ys(ss(kk):tt,:,kk),~,posterior{kk}] = nb_bVarEstimator.glpMF(draws,...
            y(ss(kk):tt,:),X(ss(kk):tt,:),nLags,constant,time_trend,prior,restrictions,h,false,freq,H,mixing);    
        [beta(:,:,kk),stdBeta(:,:,kk),sigma(:,:,kk),stdSigma(:,:,kk)] = takeMean(betaD,sigmaD);
        ys0(:,:,kk) = ys(tt,:,kk);
        if waitbar 
            nb_estimator.notifyWaitbar(h,kk,iter,note)
        end
        kk = kk + 1;
    end

end

%==========================================================================
function [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doGLPMFParallel(options,y,X,restrictions,waitbar,freq,H,mixing,sizes)

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
    draws      = options.draws;
    nLags      = options.nLags;
    constant   = options.constant;
    time_trend = options.time_trend;
    prior      = options.prior;
    ysC        = cell(sizes.iter,1);
    beta       = nan(sizes.numCoeff,sizes.numDep,sizes.iter);
    sigma      = nan(sizes.numDep,sizes.numDep,sizes.iter);
    stdBeta    = nan(size(beta));
    stdSigma   = nan(size(sigma));
    R          = nan(sizes.numObs,1,sizes.iter);
    posterior  = cell(1,sizes.iter);
    tt         = sizes.start:sizes.T;
    ss         = sizes.ss;
    parfor kk = 1:sizes.iter

        yOne = y;
        XOne = X;
        
        [betaD,sigmaD,R(:,:,kk),ysC{kk},~,posterior{kk}] = nb_bVarEstimator.glpMF(draws,...
            yOne(ss(kk):tt(kk),:),XOne(ss(kk):tt(kk),:),nLags,constant,time_trend,prior,...
            restrictions,false,false,freq,H,mixing);    
        [beta(:,:,kk),stdBeta(:,:,kk),sigma(:,:,kk),stdSigma(:,:,kk)] = takeMean(betaD,sigmaD);
        if waitbar 
            send(D,1); % Update waitbar
        end
        
    end
    
    % Close parallel pool only if it where open locally
    nb_closePool(ret);
    
    % Convert smoothed estimates to double
    ys  = nan(sizes.T,sizes.nStates,sizes.iter);
    ys0 = nan(1,sizes.nStates,sizes.iter);
    for ii = 1:sizes.iter
        ys(ss(ii):tt(ii),:,ii) = ysC{ii};
        ys0(:,:,ii)            = ys(tt(ii),:,ii);
    end
    
    if waitbar
        delete(h);
    end
    
end

%==========================================================================
function [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doMinnesotaMFNormal(options,y,X,restrictions,h,note,freq,H,mixing,sizes)

    draws      = options.draws;
    nLags      = options.nLags;
    constant   = options.constant;
    time_trend = options.time_trend;
    prior      = options.prior;
    ys         = nan(sizes.T,sizes.nStates,sizes.iter);
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
            % Time-varying measurment equations
            HT = H(:,:,ss(kk):tt);
        else
            HT = H;
        end
        [betaD,sigmaD,R(:,:,kk),ys(ss(kk):tt,:,kk),~,posterior{kk}] = nb_bVarEstimator.minnesotaMF(draws,...
            y(ss(kk):tt,:),X(ss(kk):tt,:),nLags,constant,time_trend,prior,restrictions,h,freq,HT,mixing);    
        [beta(:,:,kk),stdBeta(:,:,kk),sigma(:,:,kk),stdSigma(:,:,kk)] = takeMean(betaD,sigmaD);
        ys0(:,:,kk) = ys(tt,:,kk);
        if waitbar 
            nb_estimator.notifyWaitbar(h,kk,iter,note)
        end
        kk = kk + 1;
    end

end

%==========================================================================
function [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doMinnesotaMFParallel(options,y,X,restrictions,waitbar,freq,H,mixing,sizes)

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
    draws      = options.draws;
    nLags      = options.nLags;
    constant   = options.constant;
    time_trend = options.time_trend;
    prior      = options.prior;
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
            % Time-varying measurment equations
            HT = H(:,:,ss(kk):tt(kk));
        else
            HT = H;
        end
        yOne = y;
        XOne = X;
        
        [betaD,sigmaD,R(:,:,kk),ysC{kk},~,posterior{kk}] = nb_bVarEstimator.minnesotaMF(draws,...
            yOne(ss(kk):tt(kk),:),XOne(ss(kk):tt(kk),:),nLags,constant,time_trend,prior,restrictions,false,freq,HT,mixing);    
        [beta(:,:,kk),stdBeta(:,:,kk),sigma(:,:,kk),stdSigma(:,:,kk)] = takeMean(betaD,sigmaD);
        if waitbar 
            send(D,1); % Update waitbar
        end
    end
    
    % Close parallel pool only if it where open locally
    nb_closePool(ret);
    
    % Convert smoothed estimates to double
    ys  = nan(sizes.T,sizes.nStates,sizes.iter);
    ys0 = nan(1,sizes.nStates,sizes.iter);
    for ii = 1:sizes.iter
        ys(ss(ii):tt(ii),:,ii) = ysC{ii};
        ys0(:,:,ii)            = ys(tt(ii),:,ii);
    end
    
    if waitbar
        delete(h);
    end
    
end

%==========================================================================
function [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doNwishartMFNormal(options,y,X,restrictions,h,note,H,mixing,sizes)

    draws      = options.draws;
    nLags      = options.nLags;
    constant   = options.constant;
    time_trend = options.time_trend;
    prior      = options.prior;
    ys         = nan(sizes.T,sizes.nStates,sizes.iter);
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
            % Time-varying measurment equations
            HT = H(:,:,ss(kk):tt);
        else
            HT = H;
        end
        [betaD,sigmaD,R(:,:,kk),ys(ss(kk):tt,:,kk),~,posterior{kk}] = nb_bVarEstimator.nwishartMF(draws,...
            y(ss(kk):tt,:),X(ss(kk):tt,:),nLags,constant,time_trend,prior,restrictions,h,HT,mixing);    
        [beta(:,:,kk),stdBeta(:,:,kk),sigma(:,:,kk),stdSigma(:,:,kk)] = takeMean(betaD,sigmaD);
        ys0(:,:,kk) = ys(tt,:,kk);
        if waitbar 
            nb_estimator.notifyWaitbar(h,kk,iter,note)
        end
        kk = kk + 1;
    end

end

%==========================================================================
function [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doNwishartMFParallel(options,y,X,restrictions,waitbar,H,mixing,sizes)

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
    draws      = options.draws;
    nLags      = options.nLags;
    constant   = options.constant;
    time_trend = options.time_trend;
    prior      = options.prior;
    ysC        = cell(sizes.iter,1);
    beta       = nan(sizes.numCoeff,sizes.numDep,sizes.iter);
    sigma      = nan(sizes.numDep,sizes.numDep,sizes.iter);
    stdBeta    = nan(size(beta));
    stdSigma   = nan(size(sigma));
    R          = nan(sizes.numObs,1,sizes.iter);
    posterior  = cell(1,sizes.iter);
    tt         = sizes.start:sizes.T;
    ss         = sizes.ss;
    parfor kk = 1:sizes.iter
        if size(H,3) > 1
            % Time-varying measurment equations
            HT = H(:,:,ss(kk):tt(kk));
        else
            HT = H;
        end
        yOne = y;
        XOne = X;
        
        [betaD,sigmaD,R(:,:,kk),ysC{kk},~,posterior{kk}] = nb_bVarEstimator.nwishartMF(draws,...
            yOne(ss(kk):tt(kk),:),XOne(ss(kk):tt(kk),:),nLags,constant,time_trend,prior,restrictions,false,HT,mixing);    
        [beta(:,:,kk),stdBeta(:,:,kk),sigma(:,:,kk),stdSigma(:,:,kk)] = takeMean(betaD,sigmaD);
        if waitbar 
            send(D,1); % Update waitbar
        end
        
    end
    
    % Close parallel pool only if it where open locally
    nb_closePool(ret);
    
    % Convert smoothed estimates to double
    ys  = nan(sizes.T,sizes.nStates,sizes.iter);
    ys0 = nan(1,sizes.nStates,sizes.iter);
    for ii = 1:sizes.iter
        ys(ss(ii):tt(ii),:,ii) = ysC{ii};
        ys0(:,:,ii)            = ys(tt(ii),:,ii);
    end
    
    if waitbar
        delete(h);
    end
    
end

%==========================================================================
function [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doInwishartMFNormal(options,y,X,restrictions,h,note,H,mixing,sizes)

    draws      = options.draws;
    nLags      = options.nLags;
    constant   = options.constant;
    time_trend = options.time_trend;
    prior      = options.prior;
    ys         = nan(sizes.T,sizes.nStates,sizes.iter);
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
            % Time-varying measurment equations
            HT = H(:,:,ss(kk):tt);
        else
            HT = H;
        end
        [betaD,sigmaD,R(:,:,kk),ys(ss(kk):tt,:,kk),~,posterior{kk}] = nb_bVarEstimator.inwishartMF(draws,...
            y(ss(kk):tt,:),X(ss(kk):tt,:),nLags,constant,time_trend,prior,restrictions,h,HT,mixing);    
        [beta(:,:,kk),stdBeta(:,:,kk),sigma(:,:,kk),stdSigma(:,:,kk)] = takeMean(betaD,sigmaD);
        ys0(:,:,kk) = ys(tt,:,kk);
        if waitbar 
            nb_estimator.notifyWaitbar(h,kk,iter,note)
        end
        kk = kk + 1;
        
    end

end

%==========================================================================
function [beta,stdBeta,sigma,stdSigma,R,ys,ys0,posterior] = doInwishartMFParallel(options,y,X,restrictions,waitbar,H,mixing,sizes)

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
    draws      = options.draws;
    nLags      = options.nLags;
    constant   = options.constant;
    time_trend = options.time_trend;
    prior      = options.prior;
    ysC        = cell(sizes.iter,1);
    beta       = nan(sizes.numCoeff,sizes.numDep,sizes.iter);
    sigma      = nan(sizes.numDep,sizes.numDep,sizes.iter);
    stdBeta    = nan(size(beta));
    stdSigma   = nan(size(sigma));
    R          = nan(sizes.numObs,1,sizes.iter);
    posterior  = cell(1,sizes.iter);
    tt         = sizes.start:sizes.T;
    ss         = sizes.ss;
    parfor kk = 1:sizes.iter
        if size(H,3) > 1
            % Time-varying measurment equations
            HT = H(:,:,ss(kk):tt(kk));
        else
            HT = H;
        end
        yOne = y;
        XOne = X;
        
        [betaD,sigmaD,R(:,:,kk),ysC{kk},~,posterior{kk}] = nb_bVarEstimator.inwishartMF(draws,...
            yOne(ss(kk):tt(kk),:),XOne(ss(kk):tt(kk),:),nLags,constant,time_trend,prior,restrictions,false,HT,mixing);     
        [beta(:,:,kk),stdBeta(:,:,kk),sigma(:,:,kk),stdSigma(:,:,kk)] = takeMean(betaD,sigmaD);
        if waitbar 
            send(D,1); % Update waitbar
        end
        
    end
    
    % Close parallel pool only if it where open locally
    nb_closePool(ret);
    
    % Convert smoothed estimates to double
    ys  = nan(sizes.T,sizes.nStates,sizes.iter);
    ys0 = nan(1,sizes.nStates,sizes.iter);
    for ii = 1:sizes.iter
        ys(ss(ii):tt(ii),:,ii) = ysC{ii};
        ys0(:,:,ii)            = ys(tt(ii),:,ii);
    end
    
    if waitbar
        delete(h);
    end
    
end

%==========================================================================
function [beta,stdBeta,sigma,stdSigma,posterior] = doBayesianNormal(options,y,X,yFull,XFull,restrictions,h,note,sizes)

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
            yFull(ss(kk):tt+nLags,:),XFull(ss(kk):tt+nLags,:));
        [beta(:,:,kk),stdBeta(:,:,kk),sigma(:,:,kk),stdSigma(:,:,kk)] = takeMean(betaD,sigmaD);
        if waitbar 
            nb_estimator.notifyWaitbar(h,kk,iter,note)
        end
        kk = kk + 1;                
    end 
    
end

%==========================================================================
function [beta,stdBeta,sigma,stdSigma,posterior] = doBayesianParallel(options,y,X,yFull,XFull,restrictions,waitbar,sizes)

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
            yFullOne(ss(kk):tt(kk)+nLags,:),XFullOne(ss(kk):tt(kk)+nLags,:));
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
