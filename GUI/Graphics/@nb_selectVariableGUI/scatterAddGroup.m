function scatterAddGroup(gui,~,~)
% Syntax:
%
% scatterAddGroup(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function for adding a scatter group
% 
% Written by Kenneth Sæterhagen Paulsen   

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    if strcmpi(gui.scatterSide,'left')
        if isa(plotterT,'nb_graph_ts')
            scaGroups = plotterT.scatterDates(1:2:end);
            property  = 'scatterDates';
        elseif isa(plotterT,'nb_graph_data')
            scaGroups = plotterT.scatterObs(1:2:end); 
            property  = 'scatterObs';
        else
            scaGroups = plotterT.scatterVariables(1:2:end);
            property  = 'scatterVariables';
        end
    else
        if isa(plotterT,'nb_graph_ts')
            scaGroups = plotterT.scatterDatesRight(1:2:end);
            property  = 'scatterDatesRight';
        elseif isa(plotterT,'nb_graph_data')
            scaGroups = plotterT.scatterObsRight(1:2:end); 
            property  = 'scatterObsRight';
        else
            scaGroups = plotterT.scatterVariablesRight(1:2:end);
            property  = 'scatterVariablesRight';
        end
    end
    
    if isa(plotterT,'nb_graph_cs')
        if strcmpi(gui.scatterSide,'left')
            property2 = 'scatterTypes';
        else
            property2 = 'scatterTypesRight';
        end  
        if isempty(plotterT.(property2))
            if length(plotterT.DB.types) >= 2
                plotterT.(property2) = plotterT.DB.types(1:2);

            else
                nb_errorWindow('Not possible to add scatter group as the dataset has less than two types!')
                return
            end
        end
    else
        if strcmpi(gui.scatterSide,'left')
            property2 = 'scatterVariables';
        else
            property2 = 'scatterVariablesRight';
        end  
        if isempty(plotterT.(property2))
            if length(plotterT.DB.variables) >= 2
                plotterT.(property2) = {plotterT.DB.variables(1:2)};
            else
                nb_errorWindow('Not possible to add scatter group as the dataset has less than two variables!')
                return
            end
        else
            plotterT.(property2) = [plotterT.(property2),plotterT.(property2)(end)];
        end
    end
    
    if strcmpi(gui.scatterSide,'right')
        groupName = 'scatterGroupRight';
    else
        groupName = 'scatterGroup';
    end
    
    if isempty(scaGroups)
        groupName = [groupName,'1'];
        numGroups = 0;
    else

        numGroups = size(scaGroups,2);
        found = 1;
        kk    = 1;
        while found
            groupNameT = [groupName int2str(kk)];
            found      = ~isempty(find(strcmp(groupNameT,scaGroups),1));
            kk         = kk + 1;
        end
        groupName = groupNameT;

    end

    if isa(plotterT,'nb_graph_ts')
        newScaDates = [plotterT.(property),{groupName,{plotterT.DB.startDate.toString(),plotterT.DB.endDate.toString()}}];
        plotterT.set(property,newScaDates);
    elseif isa(plotterT,'nb_graph_data')
        newScaObs = [plotterT.(property),{groupName,{plotterT.DB.startObs,plotterT.DB.endObs}}];
        plotterT.set(property,newScaObs);
    else
        newScaVars = [plotterT.(property),{groupName,plotterT.DB.variables}];
        plotterT.set(property,newScaVars);
    end

    % Update the scatter group selection list 
    set(gui.popupmenu1,'string',[scaGroups,groupName],'value',numGroups + 1);

    % Switch the scatter group of interest
    gui.initialized = 0;
    scatterPanel(gui);

end
