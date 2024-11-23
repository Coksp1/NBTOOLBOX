function lik = nb_kalmanLikelihoodUnivariateStochasticTrendDSGE(par,estStruct)
% Syntax:
%
% lik = nb_kalmanLikelihoodUnivariateStochasticTrendDSGE(par,estStruct)
%
% Description:
%
% Diffuse univariate piecewise linear Kalman filter with updating of the
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
% - par       : Current vector of the estimated parameters.
%
% - estStruct : See the nb_dsge.getObjectiveForEstimation method.
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
% - A  : The updated estimates of the transition matrix.
%
% - B  : The updated estimates of the contant term of the state equation.
%
% - C  : The updated estimates of the shock impact matrix.
%
% - ss : The updated estimates of the approximation point (steady state).
%
% - p  : The updated estimates of the parameters of the model. 
%
% See also:
% nb_kalmanSmootherUnivariateStochasticTrendDSGE, nb_dsge.updateSolution  
% nb_kalmanLikelihoodDiffuseStochasticTrendDSGE, nb_setUpForDiffuseFilter
%
% Written by Kenneth Sæterhagen Paulsen.

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    y     = estStruct.y;
    m     = ~isnan(y);
    [N,S] = size(y);
    
    % Update the parameters 
    results             = struct('beta',[]);
    p                   = estStruct.beta;
    p(estStruct.indPar) = par(~estStruct.isBreakP & ~estStruct.isTimeOfBreakP);
    
    % Solution matrices
    estStructTemp = rmfield(estStruct,'obsInd');
    sol           = nb_dsge.stateSpace(par,estStructTemp);
    if ~isempty(sol.err)
        lik = 1e10;
        return
    end
    A  = sol.A;
    C  = sol.C;
    ss = sol.ss;

    % Interpret initial conditions of state vector
    stInit = nb_dsge.interpretStochasticTrendInit(estStruct.options.parser,...
             estStruct.options.stochasticTrendInit,p);
    xf     = ss + stInit;
    
    % Observation equation
    H  = nb_dsge.makeObservationEq(estStruct.obsInd,size(A,1));
    HT = H';
    
    % Intitialize the filter
    [~,~,~,~,PS,PINF,fail] = nb_setUpForDiffuseFilter(H,A,C);
    if fail
        lik = 1e10;
        return
    end
    if ~isempty(estStruct.options.kf_init_variance)
        PS = PS*estStruct.options.kf_init_variance;
    end
    
    % Options and pre-allocation
    lik       = zeros(S,1);
    kalmanTol = estStruct.options.kf_kalmanTol;
    
    % Loop through the diffuse kalman filter iterations
    %--------------------------------------------------------------
    r  = rank(H*PINF*H',kalmanTol);
    tt = 1;
    while r && tt <= S  

        % Initialize updated states
        xu    = xf;   % Initialize x t|t with x t|t-1
        PSU   = PS;   % Initialize PS t|t with PS t|t-1
        PINFU = PINF; % Initialize PINF t|t with PINF t|t-1

        % Loop through each observables and update the state (x t|t) and
        % covariance matrix (PS t|t and PINF t|t)
        for ii = find(m(:,tt))'

            Hii  = H(ii,:);
            vf   = y(ii,tt) - Hii*xu;
            Hiit = HT(:,ii);
            FINF = Hii*PINFU*Hiit;
            FS   = Hii*PSU*Hiit;
            KS   = PSU*Hiit;
            if FINF > kalmanTol && r
                KINF          = PINFU*Hiit;
                KINF_DIV_FINF = KINF/FINF;
                xu            = xu + KINF_DIV_FINF*vf;
                PSU           = PSU + KINF*KINF_DIV_FINF'*(FS/FINF) - KS*KINF_DIV_FINF' - KINF_DIV_FINF*KS'; 
                PINFU         = PINFU - KINF*KINF'/FINF;
                lik(tt)       = lik(tt) + log(FINF);
            elseif FS > kalmanTol
                xu      = xu + KS*vf/FS; 
                PSU     = PSU - KS*KS'/FS;
                lik(tt) = lik(tt) + log(FS) + (vf*vf/FS);
            elseif FS < 0 || FINF < 0
                lik = 1e10;
                return     
            end

        end
          
        % Update the solution given the lagged values of the stochastic
        % trend
        [A,B,C,ss,p,err] = nb_dsge.updateSolution(estStruct.options,results,xu,p,tt);
        if ~isempty(err)
            lik = 1e10;
            return
        end
        
        % Forecast
        xf = ss + A*(xu - ss); % x t+1 | t = A t|t * x t|t
        if ~isempty(B)
            xf = B + xf;
        end
        PS   = A*PSU*A' + C*C'; % PS t+1|t = A t|t * PS t|t * A t|t' + Ct|t * C t|t';
        PINF = A*PINFU*A';      % PINF t+1|t = A t|t * PINF t|t * A t|t';
        
        % Check rank
        rOld = rank(H*PINFU*H',kalmanTol);
        r    = rank(H*PINF*H',kalmanTol);
        if rOld ~= r
            lik = 1e10;
            return 
        end
        tt = tt + 1;
        
    end
    
    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
    start = tt;
    for tt = start:S
        
        % Initialize updated states
        xu  = xf;   % Initialize x t|t with x t|t-1
        PSU = PS;   % Initialize PS t|t with PS t|t-1
        
        % Loop through each observables and update the state (x t|t) and
        % covariance matrix (PS t|t)
        for ii = find(m(:,tt))'
            Hii  = H(ii,:);
            vf   = y(ii,tt) - Hii*xu;
            Hiit = HT(:,ii);
            FS   = Hii*PSU*Hiit;
            KS   = PSU*Hiit;
            if FS > kalmanTol
                xu      = xu + KS*vf/FS; 
                PSU     = PSU - KS*KS'/FS;
                lik(tt) = lik(tt) + log(FS) + (vf*vf/FS);
            end
        end    
        
        % Update the solution given the lagged values of the stochastic
        % trend
        [A,B,C,ss,p,err] = nb_dsge.updateSolution(estStruct.options,results,xu,p,tt);
        if ~isempty(err)
            lik = 1e10;
            return
        end
        
        % Forecast 
        xf = ss + A*(xu - ss); % x t+1 | t = A * x t|t
        if ~isempty(B)
            xf = B + xf;
        end
        PS = A*PSU*A' + C*C'; % PS t+1|t = A * PS t|t * A' + C*C';
         
    end
    
    % Calculate full likelihood
    %--------------------------------------------------------------
    start = estStruct.options.kf_presample;
    lik   = 0.5*(lik + N*log(2*pi));
    lik   = sum(lik(start+1:end));
    
end
