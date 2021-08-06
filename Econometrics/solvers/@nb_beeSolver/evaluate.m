function obj = evaluate(obj,F,meritFunction)
% Syntax:
%
% obj = evaluate(obj,F,meritFunction)
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    for ii = 1:size(obj,1)
        obj(ii).testedFValue = F(obj(ii).tested);
        obj(ii).testedValue  = meritFunction(obj(ii).testedFValue);
    end

end
