function tempSol = solveRecursive(results,opt)
% Syntax:
%
% tempSol = nb_arima.solveRecursive(results,opt)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    tempSol       = nb_arima.solveARIMAEq(results,opt);
    tempSol.class = 'nb_arima';
    tempSol.type  = 'nb';

end
