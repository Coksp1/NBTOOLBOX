function transposeCallback(gui,hObject,~)
% Syntax:
%
% transposeCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Do the calculation
    gui.data = transpose(gui.data);

    % Close window
    delete(get(hObject,'parent'));
    
    % Notify listeners
    notify(gui,'methodFinished');

end  
