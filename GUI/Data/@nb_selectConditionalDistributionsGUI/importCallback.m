function importCallback(gui,~,~)
% Syntax:
%
% importCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the file name
    [filename,pathname] = uigetfile({'*.mat','MAT (*.mat)'},'',nb_getLastFolder(gui));

    % Read input file
    %------------------------------------------------------
    if not(~isscalar(filename) && ~isscalar(pathname))
        return
    end
    nb_setLastFolder(gui,pathname);
    
    % Find name and extension
    [~,saveN] = fileparts(filename);

    % Load .mat file
    dens = load([pathname,saveN]);
    try
        gui.distributions = dens.data;
        gui.dates         = dens.dates;
        gui.variables     = dens.variables; 
        gui.sigma         = dens.sigma; 
    catch
        nb_errorWindow('Wrong file format of the loaded .mat file.')
    end
    
    % Update table contents
    gui.addToHistory();
    gui.updateGUI();
    
end
