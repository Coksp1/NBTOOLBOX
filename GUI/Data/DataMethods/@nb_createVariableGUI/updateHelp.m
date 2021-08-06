function updateHelp(gui,listbox,~)
% Syntax:
%
% updateHelp(gui,listbox,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    list     = get(listbox,'string');
    value    = get(listbox, 'value');
    func     = list{value};
    helpText = nb_createVariableGUI.helpOn(func); 
    set(gui.textboxHelp,'string',helpText);
    
end
