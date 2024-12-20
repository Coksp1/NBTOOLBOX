function scatterPanel(gui)
% Syntax:
%
% scatterPanel(gui)
%
% Description:
%
% Part of DAG. Create option panel for scatter plots 
% 
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isempty(gui.uip)
        if ishandle(gui.uip)
            delete(gui.uip);
        end
    end

    % Get plotter object
    plotter = gui.plotter;

    % Get the scatter group selected
    string = get(gui.popupmenu1,'string');
    index  = get(gui.popupmenu1,'value');
    group  = string{index};
    side   = gui.scatterSide;
    if strcmpi(group,' ')
        return
    end

    % Creat panel
    tHeight   = 0.04;
    startX    = 0.04;
    startY    = 0.85;
    startYB   = 0.04;

    gui.uip = uipanel('parent',              gui.figureHandle,...
                      'title',               'Scatter Properties',...
                      'units',               'normalized',...
                      'tag',                 'line',...
                      'position',            [startX, startYB, 1 - startX*2, startY - tHeight*4 - startYB]);

    startPopX = 0.3;
    widthPop  = 0.35;
    heightPop = 0.09;
    startTX   = 0.04;
    widthT    = widthPop - startTX*2;
    heightT   = 0.06;
    widthB    = 1 - startPopX - widthPop - startTX*2;
    startB    = startPopX + widthPop + startTX;
    kk        = 6;
    spaceYPop = (1 - heightPop*kk)/(kk + 1);
    extra     = (heightPop - heightT)/2;

    if isa(plotter,'nb_graph_ts') || isa(plotter,'nb_graph_data')
    
        % Scatter variable 1 
        %----------------------------------------------------------
        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk - 1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Scatter variable 1');

        group = nb_getUIControlValue(gui.popupmenu1);      
        if strcmpi(side,'left')
            scaVars = plotter.scatterVariables;
            gInd    = find(strcmpi(group,plotter.scatterDates(1:2:end)),1);
        else
            scaVars = plotter.scatterVariablesRight;
            gInd    = find(strcmpi(group,plotter.scatterDatesRight(1:2:end)),1);
        end

        variable1 = scaVars{gInd}{1};
        variables = plotter.DB.variables;   
        ind       = find(strcmp(variable1,variables),1,'last');   
        value     = ind;

        pop3 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk - 1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.uip,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         variables,...
                  'value',          value,....
                  'callback',       @gui.selectScatterVariable1);
        gui.popupmenu3 = pop3; 

        % Scatter variable 2
        %----------------------------------------------------------
        kk = kk - 1;
        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk - 1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Scatter variable 2');


        variable2 = scaVars{gInd}{2};
        ind       = find(strcmp(variable2,variables),1,'last');   
        value     = ind;

        pop4 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk - 1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.uip,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         variables,...
                  'value',          value,....
                  'callback',       @gui.selectScatterVariable2);
        gui.popupmenu4 = pop4;  

        % Start date
        %----------------------------------------------------------
        kk = kk - 1;
        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk - 1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Start obs');

        if isa(plotter,'nb_graph_ts')
            
            if strcmpi(side,'left')  
                ind    = find(strcmp(group,plotter.scatterDates),1,'last');
                scaObs = plotter.scatterDates{ind + 1};
            else
                ind    = find(strcmp(group,plotter.scatterDatesRight),1,'last');
                scaObs = plotter.scatterDatesRight{ind + 1};
            end
            
        else % nb_graph_data
            
            if strcmpi(side,'left')  
                ind    = find(strcmp(group,plotter.scatterObs),1,'last');
                scaObs = plotter.scatterObs{ind + 1};
            else
                ind    = find(strcmp(group,plotter.scatterObsRight),1,'last');
                scaObs = plotter.scatterObsRight{ind + 1};
            end
            
        end

        start = scaObs{1}; 
        if isa(start,'nb_date')
            start = start.toString();
        elseif isnumeric(start)
            start = num2str(start);
        end
        
        ed = uicontrol(...
                  'units',                  'normalized',...
                  'position',               [startPopX, heightPop*(kk - 1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',                 gui.uip,...
                  'background',             [1 1 1],...
                  'style',                  'edit',...
                  'Interruptible',          'off',...
                  'horizontalAlignment',    'left',...
                  'string',                 start,....
                  'callback',               @gui.setScatterStartDate);
        gui.editbox2 = ed;

        if isa(plotter,'nb_graph_ts')
            exampleObs = plotter.DB.startDate.toString();
        else
            exampleObs = int2str(plotter.DB.startObs); 
        end
        uicontrol('units',                  'normalized',...
                  'position',               [startB, heightPop*(kk - 1) + spaceYPop*kk + extra, widthB, heightT],...
                  'parent',                 gui.uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 ['E.g. ' exampleObs]);

        % End date
        %----------------------------------------------------------
        kk = kk - 1;
        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk - 1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'End date');

        endD = scaObs{2}; 
        if isa(endD,'nb_date')
            endD = endD.toString();
        elseif isnumeric(endD)
            endD = num2str(endD);
        end
        
        ed = uicontrol(...
                  'units',                  'normalized',...
                  'position',               [startPopX, heightPop*(kk - 1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',                 gui.uip,...
                  'background',             [1 1 1],...
                  'style',                  'edit',...
                  'Interruptible',          'off',...
                  'horizontalAlignment',    'left',...
                  'string',                 endD,....
                  'callback',               @gui.setScatterEndDate);
        gui.editbox3 = ed;

        if isa(plotter,'nb_graph_ts')
            exampleObs = plotter.DB.endDate.toString();
        else
            exampleObs = int2str(plotter.DB.endObs); 
        end
        uicontrol('units',                  'normalized',...
                  'position',               [startB, heightPop*(kk - 1) + spaceYPop*kk + extra, widthB, heightT],...
                  'parent',                 gui.uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 ['E.g. ' exampleObs]);   
              
    else
        
        % Scatter type 1 
        %----------------------------------------------------------
        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk - 1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Scatter Type 1');

        if strcmpi(side,'left')
            scaT = plotter.scatterTypes;
        else
            scaT = plotter.sscatterTypesRight;
        end

        type1 = scaT{1};
        types = plotter.DB.types;   
        ind   = find(strcmp(type1,types),1,'last');   
        value = ind;

        pop3 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk - 1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.uip,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         types,...
                  'value',          value,....
                  'callback',       @gui.selectScatterType1);
        gui.popupmenu3 = pop3; 

        uicontrol('units',                  'normalized',...
                  'position',               [startB, heightPop*(kk - 1) + spaceYPop*kk + extra, widthB, heightT],...
                  'parent',                 gui.uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 '(All scatter groups)'); 

        % Scatter type 2
        %----------------------------------------------------------
        kk = kk - 1;
        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk - 1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Scatter type 2');


        type2 = scaT{2};
        ind   = find(strcmp(type2,types),1,'last');   
        value = ind;

        pop4 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk - 1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.uip,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         types,...
                  'value',          value,....
                  'callback',       @gui.selectScatterType2);
        gui.popupmenu4 = pop4;  

        uicontrol('units',                  'normalized',...
                  'position',               [startB, heightPop*(kk - 1) + spaceYPop*kk + extra, widthB, heightT],...
                  'parent',                 gui.uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 '(All scatter groups)');
              
    end

    % Colors
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol('units',                  'normalized',...
              'position',               [startTX, heightPop*(kk - 1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 gui.uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Select Color'); 
    
    % Locate or give default color to the given variable
    [endc,value] = nb_locateColor(gui,group);
    
    % Using html coding to get the background of the 
    % listbox colored  
    colors = nb_selectVariableGUI.htmlColors(endc);

    pop3 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk - 1) + spaceYPop*kk, widthPop, heightPop],...
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
              'position',       [startB, heightPop*(kk - 1) + spaceYPop*kk, widthB, heightPop],...
              'parent',         gui.uip,...
              'style',          'pushbutton',...
              'busyAction',     'cancel',...
              'Interruptible',  'off',...
              'string',         'Define',...
              'callback',       {@nb_setDefinedColor,gui,pop3});
          
    % Select scatter marker type
    %--------------------------------------------------------------
    kk = kk - 1;
    uicontrol('units',                  'normalized',...
              'position',               [startTX, heightPop*(kk - 1) + spaceYPop*kk + extra, widthT, heightT],...
              'parent',                 gui.uip,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 'Marker');

    markerTypes = {'o','s','.','x','+','^','v','<','>','*','d','h','p','none'};
    marks       = plotter.markers;
    ind         = find(strcmpi(group,marks),1,'last');
    if isempty(ind)
        value = 1;
    else
        value = find(strcmp(marks{ind + 1},markerTypes));
    end

    pop10 = uicontrol(...
              'units',          'normalized',...
              'position',       [startPopX, heightPop*(kk - 1) + spaceYPop*kk, widthPop, heightPop],...
              'parent',         gui.uip,...
              'background',     [1 1 1],...
              'style',          'popupmenu',...
              'Interruptible',  'off',...
              'string',         markerTypes,...
              'value',          value,....
              'callback',       @gui.selectScatterMarker);
    gui.popupmenu10 = pop10;  
          
    % Select scatter variables
    %--------------------------------------------------------------
    if isa(plotter,'nb_graph_cs')
        
        kk = kk - 2;
        uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk - 1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.uip,...
                  'style',          'pushbutton',...
                  'Interruptible',  'off',...
                  'string',         'Select variables',...
                  'callback',       @gui.selectScatterVariables); 
              
    end
          
    % Notify listeners if not beeing initialized
    %--------------------------------------------------------------
    if ~gui.initialized
        notify(gui,'changedGraph')
    else
        gui.initialized = 0;
    end  

end
