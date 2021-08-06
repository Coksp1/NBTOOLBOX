function sortCallback(gui,~,~)
% Syntax:
%
% sortCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Evaluate the expression
    try
        gui.data = sortProperty(gui.data,gui.type);
    catch Err
        nb_errorWindow(Err.message)
    end
        
    % Notify listeners
    notify(gui,'methodFinished');
    
end  
