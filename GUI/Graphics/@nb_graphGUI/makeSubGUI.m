function makeSubGUI(gui)
% Syntax:
%
% makeSubGUI(gui)
%
% Description:
%
% Part of DAG. Update from nb_graphGUI interface to nb_graph_tsGUI,
% nb_graph_csGUI or nb_graph_dataGUI interfaces.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    plotterT = gui.plotter;
        
    % Enable menu and assign callbacks
    %------------------------------------------------------
    if strcmpi(gui.type,'advanced')
        
        if size(gui.plotterAdv.plotter,2) == 1
            enable1 = 'on';
            enable2 = 'off';
        else
            enable1 = 'off';
            enable2 = 'on';
        end
        
        addMenuComponents(gui.plotterAdv,gui.graphMenu,gui.dataMenu,gui.propertiesMenu,gui.annotationMenu,gui.advancedMenu);
        set(gui.advancedMenu,'enable','on');
        uimenu(gui.advancedMenu,'Label','Add graph (load dataset)','separator','on','Callback',@(h,e)gui.addGraphCallback(h,e,'data'),'enable',enable1);
        uimenu(gui.advancedMenu,'Label','Add graph (load graph)','separator','off','Callback',@(h,e)gui.addGraphCallback(h,e,'graph'),'enable',enable1);    
        uimenu(gui.advancedMenu,'Label','Remove graph','Callback',@gui.removeGraphCallback,'enable',enable2);
        uimenu(gui.advancedMenu,'Label','Change graph','Callback',@gui.changeGraphCallback,'enable',enable2);
        
        % Delete the old help menu and add the one with help on templates
        delete(findobj(gui.advancedMenu,'Label','Help'));
        uimenu(gui.advancedMenu,'Label','Help','separator','on','Callback',@gui.helpAdvancedMenuCallback);
        
        addlistener(gui.plotterAdv,'updatedGraph',@gui.changedCallback);
    else
        addMenuComponents(plotterT,gui.graphMenu,gui.dataMenu,gui.propertiesMenu,gui.annotationMenu);
    end
    
    set(gui.graphMenu,'enable','on');
    set(gui.propertiesMenu,'enable','on');
    set(gui.annotationMenu,'enable','on');
    set(gui.languageMenu,'enable','on');
    set(gui.templateMenu,'enable','on');
    
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
    
    % Create context menu
    %------------------------------------------------------
    cMenu = uicontextmenu(); 
            uimenu(cMenu,'Label','Copy','Callback',@gui.copy,'userData',1);
            clipMenu = uimenu(cMenu,'Label','Copy to Clipboard');
                uimenu(clipMenu,'Label','As figure','Callback',@gui.copyToClipboard);
                uimenu(clipMenu,'Label','As data','Callback',@gui.copyToClipboardAsData,'userData',1);
            uimenu(cMenu,'Label','Paste annotation','Callback',@gui.pasteAnnotationCallback,'separator','on','userData',1);    
    gui.axesContextMenu = cMenu; 
    plotterT.setSpecial('UIContextMenu',gui.axesContextMenu);
    
    % Add listener to the graph(s) object
    %--------------------------------------------------------------
    if strcmpi(gui.type,'advanced')
        for ii = 1:size(gui.plotterAdv.plotter,2)
            addlistener(gui.plotterAdv.plotter(ii),'updatedGraph',@gui.changedCallback);
            addlistener(gui.plotterAdv.plotter(ii),'updatedGraphStyle',@gui.enableUIComponents);
        end
    else
        addlistener(plotterT,'updatedGraph',@gui.changedCallback);
        addlistener(plotterT,'updatedGraphStyle',@gui.enableUIComponents);
    end
    
end
