function nb_setDefinedColor(~,~,gui,varargin)
% Syntax:
%
% nb_defineColor(hObject,event,gui,popupmenu)
%
% Description:
%
% Make the user able to define a color and add it to the popupmenu
% handle.
% 
% Input:
% 
% - hObject   : The MATLAB handle triggering the event
%
% - event     : The event structure.
%
% - gui       : An object with the property plotter, which must be
%               an nb_graph object, and the defaultColors
%               property.
%
% - varargin  : Handle to the popupmenu handle to assign the 
%               defined color. Can be given more handles as 
%               seperate inputs
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    try
        parent        = gui.plotter.parent;
        defaultColors = gui.defaultColors;
    catch %#ok<CTCH>
        error([mfilename ':: Wrong input given to the gui input to this function.'])
    end

    % Let the user select a color
    h     = nb_defineColor();
    color = h.getColor();
    
    % Assign it to the default colors
    if isa(parent,'nb_GUI')
        endc = parent.settings.defaultColors;
    else
        endc = defaultColors;
    end
    if isnumeric(endc)
        endc = nb_num2cell(endc);
    end
    ret = nb_findColor(color,endc);
    if ret
        return
    end
    endc = [endc; {color}];
    
    if isa(parent,'nb_GUI')
        parent.settings.defaultColors = endc;
    else
        gui.defaultColors = endc;
    end
    
    % Get the html code for the given color
    color = nb_selectVariableGUI.htmlColors(color);
    
    % Assign the color to the popupmenus
    for ii = 1:size(varargin,2) 
        colors = get(varargin{ii},'string');
        colors = [colors;color]; %#ok
        set(varargin{ii},'string',colors);
    end

end
