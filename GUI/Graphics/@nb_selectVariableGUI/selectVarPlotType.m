function selectVarPlotType(gui,hObject,~)
% Syntax:
%
% selectVarPlotType(gui,hObject,event)
%
% Description:
%
% Part of DAG. Called when plot type is changed
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    % Get selected variable
    string  = get(gui.popupmenu1,'string');
    index   = get(gui.popupmenu1,'value');
    var     = string{index};

    % Get the selected plot type
    string = get(hObject,'string');
    index  = get(hObject,'value');
    plotT  = string{index};

    % Update the graph object and legend
    ind = find(strcmp(var,plotterT.plotTypes),1,'last'); 
    if isempty(ind) 
        if ~strcmpi(plotT,plotterT.plotType)
            plotterT.plotTypes = [plotterT.plotTypes,var,plotT];
        end
    else
        if strcmpi(plotT,plotterT.plotType)
            plotterT.plotTypes = [plotterT.plotTypes(1:ind - 1),plotterT.plotTypes(ind + 2:end)];
        else
            plotterT.plotTypes{ind + 1} = plotT;
        end

    end
    
    % We must prevent that stacked and grouped plot types are
    % choosen at the same time
    if ~isempty(plotterT.plotTypes)
        
        if any(strcmpi('grouped',plotterT.plotTypes(2:2:end)))
            set(gui.popupmenu2,'string',{'Line','Grouped','Area'});
        elseif any(strcmpi('stacked',plotterT.plotTypes(2:2:end)))
            set(gui.popupmenu2,'string',{'Line','Stacked','Area'});
        else
            set(gui.popupmenu2,'string',{'Line','Stacked','Grouped','Area'});
        end
        
    end

    % Update the gui (which will also notify listeners about the
    % changes made)
    updateGUI(gui,var,0)

end
