function [employed,onlookers,scouts] = separate(obj,cutLimit)
% Syntax:
%
% [employed,onlookers]        = separate(obj,cutLimit)
% [employed,onlookers,scouts] = separate(obj,cutLimit)
%
% Description:
%
% Separate the bees into employed, scouts and onlookers.
% 
% Input:
% 
% - obj       : A vector of nb_bee objects.
%
% - cutLimit  : See the property with the same name in the nb_abc
%               class. Only needed if nargout > 2.
% 
% Output:
% 
% - employed  : These are the employed bees that are keep dancing in their
%               current area if nargout == 3, else it is all the employed
%               bees.
%
% - onlookers : These are the bees that are joing the dance of the most
%               succesful employed bees.
%
% - scouts    : These are the employed bees that are going to scout for
%               a new dancing area.
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
    end
    
end
