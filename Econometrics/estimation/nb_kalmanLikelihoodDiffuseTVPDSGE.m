function lik = nb_kalmanLikelihoodDiffuseTVPDSGE(par,model,y,varargin)
% Syntax:
%
% lik = nb_kalmanLikelihoodDiffuseTVPDSGE(par,model,y,varargin)
%
% Description:
%
% Diffuse Kalman filter with observed time-varying parameters that does 
% not affect the steady state.
%
% The model function must return the given matrices in the system
% below:
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
% - par   : A parameter vector which is given as the first input to
%           the function handle given by the model input.
%
% - model : A function handle returning the following matrices (in
%           this order):
%
%           > H       : Observation matrix. As a nObs x nEndo double.
%
%           > A       : State transition matrix. As a nEndo x nEndo x T 
%                       double.
%
%           > C       : The impact of shock matrix. As a nEndo x nExo x T 
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
%           > err     : A empty string if success, otherwise the error
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
% nb_kalmanLikelihoodTVPDSGE, nb_kalmanSmootherDiffuseTVPDSGE, 
% nb_setUpForDiffuseFilter, nb_kalmanLikelihoodUnivariateTVPDSGE
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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

    % Options and pre-allocation
    [N,T]     = size(y);
    I         = eye(size(H,1));
    singular  = false;
    HT        = H';
    lik       = zeros(T,1);
    kalmanTol = options.kf_kalmanTol;
    m         = ~isnan(y);
    
    % Lead A one period, so indexing gets correct.
    A(:,:,1:T-1) = A(:,:,2:T);
    C(:,:,1:T-1) = C(:,:,2:T);
    
    % Loop through the diffuse kalman filter iterations
    %--------------------------------------------------------------
    for tt = 1:T
        
        At  = A(:,:,tt);
        BBt = C(:,:,tt)*C(:,:,tt)';
        mt  = m(:,tt);
        if all(~mt)
            x    = At*x;
            P    = At*P*At' + BBt;
            Pinf = At*Pinf*At';
        else
        
            % Prediction for state vector and covariance:
            xt = At*x;
            
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
                        P    = At*P*At' + BBt;
                        Pinf = At*Pinf*At';
                    end
                    
                else

                    % Kalman gain
                    invFINF  = I(mt,mt)/FINF;
                    KINF     = (At*PINFHT)*invFINF;
                    K        = At*PHT*invFINF - KINF*F*invFINF;

                    % Correction based on observation:
                    x     = xt + KINF*nut;
                    LINFT = (At' - HTmt*KINF');
                    Pinf  = At*Pinf*LINFT;
                    P     = At*P*LINFT + BBt - At*PINFHT*K';

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
    for t = 1:T
        
        At  = A(:,:,t);
        BBt = C(:,:,t)*C(:,:,t)';
        mt  = m(:,t);
        if all(~mt)
            x = At*x;
            P = At*P*At' + BBt;
        else
        
            % Prediction for state vector:
            xt = At*x;

            % Prediction for observation vector and covariance:
            Hmt    = H(mt,:);
            nut    = y(mt,t) - Hmt*x;
            PHT    = P*HT(:,mt);
            F      = Hmt*PHT;
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
                    P = At*P*At' + BBt;
                end
            else

                % Kalman gain
                invF = I(mt,mt)/F;
                K    = At*PHT*invF;

                % Correction based on observation:
                x = xt + K*nut;
                P = (At - K*Hmt)*P*At' + BBt;

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
