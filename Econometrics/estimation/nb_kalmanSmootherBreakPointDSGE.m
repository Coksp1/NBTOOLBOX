function [xf,xs,us,xu,uu] = nb_kalmanSmootherBreakPointDSGE(H,A,C,ss,obs,x0,P0,y,kalmanTol,states)
% Syntax:
%
% [xf,xs,us,xu,uu] = nb_kalmanSmootherBreakPointDSGE(H,A,C,ss,obs,x0,P0,...
%                               y,kalmanTol,states)
%
% Description:
%
% Piecewise linear Kalman smoother. With potentially missing observations!
%
% Observation equation:
% y(t) = H*x(t) + v(t)
% 
% State equation:
% x(t) = ss{s(t)} + A{s(t)}*(x(t-1) - ss{s(t)}) + C{s(t)}*u(t)
%
% Where u ~ N(0,I) meaning u is gaussian noise with covariance I
%
% Input:
%
% - H         : Observation matrix. As a nObs x nEndo double.
%
% - A         : State transition matrix. A cell with size 1 x nStates.
%               Each element as a nEndo x nEndo double.
%
% - C         : The impact of shock matrix. A cell with size 1 x nStates.
%               Each element as a nEndo x nExo double.
%
% - ss        : Steady-state of the endogenous variables. A cell with size 
%               1 x nStates. Each element as a nEndo x 1 double.
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
% - kalmanTol : Tolerance level for rcond of the forecast variance.
%
% - states    : A 1 x nobs double with the break period to use for each
%               period, i.e. how to index A, C and ss at each period.
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
% nb_kalmanSmootherDSGE, nb_kalmanLikelihoodBreakPointDSGE
%
% Written by Kenneth Sæterhagen Paulsen.

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Initialize state estimate from first observation if needed
    %--------------------------------------------------------------
    nExo     = size(C{1},2);
    [N,T]    = size(y);
    nEndo    = size(A{1},1);
    P        = nan(nEndo,nEndo,T+1);   % P t+1|t
    xf       = zeros(nEndo,T+1);       % x t+1|t
    xu       = zeros(nEndo,T);         % x t|t
    invF     = cell(1,T);
    K        = cell(1,T);
    P(:,:,1) = P0;  
    xf(:,1)  = x0;
    states   = [states;states(end)];
    
    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
    singular = false;
    vf       = nan(N,T);
    I        = eye(size(H,1));
    HT       = H';
    m        = ~isnan(y);
    for tt = 1:T
        
        At  = A{states(tt+1)};
        CCt = C{states(tt+1)}*C{states(tt+1)}';
        mt  = m(:,tt);
        if all(~mt)
            xu(:,tt)    = xf(:,tt);
            xf(:,tt+1)  = ss{states(tt+1)} + At*(xf(:,tt) - ss{states(tt+1)});
            P(:,:,tt+1) = At*P(:,:,tt)*At' + CCt;
            invF{tt}    = 0;
            K{tt}       = 0;
        else
            
            % Prediction for state vector:
            xt = ss{states(tt+1)} + At*(xf(:,tt) - ss{states(tt+1)});
            
            % Prediction for observation vector and covariance:
            Hmt = H(mt,:);
            nut = y(mt,tt) - Hmt*xf(:,tt);
            PHT = P(:,:,tt)*HT(:,mt);
            F   = Hmt*PHT;
            if rcond(F) < kalmanTol
                singular = true;
                if all(abs(F(:))) < kalmanTol
                    break;
                else
                    xu(:,tt)    = xf(:,tt);
                    xf(:,tt+1)  = xt;
                    P(:,:,tt+1) = At*P(:,:,tt)*At' + CCt;
                    invF{tt}    = 0;
                    K{tt}       = 0;
                end
                warning('kalman:singular',['One step ahead variance matrix is singular at iteration ' int2str(tt) '. ',...
                                           'The filtering results is most likely wrong. You may adjust the kalman tolerance.'])
            else

                % Kalman gain
                invF{tt} = I(mt,mt)/F;
                Ltt      = PHT*invF{tt};
                Ktt      = A{states(tt+1)}*Ltt;
                K{tt}    = Ktt;
                
                % Correction based on observation:
                xu(:,tt)    = xf(:,tt) + Ltt*nut;
                xf(:,tt+1)  = xt + Ktt*nut;
                P(:,:,tt+1) = (At - Ktt*Hmt)*P(:,:,tt)*At' + CCt;

                % Store filteres results
                vf(mt,tt) = nut;
                singular  = false;

            end
            
        end
         
    end
    
    if singular
        error('The variance of the forecast error remains singular until the end of the sample')
    end
    
    % Then we do the smoothing
    %-------------------------------------------------------------
    xs = nan(nEndo,T);          
    r  = zeros(nEndo,T + 1);
    t  = T + 1;
    while t > 1
        t      = t - 1;
        mt     = m(:,t);
        r(:,t) = A{states(t+1)}'*r(:,t+1); 
        if any(mt) 
            r(obs(mt),t) = r(obs(mt),t) + invF{t}*vf(mt,t) - K{t}'*r(:,t+1);
        end
        xs(:,t) = xf(:,t) + P(:,:,t)*r(:,t);
    end
    
    % Get the smoothed shocks
    %-------------------------------------------------------------
    us      = zeros(nExo,T);
    us(:,1) = C{states(1)}\(xs(:,1) - ss{states(1)});
    for t = 2:T
        us(:,t) = C{states(t)}\(xs(:,t) - ss{states(t)} - A{states(t)}*(xs(:,t-1) - ss{states(t)}) );
    end
    
    % Report the estimates
    %-------------------------------------------------------------
    xs = xs';
    us = us';
    xf = xf(:,2:end)';
    if nargout > 4
        
        % Get the updated shocks
        uu      = zeros(nExo,T);
        uu(:,1) = C{states(1)}\(xu(:,1) - ss{states(1)});
        for t = 2:T
            uu(:,t) = C{states(t)}\(xu(:,t) - ss{states(t)} - A{states(t)}*(xu(:,t-1) - ss{states(t)}) );
        end
        uu = uu';
        
    end
    xu = xu';
    
end
