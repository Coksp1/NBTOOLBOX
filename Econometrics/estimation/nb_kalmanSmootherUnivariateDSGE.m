function [xf,xs,us,xu,uu] = nb_kalmanSmootherUnivariateDSGE(H,A,C,~,x0,P0S,P0INF,y,kalmanTol)
% Syntax:
%
% [xf,xs,us,xu,uu] = nb_kalmanSmootherUnivariateDSGE(H,A,C,obs,x0,P0S,...
%                               P0INF,y,kalmanTol)
%
% Description:
%
% Diffuse univariate Kalman smoother to handle non-stationary models. With 
% potentially missing observations!
%
% Observation equation:
% y(t) = H*x(t)
% 
% State equation:
% x(t) = A*x(t-1) + C*u(t)
%
% Where u ~ N(0,I), meaning u is gaussian noise with covariance I
%
% See for example: Koopman and Durbin (1998), "Fast filtering and 
% smoothing for multivariate state space models".
%
% Input:
%
% - H       : Observation matrix. As a nObs x nEndo double.
%
% - A       : State transition matrix. As a nEndo x nEndo double.
%
% - C       : The impact of shock matrix. As a nEndo x nExo double.
%
% - obs     : Index of observables in the vector of state variables. A 
%             logical vector with size size(A,1) x 1.
%
% - x0      : Initial state vector. As a nEndo x 1 double.
%
% - P0      : Initial state variance. As a nEndo x nEndo double.
%
% - P0INF   : Initial state variance of the non-stationary variables.  
%             As a nEndo x nEndo double.
%
% - y       : Observation vector. A nObs x T double.
%
% Output:
%
% - xf : The filtered estimates of the x in the equation above.
%
% - xs : The smoothed estimates of the x in the equation above.
%
% - us : The smoothed estimates of the u in the equation above.
%
% - xu : The updated estimates of the x in the equation above.
%
% - uu : The updated estimates of the u in the equation above.
%
% See also:
% nb_kalmanSmootherDSGE, nb_kalmanLikelihoodUnivariateDSGE,
% nb_setUpForDiffuseFilter, nb_kalmanSmootherDiffuseDSGE
%
% Written by Kenneth Sæterhagen Paulsen

    % Initialize state estimate from first observation if needed
    %--------------------------------------------------------------
    nExo        = size(C,2);
    CC          = C*C';
    [nObs,S]    = size(y);
    nEndo       = size(A,1);
    PS          = nan(nEndo,nEndo,S+1);   % PS t+1|t
    PINF        = zeros(nEndo,nEndo,S+1); % PINF t+1|t
    xf          = zeros(nEndo,S+1);       % x t+1|t
    xu          = zeros(nEndo,S);         % x t|t
    KS          = zeros(nEndo,nObs,S);
    KINF        = zeros(nEndo,nObs,S);
    PS(:,:,1)   = P0S; 
    PINF(:,:,1) = P0INF;
    xf(:,1)     = x0;
    FS          = zeros(nObs,S);
    FINF        = zeros(nObs,S);

    % Loop through the diffuse kalman filter iterations
    %--------------------------------------------------------------
    vf = nan(nObs,S);
    HT = H';
    AT = A';
    m  = ~isnan(y);
    r  = rank(H*PINF(:,:,1)*H',kalmanTol);
    tt = 1;
    while r && tt <= S    
        
        % Initialize updated states
        xt    = xf(:,tt);     % Initialize x t|t with x t|t-1
        PSU   = PS(:,:,tt);   % Initialize PS t|t with PS t|t-1
        PINFU = PINF(:,:,tt); % Initialize PINF t|t with PINF t|t-1

        % Loop through each observables and update the state (x t|t) and
        % covariance matrix (PS t|t and PINF t|t)
        for ii = find(m(:,tt))'

            Hii         = H(ii,:);
            vf(ii,tt)   = y(ii,tt) - Hii*xt;
            Hiit        = HT(:,ii);
            FINF(ii,tt) = Hii*PINFU*Hiit;
            FS(ii,tt)   = Hii*PSU*Hiit;
            KS(:,ii,tt) = PSU*Hiit;
            if FINF(ii,tt) > kalmanTol && r
                KINF(:,ii,tt) = PINFU*Hiit;
                KINF_DIV_FINF = KINF(:,ii,tt)/FINF(ii,tt);
                xt            = xt + KINF_DIV_FINF*vf(ii,tt);
                PSU           = PSU + KINF(:,ii,tt)*KINF_DIV_FINF'*(FS(ii,tt)/FINF(ii,tt)) - KS(:,ii,tt)*KINF_DIV_FINF' - KINF_DIV_FINF*KS(:,ii,tt)'; 
                PINFU         = PINFU - KINF(:,ii,tt)*KINF(:,ii,tt)'/FINF(ii,tt);
            elseif FS(ii,tt) > kalmanTol
                xt  = xt + KS(:,ii,tt)*vf(ii,tt)/FS(ii,tt); 
                PSU = PSU - KS(:,ii,tt)*KS(:,ii,tt)'/FS(ii,tt);
            end

        end
            
        % Forecast
        xu(:,tt)       = xt;               % x t|t
        xf(:,tt+1)     = A*xt;             % x t+1 | t = A * x t|t
        PS(:,:,tt+1)   = A*PSU*A' + CC;    % PS t+1|t = A * PS t|t * A';
        PINF(:,:,tt+1) = A*PINFU*A';       % PINF t+1|t = A * PINF t|t * A';
        
        % Check rank
        rOld = rank(H*PINFU*H',kalmanTol);
        r    = rank(H*PINF(:,:,tt+1)*H',kalmanTol);
        if rOld ~= r
            disp(['nb_kalmanSmootherUnivariateDSGE:: The forecasting step does influence the rank of the ',...
                  'filtered one step ahead covariance matrix during the diffuse steps (PINF)!'])
        end
        
        tt = tt + 1;
        
    end
    
    % Free memory
    start = tt;
    FINF  = FINF(:,:,1:start-1);
    PINF  = PINF(:,:,1:start-1);
    KINF  = KINF(:,:,1:start-1);
    
    % From here we do the normal iterations
    for tt = start:S

         % Initialize updated states
        xt  = xf(:,tt);     % Initialize x t|t with x t|t-1
        PSU = PS(:,:,tt);   % Initialize PS t|t with PS t|t-1
        
        % Loop through each observables and update the state (x t|t) and
        % covariance matrix (PS t|t)
        for ii = find(m(:,tt))'

            Hii         = H(ii,:);
            vf(ii,tt)   = y(ii,tt) - Hii*xt;
            Hiit        = HT(:,ii);
            FS(ii,tt)   = Hii*PSU*Hiit;
            KS(:,ii,tt) = PSU*Hiit;
            if FS(ii,tt) > kalmanTol
                xt  = xt + KS(:,ii,tt)*vf(ii,tt)/FS(ii,tt); 
                PSU = PSU - KS(:,ii,tt)*KS(:,ii,tt)'/FS(ii,tt);
            end

        end    
        
        % Forecast 
        xu(:,tt)     = xt;               % x t|t
        xf(:,tt+1)   = A*xt;             % x t+1 | t = A * x t|t
        PS(:,:,tt+1) = A*PSU*A' + CC;    % PS t+1|t = A * PS t|t * A';
         
    end
    
    % Then we do the smoothing
    %-------------------------------------------------------------
    us = nan(nExo,S);
    xs = nan(nEndo,S);          
    r  = zeros(nEndo,S + 1);
    t  = S + 1;
    CT = C';
    I  = eye(nEndo);
    while t > start % Normal steps of the smoother
        t      = t - 1;
        r(:,t) = AT*r(:,t+1); 
        for ii = flipud(find(m(:,t)))'
            if FS(ii,t) > kalmanTol
                LS     = I - KS(:,ii,t)*H(ii,:)/FS(ii,t);
                r(:,t) = H(ii,:)'/FS(ii,t)*vf(ii,t) + LS'*r(:,t); 
            end
        end
        xs(:,t) = xf(:,t) + PS(:,:,t)*r(:,t);
        us(:,t) = CT*r(:,t);
    end
    
    if start > 1 % Diffuse part of the smoother
        r1 = zeros(nEndo,start); 
        for t = start-1:-1:1
            r(:,t)  = AT*r(:,t+1);
            r1(:,t) = AT*r1(:,t+1);
            for ii = flipud(find(m(:,t)))'
                if FINF(ii,t) > kalmanTol
                    LINF    = I - KINF(:,ii,t)*H(ii,:)/FINF(ii,t);
                    L0      = (KINF(:,ii,t)*(FS(ii,t)/FINF(ii,t)) - KS(:,ii,t))*H(ii,:)/FINF(ii,t);
                    r1(:,t) = H(ii,:)'*vf(ii,t)/FINF(ii,t) + L0'*r(:,t) + LINF'*r1(:,t);  
                    r(:,t)  = LINF'*r(:,t);   
                elseif FS(ii,t) > kalmanTol 
                    L      = I - KS(:,ii,t)*H(ii,:)/FS(ii,t);
                    r(:,t) = H(ii,:)'/FS(ii,t)*vf(ii,t) + L'*r(:,t);
                end
            end
            xs(:,t) = xf(:,t) + PS(:,:,t)*r(:,t) + PINF(:,:,t)*r1(:,t);
            us(:,t) = CT*r(:,t);
        end
    end
    
    % Report the estimates
    %-------------------------------------------------------------
    xs = xs';
    us = us';
    xf = xf(:,2:end)';
    if nargout > 4
        
        % Get the updated shocks
        uu      = zeros(nExo,S);
        uu(:,1) = C\xu(:,1);
        for t = 2:S
            uu(:,t) = C\(xu(:,t) - A*xu(:,t-1));
        end
        uu = uu';
        
    end
    xu = xu';
    
end
