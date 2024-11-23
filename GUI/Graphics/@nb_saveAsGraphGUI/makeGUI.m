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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(gui.plotter)
        nb_errorWindow('It is not possible to save down an empty graph object.')
        return
    end

    % Get the data tank
    appGraphs = gui.parent.graphs;
    
    % Get used save names
    oldSaveNames = fieldnames(appGraphs);
    
    if isa(gui.plotter,'nb_graph_adv')
        if isa(gui.plotter.plotter,'nb_table_data_source')
            string = 'Table';
        else
            string = 'Graph';
        end
    else
        if isa(gui.plotter,'nb_table_data_source')
            string = 'Table';
        else
            string = 'Graph';
        end
    end
    
    % Make GUI window
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
               'units',          'characters',...
               'position',       [65   15  70   20],...
               'Color',          defaultBackground,...
               'name',           [gui.parent.guiName ': Save ' string],...
               'numberTitle',    'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'resize',         'off',...
               'windowStyle',    'modal');
    nb_moveFigureToMonitor(f,currentMonitor,'center');
    
    % Create default save name
    iter  = 1;
    name  = 'untitled';
    found = any(strcmpi(name,oldSaveNames));
    while found
        
        iter  = iter + 1;
        if iter == 2
            name  = [name,int2str(iter)]; %#ok
        elseif iter >= 10
            name  = [name(:,1:end-2),int2str(iter)];
        else
            name  = [name(:,1:end-1),int2str(iter)]; 
        end
        found = any(strcmpi(name,oldSaveNames));
        
    end
    
    % Create text above edit box
    uicontrol('units',              'normalized',...
              'position',           [0.04 0.7 0.92 0.1],...
              'parent',             f,...
              'horizontalAlignment','left',...
              'style',              'text',...
              'string',             'Save Name'); 
    
    % Create edit box
    eb = uicontrol('units',                 'normalized',...
                   'position',              [0.04 0.6 0.92 0.1],...
                   'parent',                f,...
                   'horizontalAlignment',   'left',...
                   'background',            [1 1 1],...
                   'style',                 'edit',...
                   'Interruptible',         'off',...
                   'string',                name); 
    gui.editBox = eb;
               
    % Create save button
    width  = 0.2;
    height = 0.06*3/2;
    uicontrol('units',          'normalized',...
              'position',       [0.5 - width/2, 0.4, width, height],...
              'parent',         f,...
              'background',     defaultBackground,...
              'style',          'pushbutton',...
              'Interruptible',  'off',...
              'busyAction',     'cancel',...
              'string',         'Save',...
              'callback',       @gui.saveRoutine); 

    % Make it visible
    set(f,'visible','on')

end
