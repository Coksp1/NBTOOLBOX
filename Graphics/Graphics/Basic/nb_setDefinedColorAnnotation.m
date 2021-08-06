function nb_setDefinedColorAnnotation(~,~,gui,varargin)
% Syntax:
%
% nb_setDefinedColorAnnotation(hObject,event,gui,popupmenu)
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
% - gui       : An gui objects thats edit the nb_annotation 
%               objects. Must have a property defaultColors.
%
% - varargin  : Handle to the popupmenu handle to assign the 
%               defined color. Can be given more handles as 
%               seperate inputs
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    try
        defaultColors = gui.defaultColors;
    catch %#ok<CTCH>
        error([mfilename ':: Wrong input given to the gui input to this function.'])
    end

    % Let the user select a color
    h     = nb_defineColor();
    color = h.getColor();
    
    % Assign it to the default colors
    endc = defaultColors;
    ret  = ismember(color,endc,'rows');
    if ret
        return
    end
    endc              = [endc; color];
    gui.defaultColors = endc;
    
    % Get the html code for the given color
    color = nb_htmlColors(color);
    
    % Assign the color to the popupmenus
    for ii = 1:size(varargin,2) 
        colors = get(varargin{ii},'string');
        colors = [colors;color]; %#ok
        set(varargin{ii},'string',colors);
    end

end
