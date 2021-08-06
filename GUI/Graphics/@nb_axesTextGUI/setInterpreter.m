function setInterpreter(gui,hObject,~)
% Syntax:
%
% setInterpreter(gui,hObject,event)
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
    switch lower(gui.type)
        case 'title'
            plotterT.titleInterpreter = value;
        case 'xlabel'
            plotterT.xLabelInterpreter = value;
        case 'ylabel'
            plotterT.yLabelInterpreter = value;
        otherwise
            plotterT.yLabelInterpreter = value;
    end
    
    % Notify listeners
    notify(gui,'changedGraph');

end
