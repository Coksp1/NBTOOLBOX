function setPieType(gui,hObject,~)
% Syntax:
%
% setPieType(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen 

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    plotter     = gui.plotter;
    types       = plotter.DB.types;
    chosenIndex = get(hObject,'value');
    chosenType  = types(chosenIndex);
    plotter.set('typesToPlot',chosenType);

    % Update the graph
    notify(gui,'changedGraph');

end
