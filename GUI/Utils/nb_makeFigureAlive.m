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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Stored by nb_makeFigureIdle
    idleControls = getappdata(hObject.figureHandle, 'idleControls');
    setappdata(hObject.figureHandle, 'idleControls', []);
    set(idleControls,'enable','on');

    % Make the mouse pointer of the figur a time glass
    set(hObject.figureHandle,'pointer','arrow')

end
