function pauseCallback(gui,~,~)
% Syntax:
%
% pauseCallback(gui,hObject,event)
%
% Description:
%
% Pause callback.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    close(gui.figureHandle);
    gui.paused = 1;

end
