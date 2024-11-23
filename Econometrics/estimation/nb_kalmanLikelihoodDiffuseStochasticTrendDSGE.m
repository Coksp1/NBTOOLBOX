function lik = nb_kalmanLikelihoodDiffuseStochasticTrendDSGE(par,estStruct)
% Syntax:
%
% lik = nb_kalmanLikelihoodDiffuseStochasticTrendDSGE(par,estStruct)
%
% Description:
%
% Diffuse piecewise linear Kalman filter with updating of the
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
% nb_kalmanSmootherDiffuseStochasticTrendDSGE, nb_setUpForDiffuseFilter  
% nb_kalmanLikelihoodUnivariateStochasticTrendDSGE, nb_dsge.updateSolution
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
    singular = false;
    I        = eye(size(H,1));
    r        = rank(H*PINF*H',kalmanTol);
    tt       = 1;
    while r && tt <= S  

        mt = m(:,tt);
        if all(~mt)
            
            % Update the solution given the lagged values of the 
            % stochastic trend
            xu               = xf; % x t|t = x t|t-1
            [A,B,C,ss,p,err] = nb_dsge.updateSolution(estStruct.options,results,xu,p,tt);
            if ~isempty(err)
                lik = 1e10;
                return
            end
            xf = ss + A*(xu - ss); % x t+1|t = A t|t * x t|t
            if ~isempty(B)
                xf = B + xf;
            end
            PS   = A*PS*A' + C*C'; % PS t+1|t = A t|t * PS t|t * A t|t' + Ct|t * C t|t';
            PINF = A*PINF*A';      % PINF t+1|t = A t|t * PINF t|t * A t|t';
            
        else
        
            % Prediction for observation vector and covariance:
            Hmt    = H(mt,:);
            nut    = y(mt,tt) - Hmt*xf;
            HTmt   = HT(:,mt);
            PINFHT = PINF*HTmt;
            FINF   = Hmt*PINFHT;
            PSHT   = PS*HTmt;
            FS     = Hmt*PSHT;
            if rank(FINF,kalmanTol) < sum(mt)
                
                if ~all(abs(FINF(:)) < kalmanTol)
                    lik = 1e10;
                    return
                end
                break; % Continue with normal iterations
                
            else

                rcondFINF = rcond(FINF);
                if isnan(rcondFINF)
                   lik = 1e10;
                   return
                end

                rcondF = rcond(FS);
                if isnan(rcondF)
                   lik = 1e10;
                   return
                end
                
                if rcondF < kalmanTol
                    
                    singular = true;
                    if all(abs(FS(:))) < kalmanTol
                        lik = 1e10;
                        return
                    else
                        
                        % Update the solution given the lagged values of the 
                        % stochastic trend
                        xu               = xf; % x t|t = x t|t-1
                        [A,B,C,ss,p,err] = nb_dsge.updateSolution(estStruct.options,results,xu,p,tt);
                        if ~isempty(err)
                            lik = 1e10;
                            return
                        end
                        xf = ss + A*(xu - ss); % x t+1|t = A t|t * x t|t
                        if ~isempty(B)
                            xf = B + xf;
                        end
                        PS   = A*PS*A' + C*C'; % PS t+1|t = A t|t * PS t|t * A t|t' + Ct|t * C t|t';
                        PINF = A*PINF*A';      % PINF t+1|t = A t|t * PINF t|t * A t|t';
                        
                    end
                    
                else
                
                    % Correction based on observation:
                    invFINF = I(mt,mt)/FINF;
                    LINF    = PINFHT*invFINF;
                    xu      = xf + LINF*nut;
                    
                    % Update the solution given the lagged values of the 
                    % stochastic trend
                    [A,B,C,ss,p,err] = nb_dsge.updateSolution(estStruct.options,results,xu,p,tt);
                    if ~isempty(err)
                        lik = 1e10;
                        return
                    end
                    
                    % Kalman gain
                    KINF  = A*LINF;
                    KS    = A*PSHT*invFINF - KINF*FS*invFINF;
                    LINFT = (A' - HTmt*KINF');

                    % Predictions
                    xf = ss + A*(xu - ss); % x t+1|t = A t|t * x t|t
                    if ~isempty(B)
                        xf = B + xf;
                    end
                    PINF = A*PINF*LINFT; % PINF t+1|t
                    PS   = A*PS*LINFT + C*C' - A*PINFHT*KS'; % PS t+1|t
                    
                    % Add to likelihood
                    lik(tt)  = log(det(FINF));
                    singular = false;
                
                end

            end
            
        end
        tt = tt + 1;
        
    end
    
    if singular
        lik = 1e10;
        return
    end
    
    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
    start = tt;
    for tt = start:S
        
        mt = m(:,tt);
        if all(~mt)
            
            % Update the solution given the lagged values of the 
            % stochastic trend
            xu               = xf; % x t|t = x t|t-1
            [A,B,C,ss,p,err] = nb_dsge.updateSolution(estStruct.options,results,xu,p,tt);
            if ~isempty(err)
                lik = 1e10;
                return
            end
            xf = ss + A*(xu - ss); % x t+1|t = A t|t * x t|t
            if ~isempty(B)
                xf = B + xf;
            end
            PS   = A*PS*A' + C*C'; % PS t+1|t = A t|t * PS t|t * A t|t' + Ct|t * C t|t';

        else
            
            % Prediction for observation vector and covariance:
            Hmt     = H(mt,:);
            nut     = y(mt,tt) - Hmt*xf;
            PHT     = PS*HT(:,mt);
            FS      = Hmt*PHT;
            rcondFS = rcond(FS);
            if isnan(rcondFS)
               lik = 1e10;
               return
            end
            if rcondFS < kalmanTol
                singular = true;
                if all(abs(FS(:))) < kalmanTol
                    break;
                else
                    
                    % Update the solution given the lagged values of the 
                    % stochastic trend
                    xu               = xf; % x t|t = x t|t-1
                    [A,B,C,ss,p,err] = nb_dsge.updateSolution(estStruct.options,results,xu,p,tt);
                    if ~isempty(err)
                        lik = 1e10;
                        return
                    end
                    xf = ss + A*(xu - ss); % x t+1|t = A t|t * x t|t
                    if ~isempty(B)
                        xf = B + xf;
                    end
                    PS   = A*PS*A' + C*C'; % PS t+1|t = A t|t * PS t|t * A t|t' + Ct|t * C t|t';
                    
                end
            else

                % Correction based on observation:
                invFS = I(mt,mt)/FS;
                LS    = PHT*invFS;
                xu    = xf + LS*nut; % x t|t = x t|t-1
                
                % Update the solution given the lagged values of the 
                % stochastic trend
                [A,B,C,ss,p,err] = nb_dsge.updateSolution(estStruct.options,results,xu,p,tt);
                if ~isempty(err)
                    lik = 1e10;
                    return
                end
                
                % Prediction for state vector:
                xf = ss + A*(xu - ss); % x t+1|t = A t|t * x t|t
                if ~isempty(B)
                    xf = B + xf;
                end
                KS = A*LS;
                PS = (A - KS*Hmt)*PS*A' + C*C'; % PS t+1|t

                % Add to likelihood
                lik(tt)  = log(det(FS)) + nut'*invFS*nut;
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
    start = estStruct.options.kf_presample;
    lik   = 0.5*(lik + N*log(2*pi));
    lik   = sum(lik(start+1:end));
    
end
