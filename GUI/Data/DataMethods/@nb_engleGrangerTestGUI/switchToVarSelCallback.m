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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    set(gui.unitRootPanels.optionsPanel,'visible','off');
    set(gui.unitRootPanels.varSelPanel,'visible','on');

end
