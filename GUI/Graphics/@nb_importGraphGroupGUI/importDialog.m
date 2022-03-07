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
        
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
    [~,~,ext] = fileparts(filename);

    % Load the file
    %--------------------------------------------------
    switch lower(ext)

        case '.mat'

            loaded = load([pathname filename]);
            stored = fieldnames(loaded);

            if length(stored) < 1
                nb_errorWindow(['Could not read ' filename ' file. The .MAT file contain no graph objects.']);
                return
            end

            for ii = 1:length(stored)

                object = loaded.(stored{ii});

                try
                    class = object.class;
                catch %#ok<CTCH>
                    nb_errorWindow(['Could not read ' filename ' file. The .MAT file does not only contain graph objects.']);
                    return
                end

                if strcmpi(class,'nb_graph_ts') || strcmpi(class,'nb_graph_cs') || strcmpi(class,'nb_graph_data')
                    object = nb_graph_adv.unstruct(object);
                    object = nb_importGraphGUI.checkObject(object);
                elseif strcmpi(class,'nb_graph_adv') 
                    object         = nb_graph_adv.unstruct(object);
                    object.plotter = nb_importGraphGUI.checkObject(object.plotter);
                else
                    nb_errorWindow(['Could not read ' filename ' file. The .MAT file does not only contain graph objects.']);
                    return
                end

                loaded.(stored{ii}) = object;

            end

        otherwise

            nb_errorWindow(['Could not read ' filename ' file. The extension .' ext ' is not supported.']);
            return

    end

    % Assign plotter property plotter for local variables syncing
    gui.plotter = loaded.(stored{1});

    % Get the already stored data
    appGraphs     = gui.parent.graphs;
    currentGraphs = fieldnames(appGraphs);
    ind           = ismember(stored,currentGraphs);
    updated       = stored(ind);
    gui.graphs    = loaded;

    % Update the structure of stored data objects
    if ~isempty(updated)

        % Ask for a respons: 
        % - Callbacks: rename, overwrite or exit
        gui.loadOptionsWhenExist(updated);

    else

        % Need to sync local variables, and this is best done by the
        % overwrtie method.
        overwrite(gui,[],[])

    end  

end
