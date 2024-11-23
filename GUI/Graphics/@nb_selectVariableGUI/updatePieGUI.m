function updatePieGUI(gui,variable,firstTime)
% Syntax:
%
% updatePieGUI(gui,variable,firstTime)
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

    % Button group with plot options (not plot, right or 
    % left axes)
    %------------------------------------------------------
    if firstTime

        if ~isempty(gui.buttonGroup)
            delete(gui.buttonGroup);
        end

        bgWidth = 0.4;
        bg = uicontrol('parent',              f,...
                       'units',               'normalized',...
                       'Interruptible',       'off',...
                       'position',            [1 - bgWidth - startX, startY - tHeight*4, bgWidth, 1 - (startY - tHeight*4 + tHeight/2)],...
                       'string', 'Plot',...
                       'Callback',  {@pieToggleVariableCallback, gui});
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

function pieToggleVariableCallback(checkbox, ~, gui)
% Set plot option for a variable
    plotter = gui.plotter;
    
    variables     = get(gui.popupmenu1,'string');
    variableIndex = get(gui.popupmenu1,'value');
    variable      = variables{variableIndex};
    
    if (get(checkbox, 'Value') == get(checkbox, 'Max'))
        % Add variable
        plotter.variablesToPlot = [variablesToPlot, variable];
        % Update
        set(gui.uip,'visible','on');
        updateGUI(gui,variable,0)
    else
        % Remove variable
        i = strcmp(variable, plotter.variablesToPlot);
        % Update
        plotter.variablesToPlot = plotter.variablesToPlot(i);
        notify(gui,'changedGraph');
    end
end
