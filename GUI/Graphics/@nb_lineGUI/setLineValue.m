function setLineValue(gui,hObject,~,type)
% Syntax:
%
% setLineValue(gui,hObject,event,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 1;
    end

    plotterT = gui.plotter;

    % Get selected color
    string    = get(hObject,'string');
    
    % Get selected line object
    index = get(gui.popupmenu1,'value');
    
    if strcmpi(gui.type,'horizontal')
        
        newValue = str2double(string);
        if isnan(newValue)
            nb_errorWindow('The y-axis value of the horizontal line must be set to a number.')
            return
        end
        plotterT.horizontalLine(index) = newValue;
        
    elseif strcmpi(gui.type,'vertical')
        
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
        
        oldValue = plotterT.verticalLine{index};
        if iscell(oldValue)
            oldValue{type} = newValue; 
            newValue       = oldValue;
        end
        plotterT.verticalLine{index} = newValue;  
        
    else
        % Update here???????
    end

    % Notify listeners
    notify(gui,'changedGraph');

end
