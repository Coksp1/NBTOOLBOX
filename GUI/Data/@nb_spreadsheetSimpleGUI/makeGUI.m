function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG. Make GUI figure
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.data)
        enable = 'off';
    else
        enable = 'on';
    end
     
    % Set up the menu
    %------------------------------------------------------
    dataM = uimenu(gui.figureHandle,'label','File','enable',enable);
    gui.dataMenu = dataM;
        if isa(gui.parent,'nb_GUI')
            uimenu(gui.dataMenu,'Label','Save','Callback',@gui.save);
            uimenu(gui.dataMenu,'Label','Save as','Callback',@gui.saveAs);
            uimenu(gui.dataMenu,'Label','Rename dataset','separator','on','Callback',@gui.renameSpreadsheet);
        end
        uimenu(gui.dataMenu,'Label','Export','separator','on','Callback',@gui.export);
        uimenu(gui.dataMenu,'Label','Write','Callback',@gui.write);

    datasetM = uimenu(gui.figureHandle,'label','Dataset','enable',enable);
        uimenu(datasetM,'Label','Notes','Callback',@gui.editNotes);
        uimenu(datasetM,'Label','Source','Callback',@gui.getSource);
        uimenu(datasetM,'Label','Displayed Page','Callback',@gui.setPage,'separator','on');
        uimenu(datasetM,'Label','Previous Page','Callback',@gui.previousPage,'accelerator','E');
        uimenu(datasetM,'Label','Next Page','Callback',@gui.nextPage,'accelerator','D'); 
        
    gui.datasetMenu = datasetM;          

    gui.statisticsMenu = uimenu(gui.figureHandle,'label','Statistics','enable','off');

    viewM = uimenu(gui.figureHandle,'label','View');
        uimenu(viewM,'Label','Freeze','checked','on','Callback',@gui.updateTableType);
        uimenu(viewM,'Label','Unfreeze','Callback',@gui.updateTableType);
        precision = uimenu(viewM,'Label','Precision');
            uimenu(precision,'Label','1','Callback',@gui.precisionCallback);
            uimenu(precision,'Label','2','Callback',@gui.precisionCallback);
            uimenu(precision,'Label','3','Callback',@gui.precisionCallback);
            uimenu(precision,'Label','4','Callback',@gui.precisionCallback,'checked','on');
            uimenu(precision,'Label','5','Callback',@gui.precisionCallback);
            uimenu(precision,'Label','6','Callback',@gui.precisionCallback);
            uimenu(precision,'Label','7','Callback',@gui.precisionCallback);
            uimenu(precision,'Label','8','Callback',@gui.precisionCallback);
            uimenu(precision,'Label','9','Callback',@gui.precisionCallback);
    gui.viewMenu = viewM;

    helpM        = uimenu(gui.figureHandle,'label','Help');
    gui.helpMenu = helpM;

end
