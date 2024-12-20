function generalPanel(gui)
% Syntax:
%
% generalPanel(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get graph object 
    plotter = gui.plotter;

    % Create panel
    %--------------------------------------------------------------
    uip = uipanel(gui.buttonPanel,...
        'button',              'General',...
        'title',               '',...
        'borderType',          'none'); 
    gui.panelHandle4 = uip;
    
    startPopX = 0.3;
    widthPop  = 0.35;
    heightPop = 0.045;
    startTX   = 0.04;
    widthT    = widthPop - startTX*2;
    heightT   = 0.04;
    kk        = 12; 
    spaceYPop = (1 - heightPop*kk)/(kk + 1);
    extra     = -(heightPop - heightT);

    % Position
    %--------------------------------------------------------------
    nb_uicontrolDAG(gui.plotter.parent,...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Position',...
              'tooltip',                'Controls the postion of the axes in the figure. Distance from the left, distance from the bottom, width, and height.');

    pos      = plotter.position;
    space    = 0.02;
    widthPos = widthPop/4 - space*3/4;
    
    uicontrol(...
              'units',              'normalized',...
              'position',           [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPos, heightPop],...
              'parent',             uip,...
              'background',         [1 1 1],...
              'style',              'edit',...
              'Interruptible',      'off',...
              'horizontalAlignment','right',...
              'string',             num2str(pos(1)),...
              'callback',           {@gui.setAxesPosition,1}); 
    
    uicontrol(...
              'units',              'normalized',...
              'position',           [startPopX + widthPos + space, heightPop*(kk-1) + spaceYPop*kk, widthPos, heightPop],...
              'parent',             uip,...
              'background',         [1 1 1],...
              'style',              'edit',...
              'Interruptible',      'off',...
              'horizontalAlignment','right',...
              'string',             num2str(pos(2)),...
              'callback',           {@gui.setAxesPosition,2}); 
          
    uicontrol(...
              'units',              'normalized',...
              'position',           [startPopX + widthPos*2 + space*2, heightPop*(kk-1) + spaceYPop*kk, widthPos, heightPop],...
              'parent',             uip,...
              'background',         [1 1 1],...
              'style',              'edit',...
              'Interruptible',      'off',...
              'horizontalAlignment','right',...
              'string',             num2str(pos(3)),...
              'callback',           {@gui.setAxesPosition,3}); 
          
    uicontrol(...
              'units',              'normalized',...
              'position',           [startPopX + widthPos*3 + space*3, heightPop*(kk-1) + spaceYPop*kk, widthPos, heightPop],...
              'parent',             uip,...
              'background',         [1 1 1],...
              'style',              'edit',...
              'Interruptible',      'off',...
              'horizontalAlignment','right',...
              'string',             num2str(pos(4)),...
              'callback',           {@gui.setAxesPosition,4}); 
    
    % Axes shading
    %--------------------------------------------------------------
    kk = kk - 1;
    nb_uicontrolDAG(gui.plotter.parent,...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Shading',...
              'tooltip',                'Shades the background of the graph gradually from top to bottom.');


    strings = {'none','grey'};
    sh      = plotter.shading; 
    value   = find(strcmpi(sh,strings));
    if isempty(value)
        value = 1;
    end
    
    uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',         uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'string',         strings,...
              'value',          value,....
              'callback',       @gui.setAxesShading);
        
    % Grid lines
    %--------------------------------------------------------------
    if not(any(strcmpi(plotter.plotType,{'pie','donut','radar'})))
    
        kk = kk - 1;
        nb_uicontrolDAG(gui.plotter.parent,...
                  'units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Grid Lines',...
                  'tooltip',                'Creates gridlines drawn from the tick marks.');


        strings = {'on','off'};
        gri     = plotter.grid; 
        value   = find(strcmpi(gri,strings));
        if isempty(value)
            value = 1;
        end

        uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         uip,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         strings,...
                  'value',          value,....
                  'callback',       @gui.setAxesGrid);
              
    end
          
    % Grid line style
    %--------------------------------------------------------------
    if not(any(strcmpi(plotter.plotType,{'pie','donut','radar'})))
    
        kk = kk - 1;
        nb_uicontrolDAG(gui.plotter.parent,...
                  'units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Grid Line Style',...
                  'tooltip',                'Controls the style of the gridlines.');


        strings = {'-','--',':','-.'};
        gri     = plotter.gridLineStyle; 
        value   = find(strcmpi(gri,strings));
        if isempty(value)
            value = 1;
        end

        uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         uip,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         strings,...
                  'value',          value,....
                  'callback',       @gui.setAxesGridLineStyle);
              
    end
          
    % Font Size
    %--------------------------------------------------------------
    kk = kk - 1;
    nb_uicontrolDAG(gui.plotter.parent,...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Font Size*',...
              'tooltip',                 'Controls the font size of the tick mark labels on both axes.');


    axesS = plotter.axesFontSize;
    axesS = num2str(axesS);
    
    uicontrol(...
              'units',              'normalized',...
              'position',           [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',             uip,...
              'background',         [1 1 1],...
              'horizontalAlignment','right',...
              'Interruptible',      'off',...
              'style',              'edit',...
              'string',             axesS,...
              'callback',           @gui.setAxesFontSize);   
       
    % Font Size X
    %--------------------------------------------------------------
    kk = kk - 1;
    nb_uicontrolDAG(gui.plotter.parent,...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Font Size X-Axis',...
              'tooltip',                'Controls the font size of the tick mark labels on the x-axis.');


    axesS = plotter.axesFontSizeX;
    axesS = num2str(axesS);
    
    uicontrol(...
              'units',              'normalized',...
              'position',           [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',             uip,...
              'background',         [1 1 1],...
              'horizontalAlignment','right',...
              'Interruptible',      'off',...
              'style',              'edit',...
              'string',             axesS,...
              'callback',           @gui.setAxesFontSizeX);      
          
    % Font Weight
    %--------------------------------------------------------------
    kk = kk - 1;
    nb_uicontrolDAG(gui.plotter.parent,...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Font Weight',...
              'tooltip',                'Controls the font weight of the tick mark labels on both axes.');


    strings = {'normal','bold','light'};
    weight  = plotter.axesFontWeight; 
    value   = find(strcmpi(weight,strings));
    if isempty(value)
        value = 1;
    end
    
    uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',         uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'string',         strings,...
              'value',          value,....
              'callback',       @gui.setAxesFontWeight);
          
    % Precision
    %--------------------------------------------------------------
    kk = kk - 1;
    nb_uicontrolDAG(gui.plotter.parent,...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Precision',...
              'tooltip',                'Controls the number of decimals on the axes. Numbers simply rounds off, while the percentage options both rounds and forces the number of decimals to be consistent.');


    strings   = {'','1','2','3','4','5','6','%0.1f','%0.2f','%0.3f','%0.4f','%0.5f','%0.6f'};
    userData  = {[],1,2,3,4,5,6,'%0.1f','%0.2f','%0.3f','%0.4f','%0.5f','%0.6f'};
    precision = plotter.axesPrecision; 
    if ischar(precision)
        value = 7 + find(strcmp(userData(8:end),userData));
    elseif isempty(precision)
        value = 1;
    else
        value = 1 + find(precision == 1:6,1);
    end
    if isempty(value)
        value = 1;
    end

    uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',         uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'string',         strings,...
              'value',          value,...
              'userData',       userData,...
              'callback',       {@gui.set,'precision'});
          
    % Date interpreter
    %--------------------------------------------------------------
    if isa(plotter,'nb_graph_ts')
        
        kk = kk - 1;
        nb_uicontrolDAG(gui.plotter.parent,...
                  'units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Date Interpreter',...
                  'tooltip',                'Controls how the tick marks will be aligned relatively to the date.');


        strings = {'start','end','middle'};
        str     = plotter.dateInterpreter; 
        value   = find(strcmp(strings,str));
        if isempty(value)
            value = 1;
        end

        uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         uip,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         strings,...
                  'value',          value,....
                  'callback',       @gui.setAxesDateInterpreter);
              
    end
    
    % No tick marks labels
    if not(any(strcmpi(plotter.plotType,{'pie','donut','radar'})))
    
        kk = kk - 1;
        uicontrol(...
                  'units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Left tick mark labels');

        if isprop(plotter,'noTickMarkLabelsLeft')      
            value = ~plotter.noTickMarkLabelsLeft;
        else
            value = true;
        end

        uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         uip,...
                  'style',          'radiobutton',...
                  'Interruptible',  'off',...
                  'string',         '',...
                  'value',          value,....
                  'callback',       {@gui.set,'noTickMarkLabelsLeft'});
              
        kk = kk - 1;
        uicontrol(...
                  'units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Right tick mark labels');

        if isprop(plotter,'noTickMarkLabelsRight')      
            value = ~plotter.noTickMarkLabelsRight;
        else
            value = true;
        end

        uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         uip,...
                  'style',          'radiobutton',...
                  'Interruptible',  'off',...
                  'string',         '',...
                  'value',          value,....
                  'callback',       {@gui.set,'noTickMarkLabelsRight'});      
        
        kk = kk - 1;
        uicontrol(...
                  'units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Tick mark labels');

        if isprop(plotter,'noTickMarkLabels')      
            value = ~plotter.noTickMarkLabels;
        else
            value = true;
        end

        uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         uip,...
                  'style',          'radiobutton',...
                  'Interruptible',  'off',...
                  'string',         '',...
                  'value',          value,....
                  'callback',       {@gui.set,'noTickMarkLabels'});
              
    end
    
    % Template note 
    %--------------------------------------------------------------
    nb_graphSettingsGUI.addTemplateFootnote(uip,false,[0.75,-0.1,0.22,0.23]);

end
