function deleteFakeLegend(gui,~,~)
% Syntax:
%
% deleteFakeLegend(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function for deleting a fake legend    
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    
    % Get the selected fake legend
    fakeLegends = get(gui.popupmenu2,'string');
    index       = get(gui.popupmenu2,'value');
    fakeLegend  = fakeLegends{index};

    if strcmpi(fakeLegend,' ')
        return
    end
    
    % Find the fake legend to delete
    ind         = find(strcmp(fakeLegend,fakeLegends),1);
    fakeLegends = [fakeLegends(1:ind-1);fakeLegends(ind+1:end)];

    % Update the graph object
    new = [plotterT.fakeLegend(1:ind*2 - 2), plotterT.fakeLegend(ind*2 + 1:end)];
    plotterT.set('fakeLegend', new);

    % Switch the fake legend of interest
    if isempty(fakeLegends)
        fakeLegendNew = ' ';
        set(gui.popupmenu2,'string',{' '},'value',1);
    else
        fakeLegendNew = fakeLegends{1};
        set(gui.popupmenu2,'string',fakeLegends,'value',1);
        
    end
    updateFakeLegendPanel(gui,fakeLegendNew,0);
    
    % Notify listeners
    notify(gui,'changedGraph');
    
    % Update the table of the text panel
    data = get(gui.table,'data');
    if size(data,1) == 1
        data = {'',''};
        set(gui.table,'data',data,'enable','off');
    else
        index = find(strcmp(fakeLegend,data(:,1)'),1);
        data  = [data(1:index-1,:);data(index+1:end,:)];
        set(gui.table,'data',data);
    end

end
