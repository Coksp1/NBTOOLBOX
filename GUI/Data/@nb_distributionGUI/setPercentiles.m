function setPercentiles(gui)
% Syntax:
%
% setPercentiles(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0, 'defaultUicontrolBackgroundColor');
    f = nb_figure(...
        'visible',        'off',...
        'units',          'characters',...
        'position',       [40   15  100   30],...
        'Color',          defaultBackground,...
        'name',           'Kernel density estimation',...
        'numberTitle',    'off',...
        'menuBar',        'None',...
        'toolBar',        'None');
    figureHandle = f.figureHandle;
    nb_moveFigureToMonitor(figureHandle, currentMonitor, 'center');
    
    grid = nb_gridcontainer(figureHandle,...
        'Position', [0 0 1 1],...
        'Margin', 10,...
        'GridSize', [1, 2], ...
        'BorderWidth', 0);
    
    tData = cell(20, 2);
    if ~isempty(gui.percentiles)
        s            = size(gui.percentiles,2);
        tData(1:s,1) = num2cell(gui.percentiles');
        tData(1:s,2) = num2cell(gui.values');
    end
    
    t = nb_uitable(grid, ...
        'ColumnName', {'Percentile', 'Value'}, ...
        'RowName', {}, ...
        'Data', tData, ...
        'ColumnEditable', true);
    
    rightGrid = nb_gridcontainer(grid, ...
        'Margin', 10, ...
        'Padding', 0, ...
        'GridSize', [8, 2]);
    
    labelProps = nb_constant.LABEL;
    editProps = nb_constant.EDIT;
              
    % 0th percentile
    startD = '';
    if ~isempty(gui.startD)
        startD = num2str(gui.startD);
    end
    uicontrol(rightGrid, labelProps, ...
        'String', {'Start of domain'; '(0th percentile)'});
    startDBox = uicontrol(rightGrid, editProps, ...
        'String', startD);
    
    % 100th percentile
    endD = '';
    if ~isempty(gui.endD)
        endD = num2str(gui.endD);
    end
    uicontrol(rightGrid, labelProps, ...
        'String', {'End of domain'; '(100th percentile)'});
    endDBox = uicontrol(rightGrid, editProps, ...
        'String', endD);
    
    comp = struct('t',t,'startDBox',startDBox,'endDBox',endDBox,...
                  'figureHandle',figureHandle);
    
    % Done
    uicontrol(rightGrid, nb_constant.BUTTON, ...
        'string', 'Done', ...
        'callback', {@callback, gui, comp});
    
    % Cancel
    uicontrol(rightGrid, nb_constant.BUTTON, ...
        'string', 'Cancel', ...
        'callback', @(src, evt) close(figureHandle));
    
    set(f, 'visible', 'on');
    
end

function callback(~,~,gui,comp)

   data       = get(comp.t, 'Data');
   gui.startD = str2double(get(comp.startDBox, 'String'));
   if isnan(gui.startD)
        nb_errorWindow('Start of domain must be a number') 
        return
   end
   gui.endD = str2double(get(comp.endDBox, 'String'));
   if isnan(gui.endD)
        nb_errorWindow('End of domain must be a number')  
        return
   end
   
   try
       gui.percentiles = [data{:, 1}];
       gui.values      = [data{:, 2}];
       
       % Kernel density estimation
       gui.currentDistribution = nb_distribution.perc2DistCDF(gui.percentiles, gui.values, gui.startD, gui.endD);
       gui.updateGUI();
       close(comp.figureHandle);
       
   catch Err
       nb_errorWindow(Err.message);
   end
   
end
