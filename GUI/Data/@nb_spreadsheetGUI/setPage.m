function setPage(gui,~,~)
% Syntax:
%
% setPage(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
          
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(gui.parent,'nb_GUI')
        name = [gui.parent.guiName ': Set Page to Display'];
    else
        name = 'Set Page to Display';
    end

    % Create window
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
               'units',          'characters',...
               'position',       [65   15  60   9],...
               'Color',          defaultBackground,...
               'name',           name,...
               'numberTitle',    'off',...
               'menuBar',        'None',...
               'toolBar',        'None',...
               'resize',         'off');
    nb_moveFigureToMonitor(f,currentMonitor,'center');

    % Find the coordinate parameters
    startX          = 0.05;
    width           = 1 - startX*2;
    height          = 0.18;
    listExtraHeight = 0.04;

    uicontrol('units',              'normalized',...
              'position',           [startX, 0.65,width,height],...
              'parent',             f,...
              'style',              'text',...
              'string',             'Select Page',...
              'horizontalAlignment','left');             

    if isa(gui.data,'nb_modelDataSource')
        temp  = fetch(gui.data);
        pages = temp.dataNames;
    else
        pages = gui.data.dataNames;
    end           
    pop = uicontrol( 'units',             'normalized',...
                     'position',           [startX, 0.45,width,height + listExtraHeight],...
                     'parent',             f,...
                     'background',         [1 1 1],...
                     'style',              'popupmenu',...
                     'string',             pages);         

    buttonWidth  = 0.3;
    buttonHeigth = 0.2;
    uicontrol('units',       'normalized',...
              'position',    [0.5 - buttonWidth/2, (0.45 - buttonHeigth)/2,buttonWidth,buttonHeigth],...
              'parent',      f,...
              'style',       'pushbutton',...
              'string',      'Select',...
              'callback',    {@selectPageCallback,gui,pop});

    % Make GUI visible
    set(f,'visible','on');

    function selectPageCallback(~,~,gui,pop)
    % Get selected page

        try
            gui.page = get(pop,'value');
            updateTable(gui);
        catch
            nb_errorWindow('Spreadsheet has been closed.')
            delete(get(pop,'parent'));
        end

    end

end
