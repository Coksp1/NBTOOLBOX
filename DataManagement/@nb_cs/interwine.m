function obj = interwine(obj, obj2, postfix2, varargin)
% Syntax:
%
% obj = interwine(obj, cs2, '_emp', cs3, '_sim')
%
% Description:
%
% Intertwine the current object with nb_cs objects of equal types and
% variables, adding postfixes to the type names of the intertwined objects.
% 
% Caution: This method will break the link to the data source.
%
% Input:
% 
% - obj      : A nb_cs object
% 
% - obj2     : A nb_cs object
%
% - postfix2 : The postfix to add to the type names of obj2
%
% - varargin : Supply more objects and postfixes (obj3, postfix3, ...)
% 
% Output:
% 
% - obj : An object of class nb_cs
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj = breakLink(obj);

    originalTypes     = obj.types;
    originalVariables = obj.variables;    
    newTypes          = obj.types;
    
    objects   = [{obj2}, varargin(1:2:end)];
    postfixes = [postfix2, varargin(2:2:end)];   
    assert(length(objects) == length(postfixes), ...
        'All objects must be given a postfix');
    
    for i = 1:length(objects)
        
       object = breakLink(objects{i});
       postfix = postfixes{i};
       
       assert(all(ismember(originalTypes, object.types)), ...
           'Types must be equal');
       assert(all(ismember(originalVariables, object.variables)), ...
           'Variable names must be equal');
       
       object   = sortTypes(object, originalTypes);       
       object   = addPostfix(object, postfix, [], 'types');
       newTypes = [newTypes; object.types];        %#ok<AGROW>
       obj      = merge(obj, object);
       
    end
    
    typeOrder = newTypes(:)';
    obj       = sortTypes(obj, typeOrder);
    
end
