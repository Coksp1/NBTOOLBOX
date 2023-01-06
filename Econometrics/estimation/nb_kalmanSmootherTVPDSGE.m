function [xf,xs,us] = nb_kalmanSmootherTVPDSGE(H,A,C,obs,x0,P0,y,kalmanTol)
% Syntax:
%
% [xf,xs,us] = nb_kalmanSmootherTVPDSGE(H,A,B,obs,x0,P0,y,...
%                               kalmanTol)
%
% Description:
%
% Kalman smoother with observed time-varying paramerters that does not 
% affect the steady-state. With potentially missing observations!
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
% - A         : State transition matrix. As a size nEndo x nEndo x 
%               nPeriods.
%
% - C         : The impact of shock matrix. As a size nEndo x nExo x 
%               nPeriods.
%
% - obs       : Index of observables in the vector of state variables. A 
%               logical vector with size size(A,1) x 1.
%
% - x0        : Initial state vector. As a nEndo x 1 double.
%
% - P0        : Initial state variance. As a nEndo x nEndo double.
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
% nb_kalmanSmootherDSGE, nb_kalmanLikelihoodTVPDSGE
%
% Written by Kenneth Sæterhagen Paulsen.

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Initialize state estimate from first observation if needed
    %--------------------------------------------------------------
    nExo     = size(C,2);
    [N,T]    = size(y);
    nEndo    = size(A,1);
    P        = nan(nEndo,nEndo,T+1);   % P t+1|t
    xf       = zeros(nEndo,T+1);       % x t+1|t
    invF     = cell(1,T);
    K        = cell(1,T);
    P(:,:,1) = P0;  
    xf(:,1)  = x0;

    % Lead A one period, so indexing gets correct.
    A(:,:,1:T-1) = A(:,:,2:T);
    C(:,:,1:T-1) = C(:,:,2:T);
    
    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
    singular = false;
    vf       = nan(N,T);
    I        = eye(size(H,1));
    HT       = H';
    m        = ~isnan(y);
    for tt = 1:T
        
        At  = A(:,:,tt);
        BBt = C(:,:,tt)*C(:,:,tt)';
        mt  = m(:,tt);
        if all(~mt)
            xf(:,tt+1)  = At*xf(:,tt);
            P(:,:,tt+1) = At*P(:,:,tt)*At' + BBt;
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
                    P(:,:,tt+1) = At*P(:,:,tt)*At' + BBt;
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
                P(:,:,tt+1) = (At - Ktt*Hmt)*P(:,:,tt)*At' + BBt;

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
    
    % Report the estimates
    %-------------------------------------------------------------
    xs = xs';
    us = us';
    xf = xf(:,2:end)';
    
end
