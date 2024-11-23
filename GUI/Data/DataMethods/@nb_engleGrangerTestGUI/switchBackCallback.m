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

    set(gui.unitRootPanels.optionsPanel,'visible','on');
    set(gui.unitRootPanels.varSelPanel,'visible','off');

end
