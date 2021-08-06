function jbTest(gui,~,~)
% Syntax:
%
% jbTest(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Check data
    if isempty(gui.transData)
        dataObj = gui.data.window('','','',gui.page);
    else
        dataObj = gui.transData.window('','','',gui.page);
    end

    [test,pval]     = jbTest(dataObj);
    sgui            = nb_spreadsheetAdvGUI(gui.parent,test);
    sgui.figureName = [sgui.figureName, ' Test statistic'];
    sgui            = nb_spreadsheetAdvGUI(gui.parent,pval);
    sgui.figureName = [sgui.figureName, ' P-value'];
    
end

