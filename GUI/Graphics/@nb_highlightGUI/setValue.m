function setValue(gui,hObject,~,type)
% Syntax:
%
% setValue(gui,hObject,event,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    % Get selected color
    string = get(hObject,'string');
    
    % Get selected line object
    index = get(gui.popupmenu1,'value');
    if strcmpi(plotterT.plotType,'scatter')

        newValue = str2double(string);
        if isnan(newValue)
            nb_errorWindow('The x-axis value of the vertical line must be set to a number when plot type is set to scatter.')
            return
        end

    else
        
        [newValue,message] = nb_interpretDateObsTypeInputGUI(plotterT,string);
        if ~isempty(message)
            nb_errorWindow(message);
            return
        end

    end

    oldValue       = plotterT.highlight{index};
    oldValue{type} = newValue; 
    plotterT.highlight{index} = oldValue;  

    % Notify listeners
    notify(gui,'changedGraph');

end
