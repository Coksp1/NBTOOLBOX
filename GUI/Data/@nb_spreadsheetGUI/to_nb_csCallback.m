function to_nb_csCallback(gui,~,~)
% Syntax:
%
% to_nb_csCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(gui.data)
        nb_errorWindow('No data loaded.')
        return
    end

    convertgui = nb_toCrossSectionalGUI(gui,gui.data);
    addlistener(convertgui,'methodFinished',@gui.updateDataCallback);

end
