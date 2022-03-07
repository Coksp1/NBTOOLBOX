function lagLengthCallback(gui,~,~)
% Syntax:
%
% lagLengthCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
%
% Callback function for when the radiobutton choice in the lag length
% buttongroup changes. Enables/disables choices depending on whether the 
% user selects manual or automatic lag length.
% 
% Written by Eyo Herstad

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get components
    criterionBox    = gui.lagPanelComponents.criterionBox;
    maxText         = gui.lagPanelComponents.maxText;
    maxLagLengthBox = gui.lagPanelComponents.maxLagLengthBox;
    userSelectBtn   = gui.lagPanelComponents.userSelectBtn;
    userLagSelect   = gui.lagPanelComponents.userLagSelect;

    if isequal(get(userSelectBtn,'value'),1)
        set(criterionBox,'enable','off');
        set(maxText,'enable','off');
        set(maxLagLengthBox,'enable','off');
        set(userLagSelect,'enable','on');
    else
        set(criterionBox,'enable','on');
        set(maxText,'enable','on');
        set(maxLagLengthBox,'enable','on');
        set(userLagSelect,'enable','off');
    end

end

