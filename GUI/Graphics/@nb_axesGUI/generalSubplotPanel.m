function generalSubplotPanel(gui)
% Syntax:
%
% generalSubplotPanel(gui)
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
%     widthB    = 1 - startPopX - widthPop - startTX*2;
%     startB    = startPopX + widthPop + startTX;
    kk        = 12; 
    spaceYPop = (1 - heightPop*kk)/(kk + 1);
    extra     = -(heightPop - heightT);

    % Axes shading
    %--------------------------------------------------------------
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Shading');


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
    if not(strcmpi(plotter.plotType,'pie') || strcmpi(plotter.plotType,'radar'))
    
        kk = kk - 1;
        uicontrol(...
                  'units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Grid Lines');


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
    if not(strcmpi(plotter.plotType,'pie') || strcmpi(plotter.plotType,'radar'))
    
        kk = kk - 1;
        uicontrol(...
                  'units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Grid Line Style');


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
    uicontrol(...
              'units',                  'normalized',...
              'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Font Size');


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
          
    % Date interpreter
    %--------------------------------------------------------------
    if isa(plotter,'nb_graph_ts')
        
        kk = kk - 1;
        uicontrol(...
                  'units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Date Interpreter');


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
    
    % x-axis spacing 
    %--------------------------------------------------------------
    if isa(plotter,'nb_graph_ts') || isa(plotter,'nb_graph_data')
            
        supported = true;
        if isa(plotter,'nb_graph_data')
            supported = ~iscell(plotter.variableToPlotX);
        end
        
        if supported
        
            kk = kk - 1;
            uicontrol(...
                      'units',                  'normalized',...
                      'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                      'parent',                 uip,...
                      'style',                  'text',...
                      'horizontalAlignment',    'left',...
                      'string',                 'X-Axis Tick Spacing');


            value = plotter.spacing;
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
                      'callback',               @gui.setXAxisSpacing);
                  
        end
              
    end
    
    % X-Axis Tick Frequency
    %--------------------------------------------------------------     
    if isa(plotter,'nb_graph_ts')
    
        kk = kk - 1;
        uicontrol(...
                  'units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'X-Axis Tick Frequency');

        listFreq   = [365,12,4,2,1];
        stringFreq = {'Daily','Monthly','Quarterly','Semiannually','Yearly'};
        freq       = plotter.DB.frequency; 
        strings    = stringFreq(listFreq <= freq);
        value      = find(strcmpi(plotter.xTickFrequency,strings));
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
                  'callback',       @gui.setXTickFrequency);
              
    end
    
    if isa(plotter,'nb_graph_ts') || isa(plotter,'nb_graph_data')
              
        supported = true;
        if isa(plotter,'nb_graph_data')
            supported = ~iscell(plotter.variableToPlotX);
        end
        
        if supported
        
            % Start/end graph
            %----------------------------------------------------------
            kk = kk - 1;

            % We want to return local variables if used
            plotter.setSpecial('returnLocal',1);

            start = plotter.startGraph;
            if isa(start,'nb_date')
                start = start.toString();
            elseif isnumeric(start)
                start = num2str(start);
            end

            finish = plotter.endGraph;
            if isa(finish,'nb_date')
                finish = finish.toString();
            elseif isnumeric(finish)
                finish = num2str(finish);
            end

            % We must reset the returnLocal property, so everything
            % works as it suposed.
            plotter.setSpecial('returnLocal',0);

            firstPanelStart = heightPop*(kk-1) + spaceYPop*kk - 0.21;

            % Set x-axis visible range
            %----------------------------------------------------------
            uipvr = uipanel('parent',              uip,...
                            'title',               'Visible range',...
                            'units',               'normalized',...
                            'position',            [0.04, firstPanelStart, 0.92, 0.21]);

            % Add uicontrol elements to change the startGraph property
            %----------------------------------------------------------
            if get(plotter,'manuallySetStartGraph')
                enable = 'on';
                valueR = 1;
            else
                enable = 'off';
                valueR = 0;
            end

            uicontrol(...
                            'units',                'normalized',...
                            'position',             [0.04, 0.36, 0.15, 0.2],...
                            'parent',               uipvr,...
                            'style',                'text',...
                            'horizontalAlignment',  'left',...
                            'string',               'Start:'); 

            pmhsg = uicontrol('units',                'normalized',...
                              'position',             [0.2, 0.36, 0.30, 0.2],...
                              'parent',               uipvr,...
                              'style',                'edit',...
                              'background',           [1 1 1],...
                              'Interruptible',        'off',...
                              'horizontalAlignment',  'left',...
                              'enable',               enable,...
                              'string',               start,...
                              'callback',             @gui.setStartGraph);  
            gui.editBox1 = pmhsg;

            % Add uicontrol elements to change the endGraph property 
            %----------------------------------------------------------
            if get(plotter,'manuallySetEndGraph')
                enable = 'on';
                valueRE = 1;
            else
                enable = 'off';
                valueRE = 0;
            end

            uicontrol(...
                            'units',                'normalized',...
                            'position',             [0.04, 0.08, 0.15, 0.2],...
                            'parent',               uipvr,...
                            'style',                'text',...
                            'horizontalAlignment',  'left',...
                            'string',               'End:'); 

            pmheg = uicontrol('units',                'normalized',...
                              'position',             [0.2, 0.08, 0.30, 0.2],...
                              'parent',               uipvr,...
                              'style',                'edit',...
                              'background',           [1 1 1],...
                              'Interruptible',        'off',...
                              'horizontalAlignment',  'left',...
                              'enable',               enable,...
                              'string',               finish,...
                              'callback',             @gui.setEndGraph);      
            gui.editBox2 = pmheg;

            % The text above the auto/manual radiobuttons    
            %----------------------------------------------------------
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
            %----------------------------------------------------------
            uibg1 = uibuttongroup('parent',              uipvr,...
                                  'title',               '',...
                                  'borderType',          'none',...
                                  'Interruptible',       'off',...
                                  'busyAction',          'cancel',...
                                  'units',               'normalized',...
                                  'position',            [0.55, 0.36, 0.30, 0.2],...
                                  'SelectionChangeFcn',  {@gui.enableEditDates,'startGraph'}); 

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
            %----------------------------------------------------------
            uibg2 = uibuttongroup('parent',              uipvr,...
                                  'title',               '',...
                                  'borderType',          'none',...
                                  'Interruptible',       'off',...
                                  'busyAction',          'cancel',...
                                  'units',               'normalized',...
                                  'position',            [0.55, 0.08, 0.30, 0.2],...
                                  'SelectionChangeFcn',  {@gui.enableEditDates,'endGraph'}); 

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
                          
        end
        
    end

end
