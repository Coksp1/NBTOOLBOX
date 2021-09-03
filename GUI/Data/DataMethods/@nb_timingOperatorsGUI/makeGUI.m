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

    % Get the handle to the main program
    mainGUI = gui.parent;

    % Decide the window name
    switch lower(gui.type)
        case 'lag'   
            figName = 'Lag';
        case 'lead'  
            figName = 'Lead';
    end
    
    if isa(mainGUI,'nb_GUI')
        name = [mainGUI.guiName ': ' figName];
    else
        name = figName;
    end
    
    % Create window
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
               'units',          'characters',...
               'position',       [65,   15,  120,   30],...
               'Color',          defaultBackground,...
               'name',           name,...
               'numberTitle',    'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'resize',         'off',...
               'windowStyle',    'modal');
    nb_moveFigureToMonitor(f,currentMonitor,'center');
    gui.figureHandle = f;
    
    % Create panels
    %--------------------------------------------------------------
    pSpace  = 0.02;
    pWidth1 = 0.65;
    pWidth2 = 1 - pWidth1 - pSpace*3;
    uip1 = uipanel(...
        'units',              'normalized',...
        'position',           [pSpace, pSpace, pWidth1, 1 - pSpace*2],...
        'parent',             f,...
        'title',              'Options');
    
    
    uip2 = uipanel(...
        'units',              'normalized',...
        'position',           [pSpace*2 + pWidth1, pSpace, pWidth2, 1 - pSpace*2],...
        'parent',             f,...
        'title',              'Select Variables');
    
    % Variables selection list
    %--------------------------------------------------------------
    num = size(gui.data.variables,2); 
    gui.list1 = uicontrol(...
      'units',              'normalized',...
      'position',           [0.02, 0.02, 0.96, 0.96],...
      'parent',             uip2,...
      'background',         [1 1 1],...
      'style',              'listbox',...
      'string',             gui.data.variables,...
      'max',                num,...
      'value',              1:num);
    
    % Locations
    %--------------------------------------------------------------
    startPopX = 0.45;
    widthPop  = 0.525;
    heightPop = 0.06;
    startTX   = 0.06;
    widthT    = widthPop - startTX*2;
    heightT   = 0.0533;
%     widthB    = 1 - startPopX - widthPop - startTX*2;
%     startB    = startPopX + widthPop + startTX;
    kk        = 9; 
    spaceYPop = (1 - heightPop*kk)/(kk + 1);
    extra     = -(heightPop - heightT);
    
    % Number of periods
    %--------------------------------------------------------------
    uicontrol('units',              'normalized',...
              'position',           [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',             uip1,...
              'style',              'text',...
              'string',             'Number of periods',...
              'horizontalAlignment','left');             

    gui.edit1 = uicontrol(...
                     'units',             'normalized',...
                     'position',           [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                     'parent',             uip1,...
                     'background',         [1 1 1],...
                     'style',              'edit',...
                     'string',             '1',...
                     'horizontalAlignment','right',...
                     'callback',           @gui.periodChangedCallback);         
        
    % Postfix
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip1,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Postfix');

    gui.edit2 = uicontrol(...
              'units',              'normalized',...
              'position',           [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',             uip1,...
              'background',         [1 1 1],...
              'style',              'edit',...
              'horizontalAlignment','left',...
              'Interruptible',      'off',...
              'string',             ['_' lower(gui.type) '1']);               
     
    % Calculate button
    %--------------------------------------------------------------
    buttonHeight = 0.0667;
    buttonWidth  = 0.3;
    buttonXLoc   = 0.5 - buttonWidth/2;
    buttonYLoc   = (heightPop*(kk-1) + spaceYPop*kk)/2 - buttonHeight/2;
    
    uicontrol(...
              'units',              'normalized',...
              'position',           [buttonXLoc, buttonYLoc, buttonWidth, buttonHeight],...
              'parent',             uip1,...
              'style',              'pushbutton',...
              'Interruptible',      'off',...
              'busyAction',         'cancel',...
              'string',             'Calculate',...
              'callback',           @gui.calculateCallback);      
          
    % Make GUI visible
    %--------------------------------------------------------------
    set(f,'visible','on');
    
end