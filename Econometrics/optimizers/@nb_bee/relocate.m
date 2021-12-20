function obj = relocate(obj,lowerBound,upperBound,cutLimit,hasConstraints)
% Syntax:
%
% obj = relocate(obj,lowerBound,upperBound,cutLimit,hasConstraints)
%
% Description:
%
% Relocate the bees.
% 
% Input:
% 
% - obj             : A vector of nb_bee objects.
% 
% - lowerBound      : See the property with the same name in the nb_abc
%                     class.
%
% - upperBound      : See the property with the same name in the nb_abc
%                     class.
%
% - cutLimit        : See the property with the same name in the nb_abc
%                     class.
%
% - hasConstraints : See the property with the same name in the nb_abc
%                    class.
%
% Output:
% 
% - obj : A vector of nb_bee objects.
%
% See also:
% nb_abc.doMinimization
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [employed,onlookers,scouts] = separate(obj,cutLimit);
    
    employed  = dance(employed,lowerBound,upperBound);
    onlookers = joinDance(onlookers,employed,lowerBound,upperBound,hasConstraints);
    scouts    = scout(scouts,lowerBound,upperBound,hasConstraints);
    obj       = [employed;onlookers;scouts];
    
end
