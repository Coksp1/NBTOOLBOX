function currentMonitor = nb_getCurrentMonitor()
% Syntax:
%
% currentMonitor = nb_getCurrentMonitor()
%
% Description:
%
% Get the monitor which the current figure is displayed.
% 
% Output:
% 
% currentMonitor : An integer with the monitor.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    figs = findobj('type','figure');
    if isempty(figs)
        currentMonitor = 1;
        return
    end

    currentFigure      = gcf;
    set(currentFigure,'units','pixels');
    parentPos          = get(currentFigure,'position');
    set(currentFigure,'units','characters');
    monitorPos         = get(0, 'MonitorPositions');
    monitorStart       = monitorPos(:,1);
    monitorStartSorted = sort(monitorStart);
    [~,locateMonitors] = ismember(monitorStartSorted,monitorStart);
    index              = find(parentPos(1) >= monitorStartSorted,1,'last');
    currentMonitor     = locateMonitors(index);

end
