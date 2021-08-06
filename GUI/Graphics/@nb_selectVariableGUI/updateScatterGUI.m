function updateScatterGUI(gui,firstTime)
% Syntax:
%
% updateScatterGUI(gui,firstTime)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    popWidth1 = 0.41;
    popHeight = 0.05;
    tHeight   = 0.04;
    startX    = 0.04;
    startY    = 0.85;
    f         = gui.figureHandle;

    % Add/delete scatter groupes
    %------------------------------------------------------
    if firstTime

        bgWidth  = 0.2;
        bgHeight = popHeight;
        uicontrol(...
                  'units',          'normalized',...
                  'position',       [1 - popWidth1 - startX, startY, bgWidth, bgHeight],...
                  'parent',         f,...
                  'style',          'pushbutton',...
                  'Interruptible',  'off',...
                  'string',         'Add',...
                  'callback',       @gui.scatterAddGroup); 

        uicontrol(...
                  'units',          'normalized',...
                  'position',       [1 - popWidth1 - startX, startY - tHeight*3, bgWidth, bgHeight],...
                  'parent',         f,...
                  'Interruptible',  'off',...
                  'style',          'pushbutton',...
                  'string',         'Delete',...
                  'callback',       @gui.scatterDeleteGroup); 

    end

    % Panel with other properties
    %------------------------------------------------------  
    scatterPanel(gui);

end
