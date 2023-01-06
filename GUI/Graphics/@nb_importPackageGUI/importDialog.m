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
    c        = strfind(filename,'.');
    gui.name = filename(1:c(end)-1);
    ext      = filename(c(end)+1:end);

    % Load the file
    %--------------------------------------------------
    switch lower(ext)

        case 'mat'

            loaded = load([pathname filename]);
            stored = fieldnames(loaded);

            if length(stored) > 1
                nb_errorWindow(['Could not read ' filename ' file. The .MAT file contain more then one graph package object (or other variables).']);
                return
            end
            object = loaded.(stored{1});

            if isa(object,'nb_graph_package') 
                gui.package = object;
            else
                nb_errorWindow(['Could not read ' filename ' file. The .MAT file does not contain a graph package object.']);
                return
            end


        otherwise

            nb_errorWindow(['Could not read ' filename ' file. The extension .' ext ' is not supported.']);
            return

    end

    % Import Package
    importCurrent(gui); 

end

