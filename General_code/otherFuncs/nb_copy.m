function obj = nb_copy(obj)
% Syntax:
%
% obj = nb_copy(obj)
%
% Description:
%
% Make copy of object. Works on both handle and value objects.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if isa(obj, 'handle')
        obj = copy(obj);
    end
end
