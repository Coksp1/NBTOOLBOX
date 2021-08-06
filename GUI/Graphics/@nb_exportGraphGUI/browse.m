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
        {'*.pdf', 'Portable document format (*.pdf)';...
         '*.emf', 'Enhanced metafile (*.emf)';...
         '*.png', 'Portable network format (*.png)';...
         '*.eps', 'Encapsulated postscript (*.eps)';...
         '*.jpg', 'Joint Photographic Group (*.jpg)';...
         '*.svg', 'Scalable Vector Graphics (*.svg)';...
         '*.mat', 'MATLAB Object (*.mat)';...
         '*.m',   'MATLAB Script (*.m)';...
         '*.*',   'All files (*.*)'},...
         '',      nb_getLastFolder(gui));

    if isscalar(filename) || isempty(filename) || isscalar(pathname)
        nb_errorWindow('Invalid save name selected.')
        return
    end
    nb_setLastFolder(gui,pathname);
    
    % Split selected filename
    [~,filename,ext] = fileparts(filename);
    
    switch lower(ext)
        
        case '.pdf'
            value = 1;
        case '.emf'
            value = 2;
        case '.png'
            value = 3;
        case '.eps'
            value = 4;
        case '.jpg'
            value = 5;
        case '.svg'
            value = 6;
        case '.mat'
            value = 7;
        case '.m'
            value = 8;
        otherwise % I.e. ''
            value = 1;
            ext   = '.pdf';
             
    end
    
    % Change the selected file type
    set(gui.pop1,'value',value);
    
    % Assign the selected save name to the edit box
    set(gui.edit1,'string',[pathname,filename,ext])
    
end
