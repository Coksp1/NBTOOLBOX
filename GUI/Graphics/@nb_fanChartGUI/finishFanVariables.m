function finishFanVariables(gui,~,~)
% Syntax:
%
% finishFanVariables(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    
    % Assign the fan variables
    plotterT.fanVariables = gui.fanVariables;
    plotterT.fanDatasets  = {};
    plotterT.fanVariable  = '';
    
    
    % Assign the percentiles
    data = get(gui.table,'data');
    num  = size(data,1);
    perc = nan(1,num);
    for ii = 1:num
        perc(ii) = str2double(data{ii});
    end
    plotterT.fanPercentiles = perc;
    
    % Assign fan color
    colors = get(gui.handle3,'string');
    index  = get(gui.handle3,'value');
    color  = colors{index};
    plotterT.fanColor = color;
    
    % Remove plotlines of fanchart variables
    index = ismember(plotterT.variablesToPlot,gui.fanVariables);
    plotterT.variablesToPlot = plotterT.variablesToPlot(~index);
    
    % Close window
    close(gui.figureHandle)
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');

end
