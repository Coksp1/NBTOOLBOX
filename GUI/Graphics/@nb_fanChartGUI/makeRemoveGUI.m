function makeRemoveGUI(gui)
% Syntax:
%
% makeRemoveGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    parent = gui.plotter.parent;
    if isa(parent,'nb_GUI')
        name = [parent.guiName ': Remove Fan Chart'];
    else
        name = 'Remove Fan Chart';
    end

    nb_confirmWindow('Are you sure you want to delete the fan chart?',@notRemove,{@removeFanChart,gui},name)
 
end

function removeFanChart(hObject,~,gui)
        
    plotterT              = gui.plotter;
    plotterT.fanVariables = {};
    plotterT.fanDatasets  = {};
    plotterT.fanVariable  = '';
    plotterT.fanLegend    = 0;
    plotterT.defaultFans  = '';

    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');
    
    % Close question window
    close(get(hObject,'parent'));

end

function notRemove(hObject,~)

    % Close question window
    close(get(hObject,'parent'));

end
