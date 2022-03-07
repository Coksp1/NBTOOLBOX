function selectVarXCallback(gui,~,~)
% Syntax:
%
% selectVarXCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    index   = get(gui.popupmenu,'value');
    strings = get(gui.popupmenu,'string');
    vars    = strings{index};
    gui.plotter.variableToPlotX = vars;
    
    % Notify listeners
    notify(gui,'changedGraph');

end
