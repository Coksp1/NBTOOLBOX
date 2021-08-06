function convertionFinishedCallack(gui,hObject,~)
% Syntax:
%
% convertionFinishedCallack(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function called when the convertDataFinished event 
% of the nb_convertDataGUI class is triggered.
%
% Input:
%
% - hObject : An object of class nb_convertDataGUI
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if gui.objectSelectedForConverting == 1
        gui.data1 = hObject.data;
    else
        gui.data2 = hObject.data;
    end
    
    mergeDatasetEngine(gui)

end
