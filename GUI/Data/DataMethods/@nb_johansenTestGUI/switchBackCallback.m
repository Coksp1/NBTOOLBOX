function switchBackCallback(gui,~,~)
% Syntax:
%
% switchBackCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Eyo Herstad

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    set(gui.panels.optionsPanel,'visible','on');
    set(gui.panels.varSelPanel,'visible','off');

end
