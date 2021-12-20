function [L,failed] = calculateLossCommitment(options,solution,parser)
% Syntax:
%
% [L,failed] = nb_dsge.calculateLossCommitment(options,solution,parser)
%
% Description:
%
% Calculate loss of the authorities under commitment.
% 
% See also:
% nb_dsge.optimalSimpleRules, nb_dsge.calculateLoss, 
% nb_dsge.calculateLossDiscretion, nb_dsge.solveAndCalculateLoss 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Options
    tol     = options.fix_point_TolFun;
    maxIter = options.fix_point_maxiter;

    % Get matrices
    W  = full(solution.W);
    A  = solution.A;
    AT = A';
    C  = solution.C;
    CT = C';
    
    if parser.optimal
        Wold       = W;
        nAll       = size(A,1);
        W          = zeros(nAll,nAll);
        ind        = ~parser.isMultiplier;
        W(ind,ind) = Wold;
    else
        if size(W,1) ~= size(A,1)
            error([mfilename ':: The model is solved under optimal monetary policy, but you have wrongly ',...
                             'set the optimal input to the setLossFunction to false.'])
        end
    end
    
    % Get discount
    failed = false;
    beta   = options.lc_discount;
    if beta == 1
        OMG = nb_lyapunovEquation(A,C*CT,tol,maxIter);
        L   = trace(W*OMG); 
    else
    
        % Solve fixed point for P = W + beta*A'*P*A
        [P,failed] = nb_lyapunovEquation2(beta*AT,A,W,tol,maxIter);
        if failed
            L = nan; 
            return
        end

        % Apply equation (12) of Dennis (2003), PHI in his paper is here
        % a identity matrix when model is parsed with NB Toolbox.
        ss = [solution.ss; zeros(size(C,2),1)];
        PB = [AT*P*A, AT*P*C; CT*P*A, CT*P*C];
        L  = ss'*PB*ss + beta/(1 - beta)*trace(CT*P*C);
        L  = (1 - beta)*L;
    
    end
        
end
