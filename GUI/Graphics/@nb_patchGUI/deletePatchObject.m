function deletePatchObject(gui,~,~)
% Syntax:
%
% deletePatchObject(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    
    % Get the selected fake legend
    objects = get(gui.popupmenu1,'string');
    index   = get(gui.popupmenu1,'value');
    object  = objects{index};

    if strcmpi(object,' ')
        return
    end
    
    % Find the patch object to delete
    objects = [objects(1:index-1);objects(index+1:end)];

    % Update the graph object
    
    % Location
    plotterT.patch = [plotterT.patch(1:index*4 - 4), plotterT.patch(index*4 + 1:end)];

    % Notify listeners
    notify(gui,'changedGraph')
    
    % Switch the line object of interest
    if isempty(objects)
        new = ' ';
        set(gui.popupmenu1,'string',{' '},'value',1);
    else
        new = objects{1};
        set(gui.popupmenu1,'string',objects,'value',1);
        
    end
    updatePatchPanel(gui,new,0);
    
end
