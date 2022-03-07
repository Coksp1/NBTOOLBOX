function setEndGraph(gui,hObject,~)
% Syntax:
%
% setEndGraph(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotter = gui.plotter;
    string  = get(hObject,'string');
    
    [newValue,message,obj] = nb_interpretDateObsTypeInputGUI(plotter,string);
    
    if ~isempty(message)
        nb_errorWindow(message);
        return
    end
    
    if isa(plotter,'nb_graph_ts')
    
        if obj < plotter.DB.startDate
            nb_errorWindow(['The graphs end date ''' obj.toString() ''' is before the start date of the data (' plotter.DB.startDate.toString() '), which is not possible.']);
            return
        elseif obj < plotter.startGraph
            nb_errorWindow(['The graphs end date ''' obj.toString() ''' is before the start date of the graph (' plotter.startGraph.toString() '), which is not possible.']);
            return
        end
        
    else % nb_graph_data
        
        if obj < plotter.DB.startObs
            nb_errorWindow(['The graphs end obs ''' string ''' is before the start obs of the data (' int2str(plotter.DB.startObs) '), which is not possible.']);
            return
        elseif obj < plotter.startGraph
            nb_errorWindow(['The graphs end obs ''' string ''' is before the start obs of the graph (' int2str(plotter.startGraph) '), which is not possible.']);
            return
        end
        
    end
    
    % Plot
    plotter.set('endGraph',newValue);
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end
