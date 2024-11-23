function updateGUI(gui)
% Syntax:
%
% updateGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    try

        % Currently selected distribution object
        set(gui.currentDistributionMenu, 'string', {gui.distribution.name});
        set(gui.currentDistributionMenu, 'value', gui.currentDistributionIndex);

        % Enabled distribution?
        if (gui.currentEditable)
            enableProp = {'Enable', 'on'};
        else
            enableProp = {'Enable', 'off'};
        end

        % Update panels
        updateMenuBar(gui, enableProp);
        updateGraphPanel(gui);
        updateMomentsPanel(gui);
        updateDistributionPanel(gui);
        updateControlsPanel(gui, enableProp);
        updateDomainPanel(gui, enableProp);

    catch Err
        nb_errorWindow(Err.message, Err);
    end

end

function updateDistributionPanel(gui)

    if strcmpi(gui.currentDistribution.type,'ast')
        visible = 'on';
    else
        visible = 'on';
    end
    set([gui.paramBoxes{3:end}],'visible',visible);

end

function updateMenuBar(gui,enableProp)

    switch lower(gui.functionType)
        case 'pdf'
            set(gui.pdfMenuItem, 'checked', 'on');
            set(gui.cdfMenuItem, 'checked', 'off');
        case 'cdf'
            set(gui.pdfMenuItem, 'checked', 'off');
            set(gui.cdfMenuItem, 'checked', 'on');
    end
    
    % Increment mode
    set(gui.incrementEnableMenuItem, 'checked', gui.incrementMode);
    switch lower(gui.incrementSmoothing)
        case 'kernel'
            set(gui.kernelSmoothingMenuItem, 'checked', 'on');
            set(gui.neighbourhoodSmoothingMenuItem, 'checked', 'off');
        otherwise
            set(gui.kernelSmoothingMenuItem, 'checked', 'off');
            set(gui.neighbourhoodSmoothingMenuItem, 'checked', 'on');
    end
    
    set(get(gui.incrementEnableMenuItem,'parent'),enableProp{:});
    set(get(gui.kernelSmoothingMenuItem,'parent'),enableProp{:});
    set(gui.smoothingMenuItem,enableProp{:})
    otherMenu = findobj(gui.figureHandle,'type','uimenu','label','Other');
    set(otherMenu,enableProp{:})
    
end

function updateGraphPanel(gui)
    % Re-render graph
    data = asData(gui.distribution, [], gui.functionType);
    gui.plotter.resetDataSource(data);
    
    gui.plotter.set(...
        'variableToPlotX', 'domain',...
        'variablesToPlot', setdiff(data.variables, {'domain'}, 'stable'),...
        'legends', {gui.distribution.name});
    
    gui.plotter.graph();
end

function updateControlsPanel(gui, enableProp)
    % Show selected type
    distributionIndex = find(ismember(...
        get(gui.distributionMenu, 'string'),...
        gui.currentDistribution.type));
    set(gui.distributionMenu, 'value', distributionIndex, enableProp{:});

    % Show parameter names and values
    paramNames = gui.paramNames;
    paramValues = gui.currentDistribution.parameters;
    
    for i = 1:length(gui.paramLabels)
        if i <= length(paramNames)
            set(gui.paramLabels{i}, {'string', 'visible'}, {paramNames{i}, 'on'});
            set(gui.paramBoxes{i}, {'string', 'visible'}, {paramValues{i}, 'on'});
        else
            set(gui.paramLabels{i}, 'visible', 'off');
            set(gui.paramBoxes{i}, 'visible', 'off');
        end
        set(gui.paramBoxes{i}, enableProp{:});
    end

    if strcmp(gui.currentDistribution.type, 'kernel')
        set(gui.percentileLabel, 'Visible', 'on');
        set(gui.percentileButton, 'Visible', 'on', enableProp{:});
    else
        set(gui.percentileLabel, 'Visible', 'off');
        set(gui.percentileButton, 'Visible', 'off');
    end
    
    % Redraw grid
    update(gui.distributionPanel);
end

function updateDomainPanel(gui, enableProp)
    % Show lower and upper bound
    set(gui.domainLowerBox, 'string', num2str(gui.currentDistribution.lowerBound), enableProp{:});
    set(gui.domainUpperBox, 'string', num2str(gui.currentDistribution.upperBound), enableProp{:});
    set(gui.meanShiftBox, 'string', num2str(gui.currentDistribution.meanShift), enableProp{:});
end
