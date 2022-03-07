function convert(gui,~,~)
% Syntax:
%
% convert(gui,hObject,event)
%
% Description:
%
% Part of DAG. Convert the frequency of the object.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
    end

    convertgui = nb_convertDataGUI(gui,gui.data);
    addlistener(convertgui,'methodFinished',@gui.updateDataCallback);
    
end
