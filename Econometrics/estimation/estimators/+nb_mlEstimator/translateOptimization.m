function translateOptimization(exitflag)
% Syntax:
%
% nb_mlEstimator.translateOptimization(exitflag)
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

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
