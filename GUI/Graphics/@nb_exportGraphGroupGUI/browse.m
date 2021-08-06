function browse(gui,~,~)
% Syntax:
%
% browse(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the file name
    [filename, pathname] = uiputfile(...
        {'*.mat', 'MATLAB Object (*.mat)';...
         '*.*',   'All files (*.*)'},...
        '',nb_getLastFolder(gui));

    if isscalar(filename) || isempty(filename) || isscalar(pathname)
        nb_errorWindow('Invalid save name selected.')
        return
    end
    nb_setLastFolder(gui,pathname);
    
    % Split selected filename
    [~,filename,ext] = fileparts(filename);
    
    if ~strcmpi(ext,'.mat')
        nb_errorWindow('The file must be saved to a .mat file.')
        return
    end
    
    % Assign the selected save name to the edit box
    set(gui.edit1,'string',[pathname,filename,ext])
    
end
