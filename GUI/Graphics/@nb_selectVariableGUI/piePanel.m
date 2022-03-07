function piePanel(gui)
% Syntax:
%
% piePanel(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isempty(gui.uip)
        tag = get(gui.uip,'tag');
        if strcmp(tag,'pie')
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
        
        tit = 'Slice Properties';

        gui.uip = uipanel('parent',              gui.figureHandle,...
                          'title',               tit,...
                          'units',               'normalized',...
                          'tag',                 'barOrArea',...
                          'position',            [startX, startYB, 0.92, startY - tHeight*4 - startYB]);
    end

    column2X    = 0.3;
    column2W    = 0.35;
    controlH    = 0.09;
    column1X    = 0.04;
    column1W    = column2W - column1X*2;
    labelH      = 0.06;
    column3W    = 1 - column2X - column2W - column1X*2;
    column3X    = column2X + column2W + column1X;
    spaceY      = (1 - controlH*6)/7;
    extra       = (controlH - labelH)/2;

    % Colors
    %--------------------------------------------------------------
     % Locate or give default color to the given variable
    [endc,value] = nb_locateColor(gui,variable);
    
    % Using html coding to get the background of the 
    % listbox colored  
    colors = nb_selectVariableGUI.htmlColors(endc);
    
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [column1X, controlH*5 + spaceY*6 + extra, column1W, labelH],...
                  'parent',                 gui.uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Select Color'); 
              
        gui.popupmenu3 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [column2X, controlH*5 + spaceY*6, column2W, controlH],...
                  'parent',         gui.uip,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         colors,...
                  'value',          value,....
                  'callback',       @gui.selectColor);

        uicontrol(...
                  'units',          'normalized',...
                  'position',       [column3X, controlH*5 + spaceY*6, column3W, controlH],...
                  'parent',         gui.uip,...
                  'style',          'pushbutton',...
                  'Interruptible',  'off',...
                  'busyAction',     'cancel',...
                  'string',         'Define',...
                  'enable',         'off',...
                  'callback',       {@nb_setDefinedColor,gui,gui.popupmenu3});

    else
        set(gui.popupmenu3,'value',value,'string',colors);
    end
    
    % Explode toggle
    isExploded = any(strcmp(variable, plotterT.pieExplode));
    if firstTime
        uicontrol('units',                  'normalized',...
                  'position',               [column1X, controlH*4 + spaceY*5 + extra, column1W, labelH],...
                  'parent',                 gui.uip,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Explode');
              
        gui.checkbox1 = uicontrol(...
            'parent',   gui.uip,...
            'style',    'checkbox',...
            'units',    'norm',...
            'position', [column2X, controlH*4 + spaceY*5, column3W, controlH],...
            'value',    isExploded,...
            'callback', {@gui.setPieExplode, variable});
    else
        set(gui.checkbox1, 'value', isExploded);
    end

end
