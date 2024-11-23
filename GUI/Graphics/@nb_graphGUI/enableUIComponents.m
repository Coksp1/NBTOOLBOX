function enableUIComponents(gui,hObject,~)
% Syntax:
%
% enableUIComponents(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Input:
%
% - hObject : An object of class nb_graph
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isa(gui.plotter,'nb_graph')
        return
    end

    plotterT = gui.plotter;
    plotType = hObject.plotType;
    
    % Enable/disable ui-components
    reorderM = findobj(gui.propertiesMenu,'tag','reorderMenu');
    if isa(hObject,'nb_graph_ts')
        
        ch = findobj(gui.propertiesMenu,'tag','changeWhenDatesVsDates');
        if ~isempty(hObject.datesToPlot)
            
            % When we switch to Dates vs Dates graph we need to prevent
            % the user of some options.
            set(ch,'Label','Select date')
            
            rh = findobj(gui.annotationMenu,'tag','removeWhenRadarPie2');   
            set(rh,'enable','off');
    
            eh = findobj(gui.propertiesMenu,'tag','enableWhenLine');   
            set(eh,'enable','off');
            
            rh = findobj(gui.propertiesMenu,'tag','removedWhenDatesVsDates');
            set(rh,'enable','off');
            
            delete(get(reorderM,'children'));
            uimenu(reorderM,'Label','Dates','Callback',{@plotterT.reorderGUI,'dates'});
            uimenu(reorderM,'Label','Axes variables','Callback',{@plotterT.reorderGUI,'left'});
            return
            
        else
            set(ch,'Label','Select variable')
            
            rh = findobj(gui.propertiesMenu,'tag','removedWhenDatesVsDates');
            set(rh,'enable','on');
            
            delete(get(reorderM,'children'));
            uimenu(reorderM,'Label','Left axes variables','Callback',{@plotterT.reorderGUI,'left'});
            uimenu(reorderM,'Label','Right axes variables','Callback',{@plotterT.reorderGUI,'right'});
            
        end
        
    end
    
    % Remove when pie
    if strcmpi(plotType,'pie')
        enable = 'off';
    else
        enable = 'on';
    end
    removeWhenPie = findobj(gui.propertiesMenu,'tag','removeWhenPie');   
    set(removeWhenPie,'enable',enable);
    
    if strcmpi(plotType,'pie') || strcmpi(plotType,'radar')
        enable = 'off';
    else
        enable = 'on';
    end
    rh = findobj(gui.propertiesMenu,'tag','removeWhenRadarPie');   
    set(rh,'enable',enable);
    rh = findobj(gui.annotationMenu,'tag','removeWhenRadarPie');   
    set(rh,'enable',enable);
    rh = findobj(gui.annotationMenu,'tag','removeWhenRadarPie2');   
    set(rh,'enable',enable);
    
    if strcmpi(plotType,'line')
        enable = 'on';
    else
        enable = 'off';
    end
    eh = findobj(gui.propertiesMenu,'tag','enableWhenLine');   
    set(eh,'enable',enable);
    
    if strcmpi(plotType,'scatter')
        enable = 'off';
    else
        enable = 'on';
    end  
    set(reorderM,'enable',enable);
    
    % Can we add a second graph?
    if strcmpi(gui.type,'advanced')
        if size(gui.plotterAdv.plotter,2) == 2
            enable1 = 'on';
            enable2 = 'off';
        else
            enable1 = 'off';
            enable2 = 'on';
        end
        add = findobj(gui.advancedMenu,'Label','Add graph'); 
        set(add,'enable',enable2);
        rem = findobj(gui.advancedMenu,'Label','Remove graph'); 
        set(rem,'enable',enable1);
        cha = findobj(gui.advancedMenu,'Label','Change graph'); 
        set(cha,'enable',enable1);
    end
        
    % Update the changed status
    gui.changed = 1;
    
end
