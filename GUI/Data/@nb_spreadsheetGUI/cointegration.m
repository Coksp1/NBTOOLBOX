function cointegration(gui,~,~,type)
% Syntax:
%
% cointegration(gui,~,~,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Check data
    if isempty(gui.transData)
        dataObj = gui.data.window('','','',gui.page);
    else
        dataObj = gui.transData.window('','','',gui.page);
    end

    switch type
        case 'johansen'
            nb_johansenTestGUI(gui.parent,dataObj);
        case 'engle-granger'
            nb_engleGrangerTestGUI(gui.parent,dataObj);
    end
end

