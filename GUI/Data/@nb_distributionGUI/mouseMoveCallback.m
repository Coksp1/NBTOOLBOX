function mouseMoveCallback(gui, ~, ~)    
% Syntax:
%
% mouseMoveCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if strcmpi(gui.incrementMode, 'on')
        try
            % Get mouse position relative to axes
            pointInFigure = nb_getInUnits(gui.figureHandle, 'CurrentPoint', 'pixels');
            axesPosition  = getpixelposition(get(get(gui.plotter, 'axesHandle'), 'axesHandle'), true);
            pointInAxes   = (pointInFigure(1:2) - axesPosition(1:2)) ./ axesPosition(3:4);

            % Set crosshair pointer if mouse is inside axes
            if all(pointInAxes >= 0) && all(pointInAxes <= 1)
                set(gui.figureHandle, 'Pointer', 'crosshair');
            end
        catch       
        end
    end    
    
end
