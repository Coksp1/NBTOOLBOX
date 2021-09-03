function boxPanel(gui)
% Creates a panel for editing general legend properties  

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Get graph object 
    obj = gui.parent;

    % Create panel
    %--------------------------------------------------------------
    uip = uipanel('parent',              gui.figureHandle,...
                  'title',               '',...
                  'visible',             'off',...
                  'borderType',          'none',... 
                  'units',               'normalized',...
                  'position',            [0.22, 0.02, 1 - 0.24, 0.96]); 
    gui.panelHandle3 = uip;
    
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
    
    % Background Color
    %--------------------------------------------------------------
    uicontrol('units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Background Color'); 

    colorsTBC = ['None';gui.colors];
    
    gui.colorpop3 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',         uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'tag',            'first',...
              'string',         colorsTBC,...
              'value',          gui.valueColorTBC,....
              'callback',       {@gui.set,'textBackgroundColor'});

    gui.colordef3 = uicontrol(...
              'units',          'normalized',...
              'position',       [startB, heightPop*(kk-1) + spaceYPop*kk, widthB, heightPop],...
              'parent',         uip,...
              'style',          'pushbutton',...
              'Interruptible',  'off',...
              'busyAction',     'cancel',...
              'string',         'Define');    
    
    % Edge Color
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol('units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Edge Color'); 

    colorsTEC = ['None';gui.colors];
    
    gui.colorpop4 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',         uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'tag',            'first',...
              'string',         colorsTEC,...
              'value',          gui.valueColorTEC,....
              'callback',       {@gui.set,'textEdgeColor'});

    gui.colordef4 = uicontrol(...
              'units',          'normalized',...
              'position',       [startB, heightPop*(kk-1) + spaceYPop*kk, widthB, heightPop],...
              'parent',         uip,...
              'style',          'pushbutton',...
              'Interruptible',  'off',...
              'busyAction',     'cancel',...
              'string',         'Define'); 
          
    % Edge Line Style
    %--------------------------------------------------------------
%     kk = kk - 1;
%     uicontrol(...
%               'units',                  'normalized',...
%               'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
%               'parent',                 uip,...
%               'style',                  'text',...
%               'horizontalAlignment',    'left',...
%               'string',                 'Edge Line Style');
% 
%     lineStyles = {'-','--',':','-.','none'};       
%     value      = find(strcmpi(obj.textLineStyle,lineStyles),1);
% 
%     uicontrol(...
%               'units',          'normalized',...
%               'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
%               'parent',          uip,...
%               'background',     [1 1 1],...
%               'style',          'popupmenu',...
%               'Interruptible',  'off',...
%               'string',         lineStyles,...
%               'value',          value,....
%               'callback',       {@gui.set,'textLineStyle'});
   
    % Line Width
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Line Width');

    uicontrol(...
              'units',                  'normalized',...
              'position',               [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',                 uip,...
              'background',             [1 1 1],...
              'style',                  'edit',...
              'horizontalAlignment',    'right',...
              'Interruptible',          'off',...
              'string',                 num2str(obj.textLineWidth),...
              'callback',               {@gui.set,'textLineWidth'});
          
    % Margin (in pixels)
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Margin (in pixels)');

    uicontrol(...
              'units',                  'normalized',...
              'position',               [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',                 uip,...
              'background',             [1 1 1],...
              'style',                  'edit',...
              'horizontalAlignment',    'right',...
              'Interruptible',          'off',...
              'string',                 num2str(obj.textMargin),...
              'callback',               {@gui.set,'textMargin'});
          
end