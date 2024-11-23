function excelChangeLogGUI(gui,~,~,type)
% Syntax:
%
% excelChangeLogGUI(gui,~,~,type)
%
% Description:
%
% Part of DAG. Save text information from the graph package to an Excel 
% sheet.
% 
% Written by Per Bjarne Bye
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(gui.package.graphs)
        nb_errorWindow('The graph package is empty and there is nothing to read/write.')
        return
    end
    
    if strcmpi(type,'export')
        % Get the file name
        [filename, pathname] = uiputfile({'*.xlsx', 'Excel (*.xlsx)';...
                                          '*.*',    'All files (*.*)'},...
                                          '',       nb_getLastFolder(gui));

        if isscalar(filename) || isempty(filename) || isscalar(pathname)
            nb_errorWindow('Invalid save name selected.')
            return
        end

        nb_setLastFolder(gui,pathname);

        [~,saveN] = fileparts(filename);
        sName     = [pathname, saveN, '_', nb_clock()];

        % Write the package to Excel
        try
            gui.package.exportExcelChangeLog(sName,gui.packageName);
        catch Err
           nb_errorWindow('Could not write the Excel Change Log.', Err) 
        end
        
    else
        
        % Get the file
        [filename, pathname] = uigetfile({'*.xlsx', 'Excel (*.xlsx)';...
                                          '*.*',    'All files (*.*)'},...
                                          '',       nb_getLastFolder(gui));                      
        xlFile = [pathname,filename];
        
        % Read the file
        try
            gui.package.importExcelChangeLog(xlFile);
        catch Err
           nb_errorWindow('Could not read the Excel Change Log.', Err) 
        end
        
        % The package has been changed, and the updated version can be saved
        gui.changed = 1;
        
        % Also update all the graph objects saved in the GUI by copying to
        % memory
        pack        = gui.package.graphs;
        identifiers = gui.package.identifiers;
        appGraphs   = gui.parent.graphs;
        for hh = 1:size(pack,2)     
            saveName             = identifiers{hh};
            appGraphs.(saveName) = copy(pack{hh}); 
        end
        gui.parent.graphs = appGraphs;

        
    end
   
end
