function [xf,xs,us,xu,uu] = nb_kalmanSmootherDiffuseBreakPointDSGE(H,A,C,ss,obs,x0,P0,P0INF,y,kalmanTol,states)
% Syntax:
%
% [xf,xs,us,xu,uu] = nb_kalmanSmootherDiffuseBreakPointDSGE(H,A,C,ss,obs,...
%                               x0,P0,P0INF,y,kalmanTol,states)
%
% Description:
%
% Diffuse piecewise linear Kalman smoother. With potentially missing 
% observations!
%
% Observation equation:
% y(t) = H*x(t) + v(t)
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
% nb_kalmanLikelihoodDiffuseBreakPointDSGE, nb_kalmanSmootherBreakPointDSGE, 
% nb_setUpForDiffuseFilter
%
% Written by Kenneth Sæterhagen Paulsen.

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Initialize state estimate from first observation if needed
    %--------------------------------------------------------------
    nExo        = size(C{1},2);
    [N,T]       = size(y);
    nEndo       = size(A{1},1);
    P           = nan(nEndo,nEndo,T+1);   % P t+1|t
    PINF        = zeros(nEndo,nEndo,T+1); % PINF t+1|t
    xf          = zeros(nEndo,T+1);       % x t+1|t
    xu          = zeros(nEndo,T);         % x t|t
    invF        = cell(1,T);
    K           = cell(1,T);
    KINF        = invF;
    P(:,:,1)    = P0;
    PINF(:,:,1) = P0INF;
    xf(:,1)     = x0;
    states      = [states;states(end)];
    
    % Loop through the diffuse kalman filter iterations
    %--------------------------------------------------------------
    singular = false;
    vf       = nan(N,T);
    I        = eye(size(H,1));
    HT       = H';
    m        = ~isnan(y);
    for tt = 1:T
        
        At  = A{states(tt+1)};
        CCt = C{states(tt+1)}*C{states(tt+1)}';
        mt  = m(:,tt);
        if all(~mt)
            xu(:,tt)       = xf(:,tt);
            xf(:,tt+1)     = ss{states(tt+1)} + At*(xf(:,tt) - ss{states(tt+1)});
            P(:,:,tt+1)    = At*P(:,:,tt)*At' + CCt;
            PINF(:,:,tt+1) = At*PINF(:,:,tt)*At';
            invF{tt}       = 0;
            K{tt}          = 0;
            KINF{tt}       = 0;
        else
        
            % Prediction for state vector:
            xt = ss{states(tt+1)} + At*(xf(:,tt) - ss{states(tt+1)});
            
            % Prediction for observation vector and covariance:
            Hmt    = H(mt,:);
            nut    = y(mt,tt) - Hmt*xf(:,tt);
            HTmt   = HT(:,mt);
            PINFHT = PINF(:,:,tt)*HTmt;
            FINF   = Hmt*PINFHT;
            PSHT   = P(:,:,tt)*HTmt;
            FS     = Hmt*PSHT;
            if rank(FINF,kalmanTol) < sum(mt)
                
                if ~all(abs(FINF(:)) < kalmanTol)
                    error([mfilename ':: You must use the univariate Kalman filter. If called from the ',...
                                     'nb_dsge.filter method, set ''kf_method'' to ''univariate''.'])
                end
                break; % Continue with normal iterations
                
            else

                % Kalman gain
                invFINF  = I(mt,mt)/FINF;
                LINFtt   = PINFHT*invFINF;
                KINFtt   = At*LINFtt;
                KStt     = At*PSHT*invFINF - KINFtt*FS*invFINF;
                K{tt}    = KStt;
                KINF{tt} = KINFtt;
                invF{tt} = invFINF;

                % Correction based on observation:
                xu(:,tt)       = xf(:,tt) + LINFtt*nut;
                xf(:,tt+1)     = xt + KINFtt*nut;
                LINFT          = (At' - HTmt*KINFtt');
                PINF(:,:,tt+1) = At*PINF(:,:,tt)*LINFT;
                P(:,:,tt+1)    = At*P(:,:,tt)*LINFT + CCt - At*PINFHT*KStt';

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
        
        At  = A{states(tt+1)};
        CCt = C{states(tt+1)}*C{states(tt+1)}';
        mt  = m(:,tt);
        if all(~mt)
            xu(:,tt)    = xf(:,tt);
            xf(:,tt+1)  = ss{states(tt+1)} + At*(xf(:,tt) - ss{states(tt+1)});
            P(:,:,tt+1) = At*P(:,:,tt)*At' + CCt;
            invF{tt}    = 0;
            K{tt}       = 0;
        else
            
            % Prediction for state vector:
            xt = ss{states(tt+1)} + At*(xf(:,tt) - ss{states(tt+1)});

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
                    xu(:,tt)    = xf(:,tt);
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
                Ltt      = PHT*invF{tt};
                Ktt      = At*Ltt;
                K{tt}    = Ktt;

                % Correction based on observation:
                xu(:,tt)    = xf(:,tt) + Ltt*nut;
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
    xs = nan(nEndo,T);          
    r  = zeros(nEndo,T + 1);
    t  = T + 1;
    while t > 1
        t      = t - 1;
        mt     = m(:,t);
        r(:,t) = A{states(t+1)}'*r(:,t+1); 
        if any(mt) 
            r(obs(mt),t) = r(obs(mt),t) + invF{t}*vf(mt,t) - K{t}'*r(:,t+1);
        end
        xs(:,t) = xf(:,t) + P(:,:,t)*r(:,t);
    end
    
    if start > 1 % Diffuse part of the smoother
        r0          = zeros(nEndo,start); 
        r1          = r0;
        r0(:,start) = r(:,start);
        for t = start-1:-1:1
            mt      = m(:,t);
            r0(:,t) = A{states(t+1)}'*r0(:,t+1);
            r1(:,t) = A{states(t+1)}'*r1(:,t+1);
            if any(mt)
                obst       = obs(mt); 
                r1(obst,t) = r1(obst,t) + invF{t}*vf(mt,t) - K{t}'*r0(:,t+1) - KINF{t}'*r1(:,t+1);
                r0(obst,t) = r0(obst,t) - KINF{t}'*r0(:,t+1);
            end
            xs(:,t) = xf(:,t) + P(:,:,t)*r0(:,t) + PINF(:,:,t)*r1(:,t);
        end
    end
    
    % Get the smoothed shocks
    %-------------------------------------------------------------
    us      = zeros(nExo,T);
    us(:,1) = C{states(1)}\(xs(:,1) - ss{states(1)});
    for t = 2:T
        us(:,t) = C{states(t)}\(xs(:,t) - ss{states(t)} - A{states(t)}*(xs(:,t-1) - ss{states(t)}) );
    end
    
    % Report the estimates
    %-------------------------------------------------------------
    xs = xs';
    us = us';
    xf = xf(:,2:end)';
    if nargout > 4
        
        % Get the updated shocks
        uu      = zeros(nExo,T);
        uu(:,1) = C{states(1)}\(xu(:,1) - ss{states(1)});
        for t = 2:T
            uu(:,t) = C{states(t)}\(xu(:,t) - ss{states(t)} - A{states(t)}*(xu(:,t-1) - ss{states(t)}) );
        end
        uu = uu';
        
    end
    xu = xu';
    
end
