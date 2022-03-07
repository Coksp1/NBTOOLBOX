function addGraphCallback(gui,~,~,type)
% Syntax:
%
% addGraphCallback(gui,h,e)
%
% Description:
%
% Part of DAG. 
% 
% Written by Kenneth Sæterhagen Paulsen

    if strcmpi(type,'data')
        loader = nb_loadDataGUI(gui.parent);
        addlistener(loader,'sendLoadedData',@(h,e)createNewGraph(h,e,gui));
    else
        loader = nb_loadGraphGUI(gui.parent);
        addlistener(loader,'loadObjectFinished',@(h,e)createNewGraph(h,e,gui));
    end
    
end

function createNewGraph(hObject,~,gui)

    if isa(hObject,'nb_loadDataGUI')
        switch class(hObject.data)
            case 'nb_ts'
                graphObject = nb_graph_ts(hObject.data);
            case 'nb_data'
                graphObject = nb_graph_data(hObject.data);
            case 'nb_cs'
                graphObject = nb_graph_cs(hObject.data);
        end
        graphObject = defaultPlotter(gui,graphObject,'normal',gui.plotterAdv.plotter.currentTemplate);
    else
        graphObject = hObject.plotter;
        if isa(graphObject,'nb_graph_adv')
            graphObject = graphObject.plotter(1);
        end
    end
    
    if ~isa(graphObject, class(gui.plotterAdv.plotter))
        
        switch class(graphObject)
            case 'nb_graph_ts'
                graph2 = 'time-series';
            case 'nb_graph_data'
                graph2 = 'dimension-less';
            case 'nb_graph_cs'
                graph2 = 'cross-sectional';
        end
        switch class(gui.plotterAdv.plotter)
            case 'nb_graph_ts'
                graph1 = 'time-series';
            case 'nb_graph_data'
                graph1 = 'dimension-less';
            case 'nb_graph_cs'
                graph1 = 'cross-sectional';
        end
        
        nb_errorWindow(['It is not possible to combine graphs with ' graph1 ' and ' graph2 ' data in graph panel'])
        return
    end
    
    % Adjust positions
    template                        = gui.parent.settings.graphSettings.(gui.plotterAdv.plotter.currentTemplate);
    gui.plotterAdv.plotter.position = template.position1;
    graphObject.position            = template.position2;

    % Add extra plotter object to advanced graph
    addGraph(gui.plotterAdv,graphObject);

    % Assign same figureHandle
    fig = get(gui.plotterAdv.plotter(1),'figureHandle');
    setSpecial(gui.plotterAdv.plotter(2),'figureHandle',fig);
    
    % Add context menu
    cMenu = uicontextmenu(); 
            uimenu(cMenu,'Label','Copy','Callback',@gui.copy,'userData',2);
            clipMenu = uimenu(cMenu,'Label','Copy to Clipboard');
                uimenu(clipMenu,'Label','As figure','Callback',@gui.copyToClipboard);
                uimenu(clipMenu,'Label','As data','Callback',@gui.copyToClipboardAsData,'userData',2);
            uimenu(cMenu,'Label','Paste annotation','Callback',@gui.pasteAnnotationCallback,'separator','on','userData',2);     
    gui.plotterAdv.plotter(2).setSpecial('UIContextMenu',cMenu);
    
    % Move legend below, and remove legend for second graph
    set(gui.plotterAdv.plotter(1),'legLocation','below');
    set(gui.plotterAdv.plotter(2),'noLegend',true,'legLocation','best');
    
    % Update graphs
    graph(gui.plotterAdv.plotter(1));
    checkGraphObject(gui,gui.plotterAdv.plotter(2),'normal');
    
    % Update menu
    set(findobj(gui.advancedMenu,'Label','Add graph (load dataset)'),'enable','off');  
    set(findobj(gui.advancedMenu,'Label','Add graph (load graph)'),'enable','off'); 
    set(findobj(gui.advancedMenu,'Label','Remove graph'),'enable','on');    
    set(findobj(gui.advancedMenu,'Label','Change graph'),'enable','on');    
    
    % Notify
    notify(gui.plotterAdv.plotter(1),'updatedGraph');
 
end
