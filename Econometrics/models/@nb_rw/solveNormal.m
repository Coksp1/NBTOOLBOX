function tempSol = solveNormal(results,opt)
% Syntax:
%
% tempSol = nb_rw.solveNormal(results,opt)
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    tempSol       = nb_rw.solveRW(results,opt);
    tempSol.class = 'nb_rw';
    tempSol.type  = 'nb';

end
