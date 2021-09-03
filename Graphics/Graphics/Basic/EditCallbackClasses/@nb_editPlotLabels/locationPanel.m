function locationPanel(gui)
% Creates a panel for editing general legend properties  

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Create panel
    %--------------------------------------------------------------
    uip = uipanel('parent',              gui.figureHandle,...
                  'title',               '',...
                  'visible',             'off',...
                  'borderType',          'none',... 
                  'units',               'normalized',...
                  'position',            [0.22, 0.02, 1 - 0.24, 0.96]); 
    gui.panelHandle3 = uip;
    
    % Locations
    %--------------------------------------------------------------
    startPopX = 0.4;
    widthPop  = 0.35;
    heightPop = 0.055;
    startTX   = 0.04;
    widthT    = startPopX - startTX*2;
    heightT   = 0.053;
    kk        = 9;
    spaceYPop = (1 - heightPop*kk)/(kk+1);
    extra     = -(heightPop - heightT)*5;
    
    % Location
    %--------------------------------------------------------------
    if strcmpi(gui.type,'all') || strcmpi(gui.type,'column')
        enable = 'on';
    else
        enable = 'on';
    end
    
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Location');

    if strcmpi(gui.class,'nb_bar') || strcmpi(gui.class,'nb_hbar') || strcmpi(gui.class,'nb_area')
        string = {'halfway','top','bottom'}; 
    elseif strcmpi(gui.class,'nb_plotComb')
        ax = gui.parent.parent;
        ch = ax.children{gui.index(3)};
        cl = ch.types{gui.index(2)};
        if strcmpi(cl,'grouped') || strcmpi(cl,'stacked')
            string = {'halfway','top','bottom'};
        else
            string = {'center','right','left','above','below'};
        end
    else
        string = {'center','right','left','above','below'};
    end
    value = find(strcmpi(gui.format.location,string),1);
    if isempty(value)
        value = 1;
    end

    uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',          uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'enable',         enable,...
              'string',         string,...
              'value',          value,....
              'callback',       {@gui.set,'location'});
          
    % Horizontal Alignment
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Horizontal Alignment');

    alignments = {'Left','Center','Right'};
    value      = find(strcmpi(gui.format.horizontalAlignment,alignments),1);
    if isempty(value)
        value = 1;
    end
    
    uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',          uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'string',         alignments,...
              'value',          value,....
              'callback',       {@gui.set,'horizontalAlignment'});
          
    % Vertical Alignment
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Vertical Alignment');

    alignments = {'Middle','Top','Cap','Baseline','Bottom'};
    value      = find(strcmpi(gui.format.verticalAlignment,alignments),1);
    if isempty(value)
        value = 1;
    end
    
    uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',          uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'string',         alignments,...
              'value',          value,....
              'callback',       {@gui.set,'verticalAlignment'});
    
    % Rotation
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Rotation');

    uicontrol(...
              'units',                  'normalized',...
              'position',               [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',                 uip,...
              'background',             [1 1 1],...
              'style',                  'edit',...
              'horizontalAlignment',    'right',...
              'Interruptible',          'off',...
              'string',                 num2str(gui.format.rotation),...
              'callback',               {@gui.set,'rotation'});
          
    % Position
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Position');

    uicontrol(...
              'units',                  'normalized',...
              'position',               [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',                 uip,...
              'background',             [1 1 1],...
              'style',                  'edit',...
              'horizontalAlignment',    'right',...
              'Interruptible',          'off',...
              'callback',               {@gui.set,'position'});      
          
    % Space
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Space');
    
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',                 uip,...
              'background',             [1 1 1],...
              'style',                  'edit',...
              'horizontalAlignment',    'right',...
              'Interruptible',          'off',...
              'string',                 num2str(gui.format.space),...
              'callback',               {@gui.set,'space'});
             
end