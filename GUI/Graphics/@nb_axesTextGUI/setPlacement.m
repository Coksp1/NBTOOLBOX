function setPlacement(gui,hObject,~)
% Syntax:
%
% setPlacement(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get value selected
    value = nb_getUIControlValue(hObject);
    
    % Assign graph object
    plotterT = gui.plotter;
    if strcmpi(gui.type,'title')
        plotterT.titlePlacement = value;
    else
        plotterT.xLabelPlacement = value;
    end
    
    % Notify listeners
    notify(gui,'changedGraph');

end
