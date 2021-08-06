function [x,u,v] = nb_kalmanfilter(model,y,z,varargin)
% Syntax:
%
% [x,u,v] = nb_kalmanfilter(model,y,z,varargin)
%
% Description:
%
% The model function must return the given matrices in the system
% below (I.e. d,H,R,T,c,A,B,Q,G):
%
% Observation equation:
% y = d + Hx + Gz + v
% 
% State equation:
% x = c + Ax_1 + Tz + Bu
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
% - x : The filtered estimates of the x in the equation above. (x t|t)
%
% - u : The filtered estimates of the u in the equation above. (u t|t)
%
% - v : The filtered estimates of the v in the equation above. (v t|t)
%
% See also:
% nb_kalmansmoother, nb_kalmanlikelihood
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
    [x0,P,d,H,R,T,c,A,B,Q,G,~,failed] = feval(model,varargin{:});
    if failed
        error([mfilename ':: Model could not be solved.'])
    end
    if isempty(G)
        G = zeros(size(y,1),size(z,1));
    end
    if isempty(T)
        T = zeros(size(A,1),size(z,1));
    end
    
    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
    [N,n]    = size(y);
    m        = size(x0,1);
    x        = nan(m,n);
    u        = nan(size(B,2),n);
    v        = nan(N,n);
    BQB      = B*Q*B';
    HT       = H';
    AT       = A';
    singular = false;
    %Im    = eye(m);
    for tt = 1:n
        
        % Prediction for state vector and covariance:
        xt = A*x0 + T*z(:,tt) + c;

        % Prediction for observation vector and covariance:
        nut  = y(:,tt) - G*z(:,tt) -  H*x0 - d;
        PHT  = P*HT;
        F    = H*PHT + R;
        if rcond(F) < kalmanTol
            singular = true;
            if all(abs(F(:))) < kalmanTol  
                break
            else
                P       = A*P*AT + BQB;
                x(:,tt) = xt;
                u(:,tt) = 0;
                v(:,tt) = nut;
            end
        else
        
            % Kalman gain
            K = (A*PHT)/F;

            % Correction based on observation:
            xtt = xt + K*nut;
            P   = (A - K*H)*P*AT + BQB;

            % Store filtered results
            x(:,tt)  = xtt;
            u(:,tt)  = B\(xtt - xt);
            v(:,tt)  = nut;
            singular = false;

        end
            
        % Initialize for next step
        x0 = x(:,tt);
        
    end
    
    if singular
        error('The variance of the forecast error remains singular until the end of the sample')
    end
    
    x = x';
    u = u';
    v = v';
    
end
