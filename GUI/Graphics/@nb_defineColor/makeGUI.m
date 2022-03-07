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
                  'position',       [40   15  55   14],...
                  'Color',          defaultBackground,...
                  'name',           'Define Color',...
                  'numberTitle',    'off',...
                  'menuBar',        'None',...
                  'toolBar',        'None',...
                  'resize',         'off',...
                  'windowStyle',    'modal');               
    gui.figureHandle = f;
    nb_moveFigureToMonitor(f,currentMonitor,'center');
    
    % Positions
    startX       = 0.08;
    startY       = 0.08;
    scrollWidth  = 0.3;
    scrollHeight = 0.1;
    axesWidth    = 0.45;
    axesHeight   = 0.2;
    space        = 0.02;
    editWidth    = (axesWidth - space*2)/3; 
    editHeight   = 0.1;
    
    % Add the scrollbars
    %--------------------------------------------------------------
    s1 = uicontrol(...
        'units',            'normalized',...
        'parent',           f,...
        'Interruptible',    'off',...
        'Style',            'slider',...
        'sliderstep',       [0.01,0.1],...
        'Min',              0,...
        'Max',              1,...
        'Value',            0,...
        'Position',         [startX,0.75,scrollWidth,scrollHeight],...
        'Callback',         {@gui.setColor,'red'});   
    
    s2 = uicontrol(...
        'units',            'normalized',...
        'parent',           f,...
        'Interruptible',    'off',...
        'Style',            'slider',...
        'sliderstep',       [0.01,0.1],...
        'Min',              0,...
        'Max',              1,...
        'Value',            0,...
        'Position',         [startX,0.5,scrollWidth,scrollHeight],...
        'Callback',         {@gui.setColor,'green'}); 
    
    s3 = uicontrol(...
        'units',            'normalized',...
        'parent',           f,...
        'Interruptible',    'off',...
        'Style',            'slider',...
        'sliderstep',       [0.01,0.1],...
        'Min',              0,...
        'Max',              1,...
        'Value',            0,...
        'Position',         [startX,0.25,scrollWidth,scrollHeight],...
        'Callback',         {@gui.setColor,'blue'}); 
    
    % Text above edit boxes
    %--------------------------------------------------------------
    uicontrol(...
        'units',                'normalized',...
        'parent',               f,...
        'Style',                'text',...
        'horizontalAlignment',  'center',...
        'string',               'R',...
        'Position',             [1 - axesWidth - startX,1 - axesHeight - startY*4 + editHeight,editWidth,editHeight]);   
    
    uicontrol(...
        'units',                'normalized',...
        'parent',               f,...
        'Style',                'text',...
        'horizontalAlignment',  'center',...
        'string',               'G',...
        'Position',             [1 - axesWidth - startX + space + editWidth,1 - axesHeight - startY*4 + editHeight,editWidth,editHeight]); 
    
    uicontrol(...
        'units',                'normalized',...
        'parent',               f,...
        'Style',                'text',...
        'horizontalAlignment',  'center',...
        'string',               'B',...
        'Position',             [1 - axesWidth - startX + space*2 + editWidth*2,1 - axesHeight - startY*4 + editHeight,editWidth,editHeight]); 
    
    % Add the edit boxes
    %--------------------------------------------------------------
    e1 = uicontrol(...
        'units',                'normalized',...
        'parent',               f,...
        'Interruptible',        'off',...
        'Style',                'edit',...
        'backgroundColor',      [1 1 1],...
        'horizontalAlignment',  'right',...
        'string',               '0',...
        'Position',             [1 - axesWidth - startX,1 - axesHeight - startY*4,editWidth,editHeight],...
        'Callback',             {@gui.setColor,'red'});   
    
    e2 = uicontrol(...
        'units',                'normalized',...
        'parent',               f,...
        'Interruptible',        'off',...
        'Style',                'edit',...
        'backgroundColor',      [1 1 1],...
        'horizontalAlignment',  'right',...
        'string',               '0',...
        'Position',             [1 - axesWidth - startX + space + editWidth,1 - axesHeight - startY*4,editWidth,editHeight],...
        'Callback',             {@gui.setColor,'green'}); 
    
    e3 = uicontrol(...
        'units',                'normalized',...
        'parent',               f,...
        'Interruptible',        'off',...
        'Style',                'edit',...
        'backgroundColor',      [1 1 1],...
        'horizontalAlignment',  'right',...
        'string',               '0',...
        'Position',             [1 - axesWidth - startX + space*2 + editWidth*2,1 - axesHeight - startY*4,editWidth,editHeight],...
        'Callback',             {@gui.setColor,'blue'}); 
    
    % Plot the selected color in an axes
    %--------------------------------------------------------------
    ax = axes('parent',f,...
              'position',[1 - axesWidth - startX,1 - axesHeight - startY,axesWidth,axesHeight],...
              'xLim',[0,1],...
              'yLim',[0,1]);
    axis(ax,'off');
    x = [0 0 1 1 0];
    y = [1 0 0 1 1];
    p = patch(x,y,[0 0 0],'parent',ax);
    
    % Select color button
    %--------------------------------------------------------------
    buttonWidth = axesWidth*2/3;
    buttonStart = 1 - axesWidth*0.5 - buttonWidth*0.5 - startX ;
    
    uicontrol(...
        'units',                'normalized',...
        'parent',               f,...
        'Style',                'pushbutton',...
        'horizontalAlignment',  'center',...
        'string',               'Select',...
        'Position',             [buttonStart,1 - axesHeight - startY*7,buttonWidth,editHeight],...
        'callback',             @gui.close);
    
    % Assign handles
    %--------------------------------------------------------------
    gui.axesHandle  = ax;
    gui.patchHandle = p;
    gui.slider1     = s1;
    gui.slider2     = s2;
    gui.slider3     = s3;
    gui.editbox1    = e1;
    gui.editbox2    = e2;
    gui.editbox3    = e3;
    
    % Make figure visible
    %--------------------------------------------------------------
    set(f,'visible','on');
      
end
