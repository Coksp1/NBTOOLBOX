function changeSplitDate(gui,hObject,~)
% Syntax:
%
% changeSplitDate(gui,hObject,event)
%
% Description:
%
% Part of DAG. Change the date for splitting the line style
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    % Get selected variable
    string  = get(gui.popupmenu1,'string');
    index   = get(gui.popupmenu1,'value');
    var     = string{index};

    % Get the interpreted input
    string                 = get(hObject,'string');
    [newValue,message,obj] = nb_interpretDateObsTypeInputGUI(plotterT,string);
    
    if ~isempty(message)
        nb_errorWindow(message);
        return
    end
    
    % Test input
    if isa(plotterT,'nb_graph_ts')
        if obj > plotterT.endGraph
            nb_errorWindow(['The line split date ''' obj.toString() ''' is after the end date of the graph (' plotterT.endGraph.toString() '), which is not possible.']);
            return
        elseif obj < plotterT.startGraph
            nb_errorWindow(['The line split date ''' obj.toString() ''' is before the start date of the graph (' plotterT.startGraph.toString() '), which is not possible.']);
            return
        end
    else
        if obj > plotterT.endGraph
            nb_errorWindow(['The line split obs ''' num2str(obj) ''' is after the end obs of the graph (' num2str(plotterT.endGraph) '), which is not possible.']);
            return
        elseif obj < plotterT.startGraph
            nb_errorWindow(['The line split obs ''' num2str(obj) ''' is before the start obs of the graph (' num2str(plotterT.startGraph) '), which is not possible.']);
            return
        end
    end

    % Update the graph object
    plotterT.setSpecial('returnLocal',1);
    lineStyles = plotterT.lineStyles;
    plotterT.setSpecial('returnLocal',0);
    ind                 = find(strcmp(var,lineStyles),1,'last'); 
    lineStyle           = lineStyles{ind + 1};
    lineStyle{2}        = newValue;
    lineStyles{ind + 1} = lineStyle;
    plotterT.lineStyles = lineStyles;
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');
    
end
