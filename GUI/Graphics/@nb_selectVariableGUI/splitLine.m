function splitLine(gui,hObject,~)
% Syntax:
%
% splitLine(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function called when the split radiobutton is
% checked
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    % Get selected variable
    string  = get(gui.popupmenu1,'string');
    index   = get(gui.popupmenu1,'value');
    var     = string{index};

    % Get side
    selected = get(gui.buttonGroup,'selectedObject');
    side     = get(selected,'string');

    plotterT.setSpecial('returnLocal',1);
    lineStyles = plotterT.lineStyles;
    plotterT.setSpecial('returnLocal',0);
    if get(hObject,'value')

        set(gui.popupmenu5,'enable','on');
        set(gui.editbox1,'enable','on');
        set(gui.popupmenu11,'enable','on');

        % Get the split date and line style from the
        % different handles
        string = get(gui.popupmenu5,'string');
        index  = get(gui.popupmenu5,'value');
        lineS  = string{index};
        
        % Get the split date/obs
        string                 = get(gui.editbox1,'string');
        [newValue,message,obj] = nb_interpretDateObsTypeInputGUI(plotterT,string);

        % Test input
        err = 0;
        if ~isempty(message)
            message  = char(message,'');
            message  = char(message,'Default value will be used');
            nb_errorWindow(message);
            err = 1;
        end
        
        if isa(plotterT,'nb_graph_ts')
            if obj > plotterT.endGraph
                nb_errorWindow(['The line split date ''' obj.toString() ''' is after the end date of the graph (' plotterT.endGraph.toString() '), '...
                    'which is not possible. Default value will be used']);
                err = 1;
            elseif obj < plotterT.startGraph
                nb_errorWindow(['The line split date ''' obj.toString() ''' is before the start date of the graph (' plotterT.startGraph.toString() '), '...
                    'which is not possible. Default value will be used']);
                err = 1;
            end
        else
            if obj > plotterT.endGraph
                nb_errorWindow(['The line split obs ''' num2str(obj) ''' is after the end obs of the graph (' num2str(plotterT.endGraph) '), '...
                    'which is not possible. Default value will be used']);
                err = 1;
            elseif obj < plotterT.startGraph
                nb_errorWindow(['The line split obs ''' num2str(obj) ''' is before the start obs of the graph (' num2str(plotterT.startGraph) '), '...
                    'which is not possible. Default value will be used']);
                err = 1;
            end
        end

        if err
            newValue = plotterT.endGraph;
            if isa(newValue,'nb_date')
                newValue = toString(newValue);
            end
            set(gui.editbox1,'string',toString(newValue));
        end
        
        % Set the linsStyle property of the graph object
        ind                 = find(strcmp(var,lineStyles),1,'last'); 
        lineStyle           = lineStyles{ind + 1};
        lineStyles{ind + 1} = {lineStyle,newValue,lineS};
        plotterT.lineStyles = lineStyles;

    else

        set(gui.popupmenu5,'enable','off');
        set(gui.editbox1,'enable','off');
        set(gui.popupmenu11,'enable','off');

        % Set the linsStyle property of the graph object
        ind                 = find(strcmp(var,lineStyles),1,'last');
        lineStyle           = lineStyles{ind + 1};
        lineStyles{ind + 1} = lineStyle{1};
        plotterT.lineStyles = lineStyles;

    end

    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end
