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

    plotterT = gui.plotter;
    parent   = plotterT.parent;
    
    if isa(parent,'nb_GUI')
        name = [parent.guiName ': Patch Properties'];
    else
        name = 'Patch Properties';
    end
    
    % Create the main window
    %------------------------------------------------------
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
              'string',                 'Select Patch Object'); 
          
    % An helpful note...
    %------------------------------------------------------         
    uicontrol('units',                  'normalized',...
              'position',               [startX, startY + popHeight - 0.9, popWidth1 + 0.5, tHeight],...
              'parent',                 f,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 '*) The patch is used for shading the area between two lines.'); 


    number = size(plotterT.patch,2)/4;   
    if number == 0
        objects = {' '};
    else
        objects = cell(1,number);
        for ii = 1:number
            objects{ii} = ['Patch ' int2str(ii)];
        end
    end
    
    pop1 = uicontrol(...
              'units',          'normalized',...
              'position',       [startX, startY, popWidth1, popHeight],...
              'parent',         f,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'string',         objects,...
              'Interruptible',  'off',...
              'value',          1,...
              'tag',         	'left',...
              'callback',       @gui.changePatchObject); 
    gui.popupmenu1 = pop1;
    
    uicontrol(...
              'units',          'normalized',...
              'position',       [startX, startY - tHeight*3, (popWidth1 - startX)/2, popHeight],...
              'parent',         f,...
              'style',          'text',...
              'string',         'Transparency',...
              'Interruptible',  'off'); 
    
    uicontrol(...
              'units',          'normalized',...
              'position',       [startX*2 + popWidth1/2, startY - tHeight*3, (popWidth1 - startX)/2, popHeight],...
              'parent',         f,...
              'background',     [1 1 1],...
              'style',          'edit',...
              'string',         num2str(gui.plotter.patchAlpha),...
              'Interruptible',  'off',...
              'callback',       @gui.setPatchAlphaCallback);
    
    % Add/delete patch objects
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
              'callback',       @gui.addPatchObject); 

    uicontrol(...
              'units',          'normalized',...
              'position',       [1 - popWidth1 - startX, startY - tHeight*3, bgWidth, bgHeight],...
              'parent',         f,...
              'style',          'pushbutton',...
              'string',         'Delete',...
              'Interruptible',  'off',...
              'callback',       @gui.deletePatchObject); 
            
    % Create the rest of the panel (Highlight options)
    %--------------------------------------------------------------
    updatePatchPanel(gui,objects{1},1);

    % Make GUI visible 
    %--------------------------------------------------------------
    set(f,'visible','on');
          
end
