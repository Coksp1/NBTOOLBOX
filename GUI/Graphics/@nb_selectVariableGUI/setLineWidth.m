function setLineWidth(gui,hObject,~)
% Syntax:
%
% setLineWidth(gui,hObject,event)
%
% Description:
%
% Part of DAG. Sets the line width of the selected variable  
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    % Get selected variable
    string  = get(gui.popupmenu1,'string');
    index   = get(gui.popupmenu1,'value');
    var     = string{index};

    % Get selected line width
    lineW = get(hObject,'string');
    lineW = str2double(lineW);
    if isnan(lineW)
        nb_errorWindow('The provided line width must be a number.')
        return
    elseif lineW <= 0
        nb_errorWindow(['The line width must be set to a number greater than 0. Is ', num2str(lineW),'.'])
        return    
    end

    % Update the graph object
    ind  = find(strcmp(var,plotterT.lineWidths),1,'last');   
    if isempty(ind)
        if ~isequal(lineW,plotterT.lineWidth)
            plotterT.lineWidths = [plotterT.lineWidths,var,lineW];
        end
    else
        plotterT.lineWidths{ind + 1} = lineW;
    end
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end
