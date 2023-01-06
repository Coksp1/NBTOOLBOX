function scatterSelectSideToPlot(gui,~,~)
% Syntax:
%
% scatterSelectSideToPlot(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    gui.scatterSide = nb_getUIControlValue(gui.popupmenu2);
    plotter         = gui.plotter;
    switch lower(gui.scatterSide)
        
        case 'left'
            
            if isa(plotter,'nb_graph_ts')      
                scatterGroups = plotter.scatterDates(1:2:end);
            elseif isa(plotter,'nb_graph_data')  
                scatterGroups = plotter.scatterObs(1:2:end);
            else
                scatterGroups = plotter.scatterVariables(1:2:end);
            end
            
        case 'right'
            
            if isa(plotter,'nb_graph_ts')      
                scatterGroups = plotter.scatterDatesRight(1:2:end);
            elseif isa(plotter,'nb_graph_data')  
                scatterGroups = plotter.scatterObsRight(1:2:end);
            else
                scatterGroups = plotter.scatterVariablesRight(1:2:end);
            end
            
    end
    
    if isempty(scatterGroups)
        scatterGroups = {' '};
    end    
    set(gui.popupmenu1,'string',scatterGroups,'value',1);  
            
    % Update scatter panel
    updateScatterGUI(gui,false)
            
end
