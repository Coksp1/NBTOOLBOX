function saveToExcel(gui,~,~,language)
% Syntax:
%
% saveToExcel(gui,hObject,event)
%
% Description:
%
% Part of DAG. Save package data to excel
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(gui.package.graphs)
        nb_errorWindow('The graph package is empty and cannot be saved to excel.')
        return
    end

    if any(cellfun('isclass',gui.package.graphs,'nb_graph_subplot'))
        nb_errorWindow(['Cannot save data to excel when panels are included in the package. '...
                         'Please contact NB Toolbox developers if needed.'])
        return
    end
    
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
    if strcmpi(language,'english')
        sName = [sName, '_', language];
    elseif strcmpi(language,'norwegian')
        sName = [sName,'_', language];
    end
    
    % Save the data to excel
    try
        gui.package.saveData(sName,language);
    catch Err
        nb_errorWindow('Error:',Err);
    end

end
