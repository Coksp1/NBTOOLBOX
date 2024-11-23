function yAxisPanel(gui,side)
% Syntax:
%
% yAxisPanel(gui,side)
%
% Description:
%
% Part of DAG. Creates the panel with the y-axis properties.
%
% Input:
%
% - side : Either 'left' or 'right'.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get graph object 
    plotter = gui.plotter;

    % Create panel
    %--------------------------------------------------------------
    if strcmpi(side,'left')
        button = 'Left Y-Axis';
        str    = 'Y-Axis Limits*';
    else
        button = 'Right Y-Axis';
        str    = 'Y-Axis Limits';
    end
    uip = uipanel(gui.buttonPanel,...
        'button',              button,...
        'title',               '',...
        'borderType',          'none'); 
    if strcmpi(side,'left')
        gui.panelHandle2 = uip;
    else
        gui.panelHandle3 = uip;
    end
    
    % We make it impossible to set properties of the right y-axis
    % if no variables is plotted against it
    if strcmpi(side,'right') && isempty(plotter.variablesToPlotRight) && isempty(plotter.scatterVariablesRight)
        return
    end
        
    % Set y-limits
    %--------------------------------------------------------------
    firstPanelStart = 0.75;
    uipvr = uipanel('parent',              uip,...
                    'title',               str,...
                    'units',               'normalized',...
                    'position',            [0.04, firstPanelStart, 0.92, 0.21]);

    % Add uicontrol elements to change the lower y-axis limit
    if strcmpi(side,'left')
       yLim = plotter.yLim; 
    else
       yLim = plotter.yLimRight;  
    end
    
    if isempty(yLim) 
        enable  = 'off';
        valueR  = 0;
        yLimLow = '';
    elseif isnan(yLim(1))
        enable  = 'off';
        valueR  = 0;
        yLimLow = '';
    else
        enable  = 'on';
        valueR  = 1;
        yLimLow = num2str(yLim(1));
    end

    uicontrol(...
                    'units',                'normalized',...
                    'position',             [0.04, 0.36, 0.15, 0.2],...
                    'parent',               uipvr,...
                    'style',                'text',...
                    'horizontalAlignment',  'left',...
                    'string',               'Lower:'); 

    pmhsg = uicontrol('units',                'normalized',...
                      'position',             [0.2, 0.36, 0.30, 0.2],...
                      'parent',               uipvr,...
                      'style',                'edit',...
                      'background',           [1 1 1],...
                      'Interruptible',        'off',...
                      'horizontalAlignment',  'right',...
                      'enable',               enable,...
                      'string',               yLimLow,...
                      'callback',             {@gui.setYLim,'lower',side});
                  
    if strcmpi(side,'left')              
        gui.editBox3 = pmhsg;
    else
        gui.editBox5 = pmhsg;
    end

    % Add uicontrol elements to change the upper y-axis limit
    if isempty(yLim) 
        enable   = 'off';
        valueRE  = 0;
        yLimHigh = '';
    elseif isnan(yLim(2))
        enable   = 'off';
        valueRE   = 0;
        yLimHigh = '';
    else
        enable   = 'on';
        valueRE  = 1;
        yLimHigh = num2str(yLim(2));
    end

    uicontrol(...
                    'units',                'normalized',...
                    'position',             [0.04, 0.08, 0.15, 0.2],...
                    'parent',               uipvr,...
                    'style',                'text',...
                    'horizontalAlignment',  'left',...
                    'string',               'Upper:'); 

    pmheg = uicontrol('units',                'normalized',...
                      'position',             [0.2, 0.08, 0.30, 0.2],...
                      'parent',               uipvr,...
                      'style',                'edit',...
                      'background',           [1 1 1],...
                      'Interruptible',        'off',...
                      'horizontalAlignment',  'right',...
                      'enable',               enable,...
                      'string',               yLimHigh,...
                      'callback',             {@gui.setYLim,'upper',side});      
                  
    if strcmpi(side,'left')              
        gui.editBox4 = pmheg;
    else
        gui.editBox6 = pmheg;
    end
    
    % The text above the auto/manual radiobuttons    
    uicontrol(...
                    'units',                'normalized',...
                    'position',             [0.55, 0.64, 0.15, 0.2],...
                    'parent',               uipvr,...
                    'style',                'text',...
                    'string',               'Auto');

    uicontrol(...
                    'units',                'normalized',...
                    'position',             [0.70, 0.64, 0.15, 0.2],...
                    'parent',               uipvr,...
                    'style',                'text',...
                    'string',               'Manual'); 

    % Create the radio button group to select if the start
    % graph should be set manually or automatic
    uibg1 = uibuttongroup('parent',              uipvr,...
                          'title',               '',...
                          'borderType',          'none',...
                          'Interruptible',       'off',...
                          'busyAction',          'cancel',...
                          'units',               'normalized',...
                          'position',            [0.55, 0.36, 0.30, 0.2],...
                          'SelectionChangeFcn',  {@gui.enableEditYLim,'lower',side}); 

    % Make a radio button for each type  
    uicontrol(...
                      'units',              'normalized',...
                      'position',           [0.22,0,0.25,1],...
                      'parent',             uibg1,...
                      'style',              'radiobutton',...
                      'tag',                'auto',...
                      'string',             '',...
                      'value',              ~valueR);          

    uicontrol(...
                      'units',              'normalized',...
                      'position',           [0.72,0,0.25,1],...
                      'parent',             uibg1,...
                      'style',              'radiobutton',...
                      'tag',                'manual',...
                      'string',             '',...
                      'value',              valueR);    

    % Create the radio button group to select if the end
    % graph should be set manually or automatic
    uibg2 = uibuttongroup('parent',              uipvr,...
                          'title',               '',...
                          'borderType',          'none',...
                          'Interruptible',       'off',...
                          'busyAction',          'cancel',...
                          'units',               'normalized',...
                          'position',            [0.55, 0.08, 0.30, 0.2],...
                          'SelectionChangeFcn',  {@gui.enableEditYLim,'upper',side}); 

    % Make a radio button for each type                 
    uicontrol(...
                      'units',              'normalized',...
                      'position',           [0.22,0,0.25,1],...
                      'parent',             uibg2,...
                      'style',              'radiobutton',...
                      'tag',                'auto',...
                      'string',             '',...
                      'value',              ~valueRE);          

    uicontrol(...
                      'units',              'normalized',...
                      'position',           [0.72,0,0.25,1],...
                      'parent',             uibg2,...
                      'style',              'radiobutton',...
                      'tag',                'manual',...
                      'string',             '',...
                      'value',              valueRE); 
       
    % Other properties
    %--------------------------------------------------------------
    startPopX = 0.3;
    widthPop  = 0.35;
    heightPop = 0.045;
    startTX   = 0.04;
    widthT    = widthPop - startTX*2;
    heightT   = 0.04;
