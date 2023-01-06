function enableLoadMenu(gui)
% Syntax:
%
% enableLoadMenu(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if gui.loadMode
        set(findobj(gui.dataMenu,'label','Load'),'enable','on');
    else
        set(findobj(gui.dataMenu,'label','Load'),'enable','off'); 
    end

end
