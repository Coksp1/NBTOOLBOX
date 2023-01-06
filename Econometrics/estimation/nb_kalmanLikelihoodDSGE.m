function lik = nb_kalmanLikelihoodDSGE(par,model,y,varargin)
% Syntax:
%
% lik = nb_kalmanLikelihoodDSGE(par,model,y,varargin)
%
% Description:
%
% The model function must return the given matrices in the system
% below:
%
% Observation equation:
% y(t) = H*x(t)
% 
% State equation:
% x(t) = A*x(t-1) + C*u(t)
%
% Where u ~ N(0,I) meaning u is gaussian noise with covariance I
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
%           > H       : Observation matrix. As a nObs x nEndo double.
%
%           > A       : State transition matrix. As a nEndo x nEndo double.
%
%           > C       : The impact of shock matrix. As a nEndo x nExo 
%                       double.
%
%           > x       : Initial state vector. As a nEndo x 1 double.
%
%           > P       : Initial covariance of state variables, as a nEndo x 
%                       nEndo double.
%
%           > options : A struct with the fields:
%
%                       * kf_riccatiTol : Converge criteria on the Kalman
%                                         gain.
%
%                       * kf_presample  : Discarded observation of the
%                                         likelihood at the begining.
%
%            > err     : A empty string if success, otherwise the error
%                        message as a char (lik = 1e10 in this case).
%
% - y : Observation vector. A nObs x T double.
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
% nb_kalmanLikelihoodMissingDSGE, nb_kalmanSmootherDSGE
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the (initial) state space matrices (could depend on the
    % hyperparamters of the model)
    %--------------------------------------------------------------
    [H,A,C,x,P,options,err] = feval(model,par,varargin{:});
    if ~isempty(err)
        % Some error occured when trying to solve the model with the
        % current parameter values, and we return a high minus the 
        % likelihood
        lik = 1e10;
        return
    end  
    CCT  = C*C';
    
    % Remove steady-state from the observables
    y  = bsxfun(@minus,y,options.ss);
    
    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
    [N,T]      = size(y);
    nObs       = size(H,1);
    I          = eye(nObs);
    singular   = false;
    AT         = A';
    HT         = H';
    lik        = zeros(T,1);
    riccatiTol = options.kf_riccatiTol;
    kalmanTol  = options.kf_kalmanTol;
    cont       = true;
    t          = 1;
    oldK       = zeros(size(A,1),nObs);
    while cont && t <= T
        
        % Prediction for state vector:
        xt = A*x;
        
        % Prediction for observation vector and covariance:
        nut    = y(:,t) - H*x;
        PHT    = P*HT;
        F      = H*PHT;
        rcondF = rcond(F);
        if isnan(rcondF)
           lik = 1e10;
           return
        end
        
        if rcondF < kalmanTol
            singular = true;
            if ~all(abs(F(:)) < kalmanTol)
                lik = 1e10;
                return
            else
                x = xt;
                P = A*P*AT + CCT;
            end
        else
            
            % Kalman gain
            invF = I/F;
            K    = A*PHT*invF;

            % Correction based on observation:
            x = xt + K*nut;
            P = (A - K*H)*P*AT + CCT;
            
            % Add to likelihood
            lik(t)   = log(det(F)) + nut'*invF*nut;
            cont     = max(abs(K(:)-oldK(:))) > riccatiTol;
            oldK     = K;
            singular = false;
            
        end
        
        t = t + 1;
              
    end
    
    if singular
        lik = 1e10;
        return
    end
    
    if t < T
        % The kalman gain has converged
        t0 = t + 1;
        for tt = t0:T
            nut    = y(:,t) - H*x;
            x      = A*(x + K*nut);
            lik(t) = nut'*invF*nut;
        end
        lik(t0:T) = lik(t0:T) + log(det(F));
    end 
    
    % Calculate full likelihood
    %--------------------------------------------------------------
    start = options.kf_presample;
    lik   = 0.5*(lik + N*log(2*pi));
    lik   = sum(lik(start+1:end));
    
end
