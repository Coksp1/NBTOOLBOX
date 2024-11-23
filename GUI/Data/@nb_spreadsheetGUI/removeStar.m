function removeStar(gui)
% Syntax:
%
% removeStar(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    gui.changed = 0;
    current     = get(gui.figureHandle,'name');
    if nb_contains(current,'*')
        current = strrep(current,'*','');
        set(gui.figureHandle,'name',current);
    end

end
