function uih = uicontrol(obj,varargin)
% Syntax:
%
% uicontrol(obj,varargin)
%
% Description:
%
% Add a uicontrol object to a docked panel.
%
% Input:
%
% - obj      : A nb_dockedPanel object.
%
% - varargin : Optional inputs given to the MATLAB uicontrol
%              function.
%
%              Prohibited properties :
%
%              - 'position','units'
%
%              Extra properties :
%
%              - 'title' : Title placed on top of the listbox.
%
% Output:
%
% The wanted uicontrol added to the panel.
%
% Examples:
%
% h = nb_dockedPanel('titleStyle','radiobutton');
% uicontrol(h,'style','listbox',...
%             'title','Test');
% uicontrol(h,'style','listbox',...
%             'title','Test');
% uicontrol(h,'style','listbox',...
%             'title','Test');
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.numberOfChildren = obj.numberOfChildren + 1;
    obj.docked           = [obj.docked,false];

    % Parse the added properties
    %---------------------------
    title = '';
    ind   = find(strcmpi('title',varargin),1);
    if ~isempty(ind)
        title    = varargin{ind + 1};
        varargin = [varargin(1:ind-1),varargin(ind+2:end)];
    end
    obj.titles = [obj.titles, title];

    ind   = find(strcmpi('units',varargin),1);
    if ~isempty(ind)
        varargin = [varargin(1:ind-1),varargin(ind+2:end)];
        warning([mfilename ':: The units property will be set to normalized.'])
    end

    ind   = find(strcmpi('position',varargin),1);
    if ~isempty(ind)
        varargin = [varargin(1:ind-1),varargin(ind+2:end)];
        warning([mfilename ':: The position property will be overwritten.'])
    end

    % Create the wanted uicontrol object
    %-----------------------------------
    pos    = ones(1,4);
    pos(1) = obj.space;
    pos(2) = 0;
    pos(3) = 1 - obj.space*2;
    pos(4) = 1;
    uih = uicontrol(obj.panel,varargin{:},...
        'units',   'normalized',...
        'position', pos);

    % Add the title bar to the ui component
    %--------------------------------------
    if nb_isFigure(obj.parent)
        backgroundColor = get(obj.parent,'color');
    else
        backgroundColor = get(obj.parent,'backgroundColor');
    end

    oldUnits = get(uih,'units');
    set(uih,'units','characters');
    pos      = get(uih,'position');
    tPos     = [pos(1),pos(2)+pos(4),pos(3),1.25];
    set(uih,'units',oldUnits);
    uicontrol(obj.panel,...
        'backgroundColor',        backgroundColor,...
        'style',                  obj.titleStyle,...
        'units',                  'characters',...
        'position',               tPos,...
        'horizontalAlignment',    'left',...
        'string',                 title,...
        'callback',               {@obj.dockCompnent,obj.numberOfChildren});

    % Find the locations of all the ui components
    locateChildren(obj);

    % Trigger event
    notify(obj,'addedUIComponent');

end
