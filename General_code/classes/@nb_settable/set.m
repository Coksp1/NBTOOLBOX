function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of an object of class nb_settable. Give the 
% property name as a string. The input that follows should be the 
% value you want to assign to that property. 
%
% Multple properties could be set with one method call.
% 
% Input:
% 
% - obj      : An object of class nb_settable.
% 
% - varargin : Every odd input must be a string with the name of 
%              the property wanted to be set. Every even input must
%              be the value you want to set the given property to.
% 
% Output:
% 
% - obj      : The same object of class nb_settable with the given
%              properties reset.
% 
% Examples:
% 
% obj = obj.set('parent',figure);
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        obj = obj(:);
        for ii = 1:numel(obj)
            set(obj(ii),varargin);
        end
        return
    end

    if size(varargin,1) && iscell(varargin{1})
        varargin = varargin{1};
    end
    obj.doUpdate   = false;
    props          = properties(obj);
    inputProps     = nb_parseOptions(varargin{:});
    inputPropNames = fieldnames(inputProps);        
    for ii = 1:length(inputPropNames)
        check = inputPropNames{ii};
        value = inputProps.(check);
        ind   = strcmpi(check,props);
        if ~any(ind)
            error(['No public field ' check ' exists for class ' class(obj) '.']);
        end
        prop  = props{ind};
        if isprop(obj, prop)
            obj.(prop) = value;
        else
            error(['No public field ' check ' exists for class ' class(obj) '.']);
        end
    end 
    obj.doUpdate = true;
    obj.update();

end
