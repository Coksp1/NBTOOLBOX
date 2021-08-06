function updateHelp(gui,listbox,~)
% Syntax:
%
% updateHelp(gui,listbox,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    list     = get(listbox,'string');
    value    = get(listbox, 'value');
    func     = list{value};
    helpText = nb_createVariableGUI.helpOn(func); 
    set(gui.textboxHelp,'string',helpText);
    
end
