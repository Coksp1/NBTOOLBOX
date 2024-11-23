function changeSourceCallback(gui,hObject,~)
% Syntax:
%
% changeSourceCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Change between different sources.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    string = get(hObject,'string');

    % Get the source index (I.e. each page can consist of more sources)
    index         = get(gui.sourceSelect,'value');
    sourceIndex   = gui.linkInfo(index);
    indexOfSource = sum(gui.linkInfo(1:index)==sourceIndex);
       
    % Update the link of the object
    new     = gui.data;
    link    = get(new,'links');
    sources = link.subLinks(sourceIndex).source;
    if iscell(sources)
        oldSource = link.subLinks(sourceIndex).source{indexOfSource};
        link.subLinks(sourceIndex).source{indexOfSource} = string;
    else
        oldSource = link.subLinks(sourceIndex).source;
        link.subLinks(sourceIndex).source = string;
    end
    new = new.setLinks(link);
    
    try
        new = update(new,'off','on');
    catch Err
        set(hObject,'string',oldSource)
        nb_errorWindow('Error while updating the data with the new source.', Err)
        return
    end
    
    % Update source list box
    sourceList        = get(gui.sourceSelect, 'String');
    sourceList{index} = string;
    set(gui.sourceSelect, 'String', sourceList);

    % Update the data and notify the listeners (i.e. spreadsheetGUI)
    gui.data = new;
    notify(gui,'methodFinished');
    
    % Inform the user
    nb_infoWindow('The change of source was successful!')
     
end
