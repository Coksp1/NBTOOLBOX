function okCallback(gui,hObject,~)
% Syntax:
%
% okCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

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
