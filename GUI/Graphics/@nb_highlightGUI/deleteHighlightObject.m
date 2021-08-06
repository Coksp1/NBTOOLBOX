function deleteHighlightObject(gui,~,~)
% Syntax:
%
% deleteHighlightObject(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    
    % Get the selected fake legend
    objects = get(gui.popupmenu1,'string');
    index   = get(gui.popupmenu1,'value');
    object  = objects{index};

    if strcmpi(object,' ')
        return
    end
    
    % Find the line object to delete
    objects = [objects(1:index-1);objects(index+1:end)];

    % Location
    plotterT.highlight = [plotterT.highlight(1:index-1), plotterT.highlight(index+1:end)];

    % Color
    plotterT.highlightColor = [plotterT.highlightColor(1:index-1), plotterT.highlightColor(index+1:end)];
        
    % Notify listeners
    notify(gui,'changedGraph');
    
    % Switch the line object of interest
    if isempty(objects)
        new = ' ';
        set(gui.popupmenu1,'string',{' '},'value',1);
    else
        new = objects{1};
        set(gui.popupmenu1,'string',objects,'value',1);
        
    end
    updatePanel(gui,new,0);
    
end
