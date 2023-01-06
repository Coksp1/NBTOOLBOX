function importDialog(gui)
% Syntax:
%
% importDialog(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
        
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the file name
    [filename, pathname] = uigetfile({'*.mat',  'MATLAB object (*.mat)';...
                                      '*.*',    'All Files (*.*)'},'',nb_getLastFolder(gui));

    % Read input file
    %------------------------------------------------------
    if not(~isscalar(filename) && ~isscalar(pathname))
        return
    end
    nb_setLastFolder(gui,pathname);

    % Find name and extension
    [~,saveName,ext] = fileparts(filename);

    % Load the file
    %--------------------------------------------------
    switch lower(ext)

        case '.mat'

            loaded = load([pathname filename]);
            stored = fieldnames(loaded);

            if length(stored) > 1
                nb_errorWindow(['Could not read ' filename ' file. The .MAT file contain more then one graph object (or other variables).']);
                return
            end
            object = loaded.(stored{1});

            if isa(object,'nb_graph_obj')
                gui.plotter = nb_importGraphGUI.checkObject(object);
            elseif isa(object,'nb_graph_adv')
                object.plotter = nb_importGraphGUI.checkObject(object.plotter);
                gui.plotter    = object;
            elseif isa(object,'nb_graph_subplot')

                for ii = 1:length(object.graphObjects)
                    object.graphObjects{ii} = nb_importGraphGUI.checkObject(object.graphObjects{ii});
                end
                gui.plotter = object;
            else
                nb_errorWindow(['Could not read ' filename ' file. The .MAT file does not contain a graph object.']);
                return
            end

        otherwise

            nb_errorWindow(['Could not read ' filename ' file. The extension .' ext ' is not supported.']);
            return

    end

    % Get the already stored data
    appGraphs          = gui.parent.graphs;
    [saveName,message] = nb_checkSaveName(saveName);
    gui.name           = saveName;
    if ~isempty(message)

        % The selected file name is not a valid save name in
        % the GUI, so the user must provide another
        savegui = nb_saveAsGraphGUI(gui.parent,gui.plotter);
        addlistener(savegui,'saveNameSelected',@gui.notifyListeners); 
        return

    end

    % Update the structure of stored data objects
    found = isfield(appGraphs,gui.name);
    if found
        % Ask for a respons: 
        % - Callbacks: rename, overwrite or exit
        gui.loadOptionsWhenExist();
    else
        appGraphs.(gui.name) = gui.plotter;

        % Assign it to the main GUI object so I can use it later. This will
        % also make it display in the list of the GUI, see nb_GUI.set.graphs
        gui.parent.graphs    = appGraphs;

        % Sync the local variables of the imported graph and the GUI
        nb_syncLocalVariablesGUI(gui.parent,gui.plotter);
    end 

end
