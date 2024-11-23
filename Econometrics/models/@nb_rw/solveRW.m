function tempSol = solveRW(results,opt)
% Syntax:
%
% tempSol = nb_rw.solveRW(results,opt)
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Estimation results
    beta = permute(results.beta,[2,1,3]);

    % Provide solution on the form y = A*y_1 + B*x + C*e
    %--------------------------------------------------------------
    numAR    = 1;
    const    = opt.constant;
    nPeriods = size(beta,3);

    % Seperate coefficients
    betaC    = beta(:,logical(const),:);
    betaAR   = beta(:,1 + const:const + numAR,:);
    betaExo  = beta(:,1 + const + numAR:end,:);
    
    % The final solution
    tempSol.A   = betaAR;
    tempSol.B   = [betaC,betaExo];
    tempSol.C   = ones(numAR,1,nPeriods);
    tempSol.vcv = results.sigma;
   
    % Get the ordering
    tempSol.endo = opt.dependent;
    tempSol.exo  = opt.exogenous;
    if const
        tempSol.exo = [{'Constant'}, tempSol.exo];
    end
    tempSol.res = strcat('E_',opt.dependent);

end
