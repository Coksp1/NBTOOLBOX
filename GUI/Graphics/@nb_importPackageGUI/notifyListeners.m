function notifyListeners(gui,~,~)
% Syntax:
%
% notifyListeners(gui,hObject,event)
%
% Description:
%
% Part of DAG. Notify listeners
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    notify(gui,'importingDone');

    % Dump all the graph objects of the package to main program
    dumpGraphs(gui);
    
end
