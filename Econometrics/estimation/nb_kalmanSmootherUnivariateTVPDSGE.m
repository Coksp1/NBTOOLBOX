function [xf,xs,us] = nb_kalmanSmootherUnivariateTVPDSGE(H,A,C,~,x0,P0,P0INF,y,kalmanTol)
% Syntax:
%
% [xf,xs,us] = nb_kalmanSmootherUnivariateTVPDSGE(H,A,C,obs,x0,P0,...
%                               P0INF,y,kalmanTol)
%
% Description:
%
% Diffuse univariate Kalman smoother with observed time-varying 
% paramerters that does not affect the steady-state. With potentially 
% missing observations!
%
% Observation equation:
% y(t) = H*x(t)
% 
% State equation:
% x(t) = A(t)*x(t-1) + C(t)*u(t)
%
% Where u ~ N(0,I) meaning u is gaussian noise with covariance I
%
% Input:
%
% - H         : Observation matrix. As a nObs x nEndo double.
%
% - A         : State transition matrix. With size nEndo x nEndo x 
%               nPeriods.
%
% - C         : The impact of shock matrix. With size nEndo x nExo x 
%               nPeriods.
%
% - obs       : Index of observables in the vector of state variables. A 
%               logical vector with size size(A,1) x 1.
%
% - x0        : Initial state vector. As a nEndo x 1 double.
%
% - P0        : Initial state variance. As a nEndo x nEndo double.
%
% - P0INF     : Initial state variance of the non-stationary variables.  
%               As a nEndo x nEndo double.
%
% - y         : Observation vector. A nObs x T double.
%
% - kalmanTol : Tolerance level for rcond of the forecast variance.
%
% Output:
%
% - xf : The filtered estimates of the x in the equation above.
%
% - xs : The smoothed estimates of the x in the equation above.
%
% - us : The smoothed estimates of the u in the equation above.
%
% See also:
% nb_kalmanLikelihoodDiffuseTVPDSGE, nb_kalmanSmootherTVPDSGE,
% nb_setUpForDiffuseFilter
%
% Written by Kenneth Sæterhagen Paulsen.

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Initialize state estimate from first observation if needed
    %--------------------------------------------------------------
    nExo        = size(C,2);
    [nObs,S]    = size(y);
    nEndo       = size(A,1);
    PS          = nan(nEndo,nEndo,S+1);   % P t+1|t
    PINF        = zeros(nEndo,nEndo,S+1); % PINF t+1|t
    xf          = zeros(nEndo,S+1);       % x t+1|t
    xu          = zeros(nEndo,S);         % x t|t
    KS          = zeros(nEndo,nObs,S);
    KINF        = zeros(nEndo,nObs,S);
    PS(:,:,1)   = P0;  
    PINF(:,:,1) = P0INF;
    xf(:,1)     = x0;
    FS          = zeros(nObs,S);
    FINF        = zeros(nObs,S);

    % Lead one period, so indexing gets correct.
    A(:,:,1:S-1) = A(:,:,2:S);
    C(:,:,1:S-1) = C(:,:,2:S);
    A = A(:,:,ones(1,size(A,3)));
    C = C(:,:,ones(1,size(A,3)));
    
    % Loop through the diffuse kalman filter iterations
    %--------------------------------------------------------------
    vf = zeros(nObs,S);
    HT = H';
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
        xu(:,tt)       = xt;                                                 % x t|t
        xf(:,tt+1)     = A(:,:,tt)*xt;                                       % x t+1 | t = A_t * x t|t
        PS(:,:,tt+1)   = A(:,:,tt)*PSU*A(:,:,tt)' + C(:,:,tt)*C(:,:,tt)';    % PS t+1|t = A_t * PS t|t * A_t' + C_t*C_t'
        PINF(:,:,tt+1) = A(:,:,tt)*PINFU*A(:,:,tt)';                         % PINF t+1|t = A_t * PINF t|t * A_t'
        
        % Check rank
        rOld = rank(H*PINFU*H',kalmanTol);
        r    = rank(H*PINF(:,:,tt+1)*H',kalmanTol);
        if rOld ~= r
            disp(['nb_kalmanSmootherUnivariateTVPDSGE:: The forecasting step does influence the rank of the ',...
                 'filtered one step ahead covariance matrix during the diffuse steps (PINF)!'])
        end
        
        tt = tt + 1;
        
    end
    
    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
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
        xu(:,tt)     = xt;                                              % x t|t
        xf(:,tt+1)   = A(:,:,tt)*xt;                                    % x t+1 | t = A * x t|t
        PS(:,:,tt+1) = A(:,:,tt)*PSU*A(:,:,tt)' + C(:,:,tt)*C(:,:,tt)'; % PS t+1|t = A * PS t|t * A' + C_t*C_t'
         
    end
    
    % Then we do the smoothing
    %-------------------------------------------------------------
    us = nan(nExo,S);
    xs = nan(nEndo,S);          
    r  = zeros(nEndo,S + 1);
    t  = S + 1;
    I  = eye(nEndo);
    while t > start % Normal steps of the smoother
        t      = t - 1;
        r(:,t) = A(:,:,tt)'*r(:,t+1); 
        for ii = flipud(find(m(:,t)))'
            if FS(ii,t) > kalmanTol
                LS     = I - KS(:,ii,t)*H(ii,:)/FS(ii,t);
                r(:,t) = H(ii,:)'/FS(ii,t)*vf(ii,t) + LS'*r(:,t); 
            end
        end
        xs(:,t) = xf(:,t) + PS(:,:,t)*r(:,t);
        us(:,t) = C(:,:,t)'*r(:,t);
    end
    
    if start > 1 % Diffuse part of the smoother
        r1 = zeros(nEndo,start); 
        for t = start-1:-1:1
            r(:,t)  = A(:,:,tt)'*r(:,t+1);
            r1(:,t) = A(:,:,tt)'*r1(:,t+1);
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
            us(:,t) = C(:,:,t)'*r(:,t);
        end
    end
    
    % Report the estimates
    %-------------------------------------------------------------
    xs = xs';
    us = us';
    xf = xf(:,2:end)';
    
end
