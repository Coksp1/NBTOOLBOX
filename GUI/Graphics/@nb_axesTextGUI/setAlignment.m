function setAlignment(gui,hObject,~)
% Syntax:
%
% setAlignment(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Get value selected
    value = nb_getUIControlValue(hObject);
    
    % Assign graph object
    plotterT = gui.plotter;
    if strcmpi(gui.type,'title')
        plotterT.titleAlignment = value;
    else
        plotterT.xLabelAlignment = value;
    end
    
    % Notify listeners
    notify(gui,'changedGraph');

end
