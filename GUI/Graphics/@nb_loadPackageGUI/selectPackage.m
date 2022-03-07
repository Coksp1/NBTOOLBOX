function selectPackage(gui,~,~)
% Syntax:
%
% selectPackage(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get selected dataset
    index        = get(gui.listBox,'Value');
    string       = get(gui.listBox,'String');
    packageNameT = string{index};

    if isempty(packageNameT)
        close(gui.fig);
        return
    end

    % Get the package object and make a copy
    appPackages     = gui.parent.graphPackages;
    packageT        = appPackages.(packageNameT);
    gui.package     = copy(packageT);
    gui.packageName = packageNameT;

    % Close window
    close(gui.fig);
    
    % Notify listeners
    notify(gui,'loadObjectFinished');

end
