function notifyListeners(gui,~,~)
% Syntax:
%
% notifyListeners(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Sync local variables of object and GUI
    notify(gui,'importingDone');
    
end
