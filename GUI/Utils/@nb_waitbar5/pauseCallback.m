function pauseCallback(gui,~,~)
% Syntax:
%
% pauseCallback(gui,hObject,event)
%
% Description:
%
% Pause callback.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    close(gui.figureHandle);
    gui.paused = 1;

end
