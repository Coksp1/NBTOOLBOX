function [xf,xu,xs,us,lik,Ps,Ps_1,Pf,Pu] = nb_kalmanSmootherAndLikelihood(H,R,A,B,x0,P0,y,kalmanTol,kf_presample,G,z,s)
% Syntax:
%
% [xf,xu,xs,us,lik,Ps,Ps_1,Pf,Pu] = nb_kalmanSmootherAndLikelihood(H,R,...
%     A,B,obs,x0,P0,y,kalmanTol,kf_presample,G,z,s)
%
% Description:
%
% Kalman smoother. With potentially missing observations!
%
% Observation equation:
% y(t) = H*x(t) + v(t)
% 
% State equation:
% x(t) = A*x(t-1) + B*u(t)
%
% or if G and z is given
%
% x(t) = A*x(t-1) + G*z(t) + s(t)*B*u(t)
%
% Where u ~ N(0,I) and v ~ N(0,R).
%
% See for example: Koopman and Durbin (1998), "Fast filtering ans smoothing
% for multivariate state space models" and Hamilton (1994), "Time Series 
% Analysis"
%
% Input:
%
% - H            : Observation matrix. As a nObs x nEndo double.
%
% - R            : Measurement error covariance matrix. As a nObs x nObs 
%                  double. If you assume no measurement error, give 
%                  zeros(nObs).
%
% - A            : State transition matrix. As a size nEndo x nEndo.
%
% - B            : The impact of shock matrix. As a size nEndo x nExo.
%
% - x0           : Initial state vector. As a nEndo x 1 double.
%
% - P0           : Initial state variance. As a nEndo x nEndo double.
%
% - y            : Observation vector. A nObs x T double.
%
% - kalmanTol    : Kalman tolerance. 
%
% - kf_presample : Number of periods before the likelihood is calculated.
%
% - G            : A nEndo x nExo double.
%
% - z            : A nExo x T double
%
% - s            : A 1 x T double. With the stochastic-volatility process.
%                  Defaults to 1.
%
% Output:
%
% - xf   : The filtered estimates (x t+1|t) of the x in the equation above.
%          A nEndo x T + 1 double. xf(:,1) is set to x0, and is 
%          interpreted as x 1|0.
%
% - xu   : The updated estimates (x t|t) of the x in the equation above.
%          A nEndo x T + 1 double. xu(:,1) is set to x0, and is 
%          interpreted as x 0|0.
%
% - xs   : The smoothed estimates (x t|T) of the x in the equation above.
%          A nEndo x T double. xs(:,1) is interpreted as x 1|T.
%           
% - us   : The smoothed estimates of the u in the equation above.
%          A nExo x T double.
%
% - lik  : Minus the log likelihood. As a 1 x 1 double.
%
% - Ps   : Smoothed one step ahead covariance matrices. P t|T.
%          A nEndo x nEndo x T double. Ps(:,1) is interpreted as 
%          P 1|T.
%
% - Ps_1 : Smoothed etimate of Cov(x(t) x(t-1)|T). P_1 t|T.
%          A nEndo x nEndo x T double.
%
% - Pf   : Filtered one step ahead covariance matrices. P t+1|t. 
%          A nEndo x nEndo x T+1 double. P0 at first page.
%
% - Pu   : Updated one step ahead covariance matrices. P t|t.
%          A nEndo x nEndo x T+1 double. P0 at first page.
%
% See also:
% nb_kalmanLikelihoodMissingDSGE, nb_kalmanSmootherAndLikelihoodUnivariate
%
% Written by Kenneth Sæterhagen Paulsen.

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Initialize state estimate from first observation if needed
    %--------------------------------------------------------------
    nExo  = size(B,2);
    BB    = B*B';
    [N,T] = size(y);
    nEndo = size(A,1);
    Pf    = nan(nEndo,nEndo,T+1);   % P t+1|t
    Pu    = nan(nEndo,nEndo,T+1);   % P t|t
    xf    = zeros(nEndo,T+1);       % x t+1|t
    xu    = zeros(nEndo,T+1);       % x t|t
    invF  = cell(1,T);
    K     = cell(1,T);
    
    if nargin < 10
        G = zeros(nEndo,0);
        z = zeros(0,T);
    end
        
    % Intial values
    Pf(:,:,1)   = P0; % P 1|0 
    Pu(:,:,1)   = P0; % P 0|0
    xf(:,1)     = x0; % x 1|0
    xu(:,1)     = x0; % x 0|0

    % Set up for filter
    lik      = zeros(T,1);
    singular = false;
    vf       = nan(N,T);
    I        = eye(size(H,1));
    Ia       = eye(nEndo);
    HT       = H';
    AT       = A';
    m        = ~isnan(y);
    
    % Stochastic-volatility process
    if nargin < 12
        s2 = ones(1,T);
    else
        if isempty(s)
            s2 = ones(1,T);
        else
            s2 = s.^2;
        end
    end
    
    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
    for t = 1:T
        
        mt = m(:,t);
        if all(~mt)
            xu(:,t+1) = xf(:,t);
            if nargin > 10
                xf(:,t+1) = A*xf(:,t) + G*z(:,t);  % x t+1 | t = A * x t|t + G * z t + 1
            else
                xf(:,t+1) = A*xf(:,t);              % x t+1 | t = A * x t|t
            end
            Pu(:,:,t+1) = Pf(:,:,t);
            Pf(:,:,t+1) = A*Pf(:,:,t)*AT + s2(t)*BB;
            invF{t}     = 0;
            K{t}        = zeros(size(HT,1),0);
        else
        
            % Prediction for observation vector and covariance:
            Hmt = H(mt,:);
            Nmt = size(Hmt,1);
            nut = y(mt,t) - Hmt*xf(:,t);
            PHT = Pf(:,:,t)*HT(:,mt);
            F   = Hmt*PHT + R(mt,mt);
            if rcond(F) < kalmanTol
                singular = true;
                if all(abs(F(:))) < kalmanTol
                    break;
                else
                    xu(:,t+1) = xf(:,t);
                    if nargin > 10
                        xf(:,t+1) = A*xf(:,t) + G*z(:,t);  % x t+1 | t = A * x t|t + G * z t + 1
                    else
                        xf(:,t+1) = A*xf(:,t);              % x t+1 | t = A * x t|t
                    end
                    Pu(:,:,t+1) = Pf(:,:,t);
                    Pf(:,:,t+1) = A*Pf(:,:,t)*AT + s2(t)*BB;
                    invF{t}     = 0;
                    K{t}        = 0;
                end
                warning('kalman:singular',['One step ahead variance matrix is singular at iteration ' int2str(t) '. ',...
                                           'The filtering results is most likely wrong. You may adjust the kalman tolerance.'])
            else

                % Kalman gain
                invF{t} = I(mt,mt)/F;
                Ktt     = PHT*invF{t};
                K{t}    = Ktt;

                % Updated
                xu(:,t+1)   = xf(:,t) + Ktt*nut;        % x t|t
                Pu(:,:,t+1) = (Ia - Ktt*Hmt)*Pf(:,:,t); % P t|t
                
                % Predicted
                xf(:,t+1)   = A*xu(:,t+1) + G*z(:,t);  % x t+1|t
                Pf(:,:,t+1) = A*Pu(:,:,t+1)*AT + s2(t)*BB;    % P t+1|t

                % Store filteres results
                vf(mt,t) = nut;
                singular = false;
                
                % Add to likelihood
                lik(t) = log(det(F)) + nut'*invF{t}*nut + Nmt*log(2*pi);
                
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
    BT = B';
    while t > 1
        t  = t - 1;
        mt = m(:,t);
        if any(mt)
            r(:,t) = AT*r(:,t+1) + H(mt,:)'*invF{t}*vf(mt,t) - H(mt,:)'*(A*K{t})'*r(:,t+1); 
        else
            r(:,t) = AT*r(:,t+1);    
        end
        xs(:,t) = xf(:,t) + Pf(:,:,t)*r(:,t);
        if nargin <= 10
            us(:,t) = BT*r(:,t);
        end
    end
    
    % Get the smoothed shocks when exogenous variables are included in the
    % model
    if nargin > 10
        us(:,1) = B\(xs(:,1) - G*z(:,1));
        for t = 2:T
            us(:,t) = B\(xs(:,t) - A*xs(:,t-1) - G*z(:,t));
        end
    end
    
    % Report likelihood if asked for
    lik = sum(0.5*lik(kf_presample+1:end));
    
    % Calculate P t|T, i.e. smoothed estimates of the covariance  
    % matrix of one step ahead forecast. Uses section 13.6 of 
    % Hamilton (1994).
    %----------------------------------------------------------------------
    % Preallocation
    Ps   = nan(nEndo,nEndo,T+1);  % P t|T   = Cov(x(t)|T)
    Ps_1 = nan(nEndo,nEndo,T);    % P_1 t|T = Cov(x(t) x(t-1)|T)
    
    % Final period
    Ps(:,:,T+1) = Pu(:,:, T+1);                           % P T|T
    Ps_1(:,:,T) = (Ia - K{end}*H(m(:,T),:))*A*Pu(:,:, T); % P_1 T|T = (I - K*Hmt)*A*(P T-1|T-1)
    
    % See equation 13.6.11 of Hamilton (1994)
    J2 = Pu(:,:, T)*A'*pinv(Pf(:,:, T)); % J T-1 = P T-1|T-1*A'*P T|T-1
    for t = T:-1:1
        J1        = J2;
        Ps(:,:,t) = Pu(:,:, t) + J1*(Ps(:,:,t+1) - Pf(:,:, t))*J1'; % P t-1|T, equation 13.6.20 of Hamilton (1994)
        if t > 1
            J2            = Pu(:,:,t-1)*A'*pinv(Pf(:,:,t-1));
            Ps_1(:,:,t-1) = Pu(:,:,t)*J2' + J1*(Ps_1(:,:,t) - A*Pu(:,:,t))*J2'; % P_1 t-1|T
        end
    end
    
    % Remove P 0|T
    Ps = Ps(:,:,2:end);
    
end
