function importDistributionCallback(gui,~,~)
% Syntax:
%
% importDistributionCallback(gui,hObject,event)
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
    l      = load([pathname,saveN]);
    fields = fieldnames(l);
    if length(fields) ~= 1
        nb_errorWindow('Wrong file format of the loaded .mat file. The .mat file must include a nb_distribution object (and only that).')
        return
    end
    distr = l.(fields{1});
    if isa(distr,'nb_distribution')
        gui.loaded = distr;
        importDistributionGUI(gui);
    else
        nb_errorWindow('Wrong file format of the loaded .mat file. The .mat file must include a nb_distribution object (and only that).')
        return
    end
    
end
