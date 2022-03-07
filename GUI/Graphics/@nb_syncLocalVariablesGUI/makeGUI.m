function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Create the main window
    %------------------------------------------------------
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f    = figure('visible',        'off',...
                  'units',          'characters',...
                  'position',       [40   15  75   30],...
                  'Color',          defaultBackground,...
                  'name',           [gui.parent.guiName ': Conflicting Local Variables'],...
                  'numberTitle',    'off',...
                  'dockControls',   'off',...
                  'menuBar',        'None',...
                  'toolBar',        'None',...
                  'resize',         'off',...
                  'CloseRequestFcn',@gui.close);               
    gui.figureHandle = f;
    nb_moveFigureToMonitor(f,currentMonitor);
    
    % Create table with look up matrix
    %--------------------------------------------------------------
    logi       = repmat({true},length(gui.conflictingNames),1);
    tableData  = [gui.conflictingNames',gui.existing',gui.added',logi];
    
    colNames   = {'Name','Existing','Loaded','Keep Existing'};
    colEdit    = [false(1,3),true(1,1)];
    colForm    = cell(1,4);
    colForm(:) = {'char'};
    colForm{4} = 'logical'; 
    colWidth   = 'auto';
    t = nb_uitable(...
            f,...
            'units',                'normalized',...
            'position',             [0 0.2 1 0.8],...
            'data',                 tableData,...
            'columnName',           colNames,...
            'columnFormat',         colForm,...
            'columnWidth',          colWidth,...
            'columnEdit',           colEdit);

    gui.table = t;
 
    % Add Save button
    width  = 0.2;
    height = 0.1;
    uicontrol('units',          'normalized',...
              'position',       [0.5 - width/2, 0.1 - height/2, width, height],...
              'parent',         f,...
              'background',     defaultBackground,...
              'style',          'pushbutton',...
              'Interruptible',  'off',...
              'busyAction',     'cancel',...
              'string',         'Save',...
              'callback',       @gui.saveRoutine); 
    
    % Make it visible
    %--------------------------------------------------------------
    set(f,'visible','on');

end
