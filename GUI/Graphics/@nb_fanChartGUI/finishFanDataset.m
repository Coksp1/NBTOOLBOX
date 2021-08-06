function finishFanDataset(gui,~,~)
% Syntax:
%
% finishFanDataset(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    
    % Assign the fan variables
    plotterT.fanVariables = {};
    plotterT.fanDatasets  = gui.fanDataset;
    
    % Get fan variable
    plotterT.fanVariable = nb_getUIControlValue(gui.handle2);
    
    % Assign the percentiles
    data = get(gui.table,'data');
    num  = size(data,1);
    perc = nan(1,num);
    for ii = 1:num
        perc(ii) = str2double(data{ii});
    end
    plotterT.fanPercentiles = perc;
    
    % Assign fan color
    plotterT.fanColor = nb_getUIControlValue(gui.handle3);
    
    % Assign graded line color
    plotterT.fanGradedStyle = nb_getUIControlValue(gui.handle6);
    
    % Assign graded line color
    plotterT.fanGradedLineWidth = nb_getUIControlValue(gui.handle7,'numeric');
    
    % Assign fan method
    plotterT.fanMethod = nb_getUIControlValue(gui.handle5);
    
    % Close window
    close(gui.figureHandle)
    
    % Notify listeners
    %--------------------------------------------------------------
    notify(gui,'changedGraph');
    
end
