function setXAxisSpacing(gui,hObject,~)
% Syntax:
%
% setXAxisSpacing(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotter = gui.plotter;

    % Get the value selected
    strs = get(hObject,'string');
    if isempty(strs)
        sp = [];
    else
        
        if isa(plotter,'nb_graph_data')
            if strcmpi(plotter.plotType,'scatter') || ~isempty(plotter.variableToPlotX)
                sp = str2double(strs);
            else
                sp = round(str2double(strs));
            end
        else % nb_graph_ts or nb_graph_cs (only scatter plot)
            if strcmpi(plotter.plotType,'scatter')
                sp = str2double(strs);
            else
                sp = round(str2double(strs));
            end
        end
        
    end

    if numel(sp) > 1
        nb_errorWindow('The X-Axis Spacing must be a scalar number greater than 0.')
        return
    elseif isnan(sp) || sp == 0
        nb_errorWindow('The X-Axis Spacing must be a number greater than 0.')
        return
    end
    
    % Set the plotter object
    if isa(plotter,'nb_graph_cs')
        plotter.xSpacing = sp;
    else
        plotter.spacing = sp;
    end
    
    % Udate the graph
    notify(gui,'changedGraph');

end
