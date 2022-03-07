function cancelCallback(gui,~,~)
% Syntax:
%
% cancelCallback(gui,hObject,event)
%
% Description:
%
% Cancel callback.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    close(gui.figureHandle);
    gui.canceling = 1;

end
