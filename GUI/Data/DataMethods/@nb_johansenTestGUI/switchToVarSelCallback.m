function switchToVarSelCallback(gui,~,~)
% Syntax:
%
% switchToVarSelCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Eyo Herstad

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    set(gui.panels.optionsPanel,'visible','off');
    set(gui.panels.varSelPanel,'visible','on');

end
