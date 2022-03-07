function nb_makeFigureIdle(hObject,~)
% Syntax:
%
% nb_makeFigureIdle(hObject,event)
%
% Description:
%
% Callback function to make the figure idle
% 
% Input:
% 
% - hObject : A GUI object with the property figureHandle, which  
%             must be a MATLAB figure handle.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    figureHandle = hObject.figureHandle;
    
    % Disable uicontrol object of the figure
    idleControls = findobj(figureHandle,'type','uicontrol');
    ind = get(idleControls,'enable');
    ind = strcmpi(ind,'on');
    idleControls = idleControls(ind); % Only disable the uicontrol object which are enabled
    set(idleControls,'enable','off');
    
    % Store disabled controls for use by the nb_makeFigureAlive function)
    setappdata(figureHandle, 'idleControls', idleControls);
    
    % Make the mouse pointer of the figur a time glass
    set(hObject.figureHandle,'pointer','watch')
    drawnow();
    
end
