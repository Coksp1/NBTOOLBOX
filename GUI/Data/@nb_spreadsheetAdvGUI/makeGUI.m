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

    if isempty(gui.data) && isa(gui.data,'nb_dataSource')
        enable = 'off';
    else
        enable = 'on';
    end

    % Create the file menu
    %--------------------------------------------------------------
    dataM = uimenu(gui.figureHandle,'label','File','enable',enable);
    gui.dataMenu = dataM;
        if isa(gui.parent,'nb_GUI')
            if gui.openElsewhere
                uimenu(gui.dataMenu,'Label',gui.saveToMenuText,'Callback',@gui.saveToListenerCallback);
                uimenu(gui.dataMenu,'Label','Save to Session','Callback',@gui.saveAs);
                uimenu(gui.dataMenu,'Label','Rename dataset','separator','on','Callback',@gui.renameSpreadsheet);
            else
                uimenu(gui.dataMenu,'Label','Save','Callback',@gui.save);
                uimenu(gui.dataMenu,'Label','Save as','Callback',@gui.saveAs);
                uimenu(gui.dataMenu,'Label','Rename dataset','separator','on','Callback',@gui.renameSpreadsheet);
            end
        end
        uimenu(gui.dataMenu,'Label','Export','separator','on','Callback',@gui.export);
        uimenu(gui.dataMenu,'Label','Write','Callback',@gui.write);
        gui.makeHistoryGUI(gui.dataMenu, @gui.updateGUI);

    % Create the dataset menu
    %--------------------------------------------------------------   
    gui.datasetMenu = uimenu(gui.figureHandle,'label','Dataset','enable',enable);

    % Create the statistics menu
    %--------------------------------------------------------------
    if isa(gui.data,'nb_cs') || isa(gui.data,'nb_modelDataSource')
        statEnable = 'off';  
    else
        statEnable = enable;
    end
    gui.statisticsMenu = uimenu(gui.figureHandle,'label','Statistics','enable',statEnable);

    % Create the view menu
    %--------------------------------------------------------------
    viewM = uimenu(gui.figureHandle,'label','View');
        uimenu(viewM,'Label','Freeze','checked','on','Callback',@gui.updateTableType);
        uimenu(viewM,'Label','Unfreeze','Callback',@gui.updateTableType);
        precision = uimenu(viewM,'Label','Precision','separator','on');
            uimenu(precision,'Label','1','Callback',@gui.precisionCallback);
            uimenu(precision,'Label','2','Callback',@gui.precisionCallback);
            uimenu(precision,'Label','3','Callback',@gui.precisionCallback);
            uimenu(precision,'Label','4','Callback',@gui.precisionCallback,'checked','on');
            uimenu(precision,'Label','5','Callback',@gui.precisionCallback);
            uimenu(precision,'Label','6','Callback',@gui.precisionCallback);
            uimenu(precision,'Label','7','Callback',@gui.precisionCallback);
            uimenu(precision,'Label','8','Callback',@gui.precisionCallback);
            uimenu(precision,'Label','9','Callback',@gui.precisionCallback);
        uimenu(viewM,'Label','Editable','Callback',@gui.editableCallback,'checked','off');
    gui.viewMenu = viewM;

    % Create the help menu
    %--------------------------------------------------------------
    helpM        = uimenu(gui.figureHandle,'label','Help');
    gui.helpMenu = helpM;
    
    % Add the ui menu components of the dataset and statistics 
    % menus
    %--------------------------------------------------------------
    addMenuComponents(gui);

end
