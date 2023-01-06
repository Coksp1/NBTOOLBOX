function deleteCallback(gui,~,~)
% Syntax:
%
% deleteCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % List of graphs (of call nb_graph_adv)
    graphNames = gui.package.identifiers;
    if isempty(graphNames)
        nb_errorWindow('The package has no graphs, so there is nothing to delete.')
        return
    end
       
    % Panel with graph selection list
    f   = nb_guiFigure(gui.parent,'Select Graph to Delete',[65   15  70   30],'modal','off');
    uip = uipanel('parent',              f,...
                  'title',               'Select Graph',...
                  'units',               'normalized',...
                  'position',            [0.04, 0.04, 0.44, 0.92]);
    
    list = uicontrol('units',       'normalized',...
                     'position',    [0.04, 0.02, 0.92, 0.96],...
                     'parent',      uip,...
                     'background',  [1 1 1],...
                     'style',       'listbox',...
                     'string',      graphNames,...
                     'min',         1,...
                     'max',         3,...
                     'value',       1); 
                                  
    % Create Select button
    width  = 0.2;
    height = 0.06;
    uicontrol('units',          'normalized',...
              'position',       [0.5 + 0.25 - width/2 - 0.01, 0.4, width, height],...
              'parent',         f,...
              'style',          'pushbutton',...
              'Interruptible',  'off',...
              'string',         'Delete',...
              'callback',       {@graphObjectSelect,list,gui}); 
          
    % Make it visible
    set(f,'visible','on')

end

function graphObjectSelect(hObject,~,list,gui)

    % Get the graph selected
    index         = get(list,'Value');
    string        = get(list,'String');
    graphsSelected = string(index);
    
    % Delete it
    for i = 1:length(graphsSelected)
        remove(gui.package,graphsSelected{i});
    end
    gui.changed = 1;
    notify(gui,'changedGraphs');
    
    % Update templates
    gui.updateTemplates();
    
    % Close selection window
    close(get(hObject,'parent'));

end
