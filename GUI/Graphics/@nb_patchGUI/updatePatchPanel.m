function updatePatchPanel(gui,object,firstTime)
% Syntax:
%
% updatePatchPanel(gui,object,firstTime)
%
% Description:
%
% Part of DAG. Update the patch options panel  
% 
% Written by Kenneth Sæterhagen Paulsen   

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(gui.panelHandle)
        firstTime = 1;
    end

    % Get plotter object
    plotterT = gui.plotter;

    if strcmpi(object,' ')
        if ~isempty(gui.panelHandle)
            set(gui.panelHandle,'visible','off');
        end
        return
    else
        if ~isempty(gui.panelHandle)
            set(gui.panelHandle,'visible','on');
        end    
    end
    
    % Get the index of the patch object choosen, and its options
    index  = get(gui.popupmenu1,'value');
    var1   = plotterT.patch(index*4 - 2);
    var2   = plotterT.patch(index*4 - 1);
    color  = plotterT.patch{index*4};

    % Create panel
    %--------------------------------------------------------------
    tHeight   = 0.04;
    startX    = 0.04;
    startY    = 0.85;
    startYB   = 0.04;

    if firstTime
        gui.panelHandle = uipanel(...
                          'parent',              gui.figureHandle,...
                          'title',               'Properties',...
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
    kk        = 7;
    spaceYPop = (1 - heightPop*kk)/(kk + 1);
    extra     = (heightPop - heightT)/2;
    
    
    % Color
    %--------------------------------------------------------------
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Color'); 

    end

    % Locate the selected color in the color list
    parent     = plotterT.parent;
    endc       = nb_getGUIColorList(gui,parent);
    colorTemp  = color;
    valueColor = nb_findColor(colorTemp,endc);
    if valueColor == 0
        [endc,valueColor] = nb_addColor(gui,parent,endc,colorTemp);
    end
    
    % Using html coding to get the background of the 
    % listbox colored  
    colors = nb_selectVariableGUI.htmlColors(endc);

    if firstTime

        pop2 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.panelHandle,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'tag',            'first',...
                  'string',         colors,...
                  'value',          valueColor,....
                  'callback',       @gui.selectColor);
        gui.popupmenu2 = pop2;

        uicontrol(...
                  'units',          'normalized',...
                  'position',       [startB, heightPop*(kk-1) + spaceYPop*kk, widthB, heightPop],...
                  'parent',         gui.panelHandle,...
                  'style',          'pushbutton',...
                  'Interruptible',  'off',...
                  'busyAction',     'cancel',...
                  'string',         'Define',...
                  'callback',       {@nb_setDefinedColor,gui,pop2}); 

    else

        set(gui.popupmenu2,'value',valueColor,'string',colors);

    end
    
    % Variable 1
    %--------------------------------------------------------------
    kk = kk - 1;
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Variable 1');

    end

    variables  = plotterT.DB.variables;     
    value      = find(strcmp(var1,variables),1);

    if firstTime

        pop = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.panelHandle,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         variables,...
                  'value',          value,....
                  'callback',       {@gui.setValue,1});
        gui.popupmenu3 = pop;

    else

        set(gui.popupmenu3,'value',value)

    end
    
    % Variable 2
    %--------------------------------------------------------------
    kk = kk - 1;
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Variable 2');

    end
    
    value      = find(strcmp(var2,variables),1);

    if firstTime

        pop = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.panelHandle,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         variables,...
                  'value',          value,....
                  'callback',       {@gui.setValue,2});
        gui.popupmenu4 = pop;

    else

        set(gui.popupmenu4,'value',value)

    end
                
end
