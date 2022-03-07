function selectedObjectToConvert(gui,hObject,~)
% Syntax:
%
% selectedObjectToConvert(gui,hObject,event)
%
% Description:
%
% Part of DAG. Get the selected object to convert
% 
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    string  = get(gui.convertListBox,'string');
    index   = get(gui.convertListBox,'value');
    dataset = string{index};

    if strcmpi(gui.saveName1,dataset)
        dataToConvert                   = gui.data1;
        freq                            = gui.data2.frequency;
        gui.objectSelectedForConverting = 1;
    else
        dataToConvert                   = gui.data2;
        freq                            = gui.data1.frequency;
        gui.objectSelectedForConverting = 2;
    end

    % Give the user the converting options
    convertgui = nb_convertDataGUI(gui.parent,dataToConvert,'forceFreq',freq);
    addlistener(convertgui,'methodFinished',@gui.convertionFinishedCallack);

    close(get(hObject,'parent'));

end
