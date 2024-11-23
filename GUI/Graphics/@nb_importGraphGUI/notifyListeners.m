function notifyListeners(gui,~,~)
% Syntax:
%
% notifyListeners(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Sync local variables of object and GUI
    notify(gui,'importingDone');
    
end
