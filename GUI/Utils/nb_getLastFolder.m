function lastFolder = nb_getLastFolder(gui)
% Syntax:
%
% lastFolder = nb_getLastFolder(gui)
%
% Description:
%
% Get last openned folder in DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    parent = nb_getParentRecursively(gui);
    if parent == gui
        if isprop(parent,'plotter')
            plotter = parent.plotter;
            if isprop(plotter,'plotter')
                plotter = plotter.plotter;
            end
            parent = plotter.parent;
        end
    end
    
    if ~isa(parent,'nb_GUI')
        lastFolder = '';
    else
        if isfield(parent.settings,'lastFolder')
            % Robust to old session files!
            lastFolder = parent.settings.lastFolder;
        else
            lastFolder = pwd;
        end
    end
    
end
