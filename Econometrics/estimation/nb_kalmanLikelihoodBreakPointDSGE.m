function lik = nb_kalmanLikelihoodBreakPointDSGE(par,model,y,varargin)
% Syntax:
%
% lik = nb_kalmanLikelihoodBreakPointDSGE(par,model,y,varargin)
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
% x(t) = ss(t) + A(t)*(x(t-1) - ss(t)) + C(t)*u(t)
%
% Where u ~ N(0,I) meaning u is gaussian noise with covariance I
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
%           > A       : State transition matrix. A cell with size 1 x 
%                       nStates. Each element as a nEndo x nEndo double.
%
%           > C       : The impact of shock matrix. A cell with size 1 x 
%                       nStates. Each element as a nEndo x nExo double. 
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
%                       * states        : A nobs vector with the states
%                                         at the given period.
%
%                       * ss            : The steady-state of the model in 
%                                         each regime. As a cell array. 
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
% nb_kalmanLikelihoodDSGE, nb_kalmanSmootherBreakPointDSGE
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
    
    % Substract steady-state from observables
    states = options.states;
    states = [states;states(end)];
    ss     = options.ss;
    [N,T]  = size(y);
    
    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
    I          = eye(size(H,1));
    singular   = false;
    HT         = H';
    lik        = zeros(T,1);
    kalmanTol  = options.kf_kalmanTol;
    m          = ~isnan(y);
    for t = 1:T

        At  = A{states(t+1)};
        CCt = C{states(t+1)}*C{states(t+1)}';
        mt  = m(:,t);
        if all(~mt)
            x = ss{states(t+1)} + At*(x - ss{states(t+1)});
            P = At*P*At' + CCt;
        else
        
            % Prediction for state vector:
            xt = ss{states(t+1)} + At*(x - ss{states(t+1)});

            % Prediction for observation vector and covariance:
            Hmt    = H(mt,:);
            nut    = y(mt,t) - Hmt*x;
            PHT    = P*HT(:,mt);
            F      = H*PHT;
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
                    P = At*P*At' + CCt;
                end
            else

                % Kalman gain
                invF = I(mt,mt)/F;
                K    = At*PHT*invF;

                % Correction based on observation:
                x = xt + K*nut;
                P = (At - K*Hmt)*P*At' + CCt;

                % Add to likelihood
                lik(t)   = log(det(F)) + nut'*invF*nut;
                singular = false;

            end
            
        end
              
    end
    
    if singular
        lik = 1e10;
        return
    end
    
    % Calculate full likelihood
    %--------------------------------------------------------------
    start = options.kf_presample;
    lik   = 0.5*(lik + N*log(2*pi));
    lik   = sum(lik(start+1:end));
    
end
