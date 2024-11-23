function add(gui,~,~)
% Syntax:
%
% add(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
     
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Panel with graph selection list
    f   = nb_guiFigure(gui.parent,'Select Advanced Graph',[65   15  70   30],'modal','off');
    uip = uipanel('parent',              f,...
                  'title',               'Select Graph',...
                  'units',               'normalized',...
                  'position',            [0.04, 0.04, 0.44, 0.92]);
    
    % List of graphs (of call nb_graph_adv)
    appGraphs    = gui.parent.graphs;
    graphNames   = fieldnames(appGraphs);
    if isempty(graphNames)
        close(f)
        nb_errorWindow('No advanced graphs found. Nothing to add.')
        return
    end
    
    appGraphObjs = struct2cell(appGraphs);
    ind          = cellfun('isclass',appGraphObjs,'nb_graph_adv');
    ind2         = cellfun('isclass',appGraphObjs,'nb_graph_subplot');
    graphNames   = graphNames(ind | ind2);
    if isempty(graphNames)
        close(f)
        nb_errorWindow('No advanced graph or panels found. Nothing to add.')
        return
    end
    
    list = uicontrol(nb_constant.LISTBOX,...
             'position',    [0.04, 0.02, 0.92, 0.96],...
             'parent',      uip,...
             'string',      graphNames,...
             'value',       1); 
                                  
    % Create Select button
    width  = 0.2;
    height = 0.06;
    uicontrol(nb_constant.BUTTON,...
              'position',       [0.5 + 0.25 - width/2 - 0.01, 0.4, width, height],...
              'parent',         f,...
              'string',         'Select',...
              'callback',       {@graphObjectSelect,list,gui}); 
          
    % Make it visible
    set(f,'visible','on')

end

function graphObjectSelect(hObject,~,list,gui)

    appGraphs = gui.parent.graphs;

    % Get the selected graphs and add them
    graphSelected = nb_getUIControlValue(list);
    for ii = 1:length(graphSelected)
        
        if any(strcmpi(graphSelected{ii},gui.package.identifiers))
            nb_errorWindow(['The graph ' graphSelected{ii} ' is already part of the package. '...
                            'If you want to include a graph more than once you need to make '...
                            'a copy and save that copy to another save name.'])
            return
        else
            graphObject = appGraphs.(graphSelected{ii});
            if isa(graphObject,'nb_graph_subplot')
                if isempty(graphObject.figureNameNor) || isempty(graphObject.figureNameEng)
                    nb_errorWindow(['The panel you try to load must be added a name in both english and norwegian. '...
                                    'Load the panel and go Advanced->Panel Name to do this.'])
                end
            end
            gui.package.add(graphObject,graphSelected{ii});
        end
        
    end
    
    gui.changed = 1;
    notify(gui,'changedGraphs');
  
    % Update templates
    gui.updateTemplates();
    
    % Close selection window
    close(get(hObject,'parent'));

end
