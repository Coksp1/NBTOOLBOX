function [xf,xs,us,xu,uu] = nb_kalmanSmootherDiffuseDSGE(H,A,C,obs,x0,P0S,P0INF,y,kalmanTol)
% Syntax:
%
% [xf,xs,us,xu,uu] = nb_kalmanSmootherDiffuseDSGE(H,A,C,obs,x0,P0S,P0INF,...
%                               y,kalmanTol)
%
% Description:
%
% Diffuse Kalman smoother to handle non-stationary models. With 
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
% See for example: Koopman and Durbin (1998), "Fast filtering ans smoothing
% for multivariate state space models".
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
% nb_kalmanSmootherDSGE, nb_kalmanLikelihoodDiffuseDSGE,
% nb_setUpForDiffuseFilter, nb_kalmanSmootherUnivariateDSGE
%
% Written by Kenneth Sæterhagen Paulsen

    % Initialize state estimate from first observation if needed
    %--------------------------------------------------------------
    nExo        = size(C,2);
    CC          = C*C';
    [N,S]       = size(y);
    nEndo       = size(A,1);
    PS          = nan(nEndo,nEndo,S+1);   % PS t+1|t
    PINF        = zeros(nEndo,nEndo,S+1); % PINF t+1|t
    xf          = zeros(nEndo,S+1);       % x t+1|t
    xu          = zeros(nEndo,S);         % x t|t
    invF        = cell(1,S);
    KS          = invF;
    KINF        = KS;
    PS(:,:,1)   = P0S; 
    PINF(:,:,1) = P0INF;
    xf(:,1)     = x0;

    % Loop through the diffuse kalman filter iterations
    %--------------------------------------------------------------
    singular = false;
    vf       = nan(N,S);
    I        = eye(size(H,1));
    HT       = H';
    AT       = A';
    m        = ~isnan(y);
    for tt = 1:S
        
        mt = m(:,tt);
        if all(~mt)
            xu(:,tt)       = xf(:,tt);
            xf(:,tt+1)     = A*xf(:,tt);
            PS(:,:,tt+1)   = A*PS(:,:,tt)*AT + CC;
            PINF(:,:,tt+1) = A*PINF(:,:,tt)*AT;
            invF{tt}       = 0;
            KS{tt}         = 0;
            KINF{tt}       = 0;
        else
        
            % Prediction for state vector:
            xt = A*xf(:,tt);
            
            % Prediction for observation vector and covariance:
            Hmt    = H(mt,:);
            nut    = y(mt,tt) - Hmt*xf(:,tt);
            HTmt   = HT(:,mt);
            PINFZT = PINF(:,:,tt)*HTmt;
            FINF   = Hmt*PINFZT;
            PSHT   = PS(:,:,tt)*HTmt;
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
                LINFtt   = PINFZT*invFINF;
                KINFtt   = A*LINFtt;
                KStt     = A*PSHT*invFINF - KINFtt*FS*invFINF;
                KS{tt}   = KStt;
                KINF{tt} = KINFtt;
                invF{tt} = invFINF;

                % Correction based on observation:
                xu(:,tt)       = xf(:,tt) + LINFtt*nut;
                xf(:,tt+1)     = xt + KINFtt*nut;
                LINFT          = (AT - HTmt*KINFtt');
                PINF(:,:,tt+1) = A*PINF(:,:,tt)*LINFT;
                PS(:,:,tt+1)   = A*PS(:,:,tt)*LINFT + CC - A*PINFZT*KStt';

                % Store filteres results
                vf(mt,tt) = nut;
                singular  = false;

            end

        end
        
    end
    
    if singular
        error('The variance of the forecast error remains singular until the end of the diffuse step.')
    end
    
    % Free memory
    start = tt;
    PINF  = PINF(:,:,1:start-1);
    KINF  = KINF(1:start-1);
    
    % From here we do the normal iterations
    for tt = start:S
        
        mt = m(:,tt);
        if all(~mt)
            xu(:,tt)     = xf(:,tt);
            xf(:,tt+1)   = A*xf(:,tt);
            PS(:,:,tt+1) = A*PS(:,:,tt)*AT + CC;
            invF{tt}     = 0;
            KS{tt}       = 0;
        else
        
            % Prediction for state vector and covariance:
            xt = A*xf(:,tt);

            % Prediction for observation vector and covariance:
            Hmt    = H(mt,:);
            nut    = y(mt,tt) - Hmt*xf(:,tt);
            HTmt   = HT(:,mt);
            PSHT   = PS(:,:,tt)*HTmt;
            FS     = Hmt*PSHT;
            if rcond(FS) < kalmanTol
                singular = true;
                if all(abs(FS(:))) < kalmanTol
                    break;
                else
                    xu(:,tt)     = xf(:,tt);
                    xf(:,tt+1)   = A*xf(:,tt);
                    PS(:,:,tt+1) = A*PS(:,:,tt)*AT + CC;
                    invF{tt}     = 0;
                    KS{tt}       = 0;
                end
            else

                % Kalman gain
                invF{tt}  = I(mt,mt)/FS;
                Ltt       = PSHT*invF{tt};
                KStt      = A*Ltt;
                KS{tt}    = KStt;

                % Correction based on observation:
                xu(:,tt)     = xf(:,tt) + Ltt*nut;
                xf(:,tt+1)   = xt + KStt*nut;
                PS(:,:,tt+1) = (A - KStt*Hmt)*PS(:,:,tt)*AT + CC;

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
    us = nan(nExo,S);
    xs = nan(nEndo,S);          
    r  = zeros(nEndo,S + 1);
    t  = S + 1;
    CT = C';
    while t > start % Normal steps of the smoother
        t      = t - 1;
        mt     = m(:,t);
        r(:,t) = AT*r(:,t+1); 
        if any(mt)  
            obst      = obs(mt); 
            r(obst,t) = r(obst,t) + invF{t}*vf(mt,t) - KS{t}'*r(:,t+1);
        end
        xs(:,t)   = xf(:,t) + PS(:,:,t)*r(:,t);
        us(:,t)   = CT*r(:,t);
    end
    
    if start > 1 % Diffuse part of the smoother
        r1 = zeros(nEndo,start); 
        for t = start-1:-1:1
            mt      = m(:,t);
            r(:,t)  = AT*r(:,t+1);
            r1(:,t) = AT*r1(:,t+1);
            if any(mt)
                obst       = obs(mt); 
                r1(obst,t) = r1(obst,t) + invF{t}*vf(mt,t) - KS{t}'*r(:,t+1) - KINF{t}'*r1(:,t+1);
                r(obst,t)  = r(obst,t) - KINF{t}'*r(:,t+1);
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
