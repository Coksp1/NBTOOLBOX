function setAxesFontSizeX(gui,hObject,~)
% Syntax:
%
% setAxesFontSizeX(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get value selected
    string = get(hObject,'string');
    if isempty(string)
        value = [];
    else
        value = str2double(string);
    end
    
    if isnan(value)
        nb_errorWindow('The font size of the axes must be a number between 0 and 1.')
        return
    elseif value < 0 || value > 1
        nb_errorWindow('The font size of the axes must be a number between 0 and 1.')
        return
    end
    
    % Assign graph object
    gui.plotter.axesFontSizeX = value;
    
    % Udate the graph
    notify(gui,'changedGraph');
    
end
