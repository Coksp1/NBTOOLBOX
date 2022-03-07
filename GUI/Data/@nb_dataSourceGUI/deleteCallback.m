function deleteCallback(gui,~,~)
% Syntax:
%
% deleteCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Delete source of dataset.
%
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

% TODO: Make into nb_dataSource method if found robust

    index       = get(gui.sourceSelect, 'value');
    sourceIndex = gui.linkInfo(index);
       
    data     = gui.data;
    links    = get(data, 'links');  
    subLinks = links.subLinks;
    
    operations     = subLinks(sourceIndex).operations;
    operationNames = [operations{:}];
    operationNames = operationNames(1:2:end);
    
    mergeIndex = find(...
        strcmpi(operationNames, 'merge') | ...
        strcmpi(operationNames, 'mergeappend'), 1);

    if ~isempty(mergeIndex)
        % Move post-merge operations to child source
        subLinks(sourceIndex + 1).operations = [...
            subLinks(sourceIndex + 1).operations, ...
            operations(mergeIndex + 1:end)];
    else
        % Nothing left for parent to merge, so we delete the merge operation
        [parentIndex, parentOperationIndex] = findParent(subLinks, sourceIndex);
        if ~isempty(parentIndex) && ~isempty(parentOperationIndex)
            subLinks(parentIndex).operations(parentOperationIndex) = [];
        end
    end

    subLinks(sourceIndex) = [];
    links.subLinks        = subLinks;
    data                  = data.setLinks(links);
    if isempty(subLinks)
        nb_infoWindow(['The source was successfully deleted, and the deletion made the number'...
                      ' of data sources empty, which means that the data is no longer updateable!']);
        gui.data = data;
        delete(gui.sourceWindow);          
        notify(gui, 'methodFinished');
        return
    end
    
    try
        data = update(data, 'off', 'on');
    catch Err
        nb_errorWindow('Error while deleting source.', Err)
        return
    end
    
    if index > size(subLinks,1)
        index = index - 1;
    end
    set(gui.sourceSelect,'value',index)
    gui.data = data;
    gui.updateGUI();
    
    notify(gui, 'methodFinished');
    nb_infoWindow('The source was successfully deleted!');
    
end

function [parentIndex, parentOperationIndex] = findParent(subLinks, queryLink)
% This search follows (and must match) the structure of nb_dataSource.update

    parentIndex = [];
    parentOperationIndex = [];
    
    nextLink = 1;
    recursiveFind(nextLink);
    
    function recursiveFind(currentLink)
        nextLink = currentLink + 1;
        
        operationNames = [subLinks(currentLink).operations{:}];
        operationNames = operationNames(1:2:end);
        
        for operationIndex = 1:length(operationNames)
            operationName = operationNames{operationIndex};
            if any(strcmpi(operationName, {'merge', 'mergeappend'}))
                
                if (nextLink == queryLink)
                    % Found it!
                    parentIndex = currentLink;
                    parentOperationIndex = operationIndex;
                else
                    recursiveFind(nextLink);
                end
                
                % Search completed?
                if ~isempty(parentIndex)
                    return;
                end
                
            end
        end
    end

end
