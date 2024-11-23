function obj = set(obj, varargin)
% Syntax:
%
% obj = set(obj,varargin)
%
% Description:
%
% Sets the properties of the nb_model_selection_group objects. 
% 
% Input:
% 
% - obj : A vector of nb_model_selection_group objects.
%
% Optional input:
%
% If number of inputs equals 1:
% 
% - varargin{1} : A structure of fields to be set.
%
% Else:
%
% - varargin    : ...,'inputName',inputValue,... arguments.
%
%                 Where you can set all fields of some properties
%                 of the object.
%
% Output:
%
% - obj : A vector of nb_model_selection_group objects.
%
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nobj = numel(obj);
    if nobj > 1
        obj = nb_callMethod(obj,@set,'nb_model_selection_group',varargin{:});
        return
    end

    if isscalar(varargin) && isstruct(varargin{1})
        varargin = nb_struct2cellarray(varargin{1});
    end

    for j = 2:2:length(varargin)
        
        key   = varargin{j - 1};
        value = varargin{j};
        if isprop(obj, key)
            obj.(key) = value;
        elseif strcmpi(key,'data')
            obj.dataOrig = value;
        elseif isfield(obj.options, key) || strcmp(key, 'shift')
            obj.options.(key) = value;
        else
            warning(['No appropriate property or option ' key]);
        end
        
    end
    
end
