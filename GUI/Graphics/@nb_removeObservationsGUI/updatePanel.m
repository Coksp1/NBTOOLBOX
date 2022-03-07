function updatePanel(gui,variable)
% Syntax:
%
% updatePanel(gui,variable)
%
% Description:
%
% Part of DAG. Update the options panel  
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get plotter object
    plotterT = gui.plotter;

    if ~isempty(gui.panelHandle)
        set(gui.panelHandle,'visible','on');
    end    
    
    % Get the index of the variable choosen, and its options
    index  = find(strcmpi(variable,plotterT.nanVariables(1:2:end)),1);
    if isempty(index)
        type = 'none';
    else
        type = plotterT.nanVariables{index*2}{1};
    end
    
    % Create panel
    %--------------------------------------------------------------
    if ishandle(gui.panelHandle)
        delete(gui.panelHandle);
    end
    
    tHeight   = 0.04;
    startX    = 0.04;
    startY    = 0.85;
    startYB   = 0.04;

    gui.panelHandle = uipanel(...
                      'parent',              gui.figureHandle,...
                      'title',               'Properties',...
                      'units',               'normalized',...
                      'tag',                 'line',...
                      'position',            [startX, startYB, 0.92, startY - tHeight*4 - startYB]);
    
    startPopX = 0.3;
    widthPop  = 0.35;
    heightPop = 0.09;
    startTX   = 0.04;
    widthT    = widthPop - startTX*2;
    heightT   = 0.06;
    kk        = 7;
    spaceYPop = (1 - heightPop*kk)/(kk + 1);
    extra     = (heightPop - heightT)/2;
    
    % Type
    %----------------------------------------------------------
    uicontrol('units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 gui.panelHandle,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Type');
    
    value = find(strcmpi(type,gui.types));
    
    gui.typepopup = uicontrol(...
                  'units',                  'normalized',...
                  'position',               [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',                 gui.panelHandle,...
                  'background',             [1 1 1],...
                  'Interruptible',          'off',...
                  'horizontalAlignment',    'right',...
                  'style',                  'popupmenu',...
                  'string',                 gui.text,...
                  'value',                  value,...
                  'callback',               @gui.changeType);  
          
    % Update the rest of the properties panel dependent on the type
    updateTypePanel(gui,variable,type);      
              
end

