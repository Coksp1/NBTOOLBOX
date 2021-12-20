function translateOptimization(exitflag)
% Syntax:
%
% nb_mlEstimator.translateOptimization(exitflag)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch exitflag
        case 0
            error('Too many function evaluations or iterations.')
        case -1
            error('Stopped by output/plot function.')
        case -2
            error('No feasible point found.')
        case -3
            error('Problem seems unbounded.')
        otherwise
            % do nothing
    end
    
end
