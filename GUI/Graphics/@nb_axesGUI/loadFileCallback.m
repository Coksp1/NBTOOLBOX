function loadFileCallback(gui,~,~)
% Syntax:
%
% loadFileCallback(gui,~,~)
%
% Description:
% 
% Part of DAG. Callback function when user want to select file
% 
% Written by Kenneth Sæterhagen Paulsen and Henrik Halvorsen Hortemo

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the file name
    [filename, pathname] = uigetfile({'*.mat',  'MAT file (*.mat)';...
                                      '*.*',    'All Files (*.*)'},'Select Colormap file',nb_getLastFolder(gui));
                                   
    % Get the file and construct a DSGE object
    %------------------------------------------------------
    if not(~isscalar(filename) && ~isscalar(pathname))
        return
    end
    nb_setLastFolder(gui,pathname);
        
    [~,filename,ext] = fileparts(filename);  
    fullFilename     = [fullfile(pathname,filename) ext];    

    % Find name and extension
    switch lower(ext)
        case {'.mat'}
            % Do nothing
        otherwise
            nb_errorWindow(['Could not read ' gui.filename ' file. The extension .' ext ' is not supported.']);
            return
    end

    % Test the selected MAT file
    try
        value = nb_load(fullFilename);
    catch Err
        nb_errorWindow('Could not load color map file.',Err)
        return
    end
    if ~isnumeric(value)
        nb_errorWindow('Could not load color map file. File must contain a matrix with size N x 3.')
        return
    elseif size(value,2) ~= 3
        nb_errorWindow('Could not load color map file. File must contain a matrix with size N x 3.')
        return
    end
    gui.plotter.colorMap = fullFilename; 
    set(gui.colorMapEdit,'String',fullFilename);
    
    % Udate the graph
    notify(gui,'changedGraph');
        
end
