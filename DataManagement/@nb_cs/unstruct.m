function obj = unstruct(s)
% Syntax:
%
% obj = nb_cs.unstruct(s)
%
% Description:
%
% Reverse of the struct method.
% 
% Input:
% 
% - s   : See the s output of the struct method. 
% 
% Output:
% 
% - obj : An nb_cs object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj            = nb_cs();
    obj.data       = s.data;
    obj.dataNames  = s.dataNames;
    obj.types      = s.types;
    obj.userData   = s.userData;
    obj.variables  = s.variables;
    obj.links      = s.links;
    obj.updateable = s.updateable;

    if isfield(s,'localVariables')
        obj.localVariables = s.localVariables;
    end
    if isfield(s,'sorted')
        obj.sorted = s.sorted;
    end
end
