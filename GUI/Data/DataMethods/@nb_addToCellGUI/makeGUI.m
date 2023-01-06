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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the handle to the main program
    mainGUI = gui.parent;

    % Decide the window name 
    figName = ['Add ' gui.type];

    % Create window
    f = nb_guiFigure(mainGUI,figName,[65,   15,  60,   10],'modal','off');

    % Locations
    %--------------------------------------------------------------
    startPopX = 0.5;
    widthPop  = 0.4;
    heightPop = 0.15;
    startTX   = 0.05;
    widthT    = startPopX - startTX*2;
    heightT   = 0.14;
    kk        = 3; 
    spaceYPop = (1 - heightPop*kk)/(kk + 1);
    extra     = -(heightPop - heightT);
              
    % Format
    %--------------------------------------------------------------
    if strcmpi(gui.type,'row')
        location = size(gui.data.data,2);
    else
        location = size(gui.data.data,2);
    end
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 f,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Location (added after)');

    gui.location = uicontrol(...
              'units',              'normalized',...
              'position',           [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',             f,...
              'background',         [1 1 1],...
              'style',              'edit',...
              'horizontalAlignment','left',...
              'Interruptible',      'off',...
              'string',             int2str(location));   
                     
    % Calculate button
    %--------------------------------------------------------------
    buttonHeight = 0.16;
    buttonWidth  = 0.35;
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
              'callback',           @gui.addCallback);   

    % Make GUI visible
    set(f,'visible','on');

end
