function setFigureName(gui,~,~)
% Syntax:
%
% setFigureName(gui,hObject,event)
%
% Description:
%
% Part of DAG. Set figure name of nb_graph_subplot object. Both norwegian  
% and english.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    % GUI window
    %--------------------------------------------------------------
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
                  'units',          'characters',...
                  'position',       [65   15  100   20],...
                  'Color',          defaultBackground,...
                  'name',           [gui.parent.guiName ': Figure Name'],...
                  'numberTitle',    'off',...
                  'menuBar',        'None',...
                  'toolBar',        'None',...
                  'resize',         'off',...
                  'windowStyle',    'modal');
    movegui(f,'center');
    nb_moveFigureToMonitor(f,currentMonitor);
    
    topSpace      = 0.16;          
    editBoxHeight = 0.1;
    editBoxXLoc   = 0.04;
    editBoxYLoc1  = 1 - topSpace - editBoxHeight;
    editBoxYLoc2  = 1 - topSpace*2 - editBoxHeight*2;
    textYLoc1     = 1 - topSpace;
    textYLoc2     = 1 - topSpace*2 - editBoxHeight;
              
    % Norwegian
    %--------------------------------------------------------------
    uicontrol(...
              'units',                  'normalized',...
              'position',               [editBoxXLoc, textYLoc1, 1 - editBoxXLoc*2, 0.08],...
              'parent',                 f,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Norwegian');

    string = plotterT.figureNameNor;
    
    ed1 = uicontrol(...
              'units',              'normalized',...
              'position',           [editBoxXLoc, editBoxYLoc1, 1 - editBoxXLoc*2, editBoxHeight],...
              'parent',             f,...
              'background',         [1 1 1],...
              'style',              'edit',...
              'Interruptible',      'off',...
              'horizontalAlignment','left',...
              'string',             string); 
          
    % English
    %--------------------------------------------------------------
    uicontrol(...
              'units',                  'normalized',...
              'position',               [editBoxXLoc, textYLoc2, 1 - editBoxXLoc*2, 0.08],...
              'parent',                 f,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'English');

    string = plotterT.figureNameEng;
    
    ed2 = uicontrol(...
              'units',              'normalized',...
              'position',           [editBoxXLoc, editBoxYLoc2, 1 - editBoxXLoc*2, editBoxHeight],...
              'parent',             f,...
              'background',         [1 1 1],...
              'style',              'edit',...
              'Interruptible',      'off',...
              'horizontalAlignment','left',...
              'string',             string);
         
    % Update button      
    %-------------------------------------------------------------- 
    buttonHeight = 0.1;
    buttonWidth  = 0.2;
    buttonXLoc   = 0.5 - buttonWidth/2;
    buttonYLoc   = editBoxYLoc2/2 - buttonHeight/2;
    
    uicontrol(...
              'units',              'normalized',...
              'position',           [buttonXLoc, buttonYLoc, buttonWidth, buttonHeight],...
              'parent',             f,...
              'style',              'pushbutton',...
              'Interruptible',      'off',...
              'horizontalAlignment','left',...
              'string',             'Update',...
              'callback',           {@setFigureNameCallback,gui,ed1,ed2});
    
    % Make visible
    %--------------------------------------------------------------
    set(f,'visible','on');
                      
end

%==================================================================
% SUB
%==================================================================     
              
function setFigureNameCallback(~,~,gui,ed1,ed2)

    plotterT = gui.plotter;

    % Norwegian
    strNor = get(ed1,'string');
    plotterT.figureNameNor = strNor;
    
    % English
    strEng = get(ed2,'string');
    plotterT.figureNameEng = strEng;

    % Update the changed status
    changedCallback(gui,[],[]);
    
    % Close window
    close(get(ed1,'parent'))

end
