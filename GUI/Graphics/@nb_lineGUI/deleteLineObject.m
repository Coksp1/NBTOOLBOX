function deleteLineObject(gui,~,~)
% Syntax:
%
% deleteLineObject(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen   

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    
    % Get the selected fake legend
    lineObjects = get(gui.popupmenu1,'string');
    index       = get(gui.popupmenu1,'value');
    lineObject  = lineObjects{index};

    if strcmpi(lineObject,' ')
        return
    end
    
    % Find the line object to delete
    lineObjects = [lineObjects(1:index-1);lineObjects(index+1:end)];

    % Update the graph object
    if strcmpi(gui.type,'horizontal')
    
        % Location
        plotterT.horizontalLine = [plotterT.horizontalLine(1:index-1), plotterT.horizontalLine(index+1:end)];
        
        % Color
        plotterT.horizontalLineColor = [plotterT.horizontalLineColor(1:index-1), plotterT.horizontalLineColor(index+1:end)];
        
        % Line Style
        plotterT.horizontalLineStyle = [plotterT.horizontalLineStyle(1:index-1), plotterT.horizontalLineStyle(index+1:end)];
        
    elseif strcmpi(gui.type,'vertical')
        
        % Location
        plotterT.verticalLine = [plotterT.verticalLine(1:index-1), plotterT.verticalLine(index+1:end)];
        
        % Color
        plotterT.verticalLineColor = [plotterT.verticalLineColor(1:index-1), plotterT.verticalLineColor(index+1:end)];
        
        % Line Style
        plotterT.verticalLineStyle = [plotterT.verticalLineStyle(1:index-1), plotterT.verticalLineStyle(index+1:end)];
        
        % Limits
        plotterT.verticalLineLimit = [plotterT.verticalLineLimit(1:index-1), plotterT.verticalLineLimit(index+1:end)];
        
    else
        
        old  = plotterT.annotation;
        ind  = find(cellfun('isclass',old,'nb_drawLine'));
        indT = ind(index);
        plotterT.set('annotation',[old(1:indT-1), old(indT+1:end)]);
        
    end
    
    % Notify listeners
    notify(gui,'changedGraph');
    
    % Switch the line object of interest
    if isempty(lineObjects)
        lineNew = ' ';
        set(gui.popupmenu1,'string',{' '},'value',1);
    else
        lineNew = lineObjects{1};
        set(gui.popupmenu1,'string',lineObjects,'value',1);
        
    end
    updateLinePanel(gui,lineNew,0);
    
end
