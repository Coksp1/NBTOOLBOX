function obj = nb_copy(obj)
% Syntax:
%
% obj = nb_copy(obj)
%
% Description:
%
% Make copy of object. Works on both handle and value objects.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(obj, 'handle')
        obj = copy(obj);
    end
end
