function ret = tournamentSelection(obj,currentLeader)
% Syntax:
%
% ret = tournamentSelection(obj,currentLeader)
%
% Description:
%
% Play out pairwise tournament between two bees.
%
% We use Deb's rules to select the best candidate:
% 1. Any feasible solution is preferred to any infeasible solution.
% 2. Among two feasible solutions, the one having better objective 
%    function value is preferred.
% 3. Among two infeasible solutions, the one having smaller constraint 
%    violation is preferred.
%
% Here a feasible solution does satisfies the constrains applied to the
% parameters, while a infeasible solution does not.
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
% nb_bee.updateLocation
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if obj.testedFeasible && currentLeader.currentFeasible
        % Both tested and current point is feasible, so we select the
        % one with the smallest objective
        if obj.testedValue < currentLeader.currentValue
            ret = true;
        else
            ret = false;
        end
    elseif obj.testedFeasible
        % Current point is infeasible, but the tested point is, so we
        % have a new leader
        ret = true;
    elseif currentLeader.currentFeasible
        % Tested point is infeasible, so we keep the leader
        ret = false;
    else
        % Both tested and current point is infeasible, so we select the
        % one with the smallest constraint violation
        if obj.testedViolation < currentLeader.currentViolation
            ret = true;
        else
            ret = false;
        end
    end

end
