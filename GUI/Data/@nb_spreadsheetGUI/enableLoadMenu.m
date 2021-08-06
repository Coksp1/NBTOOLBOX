function enableLoadMenu(gui)
% Syntax:
%
% enableLoadMenu(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if gui.loadMode
        set(findobj(gui.dataMenu,'label','Load'),'enable','on');
    else
        set(findobj(gui.dataMenu,'label','Load'),'enable','off'); 
    end

end
