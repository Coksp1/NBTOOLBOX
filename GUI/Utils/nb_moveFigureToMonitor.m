function nb_moveFigureToMonitor(figureHandle,monitor,moveType)
% Syntax:
%
% nb_moveFigureToMonitor(figureHandle,monitor)
%
% Description:
%
% Move the figure with the given handle to the monitor specified.
% 
% Input:
% 
% - figureHandle : Handle to the figure to move.
%
% - monitor      : The monitor to move the figure to.
%
% - moveType     : Either 'center' or 'none'. Default is 'center'.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        moveType = 'center';
    end
    
    if isempty(monitor)
        monitor = 1;
    end

    % Pause a little to be sure that things are up to date
    pause(0.05);
    
    % Move the figure to the correct monitor
    monitorPos = get(0, 'MonitorPositions');
    try
        monitorCorr = monitorPos(monitor) - 1;
    catch
        error([mfilename ':: The monitor selected does not exist.'])
    end
    oldUnits    = get(figureHandle,'units');
    set(figureHandle,'units','pixels');
    pos    = get(figureHandle,'position');
    pos(1) = pos(1) + monitorCorr;
    set(figureHandle,'position',pos);
    
    % Center the window if wanted
    if strcmpi(moveType,'center')
        nb_moveCenter(figureHandle,monitor)
    end
    
    % Revert the units property
    set(figureHandle,'units',oldUnits);
       
end
