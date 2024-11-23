function viewInfoSpreadsheetCallback(gui,~,~)
% Syntax:
%
% viewSpreadsheetCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. View info about graphpackage in a spreadsheet. Possible to 
% export the same spreadsheet to Excel.
% 
% Written by Per Bjarne Bye 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(gui.package.graphs)
        nb_errorWindow('The graph package is empty and cannot be viewed as a spreadsheet.')
        return
    end
    
    nb_viewInfoSpreadsheetGUI(gui);

end
    
