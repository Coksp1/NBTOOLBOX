function obj = evaluate(obj,objective,constrFunc)
% Syntax:
%
% obj = evaluate(obj,objective,constrFunc)
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

    if isempty(constrFunc)
        for ii = 1:size(obj,1)
            obj(ii).testedValue = objective(obj(ii).tested);
        end
    else
        for ii = 1:size(obj,1)
            obj(ii).testedValue     = objective(obj(ii).tested);
            obj(ii).testedViolation = constrFunc(obj(ii).tested);
            obj(ii).testedFeasible  = all(obj(ii).testedViolation <= 0);
        end
    end

end
