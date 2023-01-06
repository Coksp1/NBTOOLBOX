function updatePanel(gui,object,firstTime)
% Syntax:
%
% updatePanel(gui,object,firstTime)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen      

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(gui.panelHandle)
        firstTime = 1;
    end

    % Get plotter object
    plotterT = gui.plotter;
    parent   = plotterT.parent;

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
    
    % Get the index of the fake legend choosen, and its options
    index  = get(gui.popupmenu1,'value');
    value  = plotterT.highlight{index};
    color  = plotterT.highlightColor{index};

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
                  'enable',         'off',...
                  'callback',       {@nb_setDefinedColor,parent,pop2}); 

    else

        set(gui.popupmenu2,'value',valueColor,'string',colors);

    end
    
    
    % Line X-Axis value (1)
    %----------------------------------------------------------
    kk = kk - 1;
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'X-Axis Value 1');

    end

    value2 = '';
    enable     = 'off';
    if iscell(value)
        enable = 'on';
        value2 = value{2};
        value  = value{1};
    end

    if isnumeric(value)
        value = num2str(value);
    else
        value = checkInput(plotterT,value);     
    end

    if ~isempty(value2)
        if isnumeric(value2)
            value2 = num2str(value2);
        else
            value2 = checkInput(plotterT,value2);     
        end
    end

    
    if firstTime

        ed = uicontrol(...
                  'units',                  'normalized',...
                  'position',               [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',                 gui.panelHandle,...
                  'background',             [1 1 1],...
                  'Interruptible',          'off',...
                  'horizontalAlignment',    'right',...
                  'style',                  'edit',...
                  'string',                 value,....
                  'callback',               {@gui.setValue,1});  

        gui.editbox1 = ed; 

    else

        set(gui.editbox1,'string',value)

    end

    % Line X-Axis value (2)
    %----------------------------------------------------------
    kk = kk - 1;
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'X-Axis Value 2');

    end

    if firstTime

        ed = uicontrol(...
                  'units',                  'normalized',...
                  'position',               [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',                 gui.panelHandle,...
                  'background',             [1 1 1],...
                  'Interruptible',          'off',...
                  'horizontalAlignment',    'right',...
                  'style',                  'edit',...
                  'enable',                 enable,...
                  'string',                 value2,....
                  'callback',               {@gui.setValue,2});  

        gui.editbox2 = ed; 

    else

        set(gui.editbox2,'string',value2,'enable',enable)

    end
               
end


%==========================================================================
% Subfunctions
%==========================================================================
function value = checkInput(plotterT,value)

    if isa(plotterT,'nb_graph_ts')

        if isa(value,'nb_date')
            if strcmpi(plotterT.plotType,'scatter')
                value = value - plotterT.startGraph + 1;
                value = num2str(value);
            else
                value = value.toString();
            end
        else % string
            if strcmpi(plotterT.plotType,'scatter')
                
                % If we have switch from a normal plot to scatter we try to
                if isempty(strfind(string,'%#'));
                    try
                        value = nb_date.toDate(value,plotterT.DB.frequency) - plotterT.startGraph + 1;
                        value = num2str(value);
                    catch %#ok<CTCH>
                        value = '1';
                    end
                end
            end 
        end
        
    elseif isa(plotterT,'nb_graph_cs')

        if ~strcmpi(plotterT.plotType,'scatter')
            value = find(strcmp(value,plotterT.typesToPlot),1,'last');
            if isempty(value)
                value = 1;
            end
        end

    end
    
end
