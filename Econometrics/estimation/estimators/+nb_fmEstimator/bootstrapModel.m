function [betaDraws,lambdaDraws,sigmaDraws,Rdraws,factorDraws] = bootstrapModel(options,res,iter)
% Bootstrap parameters and factors of the Factor model
%
% See Aastveit, Gerdrup, Jore and Thorsrud (2013)
%
% Caution: The options struct is assumed to already be index by iter!
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        iter = 'end';
    end

    if strcmpi(iter,'end')
        lambda = res.lambda;
        iter   = size(lambda,3);
    end

    if options.recursive_estim == 1
        [options,res] = getIterationResults(options,res,iter);
    end

    replic     = ceil(options.stdReplic);
    constant   = options.constant;
    time_trend = options.time_trend;
    endInd     = options.estim_end_ind;

    bootstrapM = options.stdType;
    if any(strcmpi(bootstrapM,{'h','w','nw'}))
        bootstrapM = 'bootstrap';
    end
    
    %======================================================================
    if strcmpi(options.modelType,'dynamic')
    %======================================================================
    
        numDep = length(options.dependent);
    
        % Bootstrap the residuals of the observation eq
        %----------------------------------------------
        E = nb_bootstrap(res.obsResidual,replic,bootstrapM);
        E = permute(E,[3,1,2]);
        E = E(options.factorsLags:end,:,:);
        
        % Bootstrap the residuals of the forecasting eq 
        %---------------------------------------------------------------
        U    = nb_bootstrap(res.residual(:,1:numDep),replic,bootstrapM);
        U    = permute(U,[3,1,2]);
        
        % Bootstrap the residuals of the dynamic factor eq
        %---------------------------------------------------------------
        V = nb_bootstrap(res.residual(:,numDep+1:end),replic,bootstrapM);
        
        % Then we make artificial factors and data and re-estimate the
        % data
        %-------------------------------------------------------------
        [T,nFact]   = size(res.F);
        lambda      = res.lambda;
        beta        = res.beta;
        [s1,s2]     = size(lambda);
        lambdaDraws = nan(s1,s2,replic);
        Rdraws      = nan(s2,s2,replic);
        [b1,b2]     = size(beta);
        betaDraws   = nan(b1,b2,replic);
        sigmaDraws  = nan(b2,b2,replic);
        
        % Simulate artificial factors based on the dynamic factor eq
        T              = T - options.factorsLags + 1;
        startInd       = options.estim_start_ind + options.factorsLags;
        [allReg,restr] = nb_fmEstimator.getAllDynamicRegressors(options);
        indFR          = ismember(allReg,options.factorsRHS{end});
        if options.time_trend
            indFR = [false,indFR];
        end
        if options.constant
            indFR = [false,indFR];
        end
        betaDynFac     = beta(indFR,numDep+1:end)';
        numRows        = (options.factorsLags - 1)*nFact;
        fLag           = [options.factors,nb_cellstrlag(options.factors,options.factorsLags-1,'varFast')];
        [~,indF]       = ismember(fLag,options.dataVariables);
        Fd             = nan(nFact*options.factorsLags,replic,T+1);
        F              = options.data(startInd:endInd,indF)';
        F0             = F(:,1);
        Fd(:,:,1)      = F0(:,ones(1,replic),:);
        A              = [betaDynFac;eye(numRows),zeros(numRows,nFact)];
        C              = [eye(nFact);zeros(numRows, nFact)];
        for t = 1:T
            AF          = A*F(:,t);
            AF          = AF(:,ones(1,replic));
            Fd(:,:,t+1) = AF + C*V(:,:,t);
        end
        Fd = permute(Fd(:,:,2:end),[3,1,2]);
        
        % Now we need to use the the bootstraped factors to bootstrap the
        % rest of the model
        %------------------------------------------------------------------
        factorDraws   = Fd(:,1:nFact,:);
        cF            = [ones(T,1,replic),factorDraws];
        fOpt          = options;
        fOpt.nFactors = nFact;
        for ii = 1:replic
            
            % Simulate the observation equation
            Ztilda = cF(:,:,ii)*lambda + E(:,:,ii);
            
            % Estimate the observation equation and get the updated factors
            resFac              = nb_fmEstimator.estimateFactors(fOpt,[],Ztilda,[]);
            Fdraw               = resFac.F;
            lambdaDraws(:,:,ii) = resFac.lambda;
            factorDraws(:,:,ii) = Fdraw;
            Rdraws(:,:,ii)      = resFac.R;
            
        end
        
        % Make lags of the factors (this will eat up even more degrees
        % of freedom)
        maxLags = max(max(options.nLags),options.factorsLags);
        FLag    = nb_mlag(factorDraws,maxLags,'varFast');

        T    = endInd - startInd + 1;
        Xall = nan(T-maxLags-1,0);
        if time_trend
            tt   = 1:T-maxLags-1;
            Xall = tt';
        end

        if constant
            Xall = [ones(T-maxLags-1,1),Xall];
        end
        
        % Bootstrap the forecasting equations
        F        = FLag(maxLags+1:end,:,:);
        exo      = nb_fmEstimator.getAllDynamicRegressors(options,'exoOnly');
        [~,indX] = ismember(exo,options.dataVariables);
        X        = options.data(startInd+maxLags+1:endInd,indX);
        X        = [Xall,X];
        nExo     = size(X,2);
        if options.contemporaneous
            F      = [factorDraws(maxLags+1:end,:,:),F];
            indFR2 = ismember(allReg,options.factors);
            if options.time_trend
                indFR2 = [false,indFR2];
            end
            if options.constant
                indFR2 = [false,indFR2];
            end
            indFR = indFR | indFR2;
        end
        
        % Make artificial data of the forecasting eq
        betaDep = beta(:,1:numDep);
        Yd      = nan(size(X,1),numDep,replic);
        U       = U(end-size(X,1)+1:end,:,:);
        for r = 1:replic
            Yd(:,:,r) = [X,F(:,:,r)]*betaDep;
        end
        Yd = Yd + U;
        
        % Construct the right hand side matrix
        maxDepLag    = max(options.nLags);
        indYR        = ismember(allReg,nb_cellstrlag(options.dependent,maxDepLag));
        if options.time_trend
            indYR = [false,indYR];
        end
        if options.constant
            indYR = [false,indYR];
        end
        Y            = X(:,indYR(1:nExo));
        indX         = ~(indYR | indFR);
        XX           = nan(size(Yd,1),size(X,2)+size(F,2),replic);
        XX(:,indX,:) = X(:,~indYR(1:nExo),ones(1,replic));
        YLagD        = nb_mlag(Yd,maxDepLag,'varFast');
        for ii = 1:maxDepLag
            ind               = 1 + (ii - 1)*maxDepLag:ii*maxDepLag;
            YLagD(1:ii,ind,:) = Y(1:ii,ind,ones(1,replic)); % Fill in for missing initial values
        end
        XX(:,indYR,:) = YLagD;
        XX(:,indFR,:) = F;
        Yd            = [Yd,factorDraws(maxLags+1:end,:,:)];

        % Estimate the forecasting equation
        for ii = 1:replic
            [betaDraws(:,:,ii),~,~,~,u] = nb_olsRestricted(Yd(:,:,ii),XX(:,:,ii),restr); % constant and time-trend already included!!
            sigmaDraws(:,:,ii)          = u'*u/T;
        end
              
    %======================================================================    
    elseif strcmpi(options.modelType,'favar')
    %======================================================================    
        
        nLags = options.nLags;
    
        % Bootstrap the residuals of the observation eq
        %----------------------------------------------
        E = nb_bootstrap(res.obsResidual,replic,bootstrapM);
        E = permute(E,[3,1,2]);
        E = E(nLags+1:end,:,:);
        
        % Bootstrap the residuals of the FA-VAR 
        %---------------------------------------------------------------
        U = nb_bootstrap(res.residual,replic,bootstrapM);
        
        % Then we make artificial factors and data and re-estimate the
        % data
        %-------------------------------------------------------------
        [T,nFact]   = size(res.F);
        dep         = options.dependent;
        nDep        = length(dep);
        lambda      = res.lambda;
        beta        = res.beta;
        [s1,s2]     = size(lambda);
        lambdaDraws = nan(s1,s2,replic);
        Rdraws      = nan(s2,s2,replic);
        [ss1,ss2]   = size(beta);
        betaDraws   = nan(ss1,ss2,replic);
        sigmaDraws  = nan(ss2,ss2,replic);

        % Get the true exogenous variables
        exo  = options.exogenous;
        pred = nb_cellstrlag(options.dependent,nLags,'varFast');
        ind  = ~ismember(exo,pred);
        exo  = exo(ind);
        exoI = length(exo) + options.constant + options.time_trend;
        
        % Simulate artificial factors and data based on the FA-VAR
        T          = T - nLags;
        startInd   = options.estim_start_ind + nLags;
        betaT      = beta';
        numRows    = (nLags - 1)*(nFact + nDep);
        fact       = options.factors;
        yLag       = [dep,nb_cellstrlag(dep,nLags-1,'varFast'),fact,nb_cellstrlag(fact,nLags-1,'varFast')];
        [~,indY]   = ismember(yLag,options.dataVariables);
        Yd         = nan((nFact + nDep)*nLags,replic,T);
        Y          = options.data(startInd:endInd,indY)';
        Y0         = Y(:,1);
        Yd(:,:,1)  = Y0(:,ones(1,replic),:);
        A          = [betaT(:,exoI+1:end);eye(numRows),zeros(numRows,nFact + nDep)];
        B          = [betaT(:,1:exoI);zeros(numRows,exoI)];
        [~,indX]   = ismember(exo,options.dataVariables);
        
        % Get the exogenous variables
        X    = options.data(startInd:endInd,indX);
        T    = size(X,1);
        Xall = nan(T,0);
        if time_trend
            tt   = 1:T;
            Xall = tt';
        end

        if constant
            Xall = [ones(T,1),Xall];
        end
        X = [Xall,X]';
        
        % Then we do the bootstrap
        C = [eye(nDep + nFact);zeros(numRows,nDep + nFact)];
        for t = 1:T-1
            AF          = A*Y(:,t) + B*X(:,t);
            AF          = AF(:,ones(1,replic));
            Yd(:,:,t+1) = AF + C*U(:,:,t);
        end
        Yd = permute(Yd,[3,1,2]);
        
        % Re-estimate the factors
        indYC         = 1:nDep;
        y             = Yd(:,indYC,:);
        indFC         = nDep*nLags + 1:nDep*nLags + nFact;
        F             = Yd(:,indFC,:);
        cFy           = [ones(size(y,1),1,replic),F,y];
        nFast         = length(options.observablesFast);
        fOpt          = options;
        fOpt.nFactors = nFact;
        factorDraws   = nan(T,nFact,replic);
        for ii = 1:replic
            
            % Bootstrap the observation equation
            Ztilda = cFy(:,:,ii)*lambda + E(:,:,ii);
            
            % Split into fast and slow if needed
            if nFast > 0
                ZtildaF = Ztilda(:,end-nFast+1:end);
                Ztilda  = Ztilda(:,1:end-nFast);
            else
                ZtildaF = [];
            end
            
            % Based on this, we re-estimate the factors
            res                 = nb_fmEstimator.estimateFactors(fOpt,y(:,:,ii),Ztilda,ZtildaF);
            Fdraw               = res.F;
            lambdaDraws(:,:,ii) = res.lambda;
            factorDraws(:,:,ii) = Fdraw;
            Rdraws(:,:,ii)      = res.R;
           
        end
        
        % Now we need to lag the bootstrapped factor, this will eat up
        % more degrees of freedom!
        yF    = [y,factorDraws];
        yF    = yF(nLags+1:end,:,:);
        FLag  = nb_mlag(factorDraws,nLags,'varFast');
        FLag  = FLag(nLags+1:end,:,:);
        YLag  = Yd(nLags+1:end,nDep+1:nDep*nLags,:); 
        YLagL = nb_mlag(Yd(:,nDep*(nLags-1)+1:nDep*nLags,:),1,'varFast'); % Add last lag
        YLag  = [YLag,YLagL(nLags+1:end,:,:)];
        X     = permute(X(:,nLags+1:end,ones(1,replic)),[2,1,3]);
        RHS   = [X,YLag,FLag];
        
        % Re-estimate the FA-VAR based on the updated draw of
        Tcorr = T - nLags;
        for ii = 1:replic
            [betaDraws(:,:,ii),~,~,~,u] = nb_ols(yF(:,:,ii),RHS(:,:,ii)); % constant and time trend is here included if wanted
            sigmaDraws(:,:,ii)          = u'*u/Tcorr;
        end
        
    %======================================================================    
    elseif strcmpi(options.modelType,'stepAhead')
    %======================================================================
        
        % Bootstrap the residuals of the observation eq
        %----------------------------------------------
        E  = nb_bootstrap(res.obsResidual,replic,bootstrapM);
        E  = permute(E,[3,1,2]);
        
        % Bootstrap the residuals of the step-ahead model
        %---------------------------------------------------------------
        nEq    = size(res.beta,2);
        numDep = nEq/options.nStep;
        TU     = size(res.residual,1);
        U      = nan(TU,nEq,replic);
        kk     = 0;
        for ii = 1:nEq
            if rem(ii,numDep) == 1
                kk = kk + 1;
            end
            U(1:TU-kk+1,ii,:) = permute(nb_bootstrap(res.residual(1:TU-kk+1,ii),replic,bootstrapM),[3,1,2]);
        end
        
        % Then we make artificial factors and data and re-estimate the
        % data
        %-------------------------------------------------------------
        [T,nFact]     = size(res.F);
        factorDraws   = nan(T,nFact*(1 + options.nLags + options.factorLead),replic);
        Fextra        = [ones(T,1),res.F];
        lambda        = res.lambda;
        beta          = res.beta;
        [s1,s2]       = size(lambda);
        lambdaDraws   = nan(s1,s2,replic);
        Rdraws        = nan(s2,s2,replic);
        [ss1,ss2]     = size(beta);
        betaDraws     = nan(ss1,ss2,replic);
        sigmaDraws    = nan(ss2,ss2,replic);
        fOpt          = options;
        fOpt.nFactors = nFact;
        for ii = 1:replic
            
            % Simulate the observation equation
            Ztilda = Fextra*lambda + E(:,:,ii);
            
            % Estimate the observation equation and get the factors
            resFac              = nb_fmEstimator.estimateFactors(fOpt,[],Ztilda,[]);
            lambdaDraws(:,:,ii) = resFac.lambda;
            factorDraws(:,:,ii) = [resFac.F, nb_mlag(resFac.F,options.nLags), nb_mlead(resFac.F,options.factorLead)]; 
            Rdraws(:,:,ii)      = resFac.R;
            
            % Make artificial left hand side variables of the step ahead
            % equation
            cFd = factorDraws(:,:,ii);
            if time_trend
                tt  = 1:T;
                cFd = [tt',cFd]; %#ok<AGROW>
            end
            
            if constant
                cFd = [ones(T,1),cFd]; %#ok<AGROW>
            end
            
            kk = 0;
            u  = nan(TU,nEq); 
            for jj = 1:nEq
            
                if rem(jj,numDep) == 1 || numDep == 1
                    kk = kk + 1;
                end
                ss         = 1 + options.nLags;
                tt         = T - res.correct - kk;
                y_th_tilde = cFd(ss:tt,:)*beta(:,jj) + U(1:TU-kk+1,jj,ii);
                [betaDraws(:,jj,ii),~,~,~,u(1:TU-kk+1,jj)] = nb_ols(y_th_tilde,cFd(ss:tt,:),0,0);
            end
            
            numCoeff = size(beta,1);
            for hh = 1:nEq
                for jj = 1:nEq
                    tt                   = TU - max(ceil(hh/numDep),ceil(jj/numDep)) + 1 - options.nLags  - options.factorLead;
                    sigmaDraws(hh,jj,ii) = u(1:tt,hh)'*u(1:tt,jj)/(T - numCoeff);
                end
            end
            
        end
        factorDraws = factorDraws(1 + options.nLags:end - options.factorLead,:,:);
        
    %======================================================================    
    else % singleEq, here we use a slightly simpler algorithm
    %======================================================================
        
        % Bootstrap the residuals of the observation eq
        %----------------------------------------------
        E = nb_bootstrap(res.obsResidual,replic,bootstrapM);
        E = permute(E,[3,1,2]);
        
        % Bootstrap the residuals of the forecasting eq
        %----------------------------------------------
        U  = nb_bootstrap(res.residual,replic,bootstrapM);
        U  = permute(U,[3,1,2]);
        TU = size(U,1);
        
        % Then we make artificial factors and data and re-estimate the
        % data
        %-------------------------------------------------------------
        [T,nFact]     = size(res.F);
        factorDraws   = nan(T,nFact,replic);
        Fextra        = [ones(T,1),res.F];
        lambda        = res.lambda;
        beta          = res.beta;
        [s1,s2]       = size(lambda);
        lambdaDraws   = nan(s1,s2,replic);
        Rdraws        = nan(s2,s2,replic);
        [ss1,ss2]     = size(beta);
        betaDraws     = nan(ss1,ss2,replic);
        sigmaDraws    = nan(ss2,ss2,replic);
        fOpt          = options;
        fOpt.nFactors = nFact;
        for ii = 1:replic
            
            % Simulate the observation equation
            Ztilda = Fextra*lambda + E(:,:,ii);
            
            % Estimate the observation equation and get the factors
            resFac              = nb_fmEstimator.estimateFactors(fOpt,[],Ztilda,[]);
            Fdraw               = resFac.F;
            lambdaDraws(:,:,ii) = resFac.lambda;
            factorDraws(:,:,ii) = Fdraw;
            Rdraws(:,:,ii)      = resFac.R;
            
            % Make artificial left hand side variables of the step ahead
            % equation
            cFd = Fdraw;
            if time_trend
                tt  = 1:T;
                cFd = [tt',Fdraw];
            end
            
            if constant
                cFd = [ones(T,1),cFd]; %#ok<AGROW>
            end
            y_th_tilde = cFd(1:TU,:)*beta + U(:,:,ii);
            
            % Estimate the step ahead equation
            [betaDraws(:,:,ii),~,~,~,u] = nb_ols(y_th_tilde,Fdraw(1:TU,:),constant,time_trend);
            sigmaDraws(:,:,ii)          = u'*u/T;
            
        end    
          
    end
       
end

%==========================================================================
function [tempOpt,tempRes] = getIterationResults(options,results,iter)

    % Get the result from one iteration
    %----------------------------------
    tempRes          = results;
    tempRes.beta     = results.beta(:,:,iter);
    tempRes.stdBeta  = results.stdBeta(:,:,iter);
    periods          = find(isnan(results.residual(:,1,iter)),1) - 1;
    if isempty(periods)
        periods = size(results.residual,1);
    end
    tempRes.residual = results.residual(1:periods,:,iter);
    tempRes.sigma    = results.sigma(:,:,iter);
    tempRes.lambda   = results.lambda(:,:,iter);
    tempRes.R        = results.R(:,:,iter);

    % Get the end period of recursive estimation iteration
    tempOpt = options;
    if strcmpi(options.modelType,'favar')

        periods = find(isnan(results.obsResidual(:,1,iter)),1) - 1;
        if isempty(periods)
            periods = size(results.obsResidual,1);
        end
        tempRes.obsResidual   = results.obsResidual(1:periods,:,iter);
        tempOpt.estim_end_ind = options.recursive_estim_start_ind + iter - 1 - options.nLags;
        tempRes.F             = results.F(1:periods,:,iter);

    elseif strcmpi(options.modelType,'dynamic')

        maxLag                = max(max(options.nLags),options.factorsLags);
        tempRes.obsResidual   = results.obsResidual(maxLag-1:periods,:,iter);
        tempOpt.estim_end_ind = options.recursive_estim_start_ind + iter - 1 - maxLag;
        tempRes.F             = results.F(1:periods,:,iter);

    elseif strcmpi(options.modelType,'stepahead')

        periods = find(isnan(results.F(:,1,iter)),1) - 1;
        if isempty(periods)
            periods = size(results.F,1);
        end
        tempRes.F           = results.F(1:periods,:,iter);
        tempRes.obsResidual = results.obsResidual(1:periods,:,iter);

    else

        tempRes.obsResidual = results.obsResidual(1:periods,:,iter);
        tempRes.F           = results.F(1:periods,:,iter);

    end

end
