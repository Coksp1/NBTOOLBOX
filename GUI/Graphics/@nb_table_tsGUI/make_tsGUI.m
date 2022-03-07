function make_tsGUI(gui)
% Syntax:
%
% make_tsGUI(gui)
%
% Description:
%
% Part of DAG. Make GUI figure
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;

    % Enable menu and assign callbacks
    %------------------------------------------------------
    if strcmpi(gui.type,'advanced')
        addMenuComponents(gui.plotterAdv,gui.graphMenu,gui.dataMenu,gui.propertiesMenu,gui.annotationMenu,gui.advancedMenu);
        set(gui.advancedMenu,'enable','on');
        addlistener(gui.plotterAdv,'updatedGraph',@gui.changedCallback);
    else
        addMenuComponents(plotterT,gui.graphMenu,gui.dataMenu,gui.propertiesMenu,gui.annotationMenu);
    end
    
    set(gui.languageMenu,'enable','on');
    set(gui.graphMenu,'enable','on');
    set(gui.propertiesMenu,'enable','on');
    set(gui.annotationMenu,'enable','on');

    if strcmpi(plotterT.language,'english')
        fObj = findobj(gui.languageMenu,'Label','English');
        set(fObj,'checked','on');
        fObj = findobj(gui.languageMenu,'Label','Norwegian');
        set(fObj,'checked','off');
    else
        fObj = findobj(gui.languageMenu,'Label','English');
        set(fObj,'checked','off');
        fObj = findobj(gui.languageMenu,'Label','Norwegian');
        set(fObj,'checked','on');
    end
    
    % Create context menu of panel
    %------------------------------------------------------
    cMenu = uicontextmenu(); 
            uimenu(cMenu,'Label','Copy','Callback',@gui.copy);
            clipMenu = uimenu(cMenu,'Label','Copy to Clipboard');
                uimenu(clipMenu,'Label','As figure','Callback',@gui.copyToClipboard);
                uimenu(clipMenu,'Label','As data','Callback',@gui.copyToClipboardAsData);
    gui.axesContextMenu = cMenu;
    plotterT.setSpecial('UIContextMenu',gui.axesContextMenu);
    
    % Add listener to the graph object
    %--------------------------------------------------------------
    addlistener(plotterT,'updatedGraph',@gui.changedCallback);

end
