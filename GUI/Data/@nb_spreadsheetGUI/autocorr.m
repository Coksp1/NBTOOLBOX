function autocorr(gui,~,~)
% Syntax:
%
% autocorr(gui,hObject,event)
%
% Description:
%
% Part of DAG. Calculate the autocorrelation and display it in a new graph
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Check data
    if isempty(gui.transData)
        dataObj = gui.data;
    else
        dataObj = gui.transData;
    end

    nb_autocorrelationGUI(gui.parent,dataObj);
    
end
