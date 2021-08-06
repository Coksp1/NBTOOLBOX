function summaryStatistics(gui,~,~)
% Syntax:
%
% summaryStatistics(gui,hObject,event)
%
% Description:
%
% Part of DAG. Calculate the summary statistics an open up a new window
% with a table displaying the results
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.transData)
        dataObj = gui.data;
    else
        dataObj = gui.transData;
    end

    try
        statData           = summary(dataObj);
        tempgui            = nb_spreadsheetAdvGUI(gui.parent,statData);
        tempgui.figureName = 'Summary Statistics';
    catch Err
        nb_errorWindow('Error while calculating summary table of the data set. ',Err)
    end
    
end
        
