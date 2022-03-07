function barAndAreaPanel(gui)
% Syntax:
%
% barAndAreaPanel(gui)
%
% Description:
%
% Part of DAG. Panel shown when the plot types 'grouped', 'area', 'dec'
% and 'stacked' are choosen
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isempty(gui.uip)

        tag = get(gui.uip,'tag');
        if strcmp(tag,'barOrArea')
            set(gui.uip,'visible','on');
            firstTime = 0;
        else
            delete(gui.uip);
            firstTime = 1;
        end

    else
        firstTime = 1;
    end

    % Get plotter object
    plotterT        = gui.plotter;
    datesVsDatePlot = 0;
    if isa(plotterT,'nb_graph_ts')
        if ~isempty(plotterT.datesToPlot)
            datesVsDatePlot = 1;
        end
    end
    
    % Get the variable selected
    string   = get(gui.popupmenu1,'string');
    index    = get(gui.popupmenu1,'value');
    variable = string{index};

    % Creat panel
    tHeight   = 0.04;
    startX    = 0.04;
    startY    = 0.85;
    startYB   = 0.04;

    if firstTime
        
        tit = 'Area/Bar Properties'; 
        gui.uip = uipanel('parent',              gui.figureHandle,...
                          'title',               tit,...
                          'units',               'normalized',...
                          'tag',                 'barOrArea',...
                          'position',            [startX, startYB, 0.92, startY - tHeight*4 - startYB]);
    end

    startPopX = 0.3;
    widthPop  = 0.35;
    heightPop = 0.09;
    startTX   = 0.04;
    widthT    = widthPop - startTX*2;
    heightT   = 0.06;
    widthB    = 1 - startPopX - widthPop - startTX*2;
    startB    = startPopX + widthPop + startTX;
    spaceYPop = (1 - heightPop*6)/7;
    extra     = (heightPop - heightT)/2;

    % Colors
    %--------------------------------------------------------------
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*5 + spaceYPop*6 + extra, widthT, heightT],...
                  'parent',                 gui.uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Select Color'); 

    end

    % Locate or give default color to the given variable
    [endc,value] = nb_locateColor(gui,variable);
    
    % Using html coding to get the background of the 
    % listbox colored  
    colors = nb_selectVariableGUI.htmlColors(endc);

    if firstTime

        pop3 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*5 + spaceYPop*6, widthPop, heightPop],...
                  'parent',         gui.uip,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         colors,...
                  'value',          value,....
                  'callback',       @gui.selectColor);
        gui.popupmenu3 = pop3;

        uicontrol(...
                  'units',          'normalized',...
                  'position',       [startB, heightPop*5 + spaceYPop*6, widthB, heightPop],...
                  'parent',         gui.uip,...
                  'style',          'pushbutton',...
                  'Interruptible',  'off',...
                  'busyAction',     'cancel',...
                  'string',         'Define',...
                  'enable',         'on',...
                  'callback',       {@nb_setDefinedColor,gui,pop3}); 

    else

        set(gui.popupmenu3,'value',value,'string',colors);

    end
    
    if (isa(plotterT,'nb_graph_ts') || isa(plotterT,'nb_graph_data')) && ~datesVsDatePlot
        
        ind = find(strcmp(variable,plotterT.plotTypes),1,'last');
        if isempty(ind)
            if strcmpi(plotterT.plotType,'area')
                enable = 'off';
            else
                enable = 'on';
            end
        else
            if strcmpi('area',plotterT.plotTypes{ind+1})
                enable = 'off';
            else
                enable = 'on';
            end 
        end
        
        plotterT.setSpecial('returnLocal',1);
        if isa(plotterT,'nb_graph_ts')
            ind   = find(strcmp(variable,plotterT.barShadingDate),1,'last'); 
            if isempty(ind)
                bDate = '';
            else
                bDate = plotterT.barShadingDate{ind + 1};
            end
        else
            ind = find(strcmp(variable,plotterT.barShadingObs),1,'last');
            if isempty(ind)
                bDate = '';
            else
                bDate = plotterT.barShadingObs{ind + 1};
            end
        end
        plotterT.setSpecial('returnLocal',0); 
        
        bDate = toString(bDate);
        
        if firstTime

            uicontrol('units',                  'normalized',...
                      'position',               [startTX, heightPop*4 + spaceYPop*5 + extra, widthT, heightT],...
                      'parent',                 gui.uip,...
                      'style',                  'text',...
                      'horizontalAlignment',    'left',...
                      'string',                 'Bar Shading Obs'); 

            
            ed = uicontrol(...
                      'units',          'normalized',...
                      'position',       [startPopX, heightPop*4 + spaceYPop*5, widthPop, heightPop],...
                      'parent',         gui.uip,...
                      'background',     [1 1 1],...
                      'style',          'edit',...
                      'Interruptible',  'off',...
                      'enable',         enable,...
                      'string',         bDate,...
                      'callback',       @gui.barShadingDateCallback);
            gui.editbox4 = ed;      

        else

            set(gui.editbox4,'string',bDate,'enable',enable);

        end
        
    end

end
