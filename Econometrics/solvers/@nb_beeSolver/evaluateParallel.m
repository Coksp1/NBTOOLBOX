function obj = evaluateParallel(obj,F,meritFunction)
% Syntax:
%
% obj = evaluateParallel(obj,F,meritFunction)
%
% Description:
%
% Evaluate the bees at their tested locations.
%
% Input:
% 
% - obj           : A vector of nb_beeSolver objects.
% 
% - F             : See the property with the same name in the nb_abcSolve
%                   class.
% 
% - meritFunction : See the property with the same name in the nb_abcSolve
%                   class.
%
% Output:
% 
% - obj : A vector of nb_beeSolver objects.
%
% See also:
% nb_abcSolve.doSolving
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nBees  = size(obj,1);
    tested = [obj.tested];
    nPar   = size(tested,1);
    fVal   = nan(nPar,nBees);
    parfor ii = 1:nBees
        fVal(:,ii) = feval(F,tested(:,ii));
    end
    
    % To evaluate the merit function are not to expensive to do, so we
    % do not include it the parfor in the danger of to expensive overhead
    % time due to the use of a function handle.
    for ii = 1:nBees
        obj(ii).testedFValue    = fVal(:,ii);
        obj(ii).testedViolation = meritFunction(obj(ii).testedFValue);
    end
    
end
