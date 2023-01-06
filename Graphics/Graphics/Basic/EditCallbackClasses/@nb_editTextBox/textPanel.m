function textPanel(gui)
% Creates a panel for editing general legend properties  

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get graph object 
    textBox = gui.parent;

    % Create panel
    %--------------------------------------------------------------
    uip = uipanel('parent',              gui.figureHandle,...
                  'title',               '',...
                  'visible',             'on',...
                  'borderType',          'none',... 
                  'units',               'normalized',...
                  'position',            [0.22, 0.02, 1 - 0.24, 0.96]); 
    gui.panelHandle1 = uip;
    
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
    
    % Text
    %--------------------------------------------------------------
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Text');
       
    uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',         uip,...
              'background',     [1 1 1],...
              'style',          'edit',...
              'Interruptible',  'off',...
              'string',         textBox.string,...
              'callback',       {@gui.set,'string'});
    
    % Color
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol('units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Color'); 

    gui.colorpop1 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',         uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'tag',            'first',...
              'string',         gui.colors,...
              'value',          gui.valueColorTC,....
              'callback',       {@gui.set,'color'});

    gui.colordef1 = uicontrol(...
              'units',          'normalized',...
              'position',       [startB, heightPop*(kk-1) + spaceYPop*kk, widthB, heightPop],...
              'parent',         uip,...
              'style',          'pushbutton',...
              'Interruptible',  'off',...
              'busyAction',     'cancel',...
              'string',         'Define');      
          
    % Font Angle
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Font Angle');

    angles = {'Normal','Italic','Obligue'};
    value  = find(strcmpi(textBox.fontAngle,angles),1);

    uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',          uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'string',         angles,...
              'value',          value,....
              'callback',       {@gui.set,'fontAngle'});
          
    % Font Size
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Font Size');
    
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',                 uip,...
              'background',             [1 1 1],...
              'style',                  'edit',...
              'horizontalAlignment',    'right',...
              'Interruptible',          'off',...
              'string',                 num2str(textBox.fontSize),...
              'callback',               {@gui.set,'fontSize'});
    
    % Font Weight
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Font Weight');

    weights = {'Normal','Bold','Light','Demi'};
    value   = find(strcmpi(textBox.fontWeight,weights),1);

    uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',          uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'string',         weights,...
              'value',          value,....
              'callback',       {@gui.set,'fontWeight'});
          
    % Interpreter
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Interpreter');

    interpreters = {'Tex','None','Latex'};
    value   = find(strcmpi(textBox.interpreter,interpreters),1);

    uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',          uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'string',         interpreters,...
              'value',          value,....
              'callback',       {@gui.set,'interpreter'});
          
end
