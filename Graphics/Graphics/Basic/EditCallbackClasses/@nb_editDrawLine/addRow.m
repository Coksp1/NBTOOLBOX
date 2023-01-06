function addRow(gui,~,~)
% Add row to the lookupmatrix (i.e. the table)

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    data = get(gui.table,'data');
    data = [data;1,1];
    set(gui.table,'data',data);
    
    % Update line
    obj       = gui.parent;
    obj.xData = [obj.xData;1];
    obj.yData = [obj.yData;1];
    update(obj);
    notify(obj,'annotationEdited')
    
end
