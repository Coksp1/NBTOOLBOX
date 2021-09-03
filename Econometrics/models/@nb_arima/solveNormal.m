function tempSol = solveNormal(results,opt)
% Syntax:
%
% tempSol = nb_arima.solveNormal(results,opt)
%
% Written by Kenneth S�terhagen Paulsen 

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    tempSol       = nb_arima.solveARIMAEq(results,opt);
    tempSol.class = 'nb_arima';
    tempSol.type  = 'nb';

end