%     widthB    = 1 - startPopX - widthPop - startTX*2;
%     startB    = startPopX + widthPop + startTX;
    kk        = 9; 
    spaceYPop = (firstPanelStart - heightPop*kk)/(kk + 1);
    extra     = -(heightPop - heightT);
    
    
    % Y-Axis Scale
    %--------------------------------------------------------------
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Y-Axis Scale');
   
    if strcmp(plotter.plotType,'scatter')
        
        if strcmpi(side,'right')
            var = nb_nestedCell2Cell(plotter.scatterVariablesRight);
            var = var(2:2:end);
        else
            var = nb_nestedCell2Cell(plotter.scatterVariables);
            var = var(2:2:end);
        end
        if isa(plotter,'nb_graph_ts') || isa(plotter,'nb_graph_data')
            data = plotter.DB.window('','',var);
        else
            data = plotter.DB.window('',var);
        end
        data = data.double();
        ind  = data < 1;
        if any(ind(:))
            strings = {'linear'};
        else
            strings = {'linear','log'};
        end
        
    else
        
        data = plotter.getData();
        data = data.double();
        ind  = data < 1;
        if any(any(ind))
            strings = {'linear'};
        else
            strings = {'linear','log'};
        end

    end
    
    if strcmpi(side,'left')
        scale = plotter.yScale; 
    else
        scale = plotter.yScaleRight; 
    end
    
    value   = find(strcmpi(scale,strings));
    if isempty(value)
        value          = 1;
        plotter.yScale = scale;
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
              'callback',       {@gui.setYAxisScale,side});
          
    % y-axis spacing 
    %--------------------------------------------------------------      
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Y-Axis Tick Spacing');


    value = plotter.ySpacing;
    str   = int2str(value);

    uicontrol(...
              'units',                  'normalized',...
              'position',               [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',                 uip,...
              'background',             [1 1 1],...
              'style',                  'edit',...
              'horizontalAlignment',    'right',...
              'Interruptible',          'off',...
              'string',                 str,...
              'callback',               {@gui.setYAxisSpacing,side}); 

          
    % Y-Axis Direction
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Y-Axis Direction');


    strings = {'normal','reverse'};
    if strcmpi(side,'left')
        dir = plotter.yDir; 
    else
        dir = plotter.yDirRight; 
    end
    value   = find(strcmpi(dir,strings));
    if isempty(value)
        value          = 1;
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
              'callback',       {@gui.setYAxisDir,side});
          
    if strcmpi(side,'right')
        
        % Align at base value
        %--------------------------------------------------------------
        kk = kk - 1;
        uicontrol(...
                  'units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Align axes at value');

        baseValue = plotter.alignAxes;
        if isempty(baseValue)
            string1 = '';
            string2 = '';
        else
            if isscalar(baseValue)
                baseValue = [baseValue,baseValue];
            end
            string1 = num2str(baseValue(1)); 
            string2 = num2str(baseValue(2)); 
        end
        uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, (widthPop - startTX)/2 , heightPop],...
                  'parent',         uip,...
                  'background',     [1 1 1],...
                  'style',          'edit',...
                  'Interruptible',  'off',...
                  'string',         string1,...
                  'tag',            '1',...
                  'callback',       @gui.setAlignAxes);
              
        uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX + (widthPop + startTX)/2, heightPop*(kk-1) + spaceYPop*kk, (widthPop - startTX)/2 , heightPop],...
                  'parent',         uip,...
                  'background',     [1 1 1],...
                  'style',          'edit',...
                  'Interruptible',  'off',...
                  'string',         string2,...
                  'tag',            '2',...
                  'callback',       @gui.setAlignAxes);       
        
    end
    
     % Template note 
    %--------------------------------------------------------------
    nb_graphSettingsGUI.addTemplateFootnote(uip,false,[0.4,0.0,0.85,0.1]);

end
