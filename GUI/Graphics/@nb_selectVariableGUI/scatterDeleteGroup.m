function scatterDeleteGroup(gui,~,~)
% Syntax:
%
% scatterDeleteGroup(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function for deleting a scatter group    
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the scatter groupes
    plotterT = gui.plotter;
    
    if strcmpi(gui.scatterSide,'left')
        if isa(plotterT,'nb_graph_ts')
            scaGroups = plotterT.scatterDates;
            property  = 'scatterDates';
        elseif isa(plotterT,'nb_graph_data')
            scaGroups = plotterT.scatterObs;
            property  = 'scatterObs';
        else
            scaGroups = plotterT.scatterVariables;
            property  = 'scatterVariables';
        end
    else
        if isa(plotterT,'nb_graph_ts')
            scaGroups = plotterT.scatterDatesRight;
            property  = 'scatterDatesRight';
        elseif isa(plotterT,'nb_graph_data')
            scaGroups = plotterT.scatterObsRight;
            property  = 'scatterObsRight';
        else
            scaGroups = plotterT.scatterVariablesRight;
            property  = 'scatterVariablesRight';
        end
    end
    
    if isempty(scaGroups)
        return
    end

    % Get the scatter group selected
    string = get(gui.popupmenu1,'string');
    index  = get(gui.popupmenu1,'value');
    group  = string{index};

    % Find the scatter group to delete
    ind       = find(strcmp(group,scaGroups),1);
    scaGroups = [scaGroups(1:ind-1),scaGroups(ind+2:end)];

    % Update the graph object
    plotterT.set(property, scaGroups);

    if isa(plotterT,'nb_graph_ts')
        if strcmpi(gui.scatterSide,'left')
            property2 = 'scatterVariables';
        else
            property2 = 'scatterVariablesRight';
        end  
        plotterT.(property2) = [plotterT.(property2)(1:ind-1),plotterT.(property2)(ind+1:end)];
    end
    
    % Switch the scatter group of interest
    if isempty(scaGroups)
        delete(gui.uip)
        set(gui.popupmenu1,'string',{' '},'value',1);
        notify(gui,'changedGraph')
    else
        set(gui.popupmenu1,'string',scaGroups(1:2:end),'value',1);
        scatterPanel(gui);
    end

end
