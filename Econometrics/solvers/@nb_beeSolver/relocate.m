function obj = relocate(obj,lowerBound,upperBound,cutLimit,local,F,...
                  jacobianFunction,tolerance,newtonStop,minXValue,...
                  minFunctionValue,minFFunctionValue)
% Syntax:
%
% obj = relocate(obj,lowerBound,upperBound,cutLimit,local,...
%           F,jacobianFunction,tolerance,newtonStop,minXValue,...
%           minFunctionValue,minFFunctionValue)
%
% Description:
%
% Relocate the bees.
% 
% Input:
% 
% - obj : A vector of nb_beeSolver objects.
% 
% - Otherwise see the properties with the same names in the nb_abcSolve 
%   class.
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

    [employed,onlookers,scouts] = separate(obj,cutLimit,tolerance,newtonStop);
    
    [employed,newScouts] = dance(employed,lowerBound,upperBound,F,jacobianFunction);
    scouts               = [scouts;newScouts];
    onlookers            = joinDance(onlookers,employed,lowerBound,upperBound,local);
    if local
        % If we are interested in a local solution we go join the nectar
        % of the best dancer of all time
        scouts = joinBestDancer(scouts,minXValue,minFunctionValue,minFFunctionValue);
    else
        scouts = scout(scouts,lowerBound,upperBound);
    end
    obj = [employed;onlookers;scouts];
    
end
