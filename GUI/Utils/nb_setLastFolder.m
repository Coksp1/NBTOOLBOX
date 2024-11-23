function nb_setLastFolder(gui,lastFolder)
% Syntax:
%
% nb_setLastFolder(gui,lastFolder)
%
% Description:
%
% Get last openned folder in DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    parent = nb_getParentRecursively(gui);
    if isa(parent,'nb_GUI')
        parent.settings.lastFolder = lastFolder;
    end
    
end
