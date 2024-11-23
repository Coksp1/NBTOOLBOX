function helpViewInfoSpreadsheetGUICallback(~,~,~)
% Syntax:
%
% gui.helpGraphicsMenuCallback(uiHandle,event)
%
% Description:
%
% Part of DAG
%
% Opens a nb_helpWindow with useful comments on the spreadsheet menu.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    arrow  = char(hex2dec('2192'));
    triang = char(hex2dec('25B8'));
    
    nb_helpWindow({...
        'Spreadsheet',...
        sprintf([...
        triang,' This spreadsheet is a simple way to view the series plotted in a session file \n',...
        'or graph package in one place. Note that only simple transformations can be displayed \n',...
        'here. If transformations cannot be found or if they are too complex an empty cell will \n',...
        'be displayed. There is no way to change the underlying information directly through the \n',...
        'spreadsheet, it is only for viewing purposes. Series that are not plotted will have the \n',...
        '("not plotted") identifier appended to their name.']),...
        'Different modes',...
        sprintf([...
        triang,' There are two ways to access the spreadsheet. This will affect the information that \n',...
        'that is displayed. (1) From the graph package window. Select Methods ' ,arrow, ' View \n',...
        'spreadsheet. From here you will get the spreadsheet with the contents of the graph \n',...
        'package displayed. (2) From the main GUI window. Graphics ' ,arrow, ' View spreadsheet. \n',...
        'From here you will get the spreadsheet with the contents of all the graphs of the session \n',...
        'displayed. The big difference, besides what graphs are included in the spreadsheet, is \n',...
        'that with method (1) the first column will be the figure numner, while with method (2) the \n',...
        'graphs are not numbered so the first column will be the figure name.']),...
        'Export to Excel',...
        sprintf([...
        triang, 'To export the spreadsheet to Excel, simply click on the "Export to Excel" button. \n',...
        'This will write the spreadsheet you see in DAG to an identical Excel spreadsheet for \n',...
        'sharing or other purposes. No information is lost or added in the process.'])});
    
end
