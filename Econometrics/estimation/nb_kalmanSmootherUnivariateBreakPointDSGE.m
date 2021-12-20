function [xf,xs,us,xu,uu] = nb_kalmanSmootherUnivariateBreakPointDSGE(H,A,C,ss,~,x0,P0,P0INF,y,kalmanTol,states)
% Syntax:
%
% [xf,xs,us,xu,uu] = nb_kalmanSmootherUnivariateBreakPointDSGE(H,A,C,ss,...
%                               obs,x0,P0,P0INF,y,kalmanTol,states)
%
% Description:
%
% Diffuse univariate piecewise linear Kalman smoother. With potentially  
% missing observations!
%
% Observation equation:
% y(t) = H*x(t)
% 
% State equation:
% x(t) = ss(t) + A(t)*(x(t-1) - ss(t)) + C(t)*u(t)
%
% Where u ~ N(0,I) meaning u is gaussian noise with covariance I
%
% Input:
%
% - H         : Observation matrix. As a nObs x nEndo double.
%
% - A         : State transition matrix. A cell with size 1 x nStates.
%               Each element as a nEndo x nEndo double.
%
% - C         : The impact of shock matrix. A cell with size 1 x nStates.
%               Each element as a nEndo x nExo double.
%
% - ss        : Steady-state of the endogenous variables. A cell with size 
%               1 x nStates. Each element as a nEndo x 1 double.
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
% - states    : A 1 x nobs double with the break period to use for each
%               period, i.e. how to index A,B and ss at each period.
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
% nb_kalmanLikelihoodUnivariateBreakPointDSGE,  
% nb_kalmanSmootherBreakPointDSGE, nb_setUpForDiffuseFilter
%
% Written by Kenneth Sæterhagen Paulsen.

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Initialize state estimate from first observation if needed
    %--------------------------------------------------------------
    nExo        = size(C{1},2);
    [nObs,S]    = size(y);
    nEndo       = size(A{1},1);
    PS          = nan(nEndo,nEndo,S+1);   % P t+1|t
    PINF        = zeros(nEndo,nEndo,S+1); % PINF t+1|t
    xf          = zeros(nEndo,S+1);       % x t+1|t
    xu          = zeros(nEndo,S);         % x t|t
    KS          = zeros(nEndo,nObs,S);
    KINF        = zeros(nEndo,nObs,S);
    PS(:,:,1)   = P0;
    PINF(:,:,1) = P0INF;
    xf(:,1)     = x0;
    states      = [states;states(end)];
    FS          = zeros(nObs,S);
    FINF        = zeros(nObs,S);
    
    % Loop through the diffuse kalman filter iterations
    %--------------------------------------------------------------
    vf = zeros(nObs,S);
    HT = H';
    m  = ~isnan(y);
    r  = rank(H*PINF(:,:,1)*H',kalmanTol);
    tt = 1;
    while r && tt <= S  
        
        % Matrices of the current regime
        At  = A{states(tt+1)};
        CCt = C{states(tt+1)}*C{states(tt+1)}';
        
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
        xu(:,tt)       = xt;                                            % x t|t
        xf(:,tt+1)     = ss{states(tt+1)} + At*(xt - ss{states(tt+1)}); % x t+1 | t = A * x t|t
        PS(:,:,tt+1)   = At*PSU*At' + CCt;                              % PS t+1|t = A * PS t|t * A';
        PINF(:,:,tt+1) = At*PINFU*At';                                  % PINF t+1|t = A * PINF t|t * A';
        
        % Check rank
        rOld = rank(H*PINFU*H',kalmanTol);
        r    = rank(H*PINF(:,:,tt+1)*H',kalmanTol);
        if rOld ~= r
            disp(['nb_kalmanSmootherUnivariateBreakPointDSGE:: The forecasting step does influence the rank of the ',...
                  'filtered one step ahead covariance matrix during the diffuse steps (PINF)!'])
        end
        
        tt = tt + 1;
        
    end
    
    % Free memory
    start = tt;
    FINF  = FINF(:,:,1:start-1);
    PINF  = PINF(:,:,1:start-1);
    KINF  = KINF(:,:,1:start-1);
    
    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
    start = tt;
    for tt = start:S
        
        % Matrices of the current regime
        At  = A{states(tt+1)};
        CCt = C{states(tt+1)}*C{states(tt+1)}';
        
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
        xu(:,tt)     = xt;                                            % x t|t
        xf(:,tt+1)   = ss{states(tt+1)} + At*(xt - ss{states(tt+1)}); % x t+1 | t = A * x t|t
        PS(:,:,tt+1) = At*PSU*At' + CCt;                              % PS t+1|t = A * PS t|t * A';
         
    end
    
    % Then we do the smoothing
    %-------------------------------------------------------------
    xs = nan(nEndo,S);          
    r  = zeros(nEndo,S + 1);
    t  = S + 1;
    I  = eye(nEndo);
    while t > start % Normal steps of the smoother
        t      = t - 1;
        r(:,t) = A{states(t+1)}'*r(:,t+1); 
        for ii = flipud(find(m(:,t)))'
            if FS(ii,t) > kalmanTol
                LS     = I - KS(:,ii,t)*H(ii,:)/FS(ii,t);
                r(:,t) = H(ii,:)'/FS(ii,t)*vf(ii,t) + LS'*r(:,t); 
            end
        end
        xs(:,t) = xf(:,t) + PS(:,:,t)*r(:,t);
    end
    
    if start > 1 % Diffuse part of the smoother
        r1 = zeros(nEndo,start); 
        for t = start-1:-1:1
            r(:,t)  = A{states(t+1)}'*r(:,t+1);
            r1(:,t) = A{states(t+1)}'*r1(:,t+1);
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
        end
    end
    
    % Get the smoothed shocks
    %-------------------------------------------------------------
    us      = zeros(nExo,S);
    us(:,1) = C{states(1)}\(xs(:,1) - ss{states(1)});
    for t = 2:S
        us(:,t) = C{states(t)}\(xs(:,t) - ss{states(t)} - A{states(t)}*(xs(:,t-1) - ss{states(t)}) );
    end
    
    % Report the estimates
    %-------------------------------------------------------------
    xs = xs';
    us = us';
    xf = xf(:,2:end)';
    if nargout > 4
        
        % Get the updated shocks
        uu      = zeros(nExo,S);
        uu(:,1) = C{states(1)}\(xu(:,1) - ss{states(1)});
        for t = 2:S
            uu(:,t) = C{states(t)}\(xu(:,t) - ss{states(t)} - A{states(t)}*(xu(:,t-1) - ss{states(t)}) );
        end
        uu = uu';
        
    end
    xu = xu';

end
