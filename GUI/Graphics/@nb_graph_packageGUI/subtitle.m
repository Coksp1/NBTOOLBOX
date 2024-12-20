function subtitle(gui,~,~)
% Syntax:
%
% subtitle(gui,hObject,event)
%
% Description:
%
% Part of DAG. Make the user able to edit the subtitle displayed on the 
% first page of the saved excel spreadsheet
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    package = gui.package;
    
    % Test properties
    %--------------------------------------------------------------
    if isempty(package.firstPageNameNor)
        package.firstPageNameNor = {'';''};
    else
        if ischar(package.firstPageNameNor)
            package.firstPageNameNor = cellstr(package.firstPageNameNor);
        end
    end
    
    if isempty(package.firstPageNameEng)
        package.firstPageNameEng = {'';''};
    else
        if ischar(package.firstPageNameEng)
            package.firstPageNameEng = cellstr(package.firstPageNameEng);
        end
    end

    % GUI window
    %--------------------------------------------------------------
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
                  'units',          'characters',...
                  'position',       [65   15  100   20],...
                  'Color',          defaultBackground,...
                  'name',           [gui.parent.guiName ': Excel Output Title'],...
                  'numberTitle',    'off',...
                  'menuBar',        'None',...
                  'toolBar',        'None',...
                  'resize',         'off',...
                  'windowStyle',    'modal');
    movegui(f,'center');
    nb_moveFigureToMonitor(f,currentMonitor);
    
    topSpace      = 0.16;          
    editBoxHeight = 0.1;
    editBoxXLoc   = 0.08;
    textHeight    = 0.08;
    editBoxYLoc1  = 1 - topSpace - editBoxHeight;
    editBoxYLoc2  = 1 - topSpace*2 - editBoxHeight*2;
    textYLoc1     = 1 - topSpace;
    textYLoc2     = 1 - topSpace*2 - editBoxHeight;
              
    % Norwegian
    %--------------------------------------------------------------
    uicontrol(...
              'units',                  'normalized',...
              'position',               [editBoxXLoc, textYLoc1, 1 - editBoxXLoc*2, textHeight],...
              'parent',                 f,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Norwegian');

    try 
        string = char(package.firstPageNameNor{2});
    catch %#ok<CTCH>
        package.firstPageNameNor{2} = '';
        string = '';
    end
    
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
              'position',               [editBoxXLoc, textYLoc2, 1 - editBoxXLoc*2, textHeight],...
              'parent',                 f,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'English');

    try 
        string = char(package.firstPageNameNor{2});
    catch %#ok<CTCH>
        package.firstPageNameEng{2} = '';
        string = '';
    end
    
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
    buttonHeight = 0.10;
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
              'callback',           {@setFirstPageNameCallback,gui,ed1,ed2});
    
    % Make visible
    %--------------------------------------------------------------
    set(f,'visible','on');
                      
end

%==================================================================
% SUB
%==================================================================     
              
function setFirstPageNameCallback(~,~,gui,ed1,ed2)

    package = gui.package;

    % Norwegian
    package.firstPageNameNor{2} = get(ed1,'string');
    
    % English
    package.firstPageNameEng{2} = get(ed2,'string');

    % Update the changed status
    gui.changed = 1;
    
    % Close window
    close(get(gco,'parent'))    
    
end
