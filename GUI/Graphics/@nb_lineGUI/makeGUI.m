function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    plotterT = gui.plotter;
    parent   = plotterT.parent;

    % Create the main window
    %------------------------------------------------------
    if strcmpi(gui.type,'horizontal')
        string = 'Horizontal Line';
    elseif strcmpi(gui.type,'vertical')
        string = 'Vertical Line';
    else
        string = 'Line';
    end
    
    if isa(parent,'nb_GUI')
        name = [parent.guiName ': ' string ' Properties'];
    else
        name = [string ' Properties'];
    end
    
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f    = figure('visible',        'off',...
                  'units',          'characters',...
                  'position',       [40   15  85.5   31.5],...
                  'Color',          defaultBackground,...
                  'name',           name,...
                  'numberTitle',    'off',...
                  'dockControls',   'off',...
                  'menuBar',        'None',...
                  'toolBar',        'None',...
                  'resize',         'off',...
                  'windowStyle',    'modal');               
    gui.figureHandle = f;
    nb_moveFigureToMonitor(f,currentMonitor,'center');
    
    popWidth1 = 0.41;
    popHeight = 0.05;
    tHeight   = 0.04;
    startX    = 0.04;
    startY    = 0.85;

    % Select line object pop-up menu
    %------------------------------------------------------
    uicontrol('units',                  'normalized',...
              'position',               [startX, startY + popHeight, popWidth1, tHeight],...
              'parent',                 f,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Select Line Object'); 

    if strcmpi(gui.type,'horizontal')
        number = size(plotterT.horizontalLine,2);
    elseif strcmpi(gui.type,'vertical')
        number = size(plotterT.verticalLine,2);
    else
        ann    = plotterT.annotation;
        number = sum(cellfun('isclass',ann,'nb_drawLine'));
    end       
          
    if number == 0
        lineObjects = {' '};
    else
        lineObjects = cell(1,number);
        for ii = 1:number
            lineObjects{ii} = ['Line ' int2str(ii)];
        end
    end
    
    pop1 = uicontrol(...
              'units',          'normalized',...
              'position',       [startX, startY, popWidth1, popHeight],...
              'parent',         f,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'string',         lineObjects,...
              'Interruptible',  'off',...
              'value',          1,...
              'tag',         	'left',...
              'callback',       @gui.changeLineObject); 
    gui.popupmenu1 = pop1;
    
    % Add/delete line objects
    %------------------------------------------------------
    bgWidth  = 0.2;
    bgHeight = popHeight;
    uicontrol(...
              'units',          'normalized',...
              'position',       [1 - popWidth1 - startX, startY, bgWidth, bgHeight],...
              'parent',         f,...
              'style',          'pushbutton',...
              'string',         'Add',...
              'Interruptible',  'off',...
              'callback',       @gui.addLineObject); 

    uicontrol(...
              'units',          'normalized',...
              'position',       [1 - popWidth1 - startX, startY - tHeight*3, bgWidth, bgHeight],...
              'parent',         f,...
              'style',          'pushbutton',...
              'string',         'Delete',...
              'Interruptible',  'off',...
              'callback',       @gui.deleteLineObject); 
            
    % Create the rest line panel (Line options)
    %--------------------------------------------------------------
    updateLinePanel(gui,lineObjects{1},1);

    % Make GUI visible 
    %--------------------------------------------------------------
    set(f,'visible','on');
          
end