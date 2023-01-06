function solution = solveNormal(results,options)
% Syntax:
%
% solution = nb_manualModel.solveNormal(results,options)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(options.solveFunc)
        solution = struct();
    else
        solveFunc = str2func(options.solveFunc);
        solution  = solveFunc(results,options);
    end
    
    solution.class = 'nb_manualModel';
    solution.type  = 'nb';
    
end
