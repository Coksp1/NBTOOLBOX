function linePanel(gui)
% Syntax:
%
% linePanel(gui)
%
% Description:
%
% Part of DAG. Panel with the line options
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isempty(gui.uip)

        tag = get(gui.uip,'tag');
        if strcmpi(tag,'line')
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
    plotterT = gui.plotter;
    
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

    % Create panel
    %--------------------------------------------------------------
    tHeight   = 0.04;
    startX    = 0.04;
    startY    = 0.85;
    startYB   = 0.04;

    if firstTime
        gui.uip = uipanel('parent',              gui.figureHandle,...
                          'title',               'Line Properties',...
                          'units',               'normalized',...
                          'tag',                 'line',...
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
    kk        = 5;
    spaceYPop = (1 - heightPop*kk)/(kk + 1);
    extra     = (heightPop - heightT)/2;
    
    
    % Colors
    %--------------------------------------------------------------
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
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
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
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
                  'position',       [startB, heightPop*(kk-1) + spaceYPop*kk, widthB, heightPop],...
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

    % Line Style  
    %--------------------------------------------------------------
    kk = kk - 1;
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Select Line Style');

    end

    lineStyles = {'-','--',':','-.','none'};          
    ind         = find(strcmp(variable,plotterT.lineStyles),1,'last');  
    splitted    = 0;
    
    if isa(plotterT,'nb_graph_ts')
        obsSecond = plotterT.endGraph.toString();
    elseif isa(plotterT,'nb_graph_data')
        obsSecond = int2str(plotterT.endGraph);
    else
        obsSecond = '';
    end
    if isempty(ind)
        plotterT.lineStyles = [plotterT.lineStyles,variable,'-'];
        value              = 1;
    else

        old = plotterT.lineStyles{ind + 1};
        if iscell(old)
            splitted  = 1;
            oldSecond = old{3};
            obsSecond = old{2};
            if isa(obsSecond,'nb_date')
                obsSecond = obsSecond.toString();
            elseif isnumeric(obsSecond)
                obsSecond = int2str(obsSecond);
            end
            old = old{1}; 
        end
        value = find(strcmp(old,lineStyles),1);
        
        if isempty(value)
            value = 2;
            if iscell(plotterT.lineStyles{ind + 1})
                plotterT.lineStyles{ind + 1}{1} = '--';
            else
                plotterT.lineStyles{ind + 1} = '--';
            end
        end

    end
    
    if firstTime

        pop4 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.uip,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         lineStyles,...
                  'value',          value,....
                  'callback',       @gui.selectLineStyle1);
        gui.popupmenu4 = pop4;

    else

        set(gui.popupmenu4,'value',value)

    end

    if (isa(plotterT,'nb_graph_ts') || isa(plotterT,'nb_graph_data')) && ~datesVsDatePlot
        
        if firstTime

            r1 = uicontrol(...
                      'units',          'normalized',...
                      'position',       [startB, heightPop*(kk-1) + spaceYPop*kk, widthB, heightPop],...
                      'parent',         gui.uip,...
                      'style',          'radiobutton',...
                      'Interruptible',  'off',...
                      'string',         'Split',...
                      'value',          splitted,...
                      'callback',       @gui.splitLine); 

            gui.radiobutton1 = r1;      

        else

            set(gui.radiobutton1,'value',splitted);

        end
        
    end
    
    % Line Style Second period
    %--------------------------------------------------------------
    if (isa(plotterT,'nb_graph_ts') || isa(plotterT,'nb_graph_data')) && ~datesVsDatePlot
    
        kk = kk - 1;
        if splitted
            value  = find(strcmp(oldSecond,lineStyles),1);
            if isempty(value)
                value = 2;
                plotterT.lineStyles{ind + 1}{2} = '--';
            end
            
            enable = 'on';
        else
            value = 1;
            enable = 'off';
        end

        if firstTime

            uicontrol('units',                  'normalized',...
                      'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                      'parent',                 gui.uip,...
                      'style',                  'text',...
                      'horizontalAlignment',    'left',...
                      'string',                 'Select Line Style 2'); 

            pop5 = uicontrol(...
                      'units',          'normalized',...
                      'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                      'parent',         gui.uip,...
                      'background',     [1 1 1],...
                      'style',          'popupmenu',...
                      'Interruptible',  'off',...
                      'string',         lineStyles,...
                      'value',          value,....
                      'enable',         enable,...
                      'callback',       @gui.selectLineStyle2);
            gui.popupmenu5 = pop5;      

            ed = uicontrol(...
                      'units',          'normalized',...
                      'position',       [startB, heightPop*(kk-1) + spaceYPop*kk, widthB, heightPop],...
                      'parent',         gui.uip,...
                      'background',     [1 1 1],...
                      'style',          'edit',...
                      'Interruptible',  'off',...
                      'string',         obsSecond,...
                      'enable',         enable,...
                      'callback',       @gui.changeSplitDate);
            gui.editbox1 = ed;

        else

            set(gui.popupmenu5,'value',value,'enable',enable);
            set(gui.editbox1,'string',obsSecond,'enable',enable);

        end
        
    end

    % Line width
    %--------------------------------------------------------------
    if ~strcmpi(plotterT.plotType,'radar')
    
        kk = kk - 1;
        ind  = find(strcmp(variable,plotterT.lineWidths),1,'last');   
        if isempty(ind)
            lineWidth = num2str(plotterT.lineWidth);
        else
            lineWidth = num2str(plotterT.lineWidths{ind + 1});
        end

        if firstTime

            uicontrol('units',                  'normalized',...
                      'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                      'parent',                 gui.uip,...
                      'style',                  'text',...
                      'horizontalAlignment',    'left',...
                      'string',                 'Line Width');

            ed = uicontrol(...
                      'units',          'normalized',...
                      'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                      'parent',         gui.uip,...
                      'background',     [1 1 1],...
                      'style',          'edit',...
                      'Interruptible',  'off',...
                      'string',         lineWidth,....
                      'callback',       @gui.setLineWidth);  

            gui.editbox2 = ed; 

        else

            set(gui.editbox2,'string',lineWidth);

        end
        
    end

    % Marker type
    %--------------------------------------------------------------
    if ~strcmpi(plotterT.plotType,'radar')
    
        kk = kk - 1;
        markers = {'none','+','o','*','.','x','square','diamond','^','v','>','<','pentagram','hexagram'};          
        ind     = find(strcmp(variable,plotterT.markers),1,'last');   
        if isempty(ind)
            value = 1;
        else
            old   = plotterT.markers{ind + 1};
            value = find(strcmp(old,markers),1);
        end

        if firstTime

            uicontrol('units',                  'normalized',...
                      'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                      'parent',                 gui.uip,...
                      'style',                  'text',...
                      'horizontalAlignment',    'left',...
                      'string',                 'Markers');

            pop6 = uicontrol(...
                      'units',          'normalized',...
                      'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                      'parent',         gui.uip,...
                      'background',     [1 1 1],...
                      'style',          'popupmenu',...
                      'Interruptible',  'off',...
                      'string',         markers,...
                      'value',          value,....
                      'callback',       {@gui.selectMarker,'1'});
            gui.popupmenu6 = pop6;
            
        else
            set(gui.popupmenu6,'value',value);
        end
        
    end
    
    if (isa(plotterT,'nb_graph_ts') || isa(plotterT,'nb_graph_data')) && ~datesVsDatePlot
        
        ind = find(strcmp([variable '(2)'],plotterT.markers),1,'last');   
        if isempty(ind)
            value = 1;
        else
            old   = plotterT.markers{ind + 1};
            value = find(strcmp(old,markers),1);
        end
        
        if firstTime
            
            pop11 = uicontrol(...
                      'units',          'normalized',...
                      'position',       [startPopX+widthPop+0.01, heightPop*(kk-1) + spaceYPop*kk, widthPop-0.02, heightPop],...
                      'parent',         gui.uip,...
                      'background',     [1 1 1],...
                      'style',          'popupmenu',...
                      'Interruptible',  'off',...
                      'enable',         enable,...
                      'string',         markers,...
                      'value',          value,....
                      'callback',       {@gui.selectMarker,'2'});
            gui.popupmenu11 = pop11; 
            
        else
            set(gui.popupmenu11,'value',value,'enable',enable);
        end
        
    end

end
