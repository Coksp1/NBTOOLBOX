function nb_newGraphGUI(mainGUI)
% Syntax:
%
% nb_newGraphGUI(mainGUI)
%
% Description:
%
% Function to select a new graph object.
% 
% Input:
% 
% - mainGUI : As an nb_GUI object
% 
% Output:
% 
% - A graph GUI
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
               'units',          'characters',...
               'position',       [65   15  70   30],...
               'Color',          defaultBackground,...
               'name',           [mainGUI.guiName ': Graph Type Selection'],...
               'numberTitle',    'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'windowStyle',    'modal',...
               'resize',         'off');
    nb_moveFigureToMonitor(f,currentMonitor,'center');      
    
    % Panel with graph selection list
    uip = uipanel('parent',              f,...
                  'title',               'Graph Type',...
                  'units',               'normalized',...
                  'position',            [0.04, 0.04, 0.44, 0.92]);
    
    % List of graph types
    graphTypes = {'Graph','Advanced Graph','Panel','Subplot','Table','Advanced Table'};
    
    list = uicontrol('units',       'normalized',...
                     'position',    [0.04, 0.02, 0.92, 0.96],...
                     'parent',      uip,...
                     'background',  [1 1 1],...
                     'style',       'listbox',...
                     'string',      graphTypes,...
                     'max',         1); 
                 
    % Create help icon button
    x = imread('qmark.png');

    uicontrol(f,...
              'units',          'normalized',...
              'position',       [0.90,0.01,0.09,0.08],...
              'callback',       @helpGraphTypeSelection,...
              'String',         '',...
              'cData',          x,...
              'Interruptible',  'off',...
              'Style',          'pushbutton',...
              'tag',            'grouped');  
                 
                 
                                  
    % Create ok button
    width  = 0.2;
    height = 0.06;
    uicontrol('units',          'normalized',...
              'position',       [0.5 + 0.25 - width/2 - 0.01, 0.4, width, height],...
              'parent',         f,...
              'style',          'pushbutton',...
              'Interruptible',  'off',...
              'string',         'OK',...
              'callback',       {@graphObjectSelect,list,mainGUI}); 
          
    % Make it visible
    set(f,'visible','on')

end

function graphObjectSelect(hObject,~,list,mainGUI)

    % Get the model type selected
  
    index     = get(list,'Value');
    string    = get(list,'String');
    graphType = string{index};
    
    % Make model GUI and model object
    switch graphType
        
        case 'Graph'
            
            nb_graphGUI(mainGUI,'normal',1,0,mainGUI.settings.defaultNormalTemplate);
            
        case 'Advanced Graph'
            
            nb_graphGUI(mainGUI,'advanced',1,0,mainGUI.settings.defaultAdvancedTemplate);
            
        case 'Panel'
            
            nb_graph_subplotGUI(mainGUI);
            
        case 'Subplot'
            
            loadgui = nb_loadDataGUI(mainGUI);
            addlistener(loadgui,'sendLoadedData',@loadDataToSubplot);
            
        case 'Table'
            
            nb_graphGUI(mainGUI,'normal',1,1);
            
        case 'Advanced Table'
            
            nb_graphGUI(mainGUI,'advanced',1,1);
            
    end
    
    % Close selection window
    close(get(hObject,'parent'));

end

%==================================================================
% Callbacks
%==================================================================
function loadDataToSubplot(hObject,~)
% - hObject : An nb_loadDataGUI object

    loaded = hObject.data;
    if isa(loaded,'nb_modelDataSource')
        loaded = nb_smart2TS(loaded.variables);
    end
    nb_graphSubPlotGUI(loaded,hObject.parent);

end

function helpGraphTypeSelection(~,~)
    
    arrow  = char(hex2dec('2192'));
    
    nb_helpWindow(...
        {'Graph',...
        sprintf(['To create a simple graph in DAG, use the "Graph" option. This option \n',...
        'will open an empty figure window. From here you can load data and edit the type, look \n',...
        'and features of the graph. Note that with the "Graph" type you will not have access \n',...
        'to the "Advanced menu" needed for setting, title, footer, name, numbering and other \n',...
        'options.']),...
        'Advanced graph',...
        sprintf(['To create a graph for publication or other means that need a title, footer \n',...
        'and numbering use the "Advanced graph". You will also need to use the "Advanced \n',...
        'graph" if you want to include the graph in a graph package at some point. The window \n',...
        'will look very similiar to the one created by the "Graph" option beside the fact that \n',...
        'there has been made extra room for the title and footer and that you have access to the \n',...
        '"Advanced menu". Note that it is possible to convert a "Graph" into an "Advanced table" \n',...
        'and vice versa. Simply right-click on the standard graph and copy the figure locally in \n',...
        'DAG by using the "Copy" option. Then, open up an empty advanced graph and right-click \n',...
        'somewhere in that window. By using the "Paste" option the standard graph will be \n',...
        'converted to an advanced graph. This works analogously the other way around, in that \n',...
        'case the footer and title will be removed.'])...
        'Panel',...
        sprintf(['The "Panel" is a canvas that can contain several graphs and / or tables. \n',...
        'A panel can then be saved and included in a graph package like any other graphical \n',...
        'object in DAG. When you start up the graph panel it is by default a 2 x 2 subplot, \n',...
        'where all subplots are empty. To import a graph you must first create it by producing \n',...
        'a normal graph or an advanced graph. Then copy it by right-clicking and choosing "Copy" \n',...
        'and then paste it into the subplot of the panel you want by right-clicking and choosing \n',...
        'the "Paste" option']),...
        'Subplot',...
        sprintf(['The "Subplot" type is a quick way to create a 2 x 2 subplot with graphs in DAG. \n',...
        'Only one variable will be plotted in each subplot. If the dataset has more than four \n',...
        'variables you can switch the plotted variables by using Graph ',arrow,' Graphs.']),...
        'Table',...
        sprintf(['To construct a table in DAG, use the "Table" option. This option opens an empty \n',...
        'figure in which you can load a dataset.  When a data set is uploaded it will automatically \n',...
        'generate a table with a standard template. By right-clicking on the table and \n',...
        'choosing Template ',arrow,' Latex, it is possible to change a template to the baseline LaTeX \n',...
        'layout. To set the width of the columns and rows manually, right-click and choose \n',...
        'Align ',arrow,' Columns / Rows.']),...
        'Advanced table',...
        sprintf(['Similar to how the Graph / Advanced graph works, the "Advanced table" give you access \n',...
        'to adding a title, footer, numbering and other elements required for publication through the \n',...
        '"Advanced menu". Furthermore, you will need to use an "Advanced table" if you want to \n',...
        'include it in a graph package at some point. Note that it is possible to convert a \n',...
        '"Table" into an "Advanced table" and vice versa. Simply right-click on the standard table \n',...
        'and copy the figure locally in DAG by using the "Copy" option. Then, open up an empty \n',...
        'advanced table and right-click somewhere in that window. By using the "Paste" option \n',...
        'the standard table will be converted to an advanced table. This works analogously the \n',...
        'other way around, in that case the footer and title will be removed.'])});
end
















