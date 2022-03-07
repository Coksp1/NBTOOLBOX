function originalTSMerge(gui)
% Syntax:
%
% originalTSMerge(gui)
%
% Description:
%
% Part of DAG. Open up dialog box for appending one nb_ts object to  
% another (same frequency).
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    name = [gui.parent.guiName ': Append Options'];

    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
               'units',          'characters',...
               'position',       [65   15  60   10],...
               'Color',          defaultBackground,...
               'name',           name,...
               'numberTitle',    'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'resize',         'off',...
               'windowStyle',    'modal');
    nb_moveFigureToMonitor(f,currentMonitor,'center');

    % Locations
    %--------------------------------------------------------------
    startPopX = 0.45;
    widthPop  = 0.525;
    heightPop = 0.09;
    startTX   = 0.06;
    widthT    = widthPop - startTX*2;
    heightT   = 0.08;
    kk        = 2; 
    spaceYPop = (1 - heightPop*kk)/(kk + 1);
    extra     = -(heightPop - heightT);
    
    % Type of appending
    %--------------------------------------------------------------
    uicontrol('units',              'normalized',...
              'position',           [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',             f,...
              'style',              'text',...
              'string',             'Method',...
              'horizontalAlignment','left');             

    gui.appendType = uicontrol(...
                     'units',             'normalized',...
                     'position',           [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                     'parent',             f,...
                     'background',         [1 1 1],...
                     'style',              'popupmenu',...
                     'string',             {'Standard','Level/Growth','Level/Level'},...
                     'horizontalAlignment','right');  
                 
    % Calculate button
    %--------------------------------------------------------------
    buttonHeight = 0.15;
    buttonWidth  = 0.4;
    buttonXLoc   = 0.5 - buttonWidth/2;
    buttonYLoc   = (heightPop*(kk-1) + spaceYPop*kk)/2 - buttonHeight/2;
    
    uicontrol(...
              'units',              'normalized',...
              'position',           [buttonXLoc, buttonYLoc, buttonWidth, buttonHeight],...
              'parent',             f,...
              'style',              'pushbutton',...
              'Interruptible',      'off',...
              'busyAction',         'cancel',...
              'string',             'OK',...
              'callback',           @gui.appendCallback);  
          
    % Mae visible
    set(f,'visible','on')
    
end
