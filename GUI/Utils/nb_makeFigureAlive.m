function nb_makeFigureAlive(hObject,~)
% Syntax:
%
% nb_makeFigureAlive(hObject,event)
%
% Description:
%
% Callback function to make the figure alive, after being idle.
% 
% Input:
% 
% - hObject : A GUI object with the property figureHandle, which  
%             must be a MATLAB figure handle.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    figureHandle = hObject.figureHandle;
    if isempty(figureHandle)
        figureHandle = nb_getParentRecursively(hObject.parent);
    end

    % Stored by nb_makeFigureIdle
    idleControls = getappdata(figureHandle, 'idleControls');
    setappdata(figureHandle, 'idleControls', []);
    idleControls = idleControls(ishandle(idleControls));
    set(idleControls,'enable','on');

    idlePanels = getappdata(figureHandle, 'idlePanels');
    setappdata(figureHandle, 'idlePanels', []);
    idlePanels = idlePanels(ishandle(idlePanels));
    set(idlePanels,'enable','on');

    % Make the mouse pointer of the figur a pointer
    set(figureHandle,'pointer','arrow')
    pause(0.1);

end
