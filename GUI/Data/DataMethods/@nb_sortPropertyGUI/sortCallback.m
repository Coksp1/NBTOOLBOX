function sortCallback(gui,~,~)
% Syntax:
%
% sortCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Evaluate the expression
    try
        gui.data = sortProperty(gui.data,gui.type);
    catch Err
        nb_errorWindow(Err.message)
    end
        
    % Notify listeners
    notify(gui,'methodFinished');
    
end  
