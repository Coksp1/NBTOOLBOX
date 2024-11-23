function saveCallback(gui,hObject,~)
% Syntax:
%
% saveCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Save imported data to DAG session.
%
% Input:
%
% - hObject : nb_syncLocalVariablesGUI or []
%
% Written by Eyo I. Herstad and Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isempty(hObject)
        % Get nb_ts,nb_cs or nb_data object from the 
        % nb_syncLocalVariablesGUI object
        gui.data = hObject.object;
    end

    % Get the already stored data
    appData = gui.parent.data;

    [gui.name,message] = nb_checkSaveName(gui.name);
    if ~isempty(message)

        % The selected file name is not a valid save name in
        % the GUI, so the user must provide another
        savegui = nb_saveAsDataGUI(gui.parent,gui.data);
        addlistener(savegui,'saveNameSelected',@gui.closeWindow); 
        return

    end
    
    % Update the structure of stored data objects
    found = isfield(appData,gui.name);
    if found
        % Ask for a respons:
        % - Callbacks: merge, overwrite or exit
        gui.loadOptionsWhenExist();
    else
        
        [saveName,message] = nb_checkSaveName(gui.name);
        if ~isempty(message)
            nb_errorWindow(message);
            return
        end
       
        appData.(saveName) = gui.data;
        
        % Assign it to the main GUI object so I can use it later
        gui.parent.data = appData;

    end

    % Close file import window
    closeWindow(gui,'','');

end
