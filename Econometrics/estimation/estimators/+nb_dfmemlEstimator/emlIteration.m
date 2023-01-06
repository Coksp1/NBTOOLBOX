function results = emlIteration(options,results,X)
% Syntax:
%
% results = nb_dfmemlEstimator.emlIteration(options,results,X)
%
% Description:
%
% Do one iteration of the expected maximum likelihood algorithm for
% estimating a dynamic factor model.
%
% Inputs:
%
% - options : A struct with estimation options. See 
%             nb_dfmemlEstimator.template or nb_dfmemlEstimator.help.
%
% - results : A struct with the output from nb_dfmemlEstimator.initialize.
%
% - X       : A T x N double storing the data on the observables.
%
% Output:
%
% - results : A struct with the updated matrices and value of the 
%             likelihood at the current iteration.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Run kalman filter
    [alpha0,P0,Pinf0] = nb_dfmemlEstimator.intiKF(results);
    if isempty(Pinf0)
        [~,~,alpha,~,lik,Ps,Ps_1] = nb_kalmanSmootherAndLikelihood(results.Z,results.R,results.T,results.BQ,alpha0,P0,X',...
                                                options.kf_kalmanTol,options.kf_presample);
    else
        [~,~,alpha,~,lik,Ps,Ps_1] = nb_kalmanSmootherAndLikelihoodUnivariate(results.Z,results.R,results.T,results.BQ,alpha0,...
                                                P0,Pinf0,X',options.kf_kalmanTol,options.kf_presample);
    end
    results.likelihood = lik;
    
    % Update transition matrix (factors)
    %-----------------------------------
    results = updateFactorsBlocks(options,results,alpha,Ps,Ps_1);

    % Update transition matrix (idiosyncratic components)
    %----------------------------------------------------
    if options.nLagsIdiosyncratic
        results = updateIdiosyncatic(options,results,alpha,Ps,Ps_1);
    end

    % Standardize residuals to have a covariance matrix 
    % as the identity matrix
    %----------------------------------------------------
    results = nb_dfmemlEstimator.getBQ(results);
    
    % Update measurement equation
    %------------------------------------------------
    if ~isempty(options.blocks)
        results = updateLoadingsBlocks(options,results,alpha,Ps,X);
    else
        results = updateLoadings(options,results,alpha,Ps,X);
    end

end

%==========================================================================
function results = updateFactorsBlocks(options,results,alpha,Ps,Ps_1)

    T = size(alpha,2) - 1;
    if options.factorRestrictions
        
        % Each factor is model as uncorrelated AR(nLags) processes in this
        % case
        for ii = 1:options.nFactors

            % Index of the wanted factor including lags of the transition
            % matrix.
            ind = ii:options.nFactors:options.nFactors*options.nLags;

            % E[F(t)*F(t)' | OmegaV]
            Eff_00 = alpha(ind,2:end)*alpha(ind,2:end)' + sum(Ps(ind,ind,2:end),3);

            % E[F(t-1)*F(t-1)' | OmegaV]
            Eff_11 = alpha(ind,1:end-1)*alpha(ind,1:end-1)' + sum(Ps(ind,ind,1:end-1),3);

            % E[F(t)*F(t-1)' | OmegaV]
            Eff_01 = alpha(ind,2:end)*alpha(ind,1:end-1)' + sum(Ps_1(ind,ind,2:end),3);

            % Estimate AR(nLags) for this factor (eq 6)
            results.T(ii,ind) = Eff_01/Eff_11;

            % Covariance matrix of residuals of AR(nLags) of the current factor
            % (eq 8)
            results.Q(ii,ii) = (Eff_00 - results.T(ii,ind)*Eff_01')/T;

        end
        
    else
        
        % No restriction on the dynamics of the factors is applied in this
        % case
        ind  = 1:options.nFactors*options.nLags;
        indF = 1:options.nFactors;

        % E[F(t)*F(t)' | OmegaV]
        Eff_00 = alpha(ind,2:end)*alpha(ind,2:end)' + sum(Ps(ind,ind,2:end),3);

        % E[F(t-1)*F(t-1)' | OmegaV]
        Eff_11 = alpha(ind,1:end-1)*alpha(ind,1:end-1)' + sum(Ps(ind,ind,1:end-1),3);

        % E[F(t)*F(t-1)' | OmegaV]
        Eff_01 = alpha(ind,2:end)*alpha(ind,1:end-1)' + sum(Ps_1(ind,ind,2:end),3);

        % Estimate VAR(nLags) for all factors
        results.T(indF,ind) = Eff_01/Eff_11;

        % Covariance matrix of residuals of the VAR(nLags) of all the
        % factors
        results.Q(indF,indF) = (Eff_00 - results.T(indF,ind)*Eff_01')/T;
        
    end

end

%==========================================================================
function results = updateIdiosyncatic(options,results,alpha,Ps,Ps_1)

    % Get indicies
    indEps = nb_dfmemlEstimator.getEpsInd(options);
    indQ   = options.nFactors + 1:size(results.Q,1);

    % E[eps(t)'*eps(t) | OmegaV], remember that we are only interested
    % in the diagonal
    Eee_00 = diag(sum(alpha(indEps, 2:end).^2,2)) + diag(diag(sum(Ps(indEps,indEps,2:end),3)));

    % E[eps(t-1)'*eps(t-1) | OmegaV]
    Eee_11_diag = sum(alpha(indEps, 1:end-1).^2,2) + diag(sum(Ps(indEps,indEps,1:end-1),3));

    % E[eps(t)'*eps(t-1) | OmegaV]
    Eee_01 = diag(sum(alpha(indEps, 2:end).*alpha(indEps, 1:end-1),2)) + diag(diag(sum(Ps_1(indEps,indEps,2:end),3)));   

    % Estimate AR(p) for all idosyncatic components (eq 6)
    indNotZero                   = ~abs(Eee_11_diag) < eps;
    indEpsNZ                     = indEps(indNotZero);
    results.T(indEpsNZ,indEpsNZ) = Eee_01(indNotZero,indNotZero)*diag(1./Eee_11_diag(indNotZero));
                      
    % Covariance matrix of residuals of all the AR(p) models for the 
    % idosyncatic components (eq 8)
    T                    = size(alpha,2) - 1;
    results.Q(indQ,indQ) = (Eee_00 - results.T(indEps,indEps)*Eee_01')/T;

end

%==========================================================================
function results = updateLoadingsBlocks(options,results,alpha,Ps,X)

    if options.mixedFrequency
        % Get mapping for low frequency variables
        Hlow      = nb_dfmemlEstimator.getIdiosyncraticMapping(options);
        startIdio = options.nFactors*max(options.nLags,5);
    else
        startIdio = options.nFactors*options.nLags;
    end
    
    % Find missing observations
    nanInd    = isnan(X);
    X(nanInd) = 0;
    
    % Get number of unique blocks
    [uBlocks,~,locB] = unique(options.blocks,'rows');
    nUBlocks         = size(uBlocks,1);
    
    % Some other sizes
    [T,N] = size(X);
    if options.mixedFrequency
        nHigh   = options.nHigh;
        nLow    = N - nHigh;
        locsOfL = 1:nLow;
    else
        nHigh = N;
    end
    locs = 1:N;
    
    % Loop each unique block
    for ii = 1:nUBlocks
        
        % Get the number of loaded factors
        nLoadedF = sum(uBlocks(ii,:));
        
        % High frequency 
        %---------------
        
        % Get block information, and which high frequency variables that 
        % loads on the factors in this way
        indB   = uBlocks(ii,:);
        locBH  = locB(1:nHigh) == ii;
        locsH  = locs(locBH);
        locsHS = startIdio + locsH;
        nVars  = size(locsH,2);
       
        % Preallocation for eq 13
        d = zeros(nVars*nLoadedF,nVars*nLoadedF);
        n = zeros(nVars,nLoadedF);
        for t = 1:T
            
            % Selction matrix of eq 13 for a given time period
            Wt = diag(~nanInd(t,locsH));  

            % E[F(t)*F(t)' | OmegaV]
            d = d + kron(alpha(indB,t)*alpha(indB,t)' + Ps(indB,indB,t),Wt);

            % E[X(t)*F(t)' | OmegaV]
            if options.nLagsIdiosyncratic
                n = n + X(t,locsH)'*alpha(indB,t)' - Wt*(alpha(locsHS,t)*alpha(indB,t)' + Ps(locsHS,indB,t));
            else
                n = n + X(t,locsH)'*alpha(indB,t)';
            end
            
        end

        % Apply eq 13 for high frequency series
        results.Z(locsH,indB) = reshape(d\n(:),nVars,nLoadedF);
        
        % Low frequency
        %---------------------------------
        if options.mixedFrequency
            
            % Which quarterly variables load the factors in this way?
            locBL  = locB(nHigh+1:end) == ii;
            locsL  = locsOfL(locBL);
            locsLS = startIdio + locsL;
            if options.nLagsIdiosyncratic
                locsLS = locsLS + nHigh;
            end
        
            % Select the loading index, for low frequency these also
            % include lagged factors
            indBL   = repmat(uBlocks(ii,:),[1,5]);
            nStates = size(alpha,1);
            
            for qq = 1:size(locsL,2)

                % Index of eps for this low frequency variable, including
                % lagged values of eps due to mixed frequency mapping
                locsLqq = locsLS(qq):nLow:nStates;
                
                % Preallocation for eq 13 for one low frequency variable
                d = zeros(5*nLoadedF,5*nLoadedF);
                n = zeros(1,5*nLoadedF);

                % Get the count of this variable amoung all variables
                count = locsLS(qq) - startIdio;
                
                % Get the count of this variable amoung the low frequency
                % variables
                if options.nLagsIdiosyncratic
                    lowCount = count - nHigh;
                else
                    lowCount = count;
                    count    = count + nHigh;
                end
                
                % Get mapping for this variable
                Hqq = Hlow(lowCount,lowCount:nLow:end);
                for t = find(~nanInd(:,count))'

                    % E[F(t)*F(t)' | OmegaV]
                    d = d + alpha(indBL,t)*alpha(indBL,t)' + Ps(indBL,indBL,t);

                    % E[X(t)*F(t)' | OmegaV]
                    n = n + X(t,count)'*alpha(indBL,t)' - Hqq*alpha(locsLqq,t)*alpha(indBL,t)' - Hqq*Ps(locsLqq,indBL,t);
                    
                end
                
                % Apply eq 13 restricted to the mapping of this low 
                % frequency variable
                [R,r] = nb_dfmemlEstimator.getMapping(options,count);
                r     = repmat(r,[nLoadedF,1]);
                R     = kron(R,eye(nLoadedF));
                Zq    = d\n';
                Zq    = Zq - (d\R')*((R*(d\R'))\(R*Zq - r));

                % Place updated values in output structure
                results.Z(count,indBL) = Zq';
                
            end
            
        end
        
    end
    
    % If we have no serial correlation in the idiosyncratic components
    % we need to update the measurement error covariance matrix. See
    % appendix B of Banbura and Modugno (2010)
    if options.nLagsIdiosyncratic == 0
        In = eye(N);
        R  = zeros(N,N);
        for t = 1:T
            Wt = diag(~nanInd(t,:)); % Selection matrix
            R  = R + (X(t,:)' - Wt*results.Z*alpha(:,t))*(X(t,:)' - Wt*results.Z*alpha(:,t))' +...
                    Wt*results.Z*Ps(:,:,t)*results.Z'*Wt + (In - Wt)*results.R*(In - Wt);
        end
        results.R = diag(diag(R/T));
    end
    
end

%==========================================================================
function results = updateLoadings(options,results,alpha,Ps,X)
% Here there has not been set any restriction on the loadings of the
% factors.

    if options.mixedFrequency
        % Get mapping for low frequency variables
        Hlow      = nb_dfmemlEstimator.getIdiosyncraticMapping(options);
        startIdio = options.nFactors*max(options.nLags,5);
    else
        startIdio = options.nFactors*options.nLags;
    end
    
    % Find missing observations
    nanInd    = isnan(X);
    X(nanInd) = 0;
    
    % Some other sizes
    [T,N] = size(X);
    if options.mixedFrequency
        nHigh   = options.nHigh;
        nLow    = N - nHigh;
    else
        nHigh = N;
    end
    nFac      = options.nFactors;
    indB      = 1:nFac;
        
    % High frequency 
    %---------------

    % Get block information, and which high frequency variables that 
    % loads on the factors in this way
    locsH  = 1:nHigh;
    locsHS = startIdio + locsH;
    nVars  = size(locsH,2);

    % Preallocation for eq 13
    d = zeros(nVars*nFac,nVars*nFac);
    n = zeros(nVars,nFac);
    for t = 1:T

        % Selction matrix of eq 13 for a given time period
        Wt = diag(~nanInd(t,locsH));  

        % E[F(t)*F(t)' | OmegaV]
        d = d + kron(alpha(indB,t)*alpha(indB,t)' + Ps(indB,indB,t),Wt);

        % E[X(t)*F(t)' | OmegaV]
        if options.nLagsIdiosyncratic
            n = n + X(t,locsH)'*alpha(indB,t)' - Wt*(alpha(locsHS,t)*alpha(indB,t)' + Ps(locsHS,indB,t));
        else
            n = n + X(t,locsH)'*alpha(indB,t)';
        end

    end

    % Apply eq 13 for high frequency series
    results.Z(locsH,indB) = reshape(d\n(:),nVars,nFac);

    % Low frequency
    %---------------------------------
    if options.mixedFrequency

        locsL  = 1:nLow;
        locsLS = startIdio + locsL;
        if options.nLagsIdiosyncratic
            locsLS = locsLS + nHigh;
        end

        % Select the loading index, for low frequency these also
        % include lagged factors
        indBL   = 1:startIdio;
        nStates = size(alpha,1);

        for qq = 1:size(locsL,2)

            % Index of eps for this low frequency variable, including
            % lagged values of eps due to mixed frequency mapping
            locsLqq = locsLS(qq):nLow:nStates;

            % Preallocation for eq 13 for one low frequency variable
            d = zeros(5*nFac,5*nFac);
            n = zeros(1,5*nFac);

            % Get the count of this variable amoung all variables
            count = locsLS(qq) - startIdio;

            % Get the count of this variable amoung the low frequency
            % variables
            if options.nLagsIdiosyncratic
                lowCount = count - nHigh;
            else
                lowCount = count;
                count    = count + nHigh;
            end

            % Get mapping for this variable
            Hqq = Hlow(lowCount,lowCount:nLow:end);
            for t = find(~nanInd(:,count))'

                % E[F(t)*F(t)' | OmegaV]
                d = d + alpha(indBL,t)*alpha(indBL,t)' + Ps(indBL,indBL,t);

                % E[X(t)*F(t)' | OmegaV]
                n = n + X(t,count)'*alpha(indBL,t)' - Hqq*alpha(locsLqq,t)*alpha(indBL,t)' - Hqq*Ps(locsLqq,indBL,t);

            end

            % Apply eq 13 restricted to the mapping of this low 
            % frequency variable
            [R,r] = nb_dfmemlEstimator.getMapping(options,count);
            r     = repmat(r,[nFac,1]);
            R     = kron(R,eye(nFac));
            Zq    = d\n';
            Zq    = Zq - (d\R')*((R*(d\R'))\(R*Zq - r));

            % Place updated values in output structure
            results.Z(count,indBL) = Zq';

        end

    end
    
    % If we have no serial correlation in the idiosyncratic components
    % we need to update the measurement error covariance matrix. See
    % appendix B of Banbura and Modugno (2010)
    if options.nLagsIdiosyncratic == 0
        In = eye(N);
        R  = zeros(N,N);
        for t = 1:T
            Wt = diag(~nanInd(t,:)); % Selection matrix
            R  = R + (X(t,:)' - Wt*results.Z*alpha(:, t))*(X(t,:)' - Wt*results.Z*alpha(:,t))' +...
                    Wt*results.Z*Ps(:,:,t)*results.Z'*Wt + (In - Wt)*results.R*(In - Wt);
        end
        results.R = diag(diag(R/T));
    end
    
end
