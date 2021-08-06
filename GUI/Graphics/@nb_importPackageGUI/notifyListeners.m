function notifyListeners(gui,~,~)
% Syntax:
%
% notifyListeners(gui,hObject,event)
%
% Description:
%
% Part of DAG. Notify listeners
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    notify(gui,'importingDone');

    % Dump all the graph objects of the package to main program
    dumpGraphs(gui);
    
end
