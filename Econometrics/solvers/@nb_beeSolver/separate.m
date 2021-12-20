function [employed,onlookers,scouts] = separate(obj,cutLimit,tolerance,newtonStop)
% Syntax:
%
% [employed,onlookers]        = separate(obj,cutLimit,tolerance,newtonStop)
% [employed,onlookers,scouts] = separate(obj,cutLimit,tolerance,newtonStop)
%
% Description:
%
% Separate the bees into employed, scouts and onlookers.
% 
% Input:
% 
% - obj       : A vector of nb_beeSolver objects.
%
% - cutLimit  : See the property with the same name in the nb_abcSolve
%               class. Only needed if nargout > 2.
% 
% Output:
% 
% - employed  : These are the employed bees that are keep dancing in their
%               current area if nargout == 3, else it is all the employed
%               bees. As a vector of nb_beeSolver objects.
%
% - onlookers : These are the bees that are joing the dance of the most
%               succesful employed bees. As a vector of nb_beeSolver 
%               objects.
%
% - scouts    : These are the employed bees that are going to scout for
%               a new dancing area. As a vector of nb_beeSolver objects.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        cutLimit = 20;
    end

    types     = {obj.type};
    ind       = strcmpi(types,'employed');
    onlookers = obj(~ind);
    employed  = obj(ind);
    if nargout > 2
        indScouts = [employed.trials] > cutLimit;
        scouts    = employed(indScouts);
        employed  = employed(~indScouts);
        if newtonStop && ~isempty(scouts)
            % In this case we stop the employed bees that uses newton
            % update if the solution they converged to is not a solution,
            % which may be an indication that a derivative based method
            % does not work to solve the problem
            ind = scouts.method == 2;
            if any(ind)
                newtonScouts                   = scouts(ind);
                stopInd                        = [newtonScouts.currentValue] > tolerance;
                [newtonScouts(stopInd).method] = deal(1); 
                scouts(ind)                    = newtonScouts;
            end
        end
    end
    
end
