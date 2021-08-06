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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    close(gui.figureHandle);
    gui.paused = 1;

end
