function sol = correctSolutionDuringRT(obj,sol,estOptions)
% Syntax:
%
% sol = correctSolutionDuringRT(obj,sol,estOptions)
%
% See also:
% nb_model_vintages.forecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Here we must correct the solution of the model due to regressor may
    % change over time, as the observables may lead one period.
    if obj.options.unbalanced
        sol.factorsRHS = estOptions.factorsRHS;
        nExo           = length(sol.exo) - length(sol.factorsRHS);
        sol.exo        = [sol.exo(1:nExo), sol.factorsRHS];
    end
    
end
