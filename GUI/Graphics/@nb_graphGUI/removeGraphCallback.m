function removeGraphCallback(gui,~,~)
% Syntax:
%
% removeGraphCallback(gui,h,e)
%
% Description:
%
% Part of DAG. 
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nb_confirmWindow('Are you sure you want to remove the second graph?',...
        @no,@(h,e)yes(h,e,gui),[gui.parent.guiName ': Remove second graph'])

end

function yes(hObject,~,gui)

    % Close question window
    close(get(hObject,'parent'));

    % Delete axes of second graph
    ax = get(gui.plotterAdv.plotter(2),'axesHandle');
    set(ax,'deleteOption','all');
    delete(ax);
    
    % Remove second axes
    removeGraph(gui.plotterAdv);
    
    % Adjust positions
    gui.plotterAdv.plotter.position = gui.parent.settings.graphSettings.(gui.template).position;

    % Set legend location to default
    set(gui.plotterAdv.plotter(1),'legLocation',...
        gui.parent.settings.graphSettings.(gui.template).legLocation);
    
    % Graph
    graph(gui.plotterAdv.plotter);
    if gui.currentGraph == 2
        changeMenu(gui,1);
        gui.currentGraph = 1;
    else
        notify(gui.plotterAdv.plotter,'updatedGraphStyle');
    end
    
    % Update menu
    set(findobj(gui.advancedMenu,'Label','Add graph (load dataset)'),'enable','on');  
    set(findobj(gui.advancedMenu,'Label','Add graph (load graph)'),'enable','on'); 
    set(findobj(gui.advancedMenu,'Label','Remove graph'),'enable','off');    
    set(findobj(gui.advancedMenu,'Label','Change graph'),'enable','off');    
    
    % Notify
    notify(gui.plotterAdv.plotter,'updatedGraph');
    
    % Make sure that current graph property is also correct in 
    % the nb_graph_adv object
    gui.plotterAdv.currentGraph = 1;
    
end

function no(hObject,~)
    % Close question window
    close(get(hObject,'parent'));
end
