function tempSol = solveRecursive(results,opt)
% Syntax:
%
% tempSol = nb_singleEq.solveRecursive(results,opt,ident)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    estim_method = opt.estim_method;
    switch lower(estim_method)
        case {'ols','quantile'}
            tempSol = nb_singleEq.solveOLSEq(results,opt);
        case 'tsls'
            tempSol = nb_singleEq.solveTSLSEqRecursiv(results,opt);
        otherwise
            error([mfilename ':: The estimation method ' estim_method ' is not supported.'])
    end

    if ~isfield(tempSol,'class')
        tempSol.class = 'nb_singleEq';
    end
    tempSol.type = 'nb';

end
