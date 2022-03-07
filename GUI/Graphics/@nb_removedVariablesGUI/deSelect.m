function deSelect(gui,~,~)
% Syntax:
%
% deSelect(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
        
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get selected variables
    indexT     = get(gui.selList,'value');
    stringT    = get(gui.selList,'string');
    varsToDel  = stringT(indexT);

    % Find out which to keep
    indexT     = ismember(stringT,varsToDel);
    varsToKeep = stringT(~indexT);

    % Update the list of the selected variables
    if isempty(varsToKeep)
        set(gui.selList,'string',varsToKeep);%,'value',[],'max',[]);
    else
        set(gui.selList,'string',varsToKeep,'value',1,'max',length(varsToKeep));
    end

    % Update the nb_graph_adv object
    gui.plotter.remove = varsToKeep;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
