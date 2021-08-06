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
    indexT      = get(gui.selList,'value');
    stringT     = get(gui.selList,'string');
    typesToDel  = stringT(indexT);

    % Find out which to keep
    indexT      = ismember(stringT,typesToDel);
    typesToKeep = stringT(~indexT);

    % Update the list of the selected variables
    if isempty(typesToKeep)
        set(gui.selList,'string',typesToKeep);%,'value',[],'max',[]);
    else
        set(gui.selList,'string',typesToKeep,'value',1,'max',length(typesToKeep));
    end

    % Update the nb_graph_adv object
    gui.plotter.forecastTypes = typesToKeep;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
