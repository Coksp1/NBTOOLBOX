function lik = nb_kalmanlikelihood_missing(par,model,y,z,start,varargin)
% Syntax:
%
% lik = nb_kalmanlikelihood_missing(par,model,y,z,varargin)
%
% Description:
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
% - par   : A parameter vector which is given as the first input to
%           the function handle given by the model input.
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
%           > failed : Give true if model cannot be solved. lik = 1e10 
%                      in this case.
%
% - y     : Observation vector. A nvar x nobs double.
%
% - z     : Observation vector of exogenous. A nxvar x nobs double.
%
% - start : Start observation of the likelihood calculation.
%
% Optional input:
%
% - varargin : Optional inputs given to the function handle given
%              by the model input.
%
% Output:
%
% - lik : Minus the log likelihood. As a 1 x 1 double.
%
% See also:
% nb_kalmanlikelihood, nb_kalmansmoother_missing
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(z)
        z = zeros(0,size(y,2));
    end
    
    % Get the (initial) state space matrices (could depend on the
    % hyperparamters of the model)
    %--------------------------------------------------------------
    [x,P,d,H,R,T,c,A,B,Q,G,~,failed] = feval(model,par,varargin{:});
    if failed
        lik = 1e10;
        return
    end
    
    % Allow for time-varying measurement equation, so in the constant
    % case we just expand it  
    [N,n] = size(y);
    if size(H,3) == 1
        % We allow for the measurement equation to be time-varying
        H = H(:,:,ones(1,n));
    end
    
    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
    singular  = false;
    lik       = zeros(n,1);
    I         = eye(size(H,1));
    AT        = A';
    HT        = permute(H,[2,1,3]);
    BQB       = B*Q*B';
    kalmanTol = eps^(0.5);
    m         = ~isnan(y);
    for tt = 1:n
        
        mt = m(:,tt);
        if all(~mt)
            x = A*x + G*z(:,tt) + c;
            P = A*P*AT + BQB;
        else
        
            % Prediction for state vector and covariance:
            xt = A*x + G*z(:,tt) + c;

            % Prediction for observation vector and covariance:
            Hmt    = H(mt,:,tt);
            nut    = y(mt,tt) - T(mt,:)*z(:,tt) - Hmt*x - d(mt);
            PHT    = P*HT(:,mt,tt);
            F      = Hmt*PHT + R(mt,mt);
            rcondF = rcond(F);
            if isnan(rcondF)
               lik = 1e10;
               return
            end
            if rcondF < kalmanTol
                singular = true;
                if all(abs(F(:))) < kalmanTol
                    break;
                else
                    x = xt;
                    P = A*P*AT + BQB;
                end
            else

                % Kalman gain
                invF = I(mt,mt)/F;
                K    = (A*PHT)*invF;

                % Correction based on observation:
                x = xt + K*nut;
                P = (A - K*Hmt)*P*AT + BQB;

                % Add to likelihood
                lik(tt)  = log(det(F)) + nut'*invF*nut;
                singular = false;

            end
            
        end
        
    end
    
    % Calculate full likelihood
    %--------------------------------------------------------------
    if singular
        lik = 1e10;
    else
        lik = 0.5*(sum(lik(start:end)) + N*(n-start+1)*log(2*pi));
    end

end
