function [L,failed] = calculateLossDiscretion(options,solution,traceOnly)
% Syntax:
%
% [L,failed] = calculateLossDiscretion(options,solution,traceOnly)
%
% Description:
%
% Calculate loss of the authorities under discretion.
% 
% See also:
% nb_dsge.optimalSimpleRules, nb_dsge.calculateLoss, 
% nb_dsge.calculateLossCommitment, nb_dsge.solveAndCalculateLoss 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Options
    tol      = options.fix_point_TolFun;
    maxIter  = options.fix_point_maxiter;

    % Get matrices
    W     = full(solution.W);
    H0    = solution.A; % Taken as initial guess 
    A0    = solution.A0;
    Alead = solution.Alead;
    Alag  = solution.Alag;
    B     = solution.C; 
     
    % Step 2 of the algorithm in Dennis (2003)
    GAM = Alead*H0 + A0;
    H   = -GAM\Alag; 
    D   = -GAM\B;
    
    % Get discount
    L    = nan;
    beta = options.lc_discount;
    if beta == 1
        
        % Step 3 of the algorithm in Dennis (2003) in the case beta == 1
        [OMG,failed] = nb_lyapunovEquation(H,D*D',tol,maxIter);
        L            = trace(W*OMG); 
        
    else
    
        % Step 3 of the algorithm in Dennis (2003)
        
        % Solve fixed point for M = W + beta*H'*M*H
        [M,failed] = nb_lyapunovEquation2(beta*H',H,W,tol,maxIter);
        if failed 
            return
        end

        % Apply equation (16) of Dennis (2003), PHI in his paper is here
        % a identity matrix when model is parsed with NB Toolbox.
        if traceOnly
            L  = trace(D'*M*D);
        else
            HT = H';
            DT = D';
            ss = [solution.ss; zeros(size(CT,2),1)];
            MB = [HT*M*H, HT*M*D; DT*M*H, DT*M*H];
            L  = ss'*MB*ss + beta/(1 - beta)*trace(DT*M*D);
        end
        L  = (1 - beta)*L;
    
    end
    if isnan(L)
        failed = true;
    end

end
