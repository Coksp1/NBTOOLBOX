function unitRoot(gui,~,~)
% Syntax:
%
% unitRoot(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
    end
    
    if isempty(gui.transData)
        dataObj = gui.data;
    else
        dataObj = gui.transData;
    end
    
    % Check that the data is valid
    if gui.data.numberOfObservations < 10
        nb_errorWindow('Cannot perform unit root test on a dataset with less than 10 periods');
        return
    end

    
    nb_unitRootGUI(gui.parent,dataObj.window('','','',gui.page));
    %addlistener(methodgui,'methodFinished',@gui.updateDataCallback);

end

