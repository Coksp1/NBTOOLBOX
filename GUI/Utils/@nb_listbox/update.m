function update(obj)
% Syntax:
%
% update(obj)
%
% Description:
%
% Update nb_listbox object.
% 
% Input:
% 
% - obj : An object of class nb_listbox.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~obj.doUpdate
        return
    end

    if isempty(obj.parent)
        obj.doUpdate = false;
        obj.parent   = figure;
        addButtonDownCallback(obj);
        obj.doUpdate = true;
    end

    visible               = 'off';
    obj.underConstruction = true;
    
    % Check that parent of uicontextmenu handle correspond to the parent of
    % this list box.
    if ~isempty(obj.UIContextMenu)
        parUI = nb_getParentRecursively(obj.matlabParent);
        if parUI ~= get(obj.UIContextMenu,'parent')
             set(obj.UIContextMenu,'parent',parUI);
        end
    end
    
    % Main panel
    props = struct(...
        'visible',          visible,...
        'backgroundColor',  obj.backgroundColor,...
        'parent',           obj.matlabParent,...
        'position',         obj.position);
    if isempty(obj.mainUIPanel)
        obj.mainUIPanel = nb_blankUIPanel(props,...
            'sizeChangedFcn',   @obj.updateCallback);
    else
        set(obj.mainUIPanel,props);
    end
    drawnow;
    
    % Get main hight in pixels
    set(obj.mainUIPanel,'units','pixels');
    obj.mainPosition = get(obj.mainUIPanel,'position');
    set(obj.mainUIPanel,'units','normalized');
    
    % Place a axes object to display the border line
    props = struct(...
        'position',  [obj.mainPosition(1) - obj.borderMargin, obj.mainPosition(2) - obj.borderMargin,...
                      obj.mainPosition(3) + obj.borderMargin*2, obj.mainPosition(4) + obj.borderMargin*2],...  
        'visible',   visible);
    if isempty(obj.borderAxes)
        obj.borderAxes = nb_blankAxes(obj.matlabParent,'units','pixels','clipping','on',props);
    else
        set(obj.borderAxes,props);
    end
    
    % Add title
    if isempty(obj.titleHandle)
        obj.titleHandle = title(obj.borderAxes,obj.title,'parent',obj.borderAxes);
    else
        if ishandle(obj.titleHandle)
            set(obj.titleHandle,'string',obj.title);
        else
            obj.titleHandle = title(obj.borderAxes,obj.title,'parent',obj.borderAxes);
        end
    end
    
    % Plot border line
    plotBorderLine(obj);
    
    % Place a axes object to display the text boxes
    props = struct('visible',visible);
    if isempty(obj.textAxes)
        obj.textAxes = nb_blankAxes(obj.mainUIPanel,props);
    else
        if ishandle(obj.textAxes)
            set(obj.textAxes,props);
        else
            obj.textAxes = nb_blankAxes(obj.mainUIPanel,props);
        end
    end
    
    % Create slider
    addList = true;
    props   = struct(...
        'backgroundColor',  obj.scrollBarColor,...
        'position',         [obj.mainPosition(3) - obj.scrollBarWidth,0,obj.scrollBarWidth,obj.mainPosition(4)]);
    if isempty(obj.scrollUIControl)
        % Create slider
        obj.scrollUIControl = uicontrol(...
            'parent',   obj.mainUIPanel,...
            'style',    'slider',...
            'units',    'pixels',...
            props); 
    else
        set(obj.scrollUIControl,props);
        addList = false;
    end
    
    % Update slider
    numString      = length(obj.string);
    obj.left2Slide = max(numString*obj.elementHeight - obj.mainPosition(4),0); % What is left to slide?
    minorSteps     = min(obj.elementHeight/obj.left2Slide,1);
    majorSteps     = min(minorSteps*2,1);
    if obj.left2Slide == 0
        set(obj.scrollUIControl,'visible','off'); % Nothing to slide, so we remove it
    else
        set(obj.scrollUIControl,'max',obj.left2Slide,'sliderStep',[minorSteps,majorSteps],'value',obj.left2Slide,'visible','on');
    end
    
    % Update the list
    updateList(obj,false);
    
    % Add listener to slider
    if addList
        obj.scrollListener = addlistener(obj.scrollUIControl, 'Value', 'PostSet', @obj.sliderCallback);
    end
    
    % Make it visible again
    set(obj.mainUIPanel,'visible','on');
    set(obj.borderAxes,'visible','on');
    obj.underConstruction = false;
    
end
