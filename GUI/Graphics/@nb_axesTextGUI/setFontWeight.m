function setFontWeight(gui,hObject,~)
% Syntax:
%
% setFontWeight(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the value selected
    afw = nb_getUIControlValue(hObject);

    % Set the plotter object
    switch lower(gui.type)
        case 'title'
            gui.plotter.titleFontWeight = afw;
        case 'xlabel'
            gui.plotter.xLabelFontWeight = afw;
        case 'ylabel'
            gui.plotter.yLabelFontWeight = afw;
        otherwise
            gui.plotter.yLabelFontWeight = afw;
    end
    
    % Notify listeners
    notify(gui,'changedGraph');

end
