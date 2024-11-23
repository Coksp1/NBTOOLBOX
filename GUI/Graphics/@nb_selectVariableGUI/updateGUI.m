function updateGUI(gui,variable,firstTime)
% Syntax:
%
% updateGUI(gui,variable,firstTime)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    popWidth1 = 0.41;
    popHeight = 0.05;
    tHeight   = 0.04;
    startX    = 0.04;
    startY    = 0.85;
    f         = gui.figureHandle;
    plotter   = gui.plotter;

    % Select plot type pop-up menu
    %------------------------------------------------------
    if firstTime

        uicontrol('units',                  'normalized',...
                  'position',               [startX, startY - tHeight*2 + 0.007, popWidth1, tHeight],...
                  'parent',                 f,...
                  'style',                  'text',...
                  'horizontalAlignment',    'left',...
                  'string',                 'Select Plot Type'); 

    end
    
    datesVsDatePlot = 0;
    if isa(plotter,'nb_graph_ts')
        if ~isempty(plotter.datesToPlot)
            datesVsDatePlot = 1;
        end
    end

    type  = strcmpi(plotter.plotType,'line') || strcmpi(plotter.plotType,'stacked')  || ...
            strcmpi(plotter.plotType,'grouped') ||  strcmpi(plotter.plotType,'area') ;
    type2 = isa(plotter,'nb_graph_cs') && strcmpi(plotter.barOrientation,'horizontal');    
        
    if (type && ~type2) || datesVsDatePlot 

        if strcmpi(plotter.plotType,'grouped') || any(strcmpi('grouped',plotter.plotTypes(2:2:end)))
            plotTypesTemp = {'Line','Grouped','Area'};   
        elseif strcmpi(plotter.plotType,'stacked') || any(strcmpi('stacked',plotter.plotTypes(2:2:end)))
            plotTypesTemp = {'Line','Stacked','Area'};   
        else
            plotTypesTemp = {'Line','Stacked','Grouped','Area'};    
        end
        
        index = find(strcmpi(variable,plotter.plotTypes),1,'last');      
        if isempty(index)
            selected = plotter.plotType;
        else
            selected = plotter.plotTypes{index + 1};      
        end
        value    = find(strcmpi(selected,plotTypesTemp),1);
        
    else
        selected      = plotter.plotType;
        plotTypesTemp = {plotter.plotType};
        value         = 1;
    end

    if firstTime

        if ~isempty(gui.popupmenu2)
            delete(gui.popupmenu2);
        end

        pop2 = uicontrol(...
                  'units',          'normalized',...
                  'position',       [startX, startY - tHeight*3, popWidth1, popHeight],...
                  'parent',         f,...
                  'background',     [1 1 1],...
                  'style',          'popupmenu',...
                  'Interruptible',  'off',...
                  'string',         plotTypesTemp,...
                  'value',          value,....
                  'callback',       @gui.selectVarPlotType); 
        gui.popupmenu2   = pop2;     

    else

        set(gui.popupmenu2,'string',plotTypesTemp,'value',value);

    end

    if datesVsDatePlot
        indexVar1 = find(strcmp(variable,plotter.datesToPlot),1);  
        indexVar2 = [];  
    else
        indexVar1 = find(strcmp(variable,plotter.variablesToPlot),1);  
        indexVar2 = find(strcmp(variable,plotter.variablesToPlotRight),1);  
    end
    if ~type 
        set(gui.popupmenu2,'enable','off') 
    else
        if (isempty(indexVar1) && isempty(indexVar2))
            set(gui.popupmenu2,'enable','off') 
        else
            set(gui.popupmenu2,'enable','on') 
        end
    end

    % Button group with plot options (not plot, right or 
    % left axes)
    %------------------------------------------------------
    if firstTime

        if ~isempty(gui.buttonGroup)
            delete(gui.buttonGroup);
        end

        bgWidth = 0.4;
        bg = uibuttongroup('parent',              f,...
                           'title',               '',...
                           'units',               'normalized',...
                           'Interruptible',       'off',...
                           'position',            [1 - bgWidth - startX, startY - tHeight*4, bgWidth, 1 - (startY - tHeight*4 + tHeight/2)],...
                           'SelectionChangeFcn',  @gui.setPlotOption);
        gui.buttonGroup = bg;

        radioStart  = 0.08;
        radioSpace  = 0.04;
        radioHeight = 0.25;
        radioWidth  = 1 - radioStart*2;
        radioYStart = (1 - radioHeight*3 - radioSpace*2)/2;

        uicontrol(...
                  'units',       'normalized',...
                  'position',    [radioStart, radioYStart + radioHeight*2 + radioSpace*2, radioWidth, radioHeight],...
                  'parent',      bg,...
                  'style',       'radiobutton',...
                  'string',      'Not Plot'); 

        uicontrol(...
                  'units',       'normalized',...
                  'position',    [radioStart, radioYStart + radioHeight + radioSpace, radioWidth, radioHeight],...
                  'parent',      bg,...
                  'style',       'radiobutton',...
                  'string',      'Left'); 

        if strcmpi(plotter.plotType,'radar') || strcmpi(plotter.plotType,'pie') || datesVsDatePlot
            enable = 'off';
        else
            enable = 'on';
        end
              
        uicontrol(...
                  'units',       'normalized',...
                  'position',    [radioStart, radioYStart, radioWidth, radioHeight],...
                  'parent',      bg,...
                  'enable',      enable,...
                  'style',       'radiobutton',...
                  'string',      'Right');    

    end

    if (isempty(indexVar1) && isempty(indexVar2)) 
        obj = findobj(gui.buttonGroup,'string','Not Plot');
        set(gui.buttonGroup,'selectedObject',obj)   
    elseif isempty(indexVar2)
        obj = findobj(gui.buttonGroup,'string','Left');
        set(gui.buttonGroup,'selectedObject',obj)
    else
        if strcmpi(plotter.plotType,'radar')
            obj = findobj(gui.buttonGroup,'string','Not Plot');
            set(gui.buttonGroup,'selectedObject',obj)
        else
            obj = findobj(gui.buttonGroup,'string','Right');
            set(gui.buttonGroup,'selectedObject',obj)
        end
    end

    % Panel with other properties
    %------------------------------------------------------      
    if not(isempty(indexVar1) && isempty(indexVar2))
        updatePanel(gui,selected)
    else
        % Not currently plotted
        if ~isempty(gui.uip)
            set(gui.uip,'visible','off');
        end
    end

    % Notify listeners if not beeing initialized
    %------------------------------------------------------
    if ~gui.initialized
        notify(gui,'changedGraph')
    else
        gui.initialized = 0;
    end

end
