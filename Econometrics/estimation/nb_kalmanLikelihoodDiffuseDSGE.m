function lik = nb_kalmanLikelihoodDiffuseDSGE(par,model,y,varargin)
% Syntax:
%
% lik = nb_kalmanLikelihoodDiffuseDSGE(par,model,y,varargin)
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
% x(t) = A*x(t-1) + B*u(t)
%
% Where u ~ N(0,I) meaning u is gaussian noise with covariance Q
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
%           > P       : Initial state variance. As a nStationaryVar x 
%                       nStationaryVar double.
%
%           > Pinf    : Initial state variance of the non-stationary   
%                       variables. As a nNonStationaryVar x 
%                       nNonStationaryVar double.
%
%           > options : A struct with the fields:
%
%                       * kf_riccatiTol : Converge criteria on the Kalman
%                                         gain.
%
%                       * kf_presample  : Discarded observation of the
%                                         likelihood at the begining.
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
% nb_kalmanLikelihoodDSGE, nb_kalmanSmootherDiffuseDSGE,
% nb_setUpForDiffuseFilter, nb_kalmanLikelihoodUnivariateDSGE
%
% Written by Kenneth Sæterhagen Paulsen
    
    % Get the (initial) state space matrices (could depend on the
    % hyperparamters of the model)
    %--------------------------------------------------------------
    [H,A,C,x,P,Pinf,options,err] = feval(model,par,varargin{:});
    if ~isempty(err)
        % Some error occured when trying to solve the model with the
        % current parameter values, and we return a high minus the 
        % likelihood
        lik = 1e10;
        return
    end  
    CCT  = C*C';
    
    % Loop through the diffuse kalman filter iterations
    %--------------------------------------------------------------
    [N,T]     = size(y);
    lik       = zeros(T,1);
    singular  = false;
    I         = eye(size(H,1));
    HT        = H';
    AT        = A';
    m         = ~isnan(y);
    kalmanTol = options.kf_kalmanTol;
    for tt = 1:T
        
        mt = m(:,tt);
        if all(~mt)
            x    = A*x;
            P    = A*P*AT + CCT;
            Pinf = A*Pinf*AT;
        else
        
            % Prediction for state vector and covariance:
            xt = A*x;
            
            % Prediction for observation vector and covariance:
            Hmt    = H(mt,:);
            nut    = y(mt,tt) - Hmt*x;
            HTmt   = HT(:,mt);
            PINFHT = Pinf*HTmt;
            FINF   = Hmt*PINFHT;
            PHT    = P*HTmt;
            F      = Hmt*PHT;
            if rank(FINF,kalmanTol) < sum(mt)
                
                if ~all(abs(FINF(:)) < kalmanTol)
                    error([mfilename ':: You must use the univariate Kalman filter. If called from the ',...
                                     'nb_dsge.filter method, set ''kf_method'' to ''univariate''.'])
                end
                break;% End of diffuse steps
                
            else
                
                rcondFINF = rcond(FINF);
                if isnan(rcondFINF)
                   lik = 1e10;
                   return
                end
                
                rcondF = rcond(F);
                if isnan(rcondF)
                   lik = 1e10;
                   return
                end
                
                if rcondF < kalmanTol
                    
                    singular = true;
                    if all(abs(F(:))) < kalmanTol
                        lik = 1e10;
                        return
                    else
                        x    = xt;
                        P    = A*P*AT + CCT;
                        Pinf = A*Pinf*AT;
                    end
                    
                else

                    % Kalman gain
                    invFINF  = I(mt,mt)/FINF;
                    KINF     = (A*PINFHT)*invFINF;
                    K        = A*PHT*invFINF - KINF*F*invFINF;

                    % Correction based on observation:
                    x     = xt + KINF*nut;
                    LINFT = (AT - HTmt*KINF');
                    Pinf  = A*Pinf*LINFT;
                    P     = A*P*LINFT + CCT - A*PINFHT*K';

                    % Add to likelihood
                    lik(tt)  = log(det(FINF));
                    singular = false;
                    
                end

            end

        end
        
    end
    
    if singular
        lik = 1e10;
        return
    end
    
    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
    for t = tt:T
        
        mt = m(:,t);
        if all(~mt)
            x = A*x;
            P = A*P*AT + CCT;
        else
        
            % Prediction for state vector:
            xt = A*x;

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
                    P = A*P*AT + CCT;
                end
            else

                % Kalman gain
                invF = I(mt,mt)/F;
                K    = A*PHT*invF;

                % Correction based on observation:
                x = xt + K*nut;
                P = (A - K*Hmt)*P*AT + CCT;

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
