function barShadingDateCallback(gui,hObject,~)
% Syntax:
%
% barShadingDateCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Change the date for shading the bars of a given variable  
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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
    
    % Remove from cell if given as empty
    
    
    if isempty(newValue)
       
        if isa(plotterT,'nb_graph_ts')
            
            plotterT.setSpecial('returnLocal',1);
            barShadingDate = plotterT.barShadingDate;
            plotterT.setSpecial('returnLocal',0);
            ind = find(strcmp(var,plotterT.barShadingDate),1,'last');
            if ~isempty(ind) % If there remove it
                plotterT.barShadingDate = [barShadingDate(1:ind-1),barShadingDate(ind+2:end)];
            end
            
        else % nb_graph_data
            
            plotterT.setSpecial('returnLocal',1);
            barShadingObs = plotterT.barShadingDate;
            plotterT.setSpecial('returnLocal',0);
            ind = find(strcmp(var,plotterT.barShadingObs),1,'last');
            if ~isempty(ind) % If there remove it
                plotterT.barShadingObs = [barShadingObs(1:ind-1),barShadingObs(ind+2:end)];
            end
            
        end
        
        % Notify listeners
        notify(gui,'changedGraph');
        return
        
    end
    
    % Test input
    if isa(plotterT,'nb_graph_ts')
        if obj > plotterT.endGraph
            nb_errorWindow(['The bar shading date ''' obj.toString() ''' is after the end date of the graph (' plotterT.endGraph.toString() '), which is not possible.']);
            return
        elseif obj < plotterT.startGraph
            nb_errorWindow(['The bar shading date ''' obj.toString() ''' is before the start date of the graph (' plotterT.startGraph.toString() '), which is not possible.']);
            return
        end
    else % nb_graph_data
        if obj > plotterT.endGraph
            nb_errorWindow(['The bar shading obs ''' num2str(obj) ''' is after the end obs of the graph (' num2str(plotterT.endGraph) '), which is not possible.']);
            return
        elseif obj < plotterT.startGraph
            nb_errorWindow(['The bar shading obs ''' num2str(obj) ''' is before the start obs of the graph (' num2str(plotterT.startGraph) '), which is not possible.']);
            return
        end
    end

    % Update the graph object
    if isa(plotterT,'nb_graph_ts')
        plotterT.setSpecial('returnLocal',1);
        barShadingDate = plotterT.barShadingDate;
        plotterT.setSpecial('returnLocal',0);
        ind = find(strcmp(var,plotterT.barShadingDate),1,'last'); 
        if isempty(ind)
            if isempty(plotterT.barShadingDate)
                plotterT.barShadingDate = {var,newValue};
            else
            	plotterT.barShadingDate = [barShadingDate,{var,newValue}];
            end
        else
            barShadingDate{ind + 1} = newValue;
            plotterT.barShadingDate = barShadingDate;
        end
    else % nb_graph_data
        plotterT.setSpecial('returnLocal',1);
        barShadingObs = plotterT.barShadingDate;
        plotterT.setSpecial('returnLocal',0);
        ind = find(strcmp(var,plotterT.barShadingObs),1,'last'); 
        if isempty(ind)
            if isempty(plotterT.barShadingObs)
                plotterT.barShadingObs = {var,newValue};
            else
                plotterT.barShadingObs = [barShadingObs,{var,newValue}];
            end
        else
            barShadingObs{ind + 1} = newValue;
            plotterT.barShadingObs = barShadingObs;
        end
    end
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');
    
end
