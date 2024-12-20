function tempSol = solveNormal(results,opt)
% Syntax:
%
% tempSol = nb_arima.solveNormal(results,opt)
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    tempSol       = nb_arima.solveARIMAEq(results,opt);
    tempSol.class = 'nb_arima';
    tempSol.type  = 'nb';

end
