function plot(obj)
    
    % Delete current graphics
    obj.deleteChildren();

    % Create parent if necessary
    if isempty(obj.parent) || ~isvalid(obj.parent)
        obj.parent = nb_axes();
        set(obj.parent, ...
            'Visible', 'off', ...
            'Position', [0 0 1 1], ...
            'Xlim', [0, 1], ...
            'YLim', [0, 1]);
    end

    % Decide the axes to plot on
    if isa(obj.parent, 'nb_axes')
        if ishandle(obj.parent.plotAxesHandle)
            obj.axesHandle = obj.parent.plotAxesHandle; 
        else
            obj.parent = nb_axes();
            set(obj.parent, ...
                'Visible', 'off', ...
                'Position', [0 0 1 1], ...
                'Xlim', [0, 1], ...
                'YLim', [0, 1]);
            obj.axesHandle = obj.parent.plotAxesHandle;
        end
    else
        error([mfilename ':: nb_table must have an nb_axes parent']);
    end
    
    % Add listeners
    if isa(obj.parent.parent, 'nb_figure')
        obj.listeners = [...
            addlistener(obj.parent.parent, 'mouseMove', @obj.onMouseMove), ...
            addlistener(obj.parent.parent, 'mouseDown', @obj.onMouseDown), ...
            addlistener(obj.parent.parent, 'mouseUp',   @obj.onMouseUp), ...
            addlistener(obj.parent.parent, 'keyPress',  @obj.onKeyPress), ...
            addlistener(obj.parent.parent, 'resized',   @(src, event) obj.update())];
    end
    
    % Create context menu
    obj.createContextMenu();

    try
        
        % Create graphic objects
        for y = 1:size(obj.cells, 1)
            for x = 1:size(obj.cells, 2)
               obj.cells(y, x).graphicHandles = obj.createCellGraphics();                       
            end
        end
        
        % Update state of graphic objects
        obj.update();
        
    catch Err

        % Delete all children made so far
        obj.deleteChildren();

        obj.parent.deleteOption = 'all';
        obj.parent.delete();

        rethrow(Err);

    end
    
    % Add to nb_axes parent
    obj.parent.addChild(obj);

end
