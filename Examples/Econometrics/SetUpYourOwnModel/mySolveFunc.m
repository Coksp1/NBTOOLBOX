function solution = mySolveFunc(results,options)
% Syntax:
%
% solution = mySolveFunc(results,options)
%
% Description:
%
% This is an example file on how to program your own model, and make it
% work with the rest of NB toolbox.
% 
% See also:
% nb_manualModel.solve
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Estimation results
    beta = permute(results.beta,[2,1,3]);

    dep = options.dependent;
    res = strcat('E_',dep);
    exo = options.exogenous;
    if options.time_trend
        exo = ['Time-trend',exo]; %#ok<*AGROW>
    end
    if options.constant
        exo = ['Constant',exo];
    end
    numDep = length(dep);
    numExo = length(exo);
    
    % Separate estimated parameters
    AR       = beta(:,1:options.AR,:);
    indExo   = options.AR + 1:options.AR + numExo;
    exoTerms = beta(:,indExo,:);
    
    % Provide solution
    nPeriods     = size(beta,3);
    nLags        = size(AR,2)/numDep;
    numRows      = (nLags - 1)*numDep;
    I            = eye(numRows);
    I            = I(:,:,ones(1,nPeriods));
    solution.A   = [AR;I,zeros(numRows,numDep,nPeriods)];
    solution.B   = [exoTerms;zeros(numRows,numExo,nPeriods)];
    solution.C   = repmat([eye(numDep);zeros(numRows,numDep)],[1,1,nPeriods]);
    solution.vcv = results.sigma;
    
    % Set the ordering
    solution.obs  = dep;
    solution.endo = [dep,nb_cellstrlag(dep,options.AR-1,'varFast')];
    solution.exo  = exo;
    solution.res  = res;
    
end
