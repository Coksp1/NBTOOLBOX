function updateDataCallback(gui,hObject,~)
% Syntax:
%
% updateDataCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% The method called when the nb_methodGUI class triggers a 
% methodFinished event.
%
% Input:
%
% - hObject : A nb_methodGUI object or a nb_mergeDataGUI.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the updated data and assign it to the spreadsheet 
    % (Calling the set.data method which will update the 
    % spreadsheet)
    try
        gui.data = hObject.data;
    catch Err
        if strcmpi(Err.identifier,'MATLAB:class:InvalidHandle')
            nb_errorWindow('Spreadsheet has been closed.')
        else
            nb_errorWindow('Fatal error::', Err)
        end
        return
    end
    
    % Add a dot when changed
    gui.changed = 1;
    
    % notify that the data has been updated. See the constructor of the
    % nb_spreadsheetAdvGUI class
    notify(gui,'updatedData')
    
end
