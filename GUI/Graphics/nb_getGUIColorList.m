function endc = nb_getGUIColorList(gui,parent)
% Syntax:
%
% endc = nb_getGUIColorList(gui,parent)
%
% Description:
%
% Get color list from this GUI or main GUI (nb_GUI).
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(parent,'nb_GUI')
        endc = parent.settings.defaultColors;
    else
        endc = gui.defaultColors;
    end
    if isnumeric(endc)
        endc = nb_num2cell(endc);
    end
    
end
