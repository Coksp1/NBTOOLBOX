function reorderCallback(gui,hObject,~)
% Syntax:
%
% reorderCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. % The function called when the OK button is pushed in the 
% GUI window.
%
% Input:
%
% - hObject : An object of class nb_reorderGUI
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    newOrder = hObject.cstr';

    % Evaluate the expression
    try
        gui.data = reorder(gui.data,newOrder,gui.type);
    catch Err
        nb_errorWindow(Err.message)
    end
        
    % Notify listeners
    notify(gui,'methodFinished');
    
end  
