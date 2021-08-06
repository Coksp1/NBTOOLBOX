function cancelCallback(gui,~,~)
% Syntax:
%
% cancelCallback(gui,hObject,event)
%
% Description:
%
% Cancel callback.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    close(gui.figureHandle);
    gui.canceling = 1;

end
