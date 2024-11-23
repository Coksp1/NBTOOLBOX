function [xf,xs,us] = nb_kalmanSmootherDiffuseTVPDSGE(H,A,C,obs,x0,P0,P0INF,y,kalmanTol)
% Syntax:
%
% [xf,xs,us] = nb_kalmanSmootherDiffuseTVPDSGE(H,A,C,obs,x0,P0,P0INF,y,...
%                               kalmanTol)
%
% Description:
%
% Diffuse Kalman smoother with observed time-varying paramerters that does not 
% affect the steady-state. With potentially missing observations!
%
% Observation equation:
% y(t) = H*x(t)
% 
% State equation:
% x(t) = A(t)*x(t-1) + B(t)*u(t)
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Initialize state estimate from first observation if needed
    %--------------------------------------------------------------
    nExo        = size(C,2);
    [N,T]       = size(y);
    nEndo       = size(A,1);
    P           = nan(nEndo,nEndo,T+1);   % P t+1|t
    PINF        = zeros(nEndo,nEndo,T+1); % PINF t+1|t
    xf          = zeros(nEndo,T+1);       % x t+1|t
    invF        = cell(1,T);
    K           = cell(1,T);
    KINF        = K;
    P(:,:,1)    = P0;  
    PINF(:,:,1) = P0INF;
    xf(:,1)     = x0;

    % Lead G one period, so indexing gets correct.
    A(:,:,1:T-1) = A(:,:,2:T);
    C(:,:,1:T-1) = C(:,:,2:T);
    
    % Loop through the diffuse kalman filter iterations
    %--------------------------------------------------------------
    singular = false;
    vf       = nan(N,T);
    I        = eye(size(H,1));
    HT       = H';
    m        = ~isnan(y);
    for tt = 1:T
        
        At  = A(:,:,tt);
        CCt = C(:,:,tt)*C(:,:,tt)';
        mt  = m(:,tt);
        if all(~mt)
            xf(:,tt+1)     = At*xf(:,tt);
            P(:,:,tt+1)    = At*P(:,:,tt)*At' + CCt;
            PINF(:,:,tt+1) = At*PINF(:,:,tt)*At';
            invF{tt}       = 0;
            K{tt}          = 0;
            KINF{tt}       = 0;
        else
        
            % Prediction for state vector:
            xt = At*xf(:,tt);
            
            % Prediction for observation vector and covariance:
            Hmt    = H(mt,:);
            nut    = y(mt,tt) - Hmt*xf(:,tt);
            HTmt   = HT(:,mt);
            PINFZT = PINF(:,:,tt)*HTmt;
            FINF   = Hmt*PINFZT;
            PSZT   = P(:,:,tt)*HTmt;
            FS     = Hmt*PSZT;
            if rank(FINF,kalmanTol) < sum(mt)
                
                if ~all(abs(FINF(:)) < kalmanTol)
                    error([mfilename ':: You must use the univariate Kalman filter. If called from the ',...
                                     'nb_dsge.filter method, set ''kf_method'' to ''univariate''.'])
                end
                break; % Continue with normal iterations
                
            else

                % Kalman gain
                invFINF  = I(mt,mt)/FINF;
                KINFtt   = (At*PINFZT)*invFINF;
                K{tt}    = At*PSZT*invFINF - KINFtt*FS*invFINF;
                KINF{tt} = KINFtt;
                invF{tt} = invFINF;

                % Correction based on observation:
                xf(:,tt+1)     = xt + KINFtt*nut;
                LINFT          = (At' - HTmt*KINFtt');
                PINF(:,:,tt+1) = At*PINF(:,:,tt)*LINFT;
                P(:,:,tt+1)    = At*P(:,:,tt)*LINFT + CCt - At*PINFZT*K{tt}';

                % Store filteres results
                vf(mt,tt) = nut;
                singular  = false;

            end

        end
        
    end
    
    if singular
        error('The variance of the forecast error remains singular until the end of the diffuse step.')
    end
    
    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
    start = tt;
    for tt = start:T
        
        At  = A(:,:,tt);
        CCt = C(:,:,tt)*C(:,:,tt)';
        mt  = m(:,tt);
        if all(~mt)
            xf(:,tt+1)  = At*xf(:,tt);
            P(:,:,tt+1) = At*P(:,:,tt)*At' + CCt;
            invF{tt}    = 0;
            K{tt}       = 0;
        else
        
            % Prediction for state vector:
            xt = At*xf(:,tt);

            % Prediction for observation vector and covariance:
            Hmt = H(mt,:);
            nut = y(mt,tt) - Hmt*xf(:,tt);
            PHT = P(:,:,tt)*HT(:,mt);
            F   = Hmt*PHT;
            if rcond(F) < kalmanTol
                singular = true;
                if all(abs(F(:))) < kalmanTol
                    break;
                else
                    xf(:,tt+1)  = xt;
                    P(:,:,tt+1) = At*P(:,:,tt)*At' + CCt;
                    invF{tt}    = 0;
                    K{tt}       = 0;
                end
                warning('kalman:singular',['One step ahead variance matrix is singular at iteration ' int2str(tt) '. ',...
                                           'The filtering results is most likely wrong. You may adjust the kalman tolerance.'])
            else

                % Kalman gain
                invF{tt} = I(mt,mt)/F;
                Ktt      = (At*PHT)*invF{tt};
                K{tt}    = Ktt;
                
                % Correction based on observation:
                xf(:,tt+1)  = xt + Ktt*nut;
                P(:,:,tt+1) = (At - Ktt*Hmt)*P(:,:,tt)*At' + CCt;

                % Store filteres results
                vf(mt,tt) = nut;
                singular  = false;

            end
            
        end
         
    end
    
    if singular
        error('The variance of the forecast error remains singular until the end of the sample')
    end
    
    % Then we do the smoothing
    %-------------------------------------------------------------
    us = nan(nExo,T);
    xs = nan(nEndo,T);          
    r  = zeros(nEndo,T + 1);
    t  = T + 1;
    while t > 1
        t      = t - 1;
        mt     = m(:,t);
        r(:,t) = A(:,:,t)'*r(:,t+1); 
        if any(mt)
            obst      = obs(mt);  
            r(obst,t) = r(obst,t) + invF{t}*vf(mt,t) - K{t}'*r(:,t+1);
        end
        xs(:,t) = xf(:,t) + P(:,:,t)*r(:,t);
        us(:,t) = C(:,:,t)'*r(:,t);
    end
    
    if start > 1 % Diffuse part of the smoother
        r0          = zeros(nEndo,start); 
        r1          = r0;
        r0(:,start) = r(:,start);
        for t = start-1:-1:1
            mt      = m(:,t);
            r0(:,t) = A(:,:,t)'*r0(:,t+1);
            r1(:,t) = A(:,:,t)'*r1(:,t+1);
            if any(mt)
                obst       = obs(mt); 
                r1(obst,t) = r1(obst,t) + invF{t}*vf(mt,t) - K{t}'*r0(:,t+1) - KINF{t}'*r1(:,t+1);
                r0(obst,t) = r0(obst,t) - KINF{t}'*r0(:,t+1);
            end
            xs(:,t) = xf(:,t) + P(:,:,t)*r0(:,t) + PINF(:,:,t)*r1(:,t);
            us(:,t) = C(:,:,t)'*r0(:,t);
        end
    end
    
    % Report the estimates
    %-------------------------------------------------------------
    xs = xs';
    us = us';
    xf = xf(:,2:end)';
    
end
