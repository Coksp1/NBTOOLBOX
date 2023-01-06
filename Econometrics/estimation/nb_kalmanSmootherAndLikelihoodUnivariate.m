function [xf,xu,xs,us,lik,Ps,Ps_1,Pf,Pinf,Pu,Pinfu] = nb_kalmanSmootherAndLikelihoodUnivariate(H,R,A,B,x0,P0,Pinf0,y,kalmanTol,kf_presample,G,z)
% Syntax:
%
% [xf,xu,xs,us,lik,Ps,Ps_1,Pf,Pinf,Pu,Pinfu] = ...
%    nb_kalmanSmootherAndLikelihood(H,R,A,B,obs,x0,P0,Pinf0,y,...
%       kalmanTol,kf_presample,G,z)
%
% Description:
%
% Kalman smoother. With potentially missing observations!
%
% Observation equation:
% y(t) = H*x(t) + v(t)
% 
% State equation:
% x(t) = A*x(t-1) + B*u(t)
%
% or if G and z is given
%
% x(t) = A*x(t-1) + G*z(t) + B*u(t)
%
% Where u ~ N(0,I) and v ~ N(0,R).
%
% See for example: Koopman and Durbin (1998), "Fast filtering ans smoothing
% for multivariate state space models" and Hamilton (1994), "Time Series 
% Analysis"
%
% Input:
%
% - H            : Observation matrix. As a nObs x nEndo double.
%
% - R            : Measurement error covariance matrix. As a nObs x nObs 
%                  double. If you assume no measurement error, give 
%                  zeros(nObs).
%
% - A            : State transition matrix. As a size nEndo x nEndo.
%
% - B            : The impact of shock matrix. As a size nEndo x nExo.
%
% - x0           : Initial state vector. As a nEndo x 1 double.
%
% - P0           : Initial state variance. As a nEndo x nEndo double.
%
% - Pinf0        : Diffuse initial state variance. As a nEndo x nEndo 
%                  double.
%
% - y            : Observation vector. A nObs x T double.
%
% - kalmanTol    : Kalman tolerance. 
%
% - kf_presample : Number of periods before the likelihood is calculated.
%
% - G            : A nEndo x nExo double.
%
% - z            : A nExo x T double
%
% Output:
%
% - xf    : The filtered estimates (x t+1|t) of the x in the equation 
%           above. A nEndo x T + 1 double. xf(:,1) is set to x0, and is 
%           interpreted as x 1|0.
% 
% - xu    : The updated estimates (x t|t) of the x in the equation above.
%           A nEndo x T + 1 double. xu(:,1) is set to x0, and is 
%           interpreted as x 0|0.
%
% - xs    : The smoothed estimates (x t|T) of the x in the equation above.
%           A nEndo x T + 1 double. xs(:,1) is interpreted as x 1|T.
%           
% - us    : The smoothed estimates of the u in the equation above.
%           A nExo x T double.
%
% - lik   : Minus the log likelihood. As a 1 x 1 double.
%
% - Ps    : Smoothed one step ahead covariance matrices. P t|T.
%           A nEndo x nEndo x T double. Ps(:,1) is interpreted as 
%           P 1|T.
%
% - Ps_1  : Smoothed etimate of Cov(x(t) x(t-1)|T). P_1 t|T.
%           A nEndo x nEndo x T double.
%
% - Pf    : Filtered one step ahead covariance matrices. P t+1|t. 
%           A nEndo x nEndo x T+1 double. P0 at first page.
%
% - Pinf  : Filtered one step ahead covariance matrices of diffuse steps.  
%           Pinf t+1|t. A nEndo x nEndo x S double, where S is the 
%           number of periods in the diffuse stage. Pinf0 at first page.
%
% - Pu    : Updated one step ahead covariance matrices. P t|t.
%           A nEndo x nEndo x T+1 double. P0 at first page.
%
% - Pinfu : Filtered one step ahead covariance matrices of diffuse steps.  
%           Pinf t+1|t. A nEndo x nEndo x S double, where S is the 
%           number of periods in the diffuse stage. Pinf0 at first page.
%
% See also:
% nb_kalmanLikelihoodMissingDSGE, nb_kalmanSmootherAndLikelihood
%
% Written by Kenneth Sæterhagen Paulsen.

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 8
        kf_presample = 5;
    end
    incrSmoother = 0;
    
    % Initialize state estimate from first observation if needed
    %--------------------------------------------------------------
    nExo  = size(B,2);
    BB    = B*B';
    [O,T] = size(y);
    nEndo = size(A,1);
    nObs  = size(H,1);
    Pf    = nan(nEndo,nEndo,T+1);   % P t+1|t
    Pu    = nan(nEndo,nEndo,T+1);   % P t|t
    Pinf  = nan(nEndo,nEndo,T+1);   % Pinf t+1|t
    Pinfu = nan(nEndo,nEndo,T+1);   % Pinf t|t
    xf    = zeros(nEndo,T+1);       % x t+1|t
    xu    = zeros(nEndo,T+1);       % x t+1|t
    KS    = zeros(nEndo,nObs,T);
    KINF  = zeros(nEndo,nObs,T);
    FS    = zeros(nObs,T);
    FINF  = zeros(nObs,T);
    
    % Intial values
    Pf(:,:,1)    = P0; % P 1|0 
    Pu(:,:,1)    = P0; % P 0|0
    Pinf(:,:,1)  = Pinf0; % Pinf 1|0
    Pinfu(:,:,1) = Pinf0; % Pinf 0|0
    xf(:,1)      = x0; % x 1|0
    xu(:,1)      = x0; % x 0|0

    % Set up for filter
    lik = zeros(T,1);
    vf  = nan(O,T);
    HT  = H';
    AT  = A';
    m   = ~isnan(y);
    
    % Loop through the diffuse kalman filter iterations
    %--------------------------------------------------------------
    r  = rank(H*Pinf(:,:,1)*H',kalmanTol);
    tt = 1;
    while r && tt <= T   
        
        % Initialize updated states
        xt    = xf(:,tt);     % Initialize x t|t with x t|t-1
        PU    = Pf(:,:,tt);   % Initialize P t|t with P t|t-1
        PINFU = Pinf(:,:,tt); % Initialize Pinf t|t with Pinf t|t-1

        % Loop through each observables and update the state (x t|t) and
        % covariance matrix (PS t|t and PINF t|t)
        for ii = find(m(:,tt))'

            Hii         = H(ii,:);
            vf(ii,tt)   = y(ii,tt) - Hii*xt;
            Hiit        = HT(:,ii);
            FINF(ii,tt) = Hii*PINFU*Hiit;
            FS(ii,tt)   = Hii*PU*Hiit + R(ii,ii);
            KS(:,ii,tt) = PU*Hiit;
            if FINF(ii,tt) > kalmanTol && r
                KINF(:,ii,tt) = PINFU*Hiit;
                KINF_DIV_FINF = KINF(:,ii,tt)/FINF(ii,tt);
                xt            = xt + KINF_DIV_FINF*vf(ii,tt);
                PU           = PU + KINF(:,ii,tt)*KINF_DIV_FINF'*(FS(ii,tt)/FINF(ii,tt)) - KS(:,ii,tt)*KINF_DIV_FINF' - KINF_DIV_FINF*KS(:,ii,tt)'; 
                PINFU         = PINFU - KINF(:,ii,tt)*KINF(:,ii,tt)'/FINF(ii,tt);
                lik(tt)       = lik(tt) + log(FINF(ii,tt));
            elseif FS(ii,tt) > kalmanTol
                xt           = xt + KS(:,ii,tt)*vf(ii,tt)/FS(ii,tt); 
                PU           = PU - KS(:,ii,tt)*KS(:,ii,tt)'/FS(ii,tt);
                lik(tt)      = lik(tt) + log(FS(ii,tt)) + (vf(ii,tt)*vf(ii,tt)/FS(ii,tt));
                incrSmoother = 1;
            end

        end
            
        % Forecast
        xu(:,tt+1) = xt;                    % x t|t
        if nargin > 10
            xf(:,tt+1) = A*xt + G*z(:,tt);  % x t+1 | t = A * x t|t + G * z t + 1
        else
            xf(:,tt+1) = A*xt;              % x t+1 | t = A * x t|t
        end
        Pu(:,:,tt+1)    = PU;               % P t|t
        Pf(:,:,tt+1)    = A*PU*AT + BB;     % P t+1|t = A * P t|t * A' + B*B';
        Pinfu(:,:,tt+1) = PINFU;            % PINF t|t = A * PINF t|t * A';
        Pinf(:,:,tt+1)  = A*PINFU*AT;       % PINF t+1|t = A * PINF t|t * A';
        
        % Check rank
        rOld = rank(H*PINFU*H',kalmanTol);
        r    = rank(H*Pinf(:,:,tt+1)*H',kalmanTol);
        if rOld ~= r
            disp(['nb_kalmanSmootherAndLikelihoodUnivariate:: The forecasting step does influence the rank of the ',...
                  'filtered one step ahead covariance matrix during the diffuse steps (PINF)!'])
        end
        
        tt = tt + 1;
         
    end
    
    % Free memory
    start = tt;
    FINF  = FINF(:,1:start-1);
    Pinf  = Pinf(:,:,1:start-1);
    Pinfu = Pinfu(:,:,1:start-1);
    KINF  = KINF(:,:,1:start-1);
    
    % From here we do the normal iterations
    for tt = start:T

         % Initialize updated states
        xt = xf(:,tt);    % Initialize x t|t with x t|t-1
        PU = Pf(:,:,tt);  % Initialize PS t|t with PS t|t-1
        
        % Loop through each observables and update the state (x t|t) and
        % covariance matrix (PS t|t)
        for ii = find(m(:,tt))'

            Hii         = H(ii,:);
            vf(ii,tt)   = y(ii,tt) - Hii*xt;
            Hiit        = HT(:,ii);
            FS(ii,tt)   = Hii*PU*Hiit + R(ii,ii);
            KS(:,ii,tt) = PU*Hiit;
            if FS(ii,tt) > kalmanTol
                xt      = xt + KS(:,ii,tt)*vf(ii,tt)/FS(ii,tt); 
                PU      = PU - KS(:,ii,tt)*KS(:,ii,tt)'/FS(ii,tt);
                lik(tt) = lik(tt) + log(FS(ii,tt)) + (vf(ii,tt)*vf(ii,tt)/FS(ii,tt));
            end

        end    
        
        % Forecast 
        xu(:,tt+1) = xt;                    % x t|t
        if nargin > 10
            xf(:,tt+1) = A*xt + G*z(:,tt);  % x t+1 | t = A * x t|t + G * z t + 1
        else
            xf(:,tt+1) = A*xt;              % x t+1 | t = A * x t|t
        end
        Pu(:,:,tt+1) = PU;                  % P t|t
        Pf(:,:,tt+1) = A*PU*A' + BB;        % P t+1|t = A * P t|t * A' + B*B';
         
    end
    
    % Then we do the smoothing
    %-------------------------------------------------------------
    us = nan(nExo,T);
    xs = nan(nEndo,T);
    r  = zeros(nEndo,T + 1);
    N  = zeros(nEndo,nEndo,T + 1);
    t  = T + 1;
    BT = B';
    I  = eye(nEndo); 
    
    % Normal steps of the smoother. Equations 23 of Koopman and 
    % Durbin (1998)
    start = start - incrSmoother; 
    while t > start 
        t        = t - 1;
        r(:,t)   = AT*r(:,t+1); 
        if t > 1
            N(:,:,t) = AT*N(:,:,t+1)*A;
        else
            % Use equation (5) of Koopman and Durbin (1998) for t == 1
            FSinv    = diag(1./FS(m(:,t),t));
            LS       = I - KS(:,m(:,t),t)*FSinv*H(m(:,t),:);
            N(:,:,t) = H(m(:,t),:)'*FSinv*H(m(:,t),:) + LS*AT*N(:,:,t+1)*A*LS;
        end
        for ii = flipud(find(m(:,t)))'
            if FS(ii,t) > kalmanTol
                LS       = I - KS(:,ii,t)*H(ii,:)/FS(ii,t);
                r(:,t)   = H(ii,:)'/FS(ii,t)*vf(ii,t) + LS'*r(:,t);
                if t > 1
                    N(:,:,t) = H(ii,:)'/FS(ii,t)*H(ii,:) +  LS'*N(:,:,t)*LS;
                end
            end
        end
        xs(:,t) = xf(:,t) + Pf(:,:,t)*r(:,t);
        if nargin <= 10
            us(:,t) = BT*r(:,t);
        end
    end
    
    % Diffuse part of the smoother. Equations 23 of Koopman and 
    % Durbin (1998)
    if start > 1 
        r1 = zeros(nEndo,start); 
        N1 = zeros(nEndo,nEndo,start);
        N2 = zeros(nEndo,nEndo,start);
        for t = start-1:-1:1
            r(:,t)    = AT*r(:,t+1);
            r1(:,t)   = AT*r1(:,t+1);
            N(:,:,t)  = AT*N(:,:,t+1)*A;
            N1(:,:,t) = AT*N1(:,:,t+1)*A;
            N2(:,:,t) = AT*N2(:,:,t+1)*A;
            for ii = flipud(find(m(:,t)))'
                if FINF(ii,t) > kalmanTol
                    LINF      = I - KINF(:,ii,t)*H(ii,:)/FINF(ii,t);
                    L0        = (KINF(:,ii,t)*(FS(ii,t)/FINF(ii,t)) - KS(:,ii,t))*H(ii,:)/FINF(ii,t);
                    LS        = I - KS(:,ii,t)*H(ii,:)/FS(ii,t);
                    r1(:,t)   = H(ii,:)'*vf(ii,t)/FINF(ii,t) + L0'*r(:,t) + LINF'*r1(:,t);  
                    r(:,t)    = LINF'*r(:,t);
                    N(:,:,t)  = LINF'*N(:,:,t)*LINF;
                    N1(:,:,t) = H(ii,:)'*FINF(ii,t)^(-1)*H(ii,:) ...
                              + LS'*N(:,:,t)*LINF + LINF'*N1(:,:,t)*LINF;
                    N2(:,:,t) = H(ii,:)'*FINF(ii,t)^(-2)*H(ii,:)*FS(ii,t) ...
                              + LS'*N1(:,:,t)*LS + LINF'*N2(:,:,t)*LS ...
                              + LS'*N1(:,:,t)*LINF + LINF'*N2(:,:,t)*LINF;
                elseif FS(ii,t) > kalmanTol 
                    L        = I - KS(:,ii,t)*H(ii,:)/FS(ii,t);
                    r(:,t)   = H(ii,:)'/FS(ii,t)*vf(ii,t) + L'*r(:,t);
                    N(:,:,t) = H(ii,:)'/FS(ii,t)*H(ii,:) +  L'*N(:,:,t)*L;
                end
            end
            xs(:,t) = xf(:,t) + Pf(:,:,t)*r(:,t) + Pinf(:,:,t)*r1(:,t);
            if nargin <= 10
                us(:,t) = BT*r(:,t);
            end
        end
    end
    
    % Get the smoothed shocks when exogenous variables are included in the
    % model
    if nargin > 10
        us(:,1) = B\(xs(:,1) - G*z(:,1));
        for t = 2:T
            us(:,t) = B\(xs(:,t) - A*xs(:,t-1) - G*z(:,t));
        end
    end
    
    % Get P t|T = Cov(x(t)|T)
    Ps = nan(nEndo,nEndo,T);  
    for t = 1:start-1
        Pc        = [Pf(:,:,t),Pinf(:,:,t)];
        Nc        = [N(:,:,t),N1(:,:,t);N1(:,:,t),N2(:,:,t)];
        Ps(:,:,t) = Pf(:,:,t) - Pc*Nc*Pc';
    end
    for t = start:T
        Ps(:,:,t) = Pf(:,:,t) - Pf(:,:,t)*N(:,:,t)*Pf(:,:,t);
    end
    
    % Get P_1 t|T = Cov(x(t),x(t-1)|T)
    Ps_1        = nan(nEndo,nEndo,T);  
    Ps_1(:,:,T) = (I - KS(:,m(:,end),end)*H(m(:,end),:))*A*Pu(:,:,T); % P_1 T|T = (I - K*Hmt)*A*(P T-1|T-1)
    
    % See equation 13.6.11 of Hamilton (1994)
    J2 = Pu(:,:, T)*AT*pinv(Pf(:,:, T)); % J T-1 = P T-1|T-1*A'*P T|T-1
    for t = T:-1:2
        J1            = J2;
        J2            = Pu(:,:,t-1)*AT*pinv(Pf(:,:,t-1));
        Ps_1(:,:,t-1) = Pu(:,:,t)*J2' + J1*(Ps_1(:,:,t) - A*Pu(:,:,t))*J2'; % P_1 t-1|T
    end
    
    % Calculate full likelihood
    %--------------------------------------------------------------
    lik = 0.5*(lik + O*log(2*pi));
    lik = sum(lik(kf_presample+1:end));
         
end
