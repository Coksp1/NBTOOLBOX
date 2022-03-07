function setNoLegend(gui,hObject,~)
% Syntax:
%
% setPosition1(gui,hObject,event)
%
% Description:
%
% Part of DAG. 
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Assign graph object
    gui.plotter.noLegend = nb_getUIControlValue(hObject);
    
    % Notify listeners
    notify(gui,'changedGraph');

end
