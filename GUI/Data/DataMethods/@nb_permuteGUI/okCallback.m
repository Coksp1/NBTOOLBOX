function okCallback(gui,hObject,~)
% Syntax:
%
% okCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    try
        gui.data = permute(gui.data);
    catch Err
        nb_errorWindow('Could not permute the data.', Err)
    end
    
    % Close window
    close(get(hObject,'parent'));
    
    % Notify listeners
    notify(gui,'methodFinished');

end
