function updateFakeLegendPanel(gui,fakeLegend,firstTime)
% Syntax:
%
% updateFakeLegendPanel(gui,fakeLegend,firstTime)
%
% Description:
%
% Part of DAG. Update the fake legend options panel 
% 
% Written by Kenneth Sæterhagen Paulsen     

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.panelHandle4)
        firstTime = 1;
    end

    % Get plotter object
    plotterT = gui.plotter;

    if strcmpi(fakeLegend,' ')
        if ~isempty(gui.panelHandle4)
            set(gui.panelHandle4,'visible','off');
        end
        return
    else
        if ~isempty(gui.panelHandle4)
            set(gui.panelHandle4,'visible','on');
        end    
    end
    
    % Get the index of the fake legend choosen, and its options
    index   = find(strcmpi(fakeLegend,plotterT.fakeLegend));
    options = plotterT.fakeLegend{index+1};
    
    % Create panel
    %--------------------------------------------------------------
    tHeight   = 0.04;
    startX    = 0.04;
    startY    = 0.85;
    startYB   = 0.04;

    if firstTime
        gui.panelHandle4 = uipanel(...
                          'parent',              gui.panelHandle3,...
                          'title',               'Fake Legend Properties',...
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
    kk        = 9;
    spaceYPop = (1 - heightPop*kk)/(kk + 1);
    extra     = (heightPop - heightT)/2;
    
    % Fake Legend Type 
    %--------------------------------------------------------------
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle4,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Type');

    end

    types = {'line','patch'};          
    ind   = find(strcmpi('type',options),1);   
    if isempty(ind)
        value = 1;
        type  = 'line';
    else

        type  = options{ind + 1};
        value = find(strcmpi(type,types),1);

    end

    if firstTime

        pop3 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.panelHandle4,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         types,...
                  'value',          value,...
                  'callback',       {@gui.setFakeLegendProperty,'type'});
        gui.popupmenu3 = pop3;

    else

        set(gui.popupmenu3,'value',value)

    end
    
    % Fake Legend Color 1
    %--------------------------------------------------------------
    kk = kk - 1;
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle4,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Color'); 

    end

       
    % Locate or give default color to the variable
    parent     = plotterT.parent;
    endc       = nb_getGUIColorList(gui,parent);
    ind        = find(strcmpi('color',options),1); 
    colorTemp2 = [];
    if isempty(ind)
        valueColor1 = 12;
    else
        % Locate the selected color in the color list
        colorTemp = options{ind + 1};
        if isnumeric(colorTemp)
            if size(colorTemp,1) > 1
                colorTemp2 = colorTemp(2,:);
                colorTemp  = colorTemp(1,:);
            end
        else
            if (size(colorTemp,2) > 1) && iscell(colorTemp)
                colorTemp2 = colorTemp{2};
                colorTemp  = colorTemp{1};
            end
        end
        valueColor1 = nb_findColor(colorTemp,endc);
        if valueColor1 == 0
            [endc,valueColor1] = nb_addColor(gui,parent,endc,colorTemp);
        end
        if ~isempty(colorTemp2)
            value2 = nb_findColor(colorTemp2,endc);
            if value2 == 0
                [endc,value2] = nb_addColor(gui,parent,endc,colorTemp2);
            end
        end
        
    end
    
    % Using html coding to get the background of the 
    % listbox colored  
    colors = nb_selectVariableGUI.htmlColors(endc);

    if firstTime

        pop4 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.panelHandle4,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'tag',            'first',...
                  'string',         colors,...
                  'value',          valueColor1,...
                  'callback',       @gui.selectFakeLegendColor);
        gui.popupmenu4 = pop4;

        def = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startB, heightPop*(kk-1) + spaceYPop*kk, widthB, heightPop],...
                  'parent',         gui.panelHandle4,...
                  'style',          'pushbutton',...
                  'Interruptible',  'off',...
                  'busyAction',     'cancel',...
                  'string',         'Define'); 

    else

        set(gui.popupmenu4,'value',valueColor1,'string',colors);

    end
    
    % Fake Legend Color 2
    %--------------------------------------------------------------
    kk = kk - 1;
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle4,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Shading Color'); 

    end
    
    if isempty(colorTemp2)
        value2 = nb_findColor([1 1 1],endc);
        if value2 == 0
            [endc,value2] = nb_addColor(gui,parent,endc,[1 1 1]);
        end
        valueR = 0;
        enable = 'off';
    else
        enable = 'on';
        valueR = 1;
    end
    colors = nb_selectVariableGUI.htmlColors(endc);
    
    if firstTime

        pop5 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.panelHandle4,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         colors,...
                  'value',          value2,...
                  'enable',         enable,...
                  'tag',            'second',...
                  'callback',       @gui.selectFakeLegendColor);
        gui.popupmenu5 = pop5;

        rb2 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startB, heightPop*(kk-1) + spaceYPop*kk, widthB, heightPop],...
                  'parent',         gui.panelHandle4,...
                  'style',          'radiobutton',...
                  'Interruptible',  'off',...
                  'string',         'Shaded Color',...
                  'value',          valueR,...
                  'callback',       @gui.addShadingColor); 
        gui.radiobutton2 = rb2;

    else

        set(gui.popupmenu5,'value',value2,'string',colors,'enable',enable);
        set(gui.radiobutton2,'value',valueR)

    end
    
    % Direction
    %--------------------------------------------------------------
    kk = kk - 1;
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle4,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Direction');

    end

    directions = {'north','south','west','east'};          
    ind        = find(strcmpi('direction',options),1);   
    if isempty(ind)
        value = 1;
    else
        direction  = options{ind + 1};
        value      = find(strcmpi(direction,directions),1);
    end

    if firstTime

        pop6 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.panelHandle4,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         directions,...
                  'value',          value,...
                  'callback',       {@gui.setFakeLegendProperty,'direction'});
        gui.popupmenu6 = pop6;

    else

        set(gui.popupmenu6,'value',value)

    end
    
    % Fake Legend Line Style
    %--------------------------------------------------------------
    kk = kk - 1;
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle4,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Line Style');

    end

    lineStyles = {'-','--',':','-.','---','none'};       
    ind        = find(strcmpi('linestyle',options),1);   
    if isempty(ind)
        value = 1;
    else
        lineStyle  = options{ind + 1};
        value      = find(strcmpi(lineStyle,lineStyles),1);
    end

    if firstTime

        pop7 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.panelHandle4,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         lineStyles,...
                  'value',          value,...
                  'callback',       {@gui.setFakeLegendProperty,'lineStyle'});
        gui.popupmenu7 = pop7;

    else

        set(gui.popupmenu7,'value',value)

    end
    
    % Fake Legend Line Width
    %--------------------------------------------------------------
    kk = kk - 1;
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle4,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Line Width');

    end
      
    ind = find(strcmpi('linewidth',options),1);   
    if isempty(ind)
        lineWidth = num2str(plotterT.lineWidth);
    else
        lineWidth  = num2str(options{ind + 1});
    end

    if firstTime

        ed = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.panelHandle4,...
                  'background',     [1 1 1],...
                  'Interruptible',  'off',...
                  'style',          'edit',...
                  'string',         lineWidth,...
                  'callback',       @gui.setFakeLegendLineWidth);  

        gui.editbox3 = ed; 

    else

        set(gui.editbox3,'string',lineWidth)

    end

    % Fake Legend Marker
    %--------------------------------------------------------------
    kk = kk - 1;
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle4,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Marker');

    end

    markers = {'none','+','o','*','.','x','square','diamond','^','v','>','<','pentagram','hexagram'};               
    ind     = find(strcmpi('marker',options),1);   
    if isempty(ind)
        value = 1;
    else
        marker  = options{ind + 1};
        value   = find(strcmpi(marker,markers),1);
    end

    if firstTime

        pop8 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.panelHandle4,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         markers,...
                  'value',          value,...
                  'callback',       {@gui.setFakeLegendProperty,'marker'});
        gui.popupmenu8 = pop8;

    else

        set(gui.popupmenu8,'value',value)

    end
    
    % Fake Legend Edge Color
    %--------------------------------------------------------------
    kk = kk - 1;
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle4,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Edge Color'); 

    end

    % Locate or give default color to the variable
    endc = nb_getGUIColorList(gui,parent);
    ind  = find(strcmpi('edgecolor',options),1); 
    if isempty(ind)
        value = [];
    else
        % Locate the selected color in the color list
        colorTemp = options{ind + 1};
        if strcmpi(colorTemp,'same')
            value = [];
        else
            value = nb_findColor(colorTemp,endc);
            if value == 0
                [endc,value] = nb_addColor(gui,parent,endc,colorTemp);
            end
        end
    end
    
    % Using html coding to get the background of the 
    % listbox colored  
    colors = nb_selectVariableGUI.htmlColors(endc);
    colors = [colors; {'same'}];
    if isempty(value)
        value = size(colors,1); % Same is chosen
    end   

    if firstTime

        pop9 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.panelHandle4,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         colors,...
                  'value',          value,...
                  'callback',       @gui.selectFakeLegendEdgeColor);
        gui.popupmenu9 = pop9;

        def2 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startB, heightPop*(kk-1) + spaceYPop*kk, widthB, heightPop],...
                  'parent',         gui.panelHandle4,...
                  'style',          'pushbutton',...
                  'Interruptible',  'off',...
                  'busyAction',     'cancel',...
                  'string',         'Define'); 

    else

        set(gui.popupmenu9,'value',value,'string',colors);

    end
    
    % Fake Legend font Color
    %--------------------------------------------------------------
    kk = kk - 1;
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle4,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Font Color'); 

    end
    
    % Locate or give default color to the variable
    endc = nb_getGUIColorList(gui,parent);
    ind  = find(strcmpi('fontcolor',options),1); 
    if isempty(ind)
        value = nb_findColor([0,0,0],endc);
        if value == 0
            [endc,value] = nb_addColor(gui,parent,endc,[0,0,0]);
        end
    else
        % Locate the selected color in the color list
        colorTemp = options{ind + 1};
        if size(colorTemp,1) > 1 && isnumeric(colorTemp)
            colorTemp = colorTemp(1,:);
        end
        value = nb_findColor(colorTemp,endc);
        if value == 0
            [endc,value] = nb_addColor(gui,parent,endc,colorTemp);
        end
    end
    
    % Using html coding to get the background of the 
    % listbox colored  
    colors = nb_selectVariableGUI.htmlColors(endc);
    if firstTime

        pop10 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.panelHandle4,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         colors,...
                  'value',          value,...
                  'callback',       @gui.selectFakeLegendFontColor);
        gui.popupmenu10 = pop10;

        def3 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startB, heightPop*(kk-1) + spaceYPop*kk, widthB, heightPop],...
                  'parent',         gui.panelHandle4,...
                  'style',          'pushbutton',...
                  'Interruptible',  'off',...
                  'busyAction',     'cancel',...
                  'string',         'Define'); 

    else
        set(gui.popupmenu9,'value',value,'string',colors);
    end
    
    % Set define callback function
    %--------------------------------------------------------------
    if firstTime
        set(def,'callback',{@nb_setDefinedColor,gui,gui.popupmenu4,gui.popupmenu5,gui.popupmenu9,gui.popupmenu10});
        set(def2,'callback',{@nb_setDefinedColor,gui,gui.popupmenu4,gui.popupmenu5,gui.popupmenu9,gui.popupmenu10});
        set(def3,'callback',{@nb_setDefinedColor,gui,gui.popupmenu4,gui.popupmenu5,gui.popupmenu9,gui.popupmenu10});
    end

    % Some options are not aplicable for the given types
    if strcmpi(type,'line')
        set(gui.popupmenu5,'enable','off');
        set(gui.radiobutton2,'enable','off');
        set(gui.popupmenu6,'enable','off');
        set(gui.popupmenu8,'enable','on');
        set(gui.popupmenu9,'enable','off');
    else
        if get(gui.radiobutton2,'value')
            set(gui.popupmenu5,'enable','on');
        else
            set(gui.popupmenu5,'enable','off');
        end
        set(gui.radiobutton2,'enable','on');
        set(gui.popupmenu6,'enable','on');
        set(gui.popupmenu8,'enable','off');
        set(gui.popupmenu9,'enable','on');
    end

end
