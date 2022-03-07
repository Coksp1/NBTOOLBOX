function setPatchAlphaCallback(gui,hObject,~)
% Syntax:
%
% setPatchAlphaCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    patchAlpha = nb_getUIControlValue(hObject,'numeric');
    if isnan(patchAlpha)
        nb_errorWindow('The patch transparency option must be between 0 and 1.')
        nb_setUIControlValue(hObject,num2str(gui.plotter.patchAlpha));
        return
    elseif patchAlpha < 0 || patchAlpha > 1
        nb_errorWindow('The patch transparency option must be between 0 and 1.')
        nb_setUIControlValue(hObject,num2str(gui.plotter.patchAlpha));
        return
    end
    gui.plotter.patchAlpha = patchAlpha;
    
    % Notify listeners
    notify(gui,'changedGraph')

end
