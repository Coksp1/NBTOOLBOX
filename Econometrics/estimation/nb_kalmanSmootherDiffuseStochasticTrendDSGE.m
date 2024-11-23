function [xf,xs,us,xu,uu,A,B,C,ss,p] = nb_kalmanSmootherDiffuseStochasticTrendDSGE(...
    H,solution,options,results,obs,x0,P0,P0INF,y,kalmanTol)
% Syntax:
%
% [xf,xs,us,xu,uu] = nb_kalmanSmootherDiffuseStochasticTrendDSGE(H,...
%                       solution,options,results,obs,x0,P0,P0INF,y,...
%                       kalmanTol)
%
% Description:
%
% Diffuse piecewise linear Kalman smoother with updating of the  
% "steady state" based on some stochastic trends of the observation part 
% of the model. Will also handle potentially missing observations!
%
% Observation equation:
% y(t) = H*x(t)
% 
% State equation:
% x(t) = ss(t) + A(t)*(x(t-1) - ss(t)) + B(t)*z(t) + C(t)*u(t)
%
% where ss(t) = G(theta,x(t-1)) and A(t), B(t) and C(t) are the solution
% around this updated approximation point (or steady state).
%
% Where u ~ N(0,I) meaning u is gaussian noise with covariance I
%
% Input:
%
% - H         : Observation matrix. As a nObs x nEndo double.
%
% - solution  : A struct containing the initial solution of the model. See
%               nb_dsge.solution property for more on this input.
%
% - options   : A struct with the model options. See the 
%               nb_dsge.createEstOptionsStruct method for more on this
%               input.
%
% - results   : A struct storing the estimation or calibration of the
%               model. See nb_dsge.results property for more on this 
%               input.
%
% - obs       : Index of observables in the vector of state variables. A 
%               logical vector with size size(A,1) x 1.
%
% - x0        : Initial state vector. As a nEndo x 1 double.
%
% - P0        : Initial state variance. As a nEndo x nEndo double.
%
% - P0INF     : Initial state variance of the non-stationary variables.  
%               As a nEndo x nEndo double.
%
% - y         : Observation vector. A nObs x T double.
%
% - kalmanTol : Tolerance level for rcond of the forecast variance.
%
% Output:
%
% - xf : The filtered estimates of the x in the equation above. As a 
%        T x nEndo double.
%
% - xs : The smoothed estimates of the x in the equation above. As a 
%        T x nEndo double.
%
% - us : The smoothed estimates of the u in the equation above. As a 
%        T x nExo double.
%
% - xu : The updated estimates of the x in the equation above. As a 
%        T x nEndo double.
%
% - uu : The updated estimates of the u in the equation above. As a 
%        T x nExo double.
%
% - A  : The updated estimates of the transition matrix. 
%        A nEndo x nEndo x T + 1 double, starting from A 0|0 to A T|T.
%
% - B  : The updated estimates of the contant term of the state equation.
%        A nEndo x nDet x T + 1 double, starting from B 0|0 to B T|T. 
%        nDet are either 0 or 1.
%
% - C  : The updated estimates of the shock impact matrix.
%        A nEndo x nExo x T + 1 double, starting from C 0|0 to C T|T. 
%
% - ss : The updated estimates of the approximation point (steady state).
%        A nEndo x 1 x T + 1 double, starting from ss 0|0 to ss T|T. 
%
% - p  : The updated estimates of the parameters of the model. As a 
%        T x nParam double.
%
% See also:
% nb_kalmanLikelihoodDiffuseStochasticTrendDSGE, nb_dsge.updateSolution
% nb_kalmanSmootherUnivariateStochasticTrendDSGE, nb_setUpForDiffuseFilter
%
% Written by Kenneth Sæterhagen Paulsen.

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Initialize state estimate from first observation if needed
    %--------------------------------------------------------------
    nDet        = size(solution.B,2);
    nExo        = size(solution.C,2);
    [N,T]       = size(y);
    nEndo       = size(solution.A,1);
    P           = nan(nEndo,nEndo,T+1);   % P t+1|t
    PINF        = zeros(nEndo,nEndo,T+1); % PINF t+1|t
    xf          = zeros(nEndo,T+1);       % x t+1|t
    xu          = zeros(nEndo,T);         % x t|t
    invF        = cell(1,T);
    K           = cell(1,T);
    KINF        = invF;
    xf(:,1)     = x0; % x 1|0
    P(:,:,1)    = P0; % P 1|0
    PINF(:,:,1) = P0INF; % PINF 1|0
    
    % Interpret initial conditions of state vector
    stInit  = nb_dsge.interpretStochasticTrendInit(options.parser,options.stochasticTrendInit,results.beta);
    xf(:,1) = xf(:,1) + stInit;
    
    % Solution matrices
    A        = nan(nEndo,nEndo,T+1);
    B        = nan(nEndo,nDet,T+1);
    C        = nan(nEndo,nExo,T+1);
    ss       = nan(nEndo,T+1);
    p        = nan(size(results.beta,1),T+1);
    A(:,:,1) = solution.A(:,:,1); % A 0|0
    B(:,:,1) = solution.B(:,:,1); % B 0|0
    C(:,:,1) = solution.C(:,:,1); % C 0|0
    ss(:,1)  = solution.ss(:,1);  % ss 0|0
    p(:,1)   = results.beta;      % p 0|0
    
    % Loop through the diffuse kalman filter iterations
    %--------------------------------------------------------------
    singular = false;
    vf       = nan(N,T);
    I        = eye(size(H,1));
    HT       = H';
    m        = ~isnan(y);
    for tt = 1:T
        
        mt = m(:,tt);
        if all(~mt)
            
            % Update the solution given the lagged values of the 
            % stochastic trend
            xu(:,tt) = xf(:,tt); % x t|t = x t|t-1
            [A(:,:,tt+1),B(:,:,tt+1),C(:,:,tt+1),ss(:,tt+1),p(:,tt+1)] = ...
                nb_dsge.updateSolution(options,results,xu(:,tt),p(:,tt),tt);
            At         = A(:,:,tt+1);
            Bt         = B(:,:,tt+1);
            Ct         = C(:,:,tt+1);
            sst        = ss(:,tt+1);
            xf(:,tt+1) = sst + At*(xu(:,tt) - sst); % x t+1|t = A t|t * x t|t
            if ~isempty(Bt)
                xf(:,tt+1) = Bt + xf(:,tt+1);
            end
            P(:,:,tt+1)    = At*P(:,:,tt)*At' + Ct*Ct'; % PS t+1|t = A t|t * PS t|t * A t|t' + Ct|t * C t|t';
            PINF(:,:,tt+1) = At*PINF(:,:,tt)*At';         % PINF t+1|t = A t|t * PINF t|t * A t|t';
            invF{tt}       = 0;
            K{tt}          = 0;
            KINF{tt}       = 0;
            
        else
        
            % Prediction for observation vector and covariance:
            Hmt    = H(mt,:);
            nut    = y(mt,tt) - Hmt*xf(:,tt);
            HTmt   = HT(:,mt);
            PINFHT = PINF(:,:,tt)*HTmt;
            FINF   = Hmt*PINFHT;
            PSHT   = P(:,:,tt)*HTmt;
            FS     = Hmt*PSHT;
            if rank(FINF,kalmanTol) < sum(mt)
                
                if ~all(abs(FINF(:)) < kalmanTol)
                    error([mfilename ':: You must use the univariate Kalman filter. If called from the ',...
                                     'nb_dsge.filter method, set ''kf_method'' to ''univariate''.'])
                end
                break; % Continue with normal iterations
                
            else

                % Correction based on observation:
                invFINF  = I(mt,mt)/FINF;
                LINFtt   = PINFHT*invFINF;
                xu(:,tt) = xf(:,tt) + LINFtt*nut;
                
                % Update the solution given the lagged values of the stochastic
                % trend
                [A(:,:,tt+1),B(:,:,tt+1),C(:,:,tt+1),ss(:,tt+1),p(:,tt+1)] = ...
                    nb_dsge.updateSolution(options,results,xu(:,tt),p(:,tt),tt);
                At  = A(:,:,tt+1);
                Bt  = B(:,:,tt+1);
                Ct  = C(:,:,tt+1);
                sst = ss(:,tt+1);
                
                % Kalman gain
                KINFtt   = At*LINFtt;
                KStt     = At*PSHT*invFINF - KINFtt*FS*invFINF;
                K{tt}    = KStt;
                KINF{tt} = KINFtt;
                invF{tt} = invFINF;

                % Prediction for state vector:
                xf(:,tt+1) = sst + At*(xu(:,tt) - sst);
                if ~isempty(Bt)
                    xf(:,tt+1) = Bt + xf(:,tt+1);
                end
                LINFT          = (At' - HTmt*KINFtt');
                PINF(:,:,tt+1) = At*PINF(:,:,tt)*LINFT;
                P(:,:,tt+1)    = At*P(:,:,tt)*LINFT + Ct*Ct' - At*PINFHT*KStt';
                
                % Store filteres results
                vf(mt,tt) = nut;
                singular  = false;

            end
            
        end
        
    end
    
    if singular
        error('The variance of the forecast error remains singular until the end of the diffuse step.')
    end
    
    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
    start = tt;
    for tt = start:T
        
        mt = m(:,tt);
        if all(~mt)
            
            % Update the solution given the lagged values of the 
            % stochastic trend
            xu(:,tt) = xf(:,tt); % x t|t = x t|t-1
            [A(:,:,tt+1),B(:,:,tt+1),C(:,:,tt+1),ss(:,tt+1),p(:,tt+1)] = ...
                nb_dsge.updateSolution(options,results,xu(:,tt),p(:,tt),tt);
            At         = A(:,:,tt+1);
            Bt         = B(:,:,tt+1);
            Ct         = C(:,:,tt+1);
            sst        = ss(:,tt+1);
            xf(:,tt+1) = sst + At*(xu(:,tt) - sst); % x t+1|t = A t|t * x t|t
            if ~isempty(Bt)
                xf(:,tt+1) = Bt + xf(:,tt+1);
            end
            P(:,:,tt+1) = At*P(:,:,tt)*At' + Ct*Ct'; % PS t+1|t = A t|t * PS t|t * A t|t' + Ct|t * C t|t';
            invF{tt}    = 0;
            K{tt}       = 0;
            
        else
            
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
                    
                    % Update the solution given the lagged values of the 
                    % stochastic trend
                    xu(:,tt) = xf(:,tt); % x t|t = x t|t-1
                    [A(:,:,tt+1),B(:,:,tt+1),C(:,:,tt+1),ss(:,tt+1),p(:,tt+1)] = ...
                        nb_dsge.updateSolution(options,results,xu(:,tt),p(:,tt),tt);
                    At         = A(:,:,tt+1);
                    Bt         = B(:,:,tt+1);
                    Ct         = C(:,:,tt+1);
                    sst        = ss(:,tt+1);
                    xf(:,tt+1) = sst + At*(xu(:,tt) - sst); % x t+1|t = A t|t * x t|t
                    if ~isempty(Bt)
                        xf(:,tt+1) = Bt + xf(:,tt+1);
                    end
                    P(:,:,tt+1) = At*P(:,:,tt)*At' + Ct*Ct'; % PS t+1|t = A t|t * PS t|t * A t|t' + Ct|t * C t|t';
                    invF{tt}    = 0;
                    K{tt}       = 0;
                    
                end
                warning('kalman:singular',['One step ahead variance matrix is singular at iteration ' int2str(tt) '. ',...
                                           'The filtering results is most likely wrong. You may adjust the kalman tolerance.'])
            else

                % Correction based on observation:
                invF{tt} = I(mt,mt)/F;
                Ltt      = PHT*invF{tt};
                xu(:,tt) = xf(:,tt) + Ltt*nut;
                
                % Update the solution given the lagged values of the stochastic
                % trend
                [A(:,:,tt+1),B(:,:,tt+1),C(:,:,tt+1),ss(:,tt+1),p(:,tt+1)] = ...
                    nb_dsge.updateSolution(options,results,xu(:,tt),p(:,tt),tt);
                At  = A(:,:,tt+1);
                Bt  = B(:,:,tt+1);
                Ct  = C(:,:,tt+1);
                sst = ss(:,tt+1);
                
                % Kalman gain
                Ktt   = At*Ltt;
                K{tt} = Ktt;
                
                % Prediction for state vector:
                xf(:,tt+1) = sst + At*(xu(:,tt) - sst);
                if ~isempty(Bt)
                    xf(:,tt+1) = Bt + xf(:,tt+1);
                end
                P(:,:,tt+1) = (At - Ktt*Hmt)*P(:,:,tt)*At' + Ct*Ct';

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
        r(:,t) = A(:,:,t+1)'*r(:,t+1); 
        if any(mt) 
            r(obs(mt),t) = r(obs(mt),t) + invF{t}*vf(mt,t) - K{t}'*r(:,t+1);
        end
        xs(:,t) = xf(:,t) + P(:,:,t)*r(:,t);
    end
    
    if start > 1 % Diffuse part of the smoother
        r0          = zeros(nEndo,start); 
        r1          = r0;
        r0(:,start) = r(:,start);
        for t = start-1:-1:1
            mt      = m(:,t);
            r0(:,t) = A(:,:,t+1)'*r0(:,t+1);
            r1(:,t) = A(:,:,t+1)'*r1(:,t+1);
            if any(mt)
                obst       = obs(mt); 
                r1(obst,t) = r1(obst,t) + invF{t}*vf(mt,t) - K{t}'*r0(:,t+1) - KINF{t}'*r1(:,t+1);
                r0(obst,t) = r0(obst,t) - KINF{t}'*r0(:,t+1);
            end
            xs(:,t) = xf(:,t) + P(:,:,t)*r0(:,t) + PINF(:,:,t)*r1(:,t);
        end
    end
    
    % Get the smoothed shocks
    %-------------------------------------------------------------
    us        = zeros(nExo,T);
    ind       = any(C(:,:,1));
    us(ind,1) = C(:,ind,1)\(xs(:,1) - xf(:,1));
    for t = 2:T
        ind = any(C(:,:,t));
        if isempty(B(:,:,t+1))
            us(ind,t) = C(:,ind,t+1)\(xs(:,t) - ss(:,t+1) - A(:,:,t+1)*(xs(:,t-1) - ss(:,t+1)) );
        else
            us(ind,t) = C(:,ind,t+1)\(xs(:,t) - ss(:,t+1) - B(:,t+1) - A(:,:,t+1)*(xs(:,t-1) - ss(:,t+1)) );
        end
    end
    
    % Report the estimates
    %-------------------------------------------------------------
    if nargout > 4
        
        % Get the updated shocks
        uu        = zeros(nExo,T);
        ind       = any(C(:,:,1));
        uu(ind,1) = C(:,ind,1)\(xu(:,1) - xf(:,1));
        for t = 2:T
            ind = any(C(:,:,1));
            if isempty(B(:,:,t+1))
                uu(ind,t) = C(:,ind,t+1)\(xu(:,t) - ss(:,t+1) - A(:,:,t+1)*(xu(:,t-1) - ss(:,t+1)) );
            else
                uu(ind,t) = C(:,ind,t+1)\(xu(:,t) - ss(:,t+1) - B(:,t+1) - A(:,:,t+1)*(xu(:,t-1) - ss(:,t+1)) );
            end
        end
        uu = uu';
        
    end
    xs = xs';
    us = us';
    xf = xf(:,2:end)';
    xu = xu';
    p  = p';
    ss = ss';
    
end
