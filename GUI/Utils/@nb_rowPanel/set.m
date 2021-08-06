function set(obj,varargin)
% Syntax:
%
% set(obj,varargin)
%
% Description:
%
% Set the properties of the underlying uicontrol object. To set other
% settable properties use the obj.propertyName syntax.
%
% Input:
% 
% - obj : An object of class nb_rowPanel.
%
% Optional input:
%
% - varargin : Input name, input value pairs. See the uipanel class
%              for supported properties.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    props = properties(obj);
    ind   = true(size(varargin));
    for ii = 1:2:length(varargin)
        propertyName = varargin{ii};
        if any(strcmpi(propertyName,props))
            if size(varargin,2) < ii + 1
                error([mfilename ':: Options must come in pairs.'])
            end
            obj.(propertyName) = varargin{ii+1};
            ind(ii:ii+1)       = false;
        end
    end

    varargin = varargin(ind);
    if ~isempty(varargin)
        set(obj.panel,varargin{:});
    end

end
