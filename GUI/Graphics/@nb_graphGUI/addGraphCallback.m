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
    
    % Adjust positions
    gui.plotterAdv.plotter.position = getTemplateProperty(gui.plotterAdv.plotter,...
        '','position1');

    % Add extra plotter object to advanced graph
    graphObject.position = getTemplateProperty(gui.plotterAdv.plotter,'','position2');
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
