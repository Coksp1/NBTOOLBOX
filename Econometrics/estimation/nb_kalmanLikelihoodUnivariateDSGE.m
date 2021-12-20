function lik = nb_kalmanLikelihoodUnivariateDSGE(par,model,y,varargin)
% Syntax:
%
% lik = nb_kalmanLikelihoodUnivariateDSGE(par,model,y,varargin)
%
% Description:
%
% Diffuse univariate linear Kalman filter. With potentially missing 
% observations!
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
% nb_kalmanLikelihoodDSGE, nb_kalmanSmootherUnivariateDSGE,
% nb_setUpForDiffuseFilter, nb_kalmanLikelihoodDiffuseDSGE
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
    CCT = C*C';
    
    % Loop through the diffuse kalman filter iterations
    %--------------------------------------------------------------
    [N,T]     = size(y);
    lik       = zeros(T,1);
    HT        = H';
    m         = ~isnan(y);
    kalmanTol = options.kf_kalmanTol;
    r         = rank(H*Pinf*H',kalmanTol);
    tt        = 1;
    while r && tt <= T    
        
        % Loop through each observables and update the state (x t|t) and
        % covariance matrix (PS t|t and PINF t|t)
        for ii = find(m(:,tt))'

            Hii  = H(ii,:);
            nut  = y(ii,tt) - Hii*x;
            Hiit = HT(:,ii);
            FINF = Hii*Pinf*Hiit;
            FS   = Hii*P*Hiit;
            KS   = P*Hiit;
            if FINF > kalmanTol && r
                KINF          = Pinf*Hiit;
                KINF_DIV_FINF = KINF/FINF;
                x             = x + KINF_DIV_FINF*nut;
                P             = P + KINF*KINF_DIV_FINF'*(FS/FINF) - KS*KINF_DIV_FINF' - KINF_DIV_FINF*KS'; 
                Pinf          = Pinf - KINF*KINF'/FINF;
                lik(tt)       = lik(tt) + log(FINF);
            elseif FS > kalmanTol
                x       = x + KS*nut/FS; 
                P       = P - KS*KS'/FS;
                lik(tt) = lik(tt) + log(FS) + (nut*nut/FS);
            end

        end
            
        % Forecast 
        rOld = rank(H*Pinf*H',kalmanTol);
        x    = A*x;            % x t+1 | t = A * x t|t
        P    = A*P*A' + CCT;   % P t+1|t = A * P t|t * A' + B*B';
        Pinf = A*Pinf*A';      % Pinf t+1|t = A * Pinf t|t * A';
        
        % Check rank
        r = rank(H*Pinf*H',kalmanTol);
        if rOld ~= r
%             disp('nb_kalmanLikelihoodUnivariateDSGE:: The forecasting step does influence the rank of the ',...
%                  'filtered one step ahead covariance matrix during the diffuse steps (PINF)!')
            lik = 1e10;
            return 
        end
        
        tt = tt + 1;
        
    end
    
    % From here we do the normal iterations
    start = tt;
    for tt = start:T
        
        % Loop through each observables and update the state (x t|t) and
        % covariance matrix (PS t|t)
        for ii = find(m(:,tt))'

            Hii  = H(ii,:);
            nut  = y(ii,tt) - Hii*x;
            Hiit = HT(:,ii);
            FS   = Hii*P*Hiit;
            KS   = P*Hiit;
            if FS > kalmanTol
                x       = x + KS*nut/FS; 
                P       = P - KS*KS'/FS;
                lik(tt) = lik(tt) + log(FS) + (nut*nut/FS);
            end

        end 

        % Forecast 
        x = A*x;            % x t+1 | t = A * x t|t
        P = A*P*A' + CCT;   % P t+1|t = A * P t|t * A' + B*B';
         
    end
    
    % Calculate full likelihood
    %--------------------------------------------------------------
    start = options.kf_presample;
    lik   = 0.5*(lik + N*log(2*pi));
    lik   = sum(lik(start+1:end));
    
end
