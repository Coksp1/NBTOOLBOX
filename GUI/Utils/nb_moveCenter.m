function nb_moveCenter(figureHandle,monitor)
% Syntax:
%
% nb_moveCenter(figureHandle,monitor)
%
% Description:
%
% Move the figure with the provided handle to the center of the
% screen.
% 
% Input:
% 
% - figureHandle : Handle to the figure to move.
%
% - monitor      : The monitor which the figure is displayed.
%                  If not provided it will be moved to the
%                  first monitor.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        monitor = nb_getCurrentMonitor();
    end

    oldUnits = get(figureHandle,'units');
    set(figureHandle,'units','pixels');

    pos        = get(figureHandle,'position');
    fWidth     = pos(3);
    fHeight    = pos(4);
    monitorPos = get(0, 'MonitorPositions');
    try
        mStartX = monitorPos(monitor,1) - 1;
        mStartY = monitorPos(monitor,2) - 1;
        if verLessThan('matlab','8.4')
            mWidth  = diff(monitorPos(monitor,[1,3])) + 1;
            mHeight = diff(monitorPos(monitor,[2,4])) + 1;
        else
            mWidth  = monitorPos(monitor,3);
            mHeight = monitorPos(monitor,4);
        end
    catch
        error([mfilename ':: The monitor selected does not exist.'])
    end
    
    % swidth - fwidth == remaining width
    rWidth  = mWidth - fWidth;
    if rWidth < 0
        rWidth = rWidth*2;
    end
    
    % sheight - fheight == remaining height
    rHeight = mHeight - fHeight;
    if rHeight < 0
        rHeight = rHeight*2;
    end
    
    % Changes position
    newpos    = pos;
    newpos(1) = rWidth/2 + mStartX;
    newpos(2) = rHeight/2 + mStartY;
    set(figureHandle,'position',newpos);
    set(figureHandle,'units',oldUnits);
    
end
