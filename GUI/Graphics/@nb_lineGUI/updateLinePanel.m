function updateLinePanel(gui,lineObject,firstTime)
% Syntax:
%
% updateLinePanel(gui,lineObject,firstTime)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen      

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(gui.panelHandle)
        firstTime = 1;
    end

    % Get plotter object
    plotterT = gui.plotter;

    if strcmpi(lineObject,' ')
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
    index = get(gui.popupmenu1,'value');
    if strcmpi(gui.type,'horizontal')
        
        valueLine = plotterT.horizontalLine(index);
        color     = plotterT.horizontalLineColor{index};
        lineStyle = plotterT.horizontalLineStyle{index};
        lineWidth = plotterT.horizontalLineWidth;
        limits    = [];
        
    elseif strcmpi(gui.type,'vertical')
        
        valueLine = plotterT.verticalLine{index};
        color     = plotterT.verticalLineColor{index};
        lineStyle = plotterT.verticalLineStyle{index};
        lineWidth = plotterT.verticalLineWidth;
        try
            limits = plotterT.verticalLineLimit{index};
        catch %#ok<CTCH>
            limits = {};
        end
        
    else
    
        % Update here ??????????????????????
        
    end
    
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
                  'callback',       @gui.selectLineColor);
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
                  'callback',       {@nb_setDefinedColor,gui,pop2}); 

    else

        set(gui.popupmenu2,'value',valueColor,'string',colors);

    end
    
    % Line Style
    %--------------------------------------------------------------
    kk = kk - 1;
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Line Style');

    end

    lineStyles = {'-','--',':','-.','none'};       
    value      = find(strcmpi(lineStyle,lineStyles),1);

    if isempty(value)
        
        value = 2;
        if strcmpi(gui.type,'horizontal')
            plotterT.horizontalLineStyle{index} = '--';
        elseif strcmpi(gui.type,'vertical')
            plotterT.verticalLineStyle{index} = '--';
        else
            % Update here?????????????????
        end
        
    end
    
    if firstTime

        pop3 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startPopX, heightPop*(kk-1) + spaceYPop*kk, widthPop, heightPop],...
                  'parent',         gui.panelHandle,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         lineStyles,...
                  'value',          value,....
                  'callback',       @gui.setLineStyle);
        gui.popupmenu3 = pop3;

    else

        set(gui.popupmenu3,'value',value)

    end
    
    % Line Width
    %--------------------------------------------------------------
    kk = kk - 1;
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                  'parent',                 gui.panelHandle,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Line Width (All)');

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
                  'string',                 lineWidth,....
                  'callback',               @gui.setLineWidth);  

        gui.editbox1 = ed; 

    else

        set(gui.editbox1,'string',lineWidth)

    end

    if strcmpi(gui.type,'horizontal')
    
        % Line Y-Axis value
        %----------------------------------------------------------
        kk = kk - 1;
        if firstTime

            uicontrol('units',                  'normalized',...
                      'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                      'parent',                 gui.panelHandle,...
                      'style',                  'text',...
                      'horizontalAlignment',    'left',...
                      'string',                 'Y-Axis Value');

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
                      'string',                 valueLine,....
                      'callback',               @gui.setLineValue);  

            gui.editbox2 = ed; 

        else

            set(gui.editbox2,'string',valueLine)

        end
        
    elseif strcmpi(gui.type,'vertical')
        
        % Line X-Axis value (1)
        %----------------------------------------------------------
        kk = kk - 1;
        if firstTime

            uicontrol('units',                  'normalized',...
                      'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                      'parent',                 gui.panelHandle,...
                      'style',                  'text',...
                      'horizontalAlignment',    'left',...
                      'string',                 'X-Axis Value');

        end

        valueLine2 = '';
        enable     = 'off';
        valueR     = 0;
        if iscell(valueLine)
            enable     = 'on';
            valueR     = 1;
            valueLine2 = valueLine{2};
            valueLine  = valueLine{1};
        end

        valueLine = checkInput(plotterT,valueLine);

        if ~isempty(valueLine2)
            
            valueLine2 = checkInput(plotterT,valueLine2);
            
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
                      'string',                 valueLine,....
                      'callback',               {@gui.setLineValue,1});  

            gui.editbox2 = ed; 

        else

            set(gui.editbox2,'string',valueLine)

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
                      'string',                 valueLine2,....
                      'callback',               {@gui.setLineValue,2});  

            gui.editbox3 = ed; 

            rb = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startB, heightPop*(kk-1) + spaceYPop*kk, widthB, heightPop],...
                  'parent',         gui.panelHandle,...
                  'style',          'radiobutton',...
                  'Interruptible',  'off',...
                  'string',         'Between',...
                  'value',          valueR,...
                  'callback',       @gui.placeBetween); 
            gui.radiobutton1 = rb;

        else

            set(gui.editbox3,'string',valueLine2,'enable',enable)
            set(gui.radiobutton1,'value',valueR)

        end
            
        % Set Y-Axis Limits
        %----------------------------------------------------------
        if isempty(limits)
            valueR = 0;
            enable = 'off';
            limit1 = '';
            limit2 = '';
        else
            valueR = 1;
            enable = 'on';
            limit1 = num2str(limits(1));
            limit2 = num2str(limits(2));
        end
        
        kk = kk - 1;
        if firstTime

            uicontrol('units',                  'normalized',...
                      'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                      'parent',                 gui.panelHandle,...
                      'style',                  'text',...
                      'horizontalAlignment',    'left',...
                      'string',                 'Lower Limit');

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
                      'string',                 limit1,....
                      'callback',               {@gui.setVerticalLineLimit,'lower'});  

            gui.editbox4 = ed; 

        else

            set(gui.editbox4,'string',limit1)

        end
        
        kk = kk - 1;
        if firstTime

            uicontrol('units',                  'normalized',...
                      'position',               [startTX, heightPop*(kk-1) + spaceYPop*kk + extra, widthT, heightT],...
                      'parent',                 gui.panelHandle,...
                      'style',                  'text',...
                      'horizontalAlignment',    'left',...
                      'string',                 'Upper Limit');

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
                      'string',                 limit2,....
                      'callback',               {@gui.setVerticalLineLimit,'upper'});  

            gui.editbox5 = ed; 
            
            rb = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startB, heightPop*(kk-1) + spaceYPop*kk, widthB, heightPop],...
                  'parent',         gui.panelHandle,...
                  'style',          'radiobutton',...
                  'Interruptible',  'off',...
                  'string',         'Manual',...
                  'value',          valueR,...
                  'callback',       @gui.setVerticalLineManualYLimits); 
            gui.radiobutton2 = rb;

        else

            set(gui.editbox5,'string',limit2,'enable',enable)
            set(gui.radiobutton2,'value',valueR)

        end
        
        
    else
        
        % Update here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
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
