function start(gui,~,~)
% Syntax:
%
% start(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    packageT = gui.package;

    % Create window
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
               'units',          'characters',...
               'position',       [65   15  60   9],...
               'Color',          defaultBackground,...
               'name',           [gui.parent.guiName ': Start Number'],...
               'numberTitle',    'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'resize',         'off',...
               'windowStyle',    'modal');
    movegui(f,'center');
    nb_moveFigureToMonitor(f,currentMonitor);

    % Find the coordinate parameters
    startX          = 0.3;
    width           = 1 - startX*2;
    height          = 0.15;
    listExtraHeight = 0.04;

    uicontrol('units',              'normalized',...
              'position',           [startX, 0.65,width,height],...
              'parent',             f,...
              'style',              'text',...
              'string',             'Start Number',...
              'horizontalAlignment','left');             

    editbox = uicontrol(...
                     'units',             'normalized',...
                     'position',           [startX, 0.45,width,height + listExtraHeight],...
                     'parent',             f,...
                     'background',         [1 1 1],...
                     'style',              'edit',...
                     'string',             int2str(packageT.start),...
                     'horizontalAlignment','right');         
        
    buttonWidth  = 0.3;
    buttonHeigth = 0.2;
    uicontrol('units',       'normalized',...
              'position',    [0.5 - buttonWidth/2, (0.45 - buttonHeigth)/2,buttonWidth,buttonHeigth],...
              'parent',      f,...
              'style',       'pushbutton',...
              'string',      'Select',...
              'callback',    {@changeStartCallback,gui,editbox});

    % Make GUI visible
    set(f,'visible','on');

end

%==================================================================
% SUB
%==================================================================
function changeStartCallback(~,~,gui,editbox)

    package = gui.package;
    
    % Get the chapter selected
    startT = get(editbox,'string');
    
    % Check for errors
    startSelected = round(str2double(startT));
    if isnan(startSelected)
        nb_errorWindow(['The chapter must be given as a integer. Not ''' startT '''.'])
        return
    end
    
    % Assign changes
    package.start = startSelected;
    
    % Update the changed status
    gui.changed = 1;
    
    % Close window
    close(get(gco,'parent'))

end
