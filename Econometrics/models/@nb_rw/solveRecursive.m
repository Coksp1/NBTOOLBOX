function tempSol = solveRecursive(results,opt)
% Syntax:
%
% tempSol = nb_rw.solveRecursive(results,opt)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    tempSol       = nb_rw.solveRW(results,opt);
    tempSol.class = 'nb_rw';
    tempSol.type  = 'nb';

end
