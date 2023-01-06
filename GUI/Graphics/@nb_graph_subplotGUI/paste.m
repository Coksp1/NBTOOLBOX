function paste(gui,~,~,subPlotter)
% Syntax:
%
% paste(gui,hObject,event,subPlotter)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    object = gui.parent.copiedObject;
    if not(isa(object,'nb_graph_obj') || isa(object,'nb_graph_adv'))
        nb_errorWindow('Cannot paste the copied object into a panel.')
        return
    end
    nb_confirmWindow('Are you sure you want to paste the copied object into the given location in the panel?',...
        @notPaste,{@pasteObject,gui,object,subPlotter},[gui.parent.guiName ': Paste Graph/Table Object'])

end

%==================================================================
% Callbacks
%==================================================================
function notPaste(hObject,~)

    close(get(hObject,'parent'));
    
end

function pasteObject(hObject,~,gui,object,subPlotter)

    close(get(hObject,'parent'));
    
    % Delete axes of old object
    if isa(subPlotter,'nb_graph_adv')
        p = subPlotter.plotter;
    else
        p = subPlotter;
    end
    
    axesToDelete = get(p,'axesHandle');
    axesToDelete.deleteOption = 'all';
    delete(axesToDelete);
    
    % Reset graph object (Will here be copied, so we need the
    % to return the object as its copied version)
    object = gui.plotter.reset(subPlotter,object);
    
    % Update the pasted object with all the needed properties
    if isa(object,'nb_graph_adv')
        object.plotter.parent = gui.parent;
    else
        object.parent = gui.parent;
    end
    addContextMenu(gui,object);
    
    % Add listeners to the pasted graph
    if isa(object,'nb_graph_adv')
        temp = object.plotter;
        addlistener(object,'updatedGraph',@gui.changedCallback);
        addlistener(object,'titleOrFooterChange',@gui.updateGraph);
        addlistener(temp,'updatedGraph',@gui.changedCallback);
        if isa(object.plotter,'nb_graph')       
            addlistener(temp,'updatedGraphStyle',@temp.enableUIComponents);
            addlistener(temp,'updatedGraphStyle',@gui.changedCallback);
        end
    else     
        addlistener(object,'updatedGraph',@gui.changedCallback);
        if isa(object,'nb_graph')
            addlistener(object,'updatedGraphStyle',@object.enableUIComponents);
            addlistener(object,'updatedGraphStyle',@gui.changedCallback);
        end
    end
    
    % Update the panel window
    graph(gui.plotter);
    gui.changed = 1;
    
    % Clean up
    delete(subPlotter)
    
end
