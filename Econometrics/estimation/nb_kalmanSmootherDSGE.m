function [xf,xs,us,xu,uu] = nb_kalmanSmootherDSGE(H,A,B,obs,x0,P0,y,kalmanTol)
% Syntax:
%
% [xf,xs,us,xu,uu] = nb_kalmanSmootherDSGE(H,A,B,obs,x0,P0,y,kalmanTol)
%
% Description:
%
% Kalman smoother. No missing observations!
%
% Observation equation:
% y(t) = H*x(t)
% 
% State equation:
% x(t) = A*x(t-1) + B*u(t)
%
% Where u ~ N(0,I) meaning u is gaussian noise with covariance I
%
% See for example: Koopman and Durbin (1998), "Fast filtering ans smoothing
% for multivariate state space models".
%
% Input:
%
% - H         : Observation matrix. As a nObs x nEndo double.
%
% - A         : State transition matrix. As a nEndo x nEndo double.
%
% - B         : The impact of shock matrix. As a nEndo x nExo double.
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
% - kalmanTol : Kalman tolerance. 
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
% nb_kalmanLikelihoodDSGE
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Initialize state estimate from first observation if needed
    %--------------------------------------------------------------
    nExo     = size(B,2);
    BB       = B*B';
    [N,T]    = size(y);
    nEndo    = size(A,1);
    P        = nan(nEndo,nEndo,T+1);   % P t+1|t
    xf       = zeros(nEndo,T+1);       % x t+1|t
    xu       = zeros(nEndo,T);         % x t|t
    invF     = nan(N,N,T);
    K        = zeros(nEndo,N,T);
    P(:,:,1) = P0;  
    xf(:,1)  = x0;

    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
    singular = false;
    vf       = nan(N,T);
    I        = eye(size(H,1));
    HT       = H';
    AT       = A';
    for tt = 1:T
        
        % Prediction for state vector and covariance:
        xt = A*xf(:,tt);
        Pt = P(:,:,tt);

        % Prediction for observation vector and covariance:
        nut = y(:,tt) - H*xf(:,tt);
        PHT = Pt*HT;
        F   = H*PHT;
        if rcond(F) < kalmanTol
            singular = true;
            if all(abs(F(:))) < kalmanTol
                break;
            else
                xu(:,tt)     = xf(:,tt);
                xf(:,tt+1)   = xt;
                P(:,:,tt+1)  = A*P(:,:,tt)*AT + BB;
                invF(:,:,tt) = 0;
                vf(:,tt)     = 0;
                K(:,:,tt)    = 0;
            end
            warning('kalman:singular',['One step ahead variance matrix is singular at iteration ' int2str(tt) '. ',...
                                           'The filtering results is most likely wrong. You may adjust the kalman tolerance.'])
        else
        
            % Kalman gain
            invF(:,:,tt) = I/F;
            Ltt          = PHT*invF(:,:,tt);
            K(:,:,tt)    = A*Ltt;

            % Correction based on observation:
            xu(:,tt)    = xf(:,tt) + Ltt*nut;
            xf(:,tt+1)  = xt + K(:,:,tt)*nut;
            P(:,:,tt+1) = (A - K(:,:,tt)*H)*Pt*AT + BB;
            vf(:,tt)    = nut;
            singular    = false;
            
        end
         
    end
    
    if singular
        error('The variance of the forecast error remains singular until the end of the sample')
    end
    
    % Then we do the smoothing
    %-------------------------------------------------------------
    us  = nan(nExo,T);
    xs  = nan(nEndo,T);          
    r   = zeros(nEndo,T + 1);
    t   = T + 1;
    BT = B';
    while t > 1
        t        = t - 1;
        r(:,t)   = A'*r(:,t+1);    
        r(obs,t) = r(obs,t) + invF(:,:,t)*vf(:,t) - K(:,:,t)'*r(:,t+1);
        xs(:,t)  = xf(:,t) + P(:,:,t)*r(:,t);
        us(:,t)  = BT*r(:,t);
    end
    
    % Report the estimates
    %-------------------------------------------------------------
    xs = xs';
    us = us';
    xf = xf(:,2:end)';
    if nargout > 4
        
        % Get the updated shocks
        uu      = zeros(nExo,T);
        uu(:,1) = B\xu(:,1);
        for t = 2:T
            uu(:,t) = B\(xu(:,t) - A*xu(:,t-1));
        end
        uu = uu';
        
    end
    xu = xu';
    
end