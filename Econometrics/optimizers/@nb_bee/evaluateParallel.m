function obj = evaluateParallel(obj,objective,constrFunc)
% Syntax:
%
% obj = evaluateParallel(obj,objective,constrFunc)
%
% Description:
%
% Evaluate the bees at their tested locations.
%
% Input:
% 
% - obj        : A vector of nb_bee objects.
% 
% - objective  : See the property with the same name in the nb_abc
%                class.
% 
% - constrFunc : See the output from nb_abc.getConstraints.
% 
% Output:
% 
% - obj : A vector of nb_bee objects.
%
% See also:
% nb_abc.doMinimization
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    nBees  = size(obj,1);
    tested = [obj.tested];
    fVal   = nan(nBees,1);
    parfor ii = 1:nBees
        fVal(ii) = feval(objective,tested(:,ii));
    end
    for ii = 1:nBees
       obj(ii).testedValue = fVal(ii);
    end
    
    % To evaluate the constraints are not to expensive to do, so we
    % do not include it the parfor in the danger of to expensive overhead
    % time due to the use of a function handle.
    if ~isempty(constrFunc)
        for ii = 1:size(obj,1)
            obj(ii).testedViolation = constrFunc(obj(ii).tested);
            obj(ii).testedFeasible  = all(obj(ii).testedViolation <= 0);
        end
    end
    
end
