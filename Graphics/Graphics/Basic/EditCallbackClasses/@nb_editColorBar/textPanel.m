function textPanel(gui)
% Creates a panel for editing general legend properties  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get graph object 
    colorBar = gui.parent;

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
    kk        = 9;
    spaceYPop = (1 - heightPop*kk)/(kk+1);
    extra     = -(heightPop - heightT)*5;
       
    % Font Size
    %--------------------------------------------------------------
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
              'string',                 num2str(colorBar.fontSize),...
              'callback',               {@gui.set,'fontSize'});
    kk = kk - 1;
    
    % Font Weight
    %--------------------------------------------------------------
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Font Weight');

    weights = {'Normal','Bold','Light','Demi'};
    value   = find(strcmpi(colorBar.fontWeight,weights),1);

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
%     kk = kk - 1;
%     uicontrol(...
%               'units',                  'normalized',...
%               'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
%               'parent',                 uip,...
%               'style',                  'text',...
%               'horizontalAlignment',    'left',...
%               'string',                 'Interpreter');
% 
%     interpreters = {'Tex','None','Latex'};
%     value   = find(strcmpi(colorBar.interpreter,interpreters),1);
% 
%     uicontrol(...
%               'units',          'normalized',...
%               'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
%               'parent',          uip,...
%               'background',     [1 1 1],...
%               'style',          'popupmenu',...
%               'Interruptible',  'off',...
%               'string',         interpreters,...
%               'value',          value,....
%               'callback',       {@gui.set,'interpreter'});
          
end
