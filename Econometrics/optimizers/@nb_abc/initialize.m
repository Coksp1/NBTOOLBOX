function initialize(obj)
% Syntax:
%
% initialize(obj)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
            
    % Initialize the bees. I.e. here all bees will be scouting
    % for a new location to feed
    constrFunc              = getConstraints(obj);
    obj.bees                = nb_bee(obj.maxNodes);
    numEmp                  = ceil(obj.employedShare*obj.maxNodes);
    [obj.bees(1:numEmp),fc] = initialize(obj.bees(1:numEmp),obj.objective,obj.lowerBound,...
                                         obj.upperBound,obj.objectiveLimit,obj.maxTrials,...
                                         constrFunc);
    obj.funEvals = fc;
    updateStatus(obj);
    obj.bees(1:numEmp) = calcFitness(obj.bees(1:numEmp),obj.fitnessFunc,obj.minFunctionValue,obj.fitnessScale);
    reportStatus(obj,'iter'); 

end
