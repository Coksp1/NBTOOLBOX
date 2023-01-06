function setRoundoff(gui,~,~) 
% Syntax:
%
% setRoundoff(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get graph object 
    package = gui.package;

    % GUI window
    %--------------------------------------------------------------
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
                  'units',          'characters',...
                  'position',       [65   15  70   10],...
                  'Color',          defaultBackground,...
                  'name',           [gui.parent.guiName ': Round-off'],...
                  'numberTitle',    'off',...
                  'menuBar',        'None',...
                  'toolBar',        'None',...
                  'resize',         'off',...
                  'windowStyle',    'normal');
    movegui(f,'center');
    nb_moveFigureToMonitor(f,currentMonitor);
    
    startPopX = 0.4;
    widthPop  = 0.2;
    heightPop = 0.055*3;
    startTX   = 0.04;
    widthT    = startPopX - startTX*2;
    heightT   = 0.053*3;
    kk        = 2;
    spaceYPop = (1 - heightPop*kk)/(kk +1);
    extra     = -(heightPop - heightT)*5;
    
    % Letter counting
    %--------------------------------------------------------------
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 f,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Number of decimals*');
          
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',                 f,...
              'style',                  'edit',...
              'Interruptible',          'off',...
              'backgroundColor',        [1,1,1],...
              'horizontalAlignment',    'right',...
              'string',                 int2str(package.roundoff),...
              'callback',               {@setProperty,gui});
          
    % Help text
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT*2.5, heightT],...
              'parent',                 f,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 '*) Give empty to not round-off');
 
    % Make GUI visible
    %--------------------------------------------------------------
    set(f,'visible','on')

end

function setProperty(hObject,~,gui)
% Callback function for setting the properties

    package = gui.package;
    string  = get(hObject,'string');
    if isempty(string)
        value = [];
    else
        value   = round(str2double(string));
        if isnan(value)
            nb_errorWindow(['The round-off option must be set to an integer. Is ' string '.'])
            return
        elseif value < 0
            nb_errorWindow(['The round-off option must be set to an integer greater then or equal to 0. Is ' string '.']) 
            return
        end
        set(hObject,'string',int2str(value));
    end
    package.roundoff = value;

    % Update the changed status
    gui.changed = 1;

end
