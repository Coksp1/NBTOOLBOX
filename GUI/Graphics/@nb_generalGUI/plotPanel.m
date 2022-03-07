function plotPanel(gui)
% Syntax:
%
% plotPanel(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get graph object 
    plotterT = gui.plotter;

    % Create panel
    %--------------------------------------------------------------
    uip = uipanel('parent',              gui.figureHandle,...
                  'title',               '',...
                  'visible',             'on',...
                  'borderType',          'none',... 
                  'units',               'normalized',...
                  'position',            [0.22, 0.02, 1 - 0.24, 0.96]); 
    gui.panelHandle1 = uip;
    
    startPopX = 0.3;
    widthPop  = 0.35;
    heightPop = 0.055;
    startTX   = 0.04;
    widthT    = widthPop - startTX*2;
    heightT   = 0.053;
    widthB    = 1 - startPopX - widthPop - startTX*2;
    startB    = startPopX + widthPop + startTX;
    kk        = 11;
    spaceYPop = (1 - heightPop*kk)/(kk + 1);
    extra     = -(heightPop - heightT)*5;
    
    % Indicators for message
    lWidth = false;
    mSize  = false;
    
    
    if strcmpi(plotterT.plotType,'grouped') || strcmpi(plotterT.plotType,'stacked') || strcmpi(plotterT.plotType,'dec')...
            || any(strcmpi(plotterT.plotTypes,'stacked')) || any(strcmpi(plotterT.plotTypes,'grouped'))
        
        % Bar shading color
        %----------------------------------------------------------
        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT - 0.005, heightPop + 0.02],...
                  'parent',                 gui.panelHandle1,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Bar Shading Color'); 

        % Locate or give default color
        parent = plotterT.parent;
        endc   = nb_getGUIColorList(gui,parent);

        % Locate the selected color in the color list
        colorTemp  = plotterT.barShadingColor;
        valueColor = nb_findColor(colorTemp,endc);
        if valueColor == 0
            [endc,valueColor] = nb_addColor(gui,parent,endc,colorTemp);
        end
        
        % Using html coding to get the background of the 
        % listbox colored  
        colors = nb_selectVariableGUI.htmlColors(endc);

        pop = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.panelHandle1,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         colors,...
                  'value',          valueColor,....
                  'callback',       {@gui.set,'barShadingColor'});

        uicontrol(...
                  'units',          'normalized',...
                  'position',       [startB, heightPop*(kk-1) + spaceYPop*kk, widthB, heightPop],...
                  'parent',         gui.panelHandle1,...
                  'style',          'pushbutton',...
                  'Interruptible',  'off',...
                  'busyAction',     'cancel',...
                  'string',         'Define',...
                  'callback',       {@nb_setDefinedColor,gui,pop}); 
        
        if isa(plotterT,'nb_graph_ts') ||   isa(plotterT,'nb_graph_data')
            
            % Bar shading date
            %----------------------------------------------------------
            kk = kk - 1;
            uicontrol('units',                  'normalized',...
                      'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk, widthT, heightPop],...
                      'parent',                 gui.panelHandle1,...
                      'style',                  'text',...
                      'horizontalAlignment',    'left',...
                      'string',                 'Bar Shading Obs');
                  
            uicontrol(...
                      'units',                  'normalized',...
                      'position',               [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop*2, heightPop],...
                      'parent',                 gui.panelHandle1,...
                      'Interruptible',          'off',...
                      'horizontalAlignment',    'left',...
                      'style',                  'text',...
                      'string',                 ' (Moved to Properties->Select Variable)');  
                  
        else
            
            % Bar shading types
            %----------------------------------------------------------
            kk = kk - 1;
            uicontrol('units',                  'normalized',...
                      'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightPop + 0.02],...
                      'parent',                 gui.panelHandle1,...
                      'style',                  'text',...
                      'horizontalAlignment',    'left',...
                      'string',                 'Bar Shading Types');

            uicontrol(...
                      'units',                  'normalized',...
                      'position',               [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                      'parent',                 gui.panelHandle1,...
                      'Interruptible',          'off',...
                      'style',                  'pushbutton',...
                      'string',                 'Select',....
                      'callback',               @gui.setBarShadingTypes);  
            
        end
    
        % Bar shading direction
        %----------------------------------------------------------
        kk = kk - 1;
        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightPop + 0.02],...
                  'parent',                 gui.panelHandle1,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Bar Shading Direction'); 

        % Locate choosen
        directions = {'north','south','west','east'};
        direction  = plotterT.barShadingDirection;
        value      = find(strcmpi(direction,directions));

        uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.panelHandle1,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         directions,...
                  'value',          value,....
                  'callback',       {@gui.set,'barShadingDirection'});
              
        % Bar width
        %---------------------------------------------------------- 
        kk = kk - 1;
        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle1,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Bar Width'); 

        % Locate choosen
        value  = num2str(plotterT.barWidth);

        uicontrol(...
                  'units',              'normalized',...
                  'position',           [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',             gui.panelHandle1,...
                  'background',         [1 1 1],...
                  'style',              'edit',...
                  'horizontalAlignment','right',...
                  'Interruptible',      'off',...
                  'string',             value,...
                  'callback',           {@gui.set,'barWidth'});
              
        % Bar width
        %---------------------------------------------------------- 
        kk = kk - 1;
        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle1,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Bar Line Width'); 

        % Locate choosen
        if isempty(plotterT.barLineWidth)
            value = '';
        else
            value = num2str(plotterT.barLineWidth);
        end
        uicontrol(...
                  'units',              'normalized',...
                  'position',           [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',             gui.panelHandle1,...
                  'background',         [1 1 1],...
                  'style',              'edit',...
                  'horizontalAlignment','right',...
                  'Interruptible',      'off',...
                  'string',             value,...
                  'callback',           {@gui.set,'barLineWidth'});      
              
        % Bar alpha1
        %---------------------------------------------------------- 
        kk = kk - 1;
        uicontrol(nb_constant.LABEL,...
                  'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',   gui.panelHandle1,...
                  'string',   'Alpha blending 1'); 

        value  = num2str(plotterT.barAlpha1);
        uicontrol(nb_constant.EDIT,...
                  'position', [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',   gui.panelHandle1,...
                  'string',   value,...
                  'callback', {@gui.set,'barAlpha1'});
              
        % Bar alpha2
        %---------------------------------------------------------- 
        kk = kk - 1;
        uicontrol(nb_constant.LABEL,...
                  'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',   gui.panelHandle1,...
                  'string',   'Alpha blending 2'); 

        value  = num2str(plotterT.barAlpha2);
        uicontrol(nb_constant.EDIT,...
                  'position', [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',   gui.panelHandle1,...
                  'string',   value,...
                  'callback', {@gui.set,'barAlpha2'});   
              
        % Bar blend
        %---------------------------------------------------------- 
        kk = kk - 1;
        uicontrol(nb_constant.LABEL,...
                  'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',   gui.panelHandle1,...
                  'string',   'Blend/shade bars'); 

        uicontrol(nb_constant.RADIOBUTTON,...
                  'position', [startPopX + 0.02, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',   gui.panelHandle1,...
                  'value',    plotterT.barBlend,...
                  'callback', {@gui.set,'barBlend'});        
              
    end
    
    if (strcmpi(plotterT.plotType,'grouped') || strcmpi(plotterT.plotType,'stacked')) ...
            && isa(plotterT,'nb_graph_cs')
    
        % Bar orientation
        %----------------------------------------------------------
        kk = kk - 1;
        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightPop],...
                  'parent',                 gui.panelHandle1,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Bar Orientation'); 

        % Locate choosen
        orientations = {'Vertical','Horizontal'};
        orientation  = plotterT.barOrientation;
        value        = find(strcmpi(orientation,orientations));

        uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.panelHandle1,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         orientations,...
                  'value',          value,....
                  'callback',       {@gui.set,'barOrientation'});
              
    end
        
    if strcmpi(plotterT.plotType,'area') || strcmpi(plotterT.plotType,'stacked')
       
        if strcmpi(plotterT.plotType,'stacked')
            kk = kk - 1;
        end
        
        % Sum to
        %----------------------------------------------------------      
        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle1,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Sum to'); 

        % Value choosen
        sumTo  = plotterT.sumTo;

        uicontrol(...
                  'units',              'normalized',...
                  'position',           [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',             gui.panelHandle1,...
                  'background',         [1 1 1],...
                  'style',              'edit',...
                  'horizontalAlignment','right',...
                  'Interruptible',      'off',...
                  'string',             num2str(sumTo),...
                  'callback',           {@gui.set,'sumTo'});
        
        
    end
    
    if strcmpi(plotterT.plotType,'candle')
        
        % Candle width
        %----------------------------------------------------------      
        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle1,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Candle Width'); 

        % Locate choosen
        value  = num2str(plotterT.candleWidth);

        uicontrol(...
                  'units',              'normalized',...
                  'position',           [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',             gui.panelHandle1,...
                  'background',         [1 1 1],...
                  'style',              'edit',...
                  'horizontalAlignment','right',...
                  'Interruptible',      'off',...
                  'string',             value,...
                  'callback',           {@gui.set,'candleWidth'});
              
    end
     
    if strcmpi(plotterT.plotType,'line') || strcmpi(plotterT.plotType,'grouped') || strcmpi(plotterT.plotType,'stacked') || ...
           strcmpi(plotterT.plotType,'dec') || any(strcmpi(plotterT.plotTypes,'stacked')) || any(strcmpi(plotterT.plotTypes,'grouped')) || ...
           strcmpi(plotterT.plotType,'scatter') || strcmpi(plotterT.plotType,'donut') || strcmpi(plotterT.plotType,'area') || ...
           any(strcmpi(plotterT.plotTypes,'area'))
        
        if not(strcmpi(plotterT.plotType,'line') || ....
                strcmpi(plotterT.plotType,'scatter') || ...
                strcmpi(plotterT.plotType,'donut')) || ...
                any(strcmpi(plotterT.plotTypes,'stacked')) ||...
                any(strcmpi(plotterT.plotTypes,'grouped')) || ...
                strcmpi(plotterT.plotType,'area') || ...
                any(strcmpi(plotterT.plotTypes,'area'))
            kk = kk - 1;
        end
       
        % Line width
        %----------------------------------------------------------      
        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle1,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Line Width*'); 
        lWidth = true;
        
        % Locate choosen
        value  = num2str(plotterT.lineWidth);

        uicontrol(...
                  'units',              'normalized',...
                  'position',           [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',             gui.panelHandle1,...
                  'background',         [1 1 1],...
                  'style',              'edit',...
                  'horizontalAlignment','right',...
                  'Interruptible',      'off',...
                  'string',             value,...
                  'callback',           {@gui.set,'lineWidth'});
              
    end
           
    if strcmpi(plotterT.plotType,'scatter')
        
        % Line style
        %----------------------------------------------------------    
        kk = kk - 1;
        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle1,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Line Style'); 

        % Locate choosen
        lineStyles = {'none','-','--',':'};
        value      = find(strcmpi(plotterT.scatterLineStyle,lineStyles));
        if isempty(value)
            value = 1;
        end

        uicontrol(...
                  'units',              'normalized',...
                  'position',           [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',             gui.panelHandle1,...
                  'background',         [1 1 1],...
                  'style',              'popupmenu',...
                  'horizontalAlignment','right',...
                  'Interruptible',      'off',...
                  'string',             lineStyles,...
                  'value',              value,...
                  'callback',           {@gui.set,'scatterLineStyle'});
        
    end
    
    if strcmpi(plotterT.plotType,'line') || any(strcmpi(plotterT.plotTypes,'line')) || strcmpi(plotterT.plotType,'scatter')
              
        % Marker size 
        %--------------------------------------------------------------
        kk = kk - 1;

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Marker Size*');
         mSize = true;
         
         uicontrol(...
                  'units',              'normalized',...
                  'position',           [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',             uip,...
                  'background',         [1 1 1],...
                  'horizontalAlignment','right',...
                  'style',              'edit',...
                  'string',             num2str(plotterT.markerSize),....
                  'callback',           {@gui.set,'markerSize'});
    
              
    end
    
    if strcmpi(plotterT.plotType,'area') || any(strcmpi('area',plotterT.plotTypes(2:2:end)))
       
        kk = kk - 1;
        
        % Abrupt area 
        %----------------------------------------------------------      
        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle1,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Abrupt at nan'); 

        % Value choosen
        areaAbrupt  = plotterT.areaAbrupt;

        uicontrol(...
                  'units',              'normalized',...
                  'position',           [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',             gui.panelHandle1,...
                  'style',              'radiobutton',...
                  'horizontalAlignment','right',...
                  'Interruptible',      'off',...
                  'value',              areaAbrupt,...
                  'callback',           {@gui.set,'areaAbrupt'});
              
        kk = kk - 1;
        
        % Accumulate area 
        %----------------------------------------------------------      
        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle1,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Accumulate area'); 

        % Value choosen
        accumulate  = plotterT.areaAccumulate;

        uicontrol(...
                  'units',              'normalized',...
                  'position',           [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',             gui.panelHandle1,...
                  'style',              'radiobutton',...
                  'horizontalAlignment','right',...
                  'Interruptible',      'off',...
                  'value',              accumulate,...
                  'callback',           {@gui.set,'areaAccumulate'});
              
        % Face alpha
        %----------------------------------------------------------
        kk = kk - 1;
        uicontrol(nb_constant.LABEL,...
                  'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',   gui.panelHandle1,...
                  'string',   'Area alpha'); 

        % Value choosen
        areaAlpha  = plotterT.areaAlpha;

        uicontrol(nb_constant.EDIT,...
                  'position',  [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',    gui.panelHandle1,...
                  'string',    nb_num2str(areaAlpha),...
                  'callback',  {@gui.set,'areaAlpha'});
         
    end
    
    % Template note 
    %--------------------------------------------------------------
    % Message depend on what options are added to the panel
    if lWidth && mSize 
        nb_graphSettingsGUI.addTemplateFootnote(uip,true);
    elseif lWidth || mSize
        nb_graphSettingsGUI.addTemplateFootnote(uip,false);
    end
     
end
