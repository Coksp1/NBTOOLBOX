function saveToListenerCallback(gui,~,~)
% Syntax:
%
% saveToListenerCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if gui.changed
        
        % Here I notify the graph GUI to update itself, i.e. the graph GUI
        % has to implement a listener to the saveToGraph event
        notify(gui,'saveToGraph');
        notify(gui,'saveToListener');   
        
    end

end
