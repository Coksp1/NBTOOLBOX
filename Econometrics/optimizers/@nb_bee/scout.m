function obj = scout(obj,lowerBound,upperBound,hasConstraints)
% Syntax:
%
% obj = scout(obj,lowerBound,upperBound,hasConstraints)
%
% Description:
%
% Employ scouts to new dancing areas.
% 
% See https://en.wikipedia.org/wiki/Artificial_bee_colony_algorithm
% for how the bees are scouting.
%
% Input:
% 
% - obj            : A vector of nb_bee objects.
% 
% - lowerBound     : See the property with the same name in the nb_abc
%                    class.
%
% - upperBound     : See the property with the same name in the nb_abc
%                    class. 
% 
% - hasConstraints : See the property with the same name in the nb_abc
%                    class.
%
% Output:
% 
% - obj        : A vector of nb_bee objects.
%
% See also:
% nb_bee.relocate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nBees = size(obj,1);
    if nBees == 0
        return
    end
    numPar = size(lowerBound,1);
    tested = nb_bee.drawCandidates(lowerBound,upperBound,numPar,nBees);

    % Assing back to the bees
    currentFeasibleDefault = ~hasConstraints;
    for ii = 1:nBees
        % We do this to make the scout accept the move later on
        obj(ii).currentFeasible  = currentFeasibleDefault; 
        obj(ii).currentValue     = inf; 
        obj(ii).currentViolation = inf;
        obj(ii).tested           = tested(:,ii);
        obj(ii).trials           = 0;
    end
    
end
