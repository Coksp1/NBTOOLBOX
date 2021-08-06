function obj = dance(obj,lowerBound,upperBound)
% Syntax:
%
% obj = dance(obj,lowerBound,upperBound) 
%
% Description:
%
% Make the employed bees move at random in their dancing area.
% 
% See https://en.wikipedia.org/wiki/Artificial_bee_colony_algorithm
% for how the employed bees are dancing.
%
% Input:
% 
% - obj        : A vector of nb_bee objects.
% 
% - lowerBound : See the property with the same name in the nb_abc
%                class.
%
% - upperBound : See the property with the same name in the nb_abc
%                class.
%
% Output:
% 
% - obj : A vector of nb_bee objects.
%
% See also:
% nb_bee.relocate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nBees  = size(obj,1);
    if nBees == 0
        return
    end
    nPar = size(obj(1).current,1);
    for ii = 1:nBees
        change = floor(rand*nPar) + 1; % Select parameter to change at random
        jj     = ii;
        while jj == ii % Select another bee at random
            jj = floor(rand*nBees) + 1; 
        end
        newDraw         = obj(ii).current;
        newDraw(change) = inf;
        while newDraw(change) > upperBound(change) || newDraw(change) < lowerBound(change)
            phi             = -1 + rand*2; % Select random numbers in [-1,1]
            newDraw(change) = obj(ii).current(change) + phi*(obj(ii).current(change) - obj(jj).current(change));
        end
        obj(ii).tested  = newDraw;
        obj(ii).trials  = obj(ii).trials + 1;
    end
     
end
