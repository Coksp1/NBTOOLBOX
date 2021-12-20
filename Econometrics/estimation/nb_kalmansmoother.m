function [xf,xs,us,vs,xu] = nb_kalmansmoother(model,y,z,varargin)
% Syntax:
%
% [xf,xs,us,vs,xu] = nb_kalmansmoother(model,y,z,varargin)
%
% Description:
%
% Kalman smoother. No missing observations!
%
% The model function must return the given matrices in the system
% below (I.e. d,H,R,T,c,A,B,Q,G):
%
% Observation equation:
% y(t) = d + H*x(t) + T*z(t) + v(t)
% 
% State equation:
% x(t) = c + A*x(t-1) + G*z(t) + B*u(t)
%
% Where u ~ N(0,Q) meaning u is gaussian noise with covariance Q
%       v ~ N(0,R) meaning v is gaussian noise with covariance R
%
% See for example: Koopman and Durbin (1998), "Fast filtering ans smoothing
% for multivariate state space models".
%
% Input:
%
% - model : A function handle returning the following matrices (in
%           this order):
%
%           > x      : Initial state vector.
%           > P      : Initial state variance.
%           > d      : Constant in the observation equation.
%           > H      : Observation matrix.
%           > R      : Measurement noise covariance.
%           > T      : Matrix on exogneous variables in the observation 
%                      equation. Set it to 0 if not needed!
%           > c      : Constant in the state equation.
%           > A      : State transition matrix.
%           > Q      : Process noise covariance.
%           > B      : Input matrix, optional.
%           > G      : Matrix on exogneous variables in the state 
%                      equation. Set it to 0 if not needed!
%           > u      : Input control vector, optional.           
%           > obs    : Index of observables in the state vector.
%           > failed : Give true if model cannot be solved. lik will
%                      be returned a value of 1e10 in this case.
%
% - y  : Observation vector. A nvar x nobs double.
%
% - z  : Observation vector of exogenous. A nxvar x nobs double.
%
% Optional input:
%
% - varargin : Optional inputs given to the function handle given
%              by the model input.
%
% Output:
%
% - xf : The filtered estimates of the x in the equation above. (x t+1|t)
%
% - xs : The smoothed estimates of the x in the equation above. (x t|T)
%
% - us : The smoothed estimates of the u in the equation above. (u t|T)
%
% - vs : The smoothed estimates of the v in the equation above. (v t|T)
%
% - xu : The updated estimates of the x in the equation above. (x t|t)
%
% See also:
% nb_kalmansmoother_missing, nb_kalmanlikelihood
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(z)
        z = zeros(0,size(y,2));
    end
    kalmanTol = eps^(0.5);

    % Get the (initial) state space matrices (could depend on the
    % hyperparamters of the model)
    %--------------------------------------------------------------
    [x0,P0,d,H,R,T,c,A,B,Q,G,~,failed] = feval(model,varargin{:});
    if failed
        error([mfilename ':: Model could not be solved.'])
    end
    if isempty(G)
        G = zeros(size(y,1),size(z,1));
    end
    if isempty(T)
        T = zeros(size(A,1),size(z,1));
    end
    
    % Initialize state estimate from first observation if needed
    %--------------------------------------------------------------
    [N,n]    = size(y);
    nEndo    = size(A,1);
    P        = nan(nEndo,nEndo,n+1);   % P t+1|t
    xf       = nan(nEndo,n+1);         % x t+1|t
    xu       = nan(nEndo,n);           % x t|t
    invF     = nan(N,N,n);
    AK       = zeros(nEndo,N,n);
    BQB      = B*Q*B';
    xf(:,1)  = x0;
    P(:,:,1) = P0;
    
    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
    singular = true;
    vf       = nan(N,n);
    I        = eye(size(H,1));
    HT       = H';
    AT       = A';
    for tt = 1:n
        
        % Prediction for state vector and covariance:
        xt = A*xf(:,tt) + G*z(:,tt) + c;
        Pt = P(:,:,tt);

        % Prediction for observation vector and covariance:
        nut    = y(:,tt) - T*z(:,tt) - H*xf(:,tt) - d;
        PHT    = Pt*HT;
        F      = H*PHT + R;
        rcondF = rcond(F);
        if isnan(rcondF)
            error([mfilename ':: Model is explosive. Forecast variance include nan.'])
        elseif rcondF < kalmanTol
            singular = true;
            if all(abs(F(:))) < kalmanTol
                break
            else
                xu(:,tt)     = xf(:,tt);
                xf(:,tt+1)   = A*xf(:,tt) + c;
                P(:,:,tt+1)  = A*Pt*AT + BQB;
                invF(:,:,tt) = 0;
                vf(:,tt)     = 0;
                AK(:,:,tt)   = 0;
            end
        else
        
            % Kalman gain
            invF(:,:,tt) = I/F;
            Kt           = PHT*invF(:,:,tt);
            AKt          = A*Kt;
            AK(:,:,tt)   = AKt;

            % Correction based on observation:
            xu(:,tt)    = xf(:,tt) + Kt*nut;         % x t|t
            xf(:,tt+1)  = xt + AKt*nut;              % x t+1|t
            P(:,:,tt+1) = (A - AKt*H)*Pt*AT + BQB;   % P t+1|t

            % Store filteres results
            vf(:,tt) = nut;
            singular = false;
            
        end
         
    end
    
    if singular
        error('The variance of the forecast error remains singular until the end of the sample')
    end
    
    % Then we do the smoothing
    %-------------------------------------------------------------
    us  = nan(size(B,2),n);
    xs  = nan(nEndo,n);          
    r   = zeros(nEndo,n + 1);
    t   = n + 1;
    QBt = Q*B';
    while t > 1
        t        = t - 1;
        r(:,t)   = AT*r(:,t+1) + HT*(invF(:,:,t)*vf(:,t) - AK(:,:,t)'*r(:,t+1));  
        xs(:,t)  = xf(:,t) + P(:,:,t)*r(:,t);
        us(:,t)  = QBt*r(:,t);
    end
    
    % Report the estimates
    %-------------------------------------------------------------
    vs = y - H*xs;
    vs = vs';
    xs = xs';
    us = us';
    xf = xf(:,2:end)';
    xu = xu';
    
end
