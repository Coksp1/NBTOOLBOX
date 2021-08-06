function exportInfoSpreadsheet2Excel(gui,~,~)
% Syntax:
%
% exportInfoSpreadsheet2Excel(gui,hObject,event)
%
% Description:
%
% Part of DAG.
%
% Export info spreadsheet to Excel.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    [filename, pathname] = uiputfile({  '*.xlsx',             'Excel (*.xlsx)';...
                                        '*.xls',              'Excel (*.xls)'},...
                                        '',                   nb_getLastFolder(gui));
    if isscalar(pathname)
        nb_errorWindow('Invalid save name selected.')
        return
    end
    nb_setLastFolder(gui,pathname);
    
    % Write to Excel
    try
        nb_xlswrite([pathname,filename],gui.info);
    catch
        nb_errorWindow('Something failed when trying to write to Excel')
        return
    end
    nb_infoWindow('Data successfully written to Excel')
end
