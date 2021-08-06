function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG. Make dialog box for selction of datasets to merge
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isa(gui.parent,'nb_GUI')
        error('The parent must be an nb_GUI window');
    end

    % List of datasets
    mainGUI  = gui.parent;
    appData  = mainGUI.data;
    datasets = fieldnames(appData);

    if isempty(gui.data1) && isempty(gui.data2)
        % Merge two selected datasets
        gui.type = 2;
    else
        % Merge one selected dataset + one existing dataset
        gui.type = 1;
    end


    if length(datasets) < gui.type
        if gui.type == 2
            nb_errorWindow('There are no or only one stored dataset, so there are no datasets to merge.')
        else
            nb_errorWindow('There are no stored dataset to merge with.')
        end
        return
    end

    if gui.type == 2
        name = [mainGUI.guiName ': Select Datasets to Merge'];
    else
        name = [mainGUI.guiName ': Select Dataset to Merge with'];
    end

    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
               'units',          'characters',...
               'position',       [65   15  70   30],...
               'Color',          defaultBackground,...
               'name',           name,...
               'numberTitle',    'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'resize',         'off',...
               'windowStyle',    'modal');
    nb_moveFigureToMonitor(f,currentMonitor,'center');

    % Panel with dataset selection list
    uip = uipanel('parent',              f,...
                  'title',               'Datasets',...
                  'units',               'normalized',...
                  'position',            [0.04, 0.04, 0.44, 0.92]);

    % List datasets
    list = uicontrol('units',       'normalized',...
                     'position',    [0.02, 0.02, 0.96, 0.96],...
                     'parent',      uip,...
                     'background',  [1 1 1],...
                     'style',       'listbox',...
                     'string',      datasets,...
                     'max',         gui.type); 

    gui.mergeListBox = list;         
                 
    % Create merge button
    width  = 0.2;
    height = 0.06;
    uicontrol('units',       'normalized',...
              'position',    [0.5 + 0.25 - width/2 - 0.01, 0.4, width, height],...
              'parent',      f,...
              'background',  defaultBackground,...
              'style',       'pushbutton',...
              'string',      'Merge',...
              'tag',         'selectDataset',...
              'callback',    @gui.mergeDatasets); 

    % Make it visible
    set(f,'visible','on')

end
