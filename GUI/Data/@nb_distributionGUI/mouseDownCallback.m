function mouseDownCallback(gui, ~, ~)    
% Syntax:
%
% mouseDownCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get mouse position relative to axes
    pointInFigure = nb_getInUnits(gui.figureHandle, 'CurrentPoint', 'pixels');
    axesPosition  = getpixelposition(get(get(gui.plotter, 'axesHandle'), 'axesHandle'), true);
    pointInAxes   = (pointInFigure(1:2) - axesPosition(1:2)) ./ axesPosition(3:4);
    
    % Inside axes?
    if all(pointInAxes >= 0) && all(pointInAxes <= 1)
        mouseDownInAxesCallback(gui, pointInAxes);
    end    
    
end

function mouseDownInAxesCallback(gui, point)
    
    if ~strcmpi(gui.incrementMode, 'on')
        return
    end
    
    axesHandle = get(gui.plotter, 'axesHandle');
    xValue     = nb_pos2pos(point(1), [0 1], axesHandle.xLim);
    yValue     = nb_pos2pos(point(2), [0 1], axesHandle.yLim);
    
    xValues = gui.currentDistribution.parameters{1};
    if ~isempty(gui.currentDistribution.meanShift)
        xValues = xValues + gui.currentDistribution.meanShift;
    end
    yValues = gui.currentDistribution.parameters{2};
    
    domainIndex = find(xValues >= xValue, 1, 'first');
    increment   = yValue - yValues(domainIndex);
    
    try
        gui.currentDistribution.increment(gui.functionType, domainIndex, increment, gui.incrementSmoothing);
        gui.updateGUI();
        gui.addToHistory();
    catch  %#ok<CTCH>
        nb_errorWindow('The smoothed distribution resulted in negative density at some point(s) in the domain')
    end
    
end
