function rename(gui,hObject,~)
% Syntax:
%
% rename(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Eyo I. Herstad and Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Close parent (I.e. the GUI)
    close(get(hObject,'parent'));
    
    % Save the loaded graph object with a new name
    nb_saveAsDataGUI(gui.parent,gui.data);
    
    % Inform the user
%      nb_infoWindow('The file was successfully imported')
    
end
