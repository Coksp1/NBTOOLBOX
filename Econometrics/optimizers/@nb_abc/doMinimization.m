function doMinimization(obj)
% Syntax:
%
% doMinimization(obj)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
            
    % Create function handle that combines inequality and equality 
    % constraints in one.
    constrFunc           = getConstraints(obj);
    obj.timer            = tic();
    obj.timeOfLastUpdate = 0;
    obj.timeOfLastSave   = 0;
    while check(obj)

        obj.bees = relocate(obj.bees,obj.lowerBound,obj.upperBound,obj.cutLimit,obj.hasConstraints);
        if obj.useParallel
            obj.bees = evaluateParallel(obj.bees,obj.objective,constrFunc);
        else
            obj.bees = evaluate(obj.bees,obj.objective,constrFunc);
        end
        obj.funEvals   = obj.funEvals + obj.maxNodes;
        obj.iterations = obj.iterations + 1;
        obj.bees       = updateLocation(obj.bees);
        updateStatus(obj);
        obj.bees       = calcFitness(obj.bees,obj.fitnessFunc,obj.minFunctionValue,obj.fitnessScale);
        reportStatus(obj,'iter');

    end

    reportStatus(obj,'done');

end
