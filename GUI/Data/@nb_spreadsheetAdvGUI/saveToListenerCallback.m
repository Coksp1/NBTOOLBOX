function saveToListenerCallback(gui,~,~)
% Syntax:
%
% saveToListenerCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if gui.changed
        
        % Here I notify the graph GUI to update itself, i.e. the graph GUI
        % has to implement a listener to the saveToGraph event
        notify(gui,'saveToGraph');
        notify(gui,'saveToListener');   
        
    end

end
