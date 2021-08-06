function setXAxisTickStartDate(gui,hObject,~)
% Syntax:
%
% setXAxisTickStartDate(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotter = gui.plotter;
    string  = get(hObject,'string');
    
    if isa(plotter,'nb_graph_ts')
        freq = gui.plotter.xTickFrequency;
    else
        freq = [];
    end
    [newValue,message,obj] = nb_interpretDateObsTypeInputGUI(plotter,string,freq);
    
    if ~isempty(message)
        nb_errorWindow(message);
        return
    end
    
    if ~isempty(newValue)
    
        if isa(plotter,'nb_graph_ts')

            if obj < convert(plotter.startGraph,obj.frequency)
                nb_errorWindow(['The X-Axis Tick Start Date ''' obj.toString() ''' is before the start date of the graph (' plotter.startGraph.toString() '), which is not possible.']);
                return
            elseif obj > convert(plotter.endGraph,obj.frequency)
                nb_errorWindow(['The X-Axis Tick Start Date ''' obj.toString() ''' is after the end date of the graph (' plotter.endGraph.toString() '), which is not possible.']);
                return
            end

        else

            if obj < plotter.startGraph
                nb_errorWindow(['The X-Axis Tick Start Obs ''' string ''' is before the start obs of the graph (' int2str(plotter.startGraph) '), which is not possible.']);
                return
            elseif obj > plotter.endGraph
                nb_errorWindow(['The X-Axis Tick Start Obs ''' string ''' is after the end obs of the graph (' int2str(plotter.endGraph) '), which is not possible.']);
                return
            end

        end
    
    end
        
    plotter.set('xTickStart',newValue);
    
    % Udate the graph
    notify(gui,'changedGraph');

end
