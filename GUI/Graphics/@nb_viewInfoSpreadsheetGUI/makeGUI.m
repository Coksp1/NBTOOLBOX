function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
%
% GUI window for displaying the info spreadsheet.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    f    = nb_guiFigure(gui.parent,gui.name,[40   15  186.4   43],'normal','on');
    gui.figureHandle = f;
    
    % Make menu
    opMenu = uimenu(f,'Label','Options');
    uimenu(opMenu,'Label','Export to Excel','callback',@gui.exportInfoSpreadsheet2Excel);
    uimenu(opMenu,'Label','Help','separator','on','callback',@gui.helpViewInfoSpreadsheetGUICallback);
    
    % Create table
    colNames    = gui.info(1,:);
    m           = length(colNames);
    data        = gui.info(2:end,:);
    colInput    = cell(1,m);
    colInput(:) = {'char'};   
    
    t = nb_uitable(f,...
        'units',                'normalized',...
        'position',             [0 0 1 1],...
        'data',                 data,...
        'columnName',           colNames,...
        'columnFormat',         colInput,...
        'columnEdit',           false(1,m));
    gui.table = t;
    
    % Show figure
    set(f,'visible','on')

end
