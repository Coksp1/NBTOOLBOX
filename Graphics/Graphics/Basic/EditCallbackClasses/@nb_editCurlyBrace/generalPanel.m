function generalPanel(gui)
% Creates a panel for editing general legend properties  

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get graph object 
    object = gui.parent;

    % Create panel
    %--------------------------------------------------------------
    uip = uipanel('parent',              gui.figureHandle,...
                  'title',               '',...
                  'visible',             'off',...
                  'borderType',          'none',... 
                  'units',               'normalized',...
                  'position',            [0.22, 0.02, 1 - 0.24, 0.96]); 
    gui.panelHandle2 = uip;
    
    startPopX = 0.4;
    widthPop  = 0.35;
    heightPop = 0.055;
    startTX   = 0.04;
    widthT    = startPopX - startTX*2;
    heightT   = 0.053;
    widthB    = 1 - startPopX - widthPop - startTX*2;
    startB    = startPopX + widthPop + startTX;
    kk        = 9;
    spaceYPop = (1 - heightPop*kk)/(kk+1);
    extra     = -(heightPop - heightT)*5;
           
    % Side
    %--------------------------------------------------------------
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Side');

    sides = {'Left','Right'};
    value = find(strcmpi(object.side,sides),1);

    if strcmpi(object.units,'data')
        enable = 'on';
    else
        enable = 'off';
    end
    
    h = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',          uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'string',         sides,...
              'enable',         enable,...
              'value',          value,....
              'callback',       {@gui.set,'side'});
    gui.sideHandle = h;      
          
    % Units
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Units');

    units = {'Data','Normalized'};
    value = find(strcmpi(object.units,units),1);

    uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',          uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'string',         units,...
              'value',          value,....
              'callback',       {@gui.set,'units'});
          
    % xData
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'X-Data');

    gui.xdata1 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop/2, heightPop],...
              'parent',          uip,...
              'background',     [1 1 1],...
              'style',          'edit',...
              'Interruptible',  'off',...
              'string',         num2str(object.xData(1)),...
              'callback',       {@gui.set,'xData1'});
    gui.xdata2 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX + widthPop/2 + startTX/2, heightPop*(kk-1) + spaceYPop*kk, widthPop/2, heightPop],...
              'parent',          uip,...
              'background',     [1 1 1],...
              'style',          'edit',...
              'Interruptible',  'off',...
              'string',         num2str(object.xData(2)),...
              'callback',       {@gui.set,'xData2'});
          
    % yData
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Y-Data');

    gui.ydata1 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop/2, heightPop],...
              'parent',          uip,...
              'background',     [1 1 1],...
              'style',          'edit',...
              'Interruptible',  'off',...
              'string',         num2str(object.yData(1)),...
              'callback',       {@gui.set,'yData1'});
    gui.ydata2 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX + widthPop/2 + startTX/2, heightPop*(kk-1) + spaceYPop*kk, widthPop/2, heightPop],...
              'parent',          uip,...
              'background',     [1 1 1],...
              'style',          'edit',...
              'Interruptible',  'off',...
              'string',         num2str(object.yData(2)),...
              'callback',       {@gui.set,'yData2'});
          
           
end
