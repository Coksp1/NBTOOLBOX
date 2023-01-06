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
        
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get selected variables
    indexT  = get(gui.varList,'value');
    stringT = get(gui.varList,'string');
    vars    = stringT(indexT);

    % Ensure no overlapping variables
    oldVars = get(gui.selList,'string');
    if ~isempty(oldVars) 
        indexT   = ismember(vars,oldVars);
        newVars  = vars(~indexT);
        vars     = [newVars; oldVars];
    end

    % Update the list of the removed variables
    set(gui.selList,'string',sort(vars),'value',1,'max',length(vars));

    % Update the graph object (nb_graph_adv)
    gui.plotter.remove = vars;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
