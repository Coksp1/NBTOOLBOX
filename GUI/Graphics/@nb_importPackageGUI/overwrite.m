function overwrite(gui,hObject,~)
% Syntax:
%
% overwrite(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the already stored objects
    appPackages = gui.parent.graphPackages;

    % Overwrite existing object
    appPackages.(gui.name) = gui.package;

    % Assign it to the main GUI object so the user can use it later
    gui.parent.graphPackages = appPackages;

    % Close parent (I.e. the GUI)
    close(get(hObject,'parent'));
    
    % Dump all the graph objects of the package to main program
    dumpGraphs(gui);

    % Notify listeners
    notify(gui,'importingDone');
     
end
