function obj = unstruct(s)
% Syntax:
%
% obj = nb_bd.unstruct(s)
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
% - obj : An nb_bd object.
%
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj            = nb_bd();
    obj.data       = s.data;
    obj.dataNames  = s.dataNames;
    obj.frequency  = s.frequency;
    obj.startDate  = s.startDate;
    obj.locations  = s.locations;
    obj.indicator  = s.indicator;
    obj.ignorenan  = s.ignorenan;
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
