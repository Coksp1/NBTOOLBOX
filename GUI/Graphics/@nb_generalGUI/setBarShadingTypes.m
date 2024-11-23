function setBarShadingTypes(gui,~,~)
% Syntax:
%
% setBarShadingTypes(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
    parent   = gui.plotter.parent;
    if isa(parent,'nb_GUI')
        name = [parent.guiName ': Bar Shading Types Selection'];
    else
        name = 'Bar Shading Types Selection';
    end
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
               'units',          'characters',...
               'position',       [65   15  70   30],...
               'Color',          defaultBackground,...
               'name',           name,...
               'numberTitle',    'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'resize',         'off');
    nb_moveFigureToMonitor(f,currentMonitor,'center');
           
    % Panel with type selection list
    uip = uipanel('parent',              f,...
                  'title',               'Select',...
                  'units',               'normalized',...
                  'position',            [0.04, 0.04, 0.44, 0.92]);
    
    % List of types
    types = plotterT.typesToPlot;
    
    list = uicontrol('units',       'normalized',...
                     'position',    [0.04, 0.02, 0.92, 0.96],...
                     'parent',      uip,...
                     'background',  [1 1 1],...
                     'style',       'listbox',...
                     'string',      types,...
                     'value',       [],... 
                     'min',         0,...
                     'max',         size(types,2)); 
                                  
    % Create ok button
    width  = 0.2;
    height = 0.06;
    uicontrol('units',          'normalized',...
              'position',       [0.5 + 0.25 - width/2 - 0.01, 0.4, width, height],...
              'parent',         f,...
              'style',          'pushbutton',...
              'Interruptible',  'off',...
              'string',         'OK',...
              'callback',       {@selectTypes,gui,list}); 
      
    % Make it visible
    set(f,'visible','on')      
          
    % Wait for the figure window to close      
    waitfor(f);      
      
    % Update graph object
    plotterT.barShadingTypes = gui.selected;
    
    % Notify listeners
    notify(gui,'changedGraph');
     
end


function selectTypes(hObject,~,gui,list)

    % Get the selected types
    string       = get(list,'string');
    index        = get(list,'value');
    sel          = string(index)';
    gui.selected = sel;
    
    close(get(hObject,'parent'));

end
