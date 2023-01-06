function saveToPDF(gui,~,~,language,extended)
% Syntax:
%
% saveToPDF(gui,hObject,event,language,extended)
%
% Description:
%
% Part of DAG. Save package to PDF
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 5
        extended = false;
    end

    if isempty(gui.package.graphs)
        nb_errorWindow('The graph package is empty and cannot be saved to PDF.')
        return
    end
    
     % Get the file name
    [filename, pathname] = uiputfile({'*.pdf', 'Portable document format (*.pdf)';...
                                      '*.*',   'All files (*.*)'},...
                                      '',      nb_getLastFolder(gui));
    
    if isscalar(filename) || isempty(filename) || isscalar(pathname)
        nb_errorWindow('Invalid save name selected.')
        return
    end
    nb_setLastFolder(gui,pathname);
    
    [~,saveN] = fileparts(filename);
    sName     = [pathname, saveN, '_', nb_clock(), '_' language];

    % Write the package to PDF
    if extended
        try
            gui.package.writePDFExtended(sName,language,1);
        catch Err
           nb_errorWindow('Could not write PDF.', Err) 
        end
    else
        try
            % Here, we want to prompt the user to choose what template to
            % apply
            f = @()gui.package.writePDF(sName,language,1,gui.template);
            chooseTemplateWindow(gui,f);
        catch Err
           nb_errorWindow('Could not write PDF.', Err) 
        end
    end

end
