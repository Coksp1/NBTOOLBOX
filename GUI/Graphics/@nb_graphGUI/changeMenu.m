function changeMenu(gui,value)
% Syntax:
%
% changeMenu(gui,value)
%
% Description:
%
% Part of DAG. 
% 
% Written by Kenneth Sæterhagen Paulsen

    % Delete old menu
    delete(findobj(gui.graphMenu,'Label','Notes'));
    delete(get(gui.dataMenu,'children'));
    delete(get(gui.propertiesMenu,'children'));
    delete(get(gui.annotationMenu,'children'));
    delete(get(gui.advancedMenu,'children'));
    
    % Create new menu
    addMenuComponents(gui.plotterAdv,gui.graphMenu,gui.dataMenu,...
        gui.propertiesMenu,gui.annotationMenu,gui.advancedMenu,value);
    
    % Add second graph menu components
    uimenu(gui.advancedMenu,'Label','Add graph (load dataset)','separator','on','Callback',@(h,e)gui.addGraphCallback(h,e,'data'),'enable','off');
    uimenu(gui.advancedMenu,'Label','Add graph (load graph)','separator','off','Callback',@(h,e)gui.addGraphCallback(h,e,'graph'),'enable','off');    
    uimenu(gui.advancedMenu,'Label','Remove graph','Callback',@gui.removeGraphCallback,'enable','on');
    uimenu(gui.advancedMenu,'Label','Change graph','Callback',@gui.changeGraphCallback,'enable','on');
    
    % Delete the old help menu and add the one with help on templates
    delete(findobj(gui.advancedMenu,'Label','Help'));
    uimenu(gui.advancedMenu,'Label','Help','separator','on','Callback',@gui.helpAdvancedMenuCallback);
    
    % Update menu
    enableUIComponents(gui,gui.plotterAdv.plotter(value),[]);
    
    % Update other stuff
    gui.plotter = gui.plotterAdv.plotter(value);

end
