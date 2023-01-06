function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % List of graphs
    appGraphs  = gui.parent.graphs;
    graphNames = fieldnames(appGraphs);
    if isempty(graphNames)
        nb_errorWindow('There are no stored graph objects to load.')
        return
    end
    f = nb_guiFigure(gui.parent,'Load graph',[65   15  70   30],'normal','off');
    
    % Panel with model selection list
    uip = uipanel('parent',   f,...
                  'title',    'Graph objects',...
                  'units',    'normalized',...
                  'position', [0.04, 0.04, 0.44, 0.92]);

    % List datasets
    list = uicontrol('units',       'normalized',...
                     'position',    [0.02, 0.02, 0.96, 0.96],...
                     'parent',      uip,...
                     'background',  [1 1 1],...
                     'style',       'listbox',...
                     'string',      sort(graphNames),...
                     'max',         1); 

    % Create load button
    width  = 0.2;
    height = 0.06;
    uicontrol('units',       'normalized',...
              'position',    [0.5 + 0.25 - width/2 - 0.01, 0.4, width, height],...
              'parent',      f,...
              'style',       'pushbutton',...
              'string',      'Load',...
              'callback',    @gui.selectGraph); 

    % Make it visible
    set(f,'visible','on')

    % Assign handles to the object
    gui.fig     = f;
    gui.listBox = list;

end
