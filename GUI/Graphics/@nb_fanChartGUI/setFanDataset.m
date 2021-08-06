function setFanDataset(gui,~,~)
% Syntax:
%
% setFanDataset(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get selected dataset
    string  = get(gui.handle1,'string');
    index   = get(gui.handle1,'value');
    dataset = string{index};
    
    % gui.plotter.parent is an nb_GUI object, which is already 
    % tested for
    appData = gui.plotter.parent.data; 
    dataset = appData.(dataset);
    
    % Test the selected dataset
    if dataset.numberOfDatasets < 2
        nb_errorWindow('The selected dataset must have more than one page.')
        return
    end
    
    variables   = dataset.variables;
    plottedVars = gui.plotter.variablesToPlot;
    index       = ismember(variables,plottedVars);
    if ~any(index)
        nb_errorWindow('The selected dataset must contain some of the variables already plotted.')
    end
    
    % Assign locally
    gui.fanDataset = dataset;
    
    % Update the properties panel
    nFans   = dataset.numberOfDatasets/2;
    numbers = 1:nFans;
    numbers = numbers(:);
    numbers = cellstr(num2str(numbers));
    value   = min(length(numbers),size(gui.plotter.fanPercentiles,2));
    
    set(gui.handle4,...
          'enable', 'off',...
          'string', numbers,...
          'value',  value);
    changeTable(gui,[],[]);
    
    set(gui.handle2,'enable','on');
    set(gui.handle4,'enable','on');
    
    % Change panel
    set(gui.panelHandle1,'visible','off');
    set(gui.panelHandle2,'visible','on');

end
