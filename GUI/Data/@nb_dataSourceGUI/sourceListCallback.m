function sourceListCallback(gui,~,~)
% Syntax:
%
% sourceListCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Get all sources in a list to be able to edit all at once.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the source index (I.e. each page can consist of more sources)
    sources              = get(gui.sourceSelect, 'String');
    gui.sourceListWindow = nb_guiFigure(gui.parent,'Source list',[50 40 80 30],'normal','off');
    gui.table            = nb_uitable(gui.sourceListWindow,'units','normalized',...
                            'ColumnFormat',{'char'},'ColumnEditable',true,...
                            'data',sources,'position',[0.04,0.13,0.92,0.83]);        
                        
    boxWidth = 0.3;                    
    uicontrol(gui.sourceListWindow,nb_constant.BUTTON,...
        'position',     [0.5-boxWidth/2,0.04, boxWidth, 0.05],...
        'string',       'Update',...
        'callback',     @(h,e)updateAll(gui,h,e));
       
    set(gui.sourceListWindow,'visible','on')
    
end
    
function updateAll(gui,~,~)     
    
    % Get the updated list
    sources = get(gui.table,'data');

    % Update the link of the object
    new      = gui.data;
    link     = get(new,'links');
    numLinks = length(link.subLinks);
    kk       = 1;
    for ii = 1:numLinks
    
        sourcesT = link.subLinks(ii).source;
        if iscell(sourcesT)
            numLinksT = length(sourcesT);
            for jj = 1:numLinksT
                link.subLinks(ii).source{jj} = sources{kk};
                kk = kk + 1;
            end
        else
            link.subLinks(ii).source = sources{kk};
            kk = kk + 1;
        end
        
    end
    new = new.setLinks(link);
    
    try
        new = update(new,'off','on');
    catch Err
        nb_errorWindow('Error while updating the data with the new source.', Err)
        return
    end
    
    % Update the data and notify the listeners (i.e. spreadsheetGUI)
    gui.data = new;
    notify(gui,'methodFinished');
    
    % Update the main window of the nb_dataSourceGUI
    gui.updateGUI();
    
    % Close source list window
    delete(gui.sourceListWindow);
    
    % Inform the user
    nb_infoWindow('The change of source was successful!')
     
end
