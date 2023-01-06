function breakLinkCallback(gui,~,~)
% Syntax:
%
% breakLinkCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Break link to data source.
%
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

% TODO: Make into nb_dataSource method if found robust

    sourceIndex = gui.linkInfo(get(gui.sourceSelect, 'value'));
       
    data    = gui.data;
    links   = get(data, 'links');     
    subLink = links.subLinks(sourceIndex);
    
    if ~isfield(subLink, 'data')
        nb_errorWindow('Please update dataset and try again.');
        return
    end
    
    subLink.sourceType = ['private(' getSubLinkClass(subLink) ')'];
    subLink.source     = subLink.data;
    subLink.variables  = nb_nestedCell2Cell(subLink.variables);

    links.subLinks(sourceIndex) = subLink;
    data = data.setLinks(links);
    
    try
        data = update(data, 'off', 'on');
    catch Err
        nb_errorWindow('Error while deleting source.', Err)
        return
    end
    
    gui.data = data;
    gui.updateGUI();
    
    notify(gui, 'methodFinished');
    nb_infoWindow('The link was successfully broken!');
end

function className = getSubLinkClass(subLink)
    if ~isempty(subLink.startDate)
        if isnumeric(subLink.startDate)
            className = 'nb_data';
        else
            className = 'nb_ts';
        end
    else % if ~isempty(subLink.types)
        className = 'nb_cs';
    end
end
