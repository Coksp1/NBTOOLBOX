function sheetCallback(gui,hObject,~)
% Syntax:
%
% sheetCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Change sheet of source link.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    string = get(hObject,'string');
    
    % Get the source index (I.e. each page can consist of more sources)
    index         = get(gui.sourceSelect,'value');
    sourceIndex   = gui.linkInfo(index);
  
    % Update the link of the object
    new      = gui.data;
    link     = get(new,'links');
    oldSheet = link.subLinks(sourceIndex).sheet;
    link.subLinks(sourceIndex).sheet = string;
    new = new.setLinks(link);
    
    try
        new = update(new,'off','on');
    catch Err
        set(hObject,'string',oldSheet)
        nb_errorWindow('Error while updating the data with the new sheet.', Err)
        return
    end
    
    % Update the data and notify the listeners (i.e. spreadsheetGUI)
    gui.data = new;
    notify(gui,'methodFinished');
    
    % Inform the user
    nb_infoWindow('The change of sheet was successful!')
     
end
