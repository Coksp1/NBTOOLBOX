function saveCurrent(gui,hObject,~)
% Syntax:
%
% saveCurrent(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Check save name
    [gui.name,message] = nb_checkSaveName(gui.name);
    if ~isempty(message)

        % The selected file name is not a valid save name in
        % the GUI, so the user must provide another
        savegui = nb_saveAsPackageGUI(gui.parent,gui.package);
        addlistener(savegui,'saveNameSelected',@gui.notifyListeners); 
        return

    end

    % Get the already stored data
    appPackages = gui.parent.graphPackages;

    % Update the structure of stored data objects
    found = isfield(appPackages,gui.name);
    if found
        % Ask for a respons: 
        % - Callbacks: rename, overwrite or exit
        loadOptionsWhenExist(gui);
    else
        
        % Save to GUI
        appPackages.(gui.name)   = gui.package;
        gui.parent.graphPackages = appPackages;
        nb_syncLocalVariablesGUI(gui.parent,gui.package);
        
        % Dump all the graph objects of the package to main program
        dumpGraphs(gui);

    end  
    
    % Close window 
    close(get(hObject,'parent')); 
    
end
