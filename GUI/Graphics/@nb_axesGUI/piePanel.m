function piePanel(gui)
% Syntax:
%
% piePanel(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Get graph object 
    plotter = gui.plotter;

    % Positions
    startPopX = 0.35;
    widthPop  = 0.35;
    heightPop = 0.045;
    startTX   = 0.04;
    widthT    = widthPop - startTX;
    heightT   = 0.04;
    widthB    = 1 - startPopX - widthPop - startTX*2;
    startB    = startPopX + widthPop + startTX;
    kk        = 12; 
    spaceYPop = (1 - heightPop*kk)/(kk + 1);
    extra     = -(heightPop - heightT);
    
    % Types to plot
    %--------------------------------------------------------------
    if strcmpi(gui.plotter.plotType,'pie')
    
        % Get all the types plotted
        typesOfData = plotter.DB.types;
        typesToPlot = plotter.typesToPlot; 
        index       = find(ismember(typesOfData,typesToPlot));

        uicontrol(gui.buttonPanel, nb_constant.LABEL,...
                  'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'button',   'Pie/Donut',...
                  'string',   'Type to plot');

        uicontrol(gui.buttonPanel, nb_constant.POPUP,...
              'position',  [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'button',    'Pie/Donut',...
              'string',    typesOfData,...
              'value',     index,....
              'callback',  @gui.setPieType);
        kk = kk - 1;
        
    else
        
        uicontrol(gui.buttonPanel, nb_constant.LABEL,...
                  'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'button',   'Pie/Donut',...
                  'string',   'Radius');

        uicontrol(gui.buttonPanel, nb_constant.EDIT,...
              'position',  [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'button',    'Pie/Donut',...
              'string',    num2str(plotter.donutRadius),...
              'callback',  {@gui.set,'donutradius'});
        kk = kk - 1;
        
        uicontrol(gui.buttonPanel, nb_constant.LABEL,...
                  'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'button',   'Pie/Donut',...
                  'string',   'Inner radius');

        uicontrol(gui.buttonPanel, nb_constant.EDIT,...
              'position',  [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'button',    'Pie/Donut',...
              'string',    num2str(plotter.donutInnerRadius),...
              'callback',  {@gui.set,'donutinnerradius'});
        kk = kk - 1;
        
    end
          
    % Label Extension
    %--------------------------------------------------------------
    pieLabelsExtension = plotter.pieLabelsExtension;
    
    uicontrol(gui.buttonPanel, nb_constant.LABEL,...
              'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
              'button',   'Pie/Donut',...
              'string',   'Labels Extension');
    
    uicontrol(gui.buttonPanel, nb_constant.EDIT,...
              'position',   [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
              'button',     'Pie/Donut',...
              'string',     pieLabelsExtension,...
              'callback',   @gui.setPieLabelsExtension);
          
    % pieAxisVisible
    %--------------------------------------------------------------
    if isprop(plotter,'pieAxisVisible')
    
        kk = kk - 1;
        value = find(strcmpi(plotter.pieAxisVisible,{'on','off'}));
        if isempty(value)
            value = 1;
        end
        uicontrol(gui.buttonPanel, nb_constant.LABEL,...
                  'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'button',   'Pie/Donut',...
                  'string',   'Axis visible');

        uicontrol(gui.buttonPanel, nb_constant.POPUP,...
                  'position',           [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'button',             'Pie/Donut',...
                  'string',             {'on','off'},...
                  'value',              value,...
                  'callback',           {@gui.set,'pieAxisVisible'});
              
    end
    
    % pieOrigoPosition
    %--------------------------------------------------------------
    if isprop(plotter,'pieOrigoPosition')
    
        if isempty(plotter.pieOrigoPosition)
            % This is the default position
            plotter.pieOrigoPosition = [-0.5,0];
        end
        kk    = kk - 1;
        value = num2str(plotter.pieOrigoPosition(1));
        uicontrol(gui.buttonPanel, nb_constant.LABEL,...
                  'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'button',   'Pie/Donut',...
                  'string',   'Pie origo position (X-axis)');

        uicontrol(gui.buttonPanel, nb_constant.EDIT,...
                  'position',    [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'button',      'Pie/Donut',...
                  'string',      value,...
                  'callback',    {@gui.set,'pieOrigoPositionX'});
              
        kk    = kk - 1;
        value = num2str(plotter.pieOrigoPosition(2));
        uicontrol(gui.buttonPanel, nb_constant.LABEL,...
                  'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'button',   'Pie/Donut',...
                  'string',   'Pie origo position (Y-axis)');

        uicontrol(gui.buttonPanel, nb_constant.EDIT,...
                  'position',    [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'button',      'Pie/Donut',...
                  'string',      value,...
                  'callback',    {@gui.set,'pieOrigoPositionY'});      
              
    end
    
    % Colors
    %--------------------------------------------------------------
    if isprop(plotter,'pieEdgeColor')
        
        kk = kk - 1;
        
        % Locate or give default color to the given variable
        [endc,value] = locateColor(gui);
        
        % Using html coding to get the background of the 
        % listbox colored  
        colors = nb_selectVariableGUI.htmlColors(endc);
        colors = [colors;{'none'}];
        if value == 0 
            value = length(colors);
        end
        
        % UI controls
        uicontrol(gui.buttonPanel, nb_constant.LABEL,...
                  'position', [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'button',   'Pie/Donut',...
                  'string',   'Select Color');
        
        selected = uicontrol(gui.buttonPanel,nb_constant.POPUP,...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'string',         colors,...
                  'value',          value,....
                  'callback',       @gui.selectColor);

        uicontrol(gui.buttonPanel,nb_constant.BUTTON,...
                  'position',       [startB, heightPop*(kk-1) + spaceYPop*kk, widthB, heightPop],...
                  'string',         'Define',...
                  'callback',       {@nb_setDefinedColor,gui,selected}); 

    end


end