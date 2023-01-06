function nb_displayValue(hObject,event,variables,variablesX)
% Syntax:
%
% nb_displayValue(hObject,event)
%
% Description:
%
% Callback function which can be used to display the value of the data 
% point in a nb_notifiesMouseOverObject object.
% 
% Input:
% 
% - hObject    : An object of class nb_axes.
%
% - event      : A nb_mouseOverObjectEvent object
%
% - variables  : A nested cellstr with the same size as the maximum value 
%                of event.h (Number of children of the axes). And each 
%                element must have size event.y (Number of plotted 
%                variables by the child).
%
% - variablesX : A nested cellstr with the same size as the maximum value 
%                of event.h (Number of children of the axes). And each 
%                element must have size event.y (Number of plotted 
%                observation by the child).
% 
% Output:
% 
% - A text box on screen displaying the data value. 
%
% Example:
%
% d      = rand(10,2);
% d(2,2) = -0.2;
% d(2,1) = -0.1;
% bar    = nb_bar(d,'style','stacked');
% func   = @(src,event)nb_displayValue(src,event,{{'Var1','Var2'}});
% addlistener(bar.parent,'mouseOverObject',func);
%
% See also:
% nb_notifiesMouseOverObject
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin <4
        variablesX = {};
        if nargin <3
            variables = {};
        end
    end

    % Get current point in axes data units
    cPoint = event.currentPoint;

    % Get new displayed string
    if size(event.value,2) == 2
        string = ['(' num2str(event.value(1)),',', num2str(event.value(2)) ')'];
    else
        string = num2str(event.value);
    end
    if ~isempty(string)
        try
            string = ['"', variables{event.h}{event.y}, '" ', string];
        catch %#ok<CTCH>
        end
        
        try
            string = ['"', variablesX{event.h}{event.x}, '" ', string];
        catch %#ok<CTCH>
        end
        
    end
    
    % Get axes units in 
    ax       = hObject.axesLabelHandle;
    oldUnits = get(ax,'units');
    set(ax,'units','characters');
    pos = get(ax,'position');
    set(ax,'units',oldUnits);
    
    % Map offset in characters to data units
    xOffset   = 3;
    yOffset   = -1;
    xOffset   = nb_dpos2dpos(xOffset,[pos(1),pos(1) + pos(3)],get(ax,'xLim'),'normal',get(ax,'xScale'));
    yOffset   = nb_dpos2dpos(yOffset,[pos(2),pos(2) + pos(4)],get(ax,'yLim'),'normal',get(ax,'yScale'));
    plotPoint = [cPoint(1) + xOffset, cPoint(2) + yOffset];
    
    % Find old object
    tOld = findobj(ax,'tag','mouseOverObjectTextBox');
    if isempty(tOld) || ~ishandle(tOld)
        
        if isempty(string)
            return
        end
        
        % Then we display the value on the screen with a new text object       
        tOld = text(plotPoint(1),plotPoint(2),string,...
             'interpreter',         'none',...
             'parent',              ax,...
             'backgroundColor',     [0.9,0.9,0.9],...
             'edgeColor',           [0.05,0.05,0.05],...
             'tag',                 'mouseOverObjectTextBox',...
             'verticalAlignment',   'top',...
             'horizontalAlignment', 'left');
        
    else
        
        if isempty(string)
            set(tOld,'visible','off');
            return
        end
        
        oldString = get(tOld,'string');
        if strcmpi(string,oldString)
            set(tOld,'position',            plotPoint,...
                     'visible',             'on',...
                     'horizontalAlignment', 'left');    
        else
            set(tOld,'string',              string,...
                     'position',            plotPoint,...
                     'visible',             'on',...
                     'horizontalAlignment', 'left'); 
        end
        
    end
    
    % Check if the extent goes outside axes
    ext      = get(tOld,'extent');
    oldUnits = get(ax,'units');
    set(ax,'units','normalized');
    pos = get(ax,'position');
    set(ax,'units',oldUnits);
    if ext(1) + ext(3) > pos(1) + pos(3)
        
        plotPoint = [cPoint(1) - xOffset/2, cPoint(2) + yOffset];
        set(tOld,'position',plotPoint,'horizontalAlignment','right')
        
    end
    
end
