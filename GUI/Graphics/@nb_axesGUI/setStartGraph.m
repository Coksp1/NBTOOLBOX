function setStartGraph(gui,hObject,~)
% Syntax:
%
% setStartGraph(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    plotter = gui.plotter;
    string  = get(hObject,'string');
    
    [newValue,message,obj] = nb_interpretDateObsTypeInputGUI(plotter,string);
    
    if ~isempty(message)
        nb_errorWindow(message);
        return
    end
    
    if isa(plotter,'nb_graph_ts')
        
        if obj > plotter.DB.endDate
            nb_errorWindow(['The graph start date ''' obj.toString() ''' is after the end date of the data (' plotter.DB.endDate.toString() '), which is not possible.']);
            return
        elseif obj > plotter.endGraph
            nb_errorWindow(['The graph start date ''' obj.toString() ''' is after the end date of the graph (' plotter.endGraph.toString() '), which is not possible.']);
            return
        end
        
    else % nb_graph_data
        
        if obj > plotter.DB.endObs
            nb_errorWindow(['The graph start obs ' string ' is after the end obs of the data (' int2str(plotter.DB.endObs) '), which is not possible.']);
            return
        elseif obj > plotter.endGraph
            nb_errorWindow(['The graph start obs ' string ' is after the end obs of the graph (' int2str(plotter.endGraph) '), which is not possible.']);
            return
        end
        
    end
    
    % Plot
    plotter.set('startGraph',newValue);
    
    % Udate the graph
    notify(gui,'changedGraph');

end
