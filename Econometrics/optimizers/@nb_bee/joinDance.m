function obj = joinDance(obj,employed,lowerBound,upperBound,hasConstraints)
% Syntax:
%
% obj = joinDance(obj,employed,lowerBound,upperBound,hasConstraints) 
%
% Description:
%
% Make the onlooker bees find a employed bee to dance with.
% 
% See https://en.wikipedia.org/wiki/Artificial_bee_colony_algorithm
% for how the onlokker bees are dancing.
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
% - obj : A vector of nb_bee objects.
%
% See also:
% nb_bee.relocate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nEmployed = size(employed,1);
    if any(nEmployed == [0,1])
        % Currently no employed bees, so we let the onlooker bees scout 
        % for new source, and therefore compete with the employed bees
        % after they also have found a new source
        obj = scout(obj,lowerBound,upperBound);
        return
    end

    % Find the employed bee to dance with. Here we assign higher
    % probability for the onlookers to go to the employed bees that are
    % performing the best
    nBees    = size(obj,1);
    prob     = calculateProbabilities(employed,hasConstraints);
    empDraw  = rand(nBees,1);
    for ii = 1:nBees        
        obj(ii).index = find(empDraw(ii)<prob,1);        
    end
    
    % Then we let the onlooker bees dance in the area they have been placed
    nPar = size(employed(1).current,1);
    for ii = 1:nBees
        change = floor(rand*nPar) + 1; % Select parameter to change at random
        jj     = obj(ii).index;
        while jj == obj(ii).index % Select another employed bee at random
            jj = floor(rand*nEmployed) + 1; 
        end
        current         = employed(obj(ii).index).current; % Get the parameter values of the employed bee that the onlooker matched with
        newDraw         = current;
        newDraw(change) = inf;
        while newDraw(change) > upperBound(change) || newDraw(change) < lowerBound(change)
            phi             = -1 + rand*2; % Select random numbers in [-1,1]
            newDraw(change) = current(change) + phi*(current(change) - employed(jj).current(change));
        end
        obj(ii).tested = newDraw;
    end
     
end
