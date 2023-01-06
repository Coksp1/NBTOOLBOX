function add2Colors(gui,color)
% Syntax:
%
% add2Colors(gui,color)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Assign it to the default colors
    ret = ismember(color,gui.colors,'rows');
    if ret
        return
    end
    gui.colors = [gui.colors; color];
    if isa(gui.parent,'nb_GUI')
        gui.parent.settings.defaultColors = gui.colors;
    end
    
    % Get the html code for the given color
    colorsAsChar = nb_selectVariableGUI.htmlColors(gui.colors);
    
    % Set ui controls
    set(gui.components.color1,'string',colorsAsChar);
    set(gui.components.color2,'string',colorsAsChar);

end
