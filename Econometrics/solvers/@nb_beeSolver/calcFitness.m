function obj = calcFitness(obj,fitnessFunc,fitnessScale,fMin)
% Syntax:
%
% obj = calcFitness(obj,fitnessFunc,fitnessScale,fMin)
%
% Description:
%
% Calculate fitness score at the current best value of each employed bee. 
% 
% Input:
% 
% - obj          : A vector of nb_beeSolver objects.
% 
% - fitnessFunc  : See the property with the same name in the nb_abcSolve
%                  class.
%
% - fitnessScale : See the property with the same name in the nb_abcSolve
%                  class.
%
% - fMin         : The smallest function evaluation found up until now.
%
% Output:
% 
% - obj          : A vector of nb_beeSolver objects.
%
% See also:
% nb_abcSolve.doSolving
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    ind   = strcmpi({obj.type},'employed');
    emp   = obj(ind);
    nBees = size(emp,1);
    fit   = fitnessFunc([emp.currentValue],fMin,fitnessScale);
    for ii = 1:nBees
        emp(ii).fitness = fit(ii);
    end
    obj(ind) = emp;
    
end
