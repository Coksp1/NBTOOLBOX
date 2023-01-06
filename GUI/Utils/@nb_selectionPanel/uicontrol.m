function uih = uicontrol(obj,varargin)
% Syntax:
%
% uih = uicontrol(obj,varargin)
%
% Description:
%
% Add a list box to the right in the window/panel, which
% can be assign the string from the list to the left.
% 
% Add (>) and remove (<) buttons will also be added.
% 
% Input:
% 
% - obj      : An nb_selectionPanel object.
%
% - varargin : Optional inputs given to the MATLAB uicontrol 
%              function.
%
%              Prohibited properties : 
%
%              - 'style','position','units'
%
%              Extra properties :
%
%              - 'title'          : Title placed on top of the 
%                                   listbox.
% 
% Output:
% 
% The wanted uicontrol listbox added to the window/panel with
% an add and remove button attached.
%
% See also:
% nb_dockedPanel
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    ind   = find(strcmpi('style',varargin),1);
    if ~isempty(ind)
        varargin = [varargin(1:ind-1),varargin(ind+2:end)];
        warning([mfilename ':: The units property will be set to ''listbox''.'])
    end
    
    % Assign the add and remove buttons
    ab = uicontrol(...
        'units',       'normalized',...
        'position',    [0 0 0.0001 0.0001],...
        'parent',      obj.parent,...
        'style',       'pushbutton',...
        'string',      '>',...
        'callback',    {@obj.addString,obj.assignPanel.numberOfChildren + 1});
    obj.addButtons = [obj.addButtons,ab];
    
    rb = uicontrol(...
        'units',       'normalized',...
        'position',    [0 0 0.0001 0.0001],...
        'parent',      obj.parent,...
        'style',       'pushbutton',...
        'string',      '<',...
        'callback',    {@obj.removeString,obj.assignPanel.numberOfChildren + 1});
    obj.removeButtons = [obj.removeButtons,rb];
    
    % Create the listbox and add it to the right nb_dockedPanel
    % object. This will trigger an addedUIComponent event, and
    % then the buttons above will be get the correct positions
    uih = uicontrol(obj.assignPanel,'style','listbox',varargin{:});

end
