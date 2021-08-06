function [YDRAW,start,finish,indY,startEst] = makeArtificial(model,options,results,method,draws,iter)
% Syntax:
%
% [YDRAW,start,finish,indY] = nb_arimaEstimator.makeArtificial(model,...
%                               options,results,method,draws,iter)
%
% Description:
%
% Make artificial data from model by simulation.
%
% Caution: The options struct is assumed to already be index by iter!
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    draws = ceil(draws);
    if isempty(method)
        method = 'bootstrap';
    end

    A     = model.A(:,:,iter);
    G     = model.G(:,:,iter);
    resid = results.residual(:,:,iter); 
    indN  = ~isnan(resid(:,1));
    resid = resid(indN,:); % Remove nan given that we could be dealing with recursive estimation
    ART   = options.AR + options.SAR;
    MAT   = options.MA + options.SMA;
    AR    = A(1,1:ART);
    C     = [1,A(1,ART+1:end)];
    
    exo      = model.factors;
    start    = options.estim_start_ind;
    nobs     = size(resid,1);
    finish   = start + nobs - 1;
    correct  = max(ART,MAT+1) - 1;
    start    = start + correct;
    nobs     = nobs - correct; 

    % Use the residuals to bootstrap: generate a random number bounded 
    % between 0 and # of residuals, then use the ceil function to select 
    % that row of the residuals (this is equivalent to sampling with 
    % replacement)

    % Then we bootstrap the residuals
    E = nb_bootstrap(resid,draws,method);
    if MAT > 0
        E = permute(E,[3,1,2]);
        E = [E,nb_mlag(E,MAT)];
        E = permute(E,[2,3,1]);
        E = E(:,:,MAT+1:end);
    end
    s = size(E,3) - nobs; 
    E = E(:,:,s+1:end);
    
    % Get the deterministic exogenous variables
    X        = nan(nobs,0);
    constant = options.constant;
    if constant 
        X = [X,ones(nobs,1)];
    end

    if isfield(options,'time_trend')
        time_trend = options.time_trend;
        if time_trend
            t = 1:nobs;
            X = [X,t']; 
        end
    end

    % Get other exogenous variables (which are not randomized!!!)
    [ind,indX] = ismember(exo,options.dataVariables);
    indX       = indX(ind);
    XS         = options.data(start:finish,indX);    
    X          = [X,XS]'; 
       
    % Clean dependent for exogenous variables
    [~,indY] = ismember(options.dependent,options.dataVariables);
    Y        = options.data(start:finish,indY)';
    if isempty(X)
        X = zeros(size(Y));
    end
    U = Y - G*X;
    U = U';
    U = [U,nb_mlag(U,ART - 1)];
    U = U';
    
    % Generate the artificial data
    %-------------------------------
    YDRAW        = zeros(1,draws,nobs - ART + 1);
    YDRAW(:,:,1) = repmat(U(1,1),[1,draws]);
    tt           = 2;
    for t = ART:nobs-1
        AY            = AR*U(:,t);
        AY            = AY(:,ones(1,draws));
        YDRAW(:,:,tt) = AY + C*E(:,:,t);
        tt            = tt + 1;
    end    
    YDRAW = permute(YDRAW,[1,3,2]);
      
    % Append contribution of exogenous variables
    X = X(:,ART:end);
    for ii = 1:draws
        YDRAW(:,:,ii)  = YDRAW(:,:,ii) + G*X;
    end
    YDRAW = permute(YDRAW,[2,1,3]);
    
    % Other outputs
    %------------------------
    start    = finish - size(YDRAW,1) + 1;
    [~,indY] = ismember(options.dependent,options.dataVariables);
    startEst = [];
    
end
