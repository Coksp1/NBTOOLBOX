function covariance(gui,~,~)
% Syntax:
%
% covariance(gui,hObject,event)
%
% Description:
%
% Part of DAG. Calculate the covariance matrix and display it in a new
% spreadsheet.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if isempty(gui.transData)
        dataObj = gui.data;
    else
        dataObj = gui.transData;
    end

    statData           = cov(dataObj);
    tempgui            = nb_spreadsheetAdvGUI(gui.parent,statData);
    tempgui.figureName = 'Covariance Matrix';

end
