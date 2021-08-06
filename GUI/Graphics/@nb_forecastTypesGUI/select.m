function select(gui,~,~)
% Syntax:
%
% select(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
        
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get selected variables
    indexT   = get(gui.varList,'value');
    stringT  = get(gui.varList,'string');
    types    = stringT(indexT);

    % Ensure no overlapping variables
    oldVars = get(gui.selList,'string');
    if ~isempty(oldVars) 
        indexT   = ismember(types,oldVars);
        newVars  = types(~indexT);
        types    = [newVars; oldVars];
    end

    % Update the list of the removed variables
    set(gui.selList,'string',sort(types),'value',1,'max',length(types));

    % Update the graph object (nb_graph_adv)
    gui.plotter.forecastTypes = types;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
