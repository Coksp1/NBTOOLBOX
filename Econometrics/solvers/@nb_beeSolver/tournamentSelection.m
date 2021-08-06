function ret = tournamentSelection(obj,currentLeader)
% Syntax:
%
% ret = tournamentSelection(obj,currentLeader)
%
% Description:
%
% Play out pairwise tournament between two bees.
%
% Input:
% 
% - obj           : The tested bee.
%
% - currentLeader : The bee that is currently the best.
% 
% Output:
% 
% - ret           : If true is returned tested be should be made the new
%                   leader.
%
% See also:
% nb_beeSolver.updateLocation
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if obj.testedValue < currentLeader.currentValue
        ret = true;
    else
        ret = false;
    end

end
