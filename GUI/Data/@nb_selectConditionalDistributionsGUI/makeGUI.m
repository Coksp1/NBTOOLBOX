function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Figure
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0, 'defaultUicontrolBackgroundColor');
    gui.figureHandle = figure(...
        'visible',        'off',...
        'units',          'characters',...
        'position',       [40   15  160   50],...
        'Color',          defaultBackground,...
        'name',           'Select distributions to condition on',...
        'numberTitle',    'off',...
        'menuBar',        'None',...
        'toolBar',        'None',...
        'resize',         'on',...
        'CloseRequestFcn', @gui.closeCallback);               
    nb_moveFigureToMonitor(gui.figureHandle, currentMonitor, 'center');

    
    fileM = uimenu(gui.figureHandle,'label','File');
        uimenu(fileM,'label','Export all','callback',@gui.exportCallback);
        uimenu(fileM,'label','Import all','callback',@gui.importCallback);
        uimenu(fileM,'label','Export distribution','callback',@gui.exportDistributionGUI,'separator','on');
        uimenu(fileM,'label','Import distribution','callback',@gui.importDistributionCallback);
        
    % Edit
    editMenu = uimenu(gui.figureHandle, 'Label', 'Edit');
    gui.makeHistoryGUI(editMenu, @gui.updateGUI);
            
    distM = uimenu(gui.figureHandle,'label','Distributions');    
        uimenu(distM,'label','Deactivate','callback',@gui.deactivateCallback);
        uimenu(distM,'label','Hard condition on variables','callback',@gui.conditionalCallback);
        uimenu(distM,'label','De-select hard condition on variables','callback',@gui.conditionalDeselctCallback);
    
    if isa(gui.model,'nb_model_generic')
        copulaM = uimenu(gui.figureHandle,'label','Copula');
            uimenu(copulaM,'label','Settings','callback',@gui.copulaSettingsCallback);
    end
    
    cMenu = uicontextmenu('parent',gui.figureHandle);
        uimenu(cMenu,'Label','Edit','Callback',@gui.editCallback);
        uimenu(cMenu,'Label','Copy','Callback',@gui.copyCallback,'separator','on');
        uimenu(cMenu,'Label','Paste','Callback',@gui.pasteCallback);
        uimenu(cMenu,'Label','Paste (mean adjusted)','Callback',@gui.pasteMeanAdjustedCallback);
        uimenu(cMenu,'Label','Paste (mode adjusted)','Callback',@gui.pasteModeAdjustedCallback);
        uimenu(cMenu,'Label','Copy limits','Callback',@gui.copyLimitsCallback,'separator','on');
        uimenu(cMenu,'Label','Paste limits','Callback',@gui.pasteLimitsCallback);
        uimenu(cMenu,'Label','Hard condition on observation','Callback',@gui.singleConditionalCallback,'separator','on');
        
    % Create table
    gui.tableHandle = nb_uitable(...
        'Parent', gui.figureHandle, ...
        'Units', 'normalized', ...
        'Position', [0 0 1 1], ...
        'cellSelectionCallback',@gui.getSelectedCells,...
        'UIContextMenu',cMenu);
    
    % Update table contents
    gui.addToHistory();
    gui.updateGUI();
    
    % Show figure
    set(gui.figureHandle,'visible','on');
    
end
