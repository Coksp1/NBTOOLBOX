function [xf,xs,us,xu,uu,A,B,C,ss,p] = nb_kalmanSmootherUnivariateStochasticTrendDSGE(...
            H,solution,options,results,~,x0,P0,P0INF,y,kalmanTol)
% Syntax:
%
% [xf,xs,us,xu,uu,A,B,C,ss] = ...
%   nb_kalmanSmootherUnivariateStochasticTrendDSGE(H,solution,options,...
%             results,obs,x0,P0,P0INF,y,kalmanTol)
%
% Description:
%
% Diffuse univariate piecewise linear Kalman smoother with updating of the
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
% nb_kalmanLikelihoodUnivariateStochasticTrendDSGE,  
% nb_kalmanSmootherDiffuseStochasticTrendDSGE, nb_setUpForDiffuseFilter
%
% Written by Kenneth Sæterhagen Paulsen.

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Initialize state estimate from first observation if needed
    %--------------------------------------------------------------
    nDet        = size(solution.B,2);
    nExo        = size(solution.C,2);
    [nObs,S]    = size(y);
    nEndo       = size(solution.A,1);
    PS          = nan(nEndo,nEndo,S+1);   % P t+1|t
    PINF        = zeros(nEndo,nEndo,S+1); % PINF t+1|t
    xf          = zeros(nEndo,S+1);       % x t+1|t
    xu          = zeros(nEndo,S);         % x t|t
    KS          = zeros(nEndo,nObs,S);
    KINF        = zeros(nEndo,nObs,S);
    PS(:,:,1)   = P0; % P 1|0
    PINF(:,:,1) = P0INF; % PINF 1|0
    xf(:,1)     = x0; % x 1|0
    FS          = zeros(nObs,S);
    FINF        = zeros(nObs,S); 
    
    % Interpret initial conditions of state vector
    stInit  = nb_dsge.interpretStochasticTrendInit(options.parser,options.stochasticTrendInit,results.beta);
    xf(:,1) = xf(:,1) + stInit;
    
    % Solution matrices
    A        = nan(nEndo,nEndo,S+1);
    B        = nan(nEndo,nDet,S+1);
    C        = nan(nEndo,nExo,S+1);
    ss       = nan(nEndo,S+1);
    p        = nan(size(results.beta,1),S+1);
    A(:,:,1) = solution.A(:,:,1); % A 0|0
    B(:,:,1) = solution.B(:,:,1); % B 0|0
    C(:,:,1) = solution.C(:,:,1); % C 0|0
    ss(:,1)  = solution.ss(:,1);  % ss 0|0
    p(:,1)   = results.beta;      % p 0|0
    
    % Loop through the diffuse kalman filter iterations
    %--------------------------------------------------------------
    vf = zeros(nObs,S);
    HT = H';
    m  = ~isnan(y);
    r  = rank(H*PINF(:,:,1)*H',kalmanTol);
    tt = 1;
    while r && tt <= S  
        
        % Initialize updated states
        xt    = xf(:,tt);     % Initialize x t|t with x t|t-1
        PSU   = PS(:,:,tt);   % Initialize PS t|t with PS t|t-1
        PINFU = PINF(:,:,tt); % Initialize PINF t|t with PINF t|t-1

        % Loop through each observables and update the state (x t|t) and
        % covariance matrix (PS t|t and PINF t|t)
        for ii = find(m(:,tt))'

            Hii         = H(ii,:);
            vf(ii,tt)   = y(ii,tt) - Hii*xt;
            Hiit        = HT(:,ii);
            FINF(ii,tt) = Hii*PINFU*Hiit;
            FS(ii,tt)   = Hii*PSU*Hiit;
            KS(:,ii,tt) = PSU*Hiit;
            if FINF(ii,tt) > kalmanTol && r
                KINF(:,ii,tt) = PINFU*Hiit;
                KINF_DIV_FINF = KINF(:,ii,tt)/FINF(ii,tt);
                xt            = xt + KINF_DIV_FINF*vf(ii,tt);
                PSU           = PSU + KINF(:,ii,tt)*KINF_DIV_FINF'*(FS(ii,tt)/FINF(ii,tt)) - KS(:,ii,tt)*KINF_DIV_FINF' - KINF_DIV_FINF*KS(:,ii,tt)'; 
                PINFU         = PINFU - KINF(:,ii,tt)*KINF(:,ii,tt)'/FINF(ii,tt);
            elseif FS(ii,tt) > kalmanTol
                xt  = xt + KS(:,ii,tt)*vf(ii,tt)/FS(ii,tt); 
                PSU = PSU - KS(:,ii,tt)*KS(:,ii,tt)'/FS(ii,tt);
            end

        end
           
        % Update the solution given the lagged values of the stochastic
        % trend
        xu(:,tt) = xt; % x t|t
        [A(:,:,tt+1),B(:,:,tt+1),C(:,:,tt+1),ss(:,tt+1),p(:,tt+1)] = ...
            nb_dsge.updateSolution(options,results,xt,p(:,tt),tt);
        
        % Forecast 
        xf(:,tt+1) = ss(:,tt+1) + A(:,:,tt+1)*(xt - ss(:,tt+1)); % x t+1|t = A t|t * x t|t
        if ~isempty(B(:,:,tt+1))
            xf(:,tt+1) = B(:,:,tt+1) + xf(:,tt+1);
        end
        PS(:,:,tt+1)   = A(:,:,tt+1)*PSU*A(:,:,tt+1)' + C(:,:,tt+1)*C(:,:,tt+1)'; % PS t+1|t = A t|t * PS t|t * A t|t' + C t|t * C t|t';
        PINF(:,:,tt+1) = A(:,:,tt+1)*PINFU*A(:,:,tt+1)'; % PINF t+1|t = A t|t * PINF t|t * A t|t';
        
        % Check rank
        rOld = rank(H*PINFU*H',kalmanTol);
        r    = rank(H*PINF(:,:,tt+1)*H',kalmanTol);
        if rOld ~= r
            disp(['nb_kalmanSmootherUnivariateBreakPointDSGE:: The forecasting step does influence the rank of the ',...
                  'filtered one step ahead covariance matrix during the diffuse steps (PINF)!'])
        end
        tt = tt + 1;
        
    end
    
    % Free memory
    start = tt;
    FINF  = FINF(:,:,1:start-1);
    PINF  = PINF(:,:,1:start-1);
    KINF  = KINF(:,:,1:start-1);
    
    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
    for tt = start:S
        
        % Initialize updated states
        xt  = xf(:,tt);     % Initialize x t|t with x t|t-1
        PSU = PS(:,:,tt);   % Initialize PS t|t with PS t|t-1
        
        % Loop through each observables and update the state (x t|t) and
        % covariance matrix (PS t|t)
        for ii = find(m(:,tt))'

            Hii         = H(ii,:);
            vf(ii,tt)   = y(ii,tt) - Hii*xt;
            Hiit        = HT(:,ii);
            FS(ii,tt)   = Hii*PSU*Hiit;
            KS(:,ii,tt) = PSU*Hiit;
            if FS(ii,tt) > kalmanTol
                xt  = xt + KS(:,ii,tt)*vf(ii,tt)/FS(ii,tt); 
                PSU = PSU - KS(:,ii,tt)*KS(:,ii,tt)'/FS(ii,tt);
            end

        end    
        
        % Update the solution given the lagged values of the stochastic
        % trend
        xu(:,tt) = xt; % x t|t
        [A(:,:,tt+1),B(:,:,tt+1),C(:,:,tt+1),ss(:,tt+1),p(:,tt+1)] = nb_dsge.updateSolution(options,results,xu(:,tt),p(:,tt),tt);
        
        % Forecast 
        xf(:,tt+1) = ss(:,tt+1) + A(:,:,tt+1)*(xt - ss(:,tt+1)); % x t+1 | t = A t|t * x t|t
        if ~isempty(B(:,:,tt+1))
            xf(:,tt+1) = B(:,:,tt+1) + xf(:,tt+1);
        end
        PS(:,:,tt+1) = A(:,:,tt+1)*PSU*A(:,:,tt+1)' + C(:,:,tt+1)*C(:,:,tt+1)'; % PS t+1|t = A t|t * PS t|t * A t|t' + C t|t*C t|t';
         
    end
    
    % Then we do the smoothing
    %-------------------------------------------------------------
    xs = nan(nEndo,S);          
    r  = zeros(nEndo,S + 1);
    t  = S + 1;
    I  = eye(nEndo);
    while t > start % Normal steps of the smoother
        t      = t - 1;
        r(:,t) = A(:,:,t+1)'*r(:,t+1); 
        for ii = flipud(find(m(:,t)))'
            if FS(ii,t) > kalmanTol
                LS     = I - KS(:,ii,t)*H(ii,:)/FS(ii,t);
                r(:,t) = H(ii,:)'/FS(ii,t)*vf(ii,t) + LS'*r(:,t); 
            end
        end
        xs(:,t) = xf(:,t) + PS(:,:,t)*r(:,t);
    end
    
    if start > 1 % Diffuse part of the smoother
        r1 = zeros(nEndo,start); 
        for t = start-1:-1:1
            r(:,t)  = A(:,:,t+1)'*r(:,t+1);
            r1(:,t) = A(:,:,t+1)'*r1(:,t+1);
            for ii = flipud(find(m(:,t)))'
                if FINF(ii,t) > kalmanTol
                    LINF    = I - KINF(:,ii,t)*H(ii,:)/FINF(ii,t);
                    L0      = (KINF(:,ii,t)*(FS(ii,t)/FINF(ii,t)) - KS(:,ii,t))*H(ii,:)/FINF(ii,t);
                    r1(:,t) = H(ii,:)'*vf(ii,t)/FINF(ii,t) + L0'*r(:,t) + LINF'*r1(:,t);  
                    r(:,t)  = LINF'*r(:,t);   
                elseif FS(ii,t) > kalmanTol 
                    L      = I - KS(:,ii,t)*H(ii,:)/FS(ii,t);
                    r(:,t) = H(ii,:)'/FS(ii,t)*vf(ii,t) + L'*r(:,t);
                end
            end
            xs(:,t) = xf(:,t) + PS(:,:,t)*r(:,t) + PINF(:,:,t)*r1(:,t);
        end
    end
    
    % Get the smoothed shocks
    %-------------------------------------------------------------
    us        = zeros(nExo,S);
    ind       = any(C(:,:,2));
    us(ind,1) = C(:,ind,2)\(xs(:,1) - xf(:,1));
    for t = 2:S
        ind = any(C(:,:,t+1));
        if isempty(B(:,:,t+1))
            us(ind,t) = C(:,ind,t+1)\(xs(:,t) - ss(:,t+1) - A(:,:,t+1)*(xs(:,t-1) - ss(:,t+1)) );
        else
            us(ind,t) = C(:,ind,t+1)\(xs(:,t) - ss(:,t+1) - B(:,:,t+1) - A(:,:,t+1)*(xs(:,t-1) - ss(:,t+1)) );
        end
    end
    
    % Report the estimates
    %-------------------------------------------------------------
    if nargout > 4
        
        % Get the updated shocks
        uu        = zeros(nExo,S);
        ind       = any(C(:,:,2));
        uu(ind,1) = C(:,ind,2)\(xu(:,1) - xf(:,1));
        for t = 2:S
            ind = any(C(:,:,2));
            if isempty(B(:,:,t+1))
                uu(ind,t) = C(:,ind,t+1)\(xu(:,t) - ss(:,t+1) - A(:,:,t+1)*(xu(:,t-1) - ss(:,t+1)) );
            else
                uu(ind,t) = C(:,ind,t+1)\(xu(:,t) - ss(:,t+1) - B(:,:,t+1) - A(:,:,t+1)*(xu(:,t-1) - ss(:,t+1)) );
            end
        end
        uu = uu';
        
    end
    xs = xs';
    us = us';
    xf = xf(:,2:end)';
    xu = xu';
    p  = p(:,2:end)';
    ss = ss';

end
