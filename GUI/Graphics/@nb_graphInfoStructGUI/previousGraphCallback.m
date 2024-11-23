function previousGraphCallback(gui,~,~)
% Syntax:
%
% previousGraphCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Display previous graph callback
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the current struct name
    displayedGraphMenu = findobj(gui.graphMenu,'checked','on');
    displayedStruct    = get(displayedGraphMenu,'label');
    
    % Locate the previous struct to display
    fnames = fieldnames(gui.GraphStruct);
    ind    = find(strcmpi(displayedStruct,fnames),1);
    if ind == 1
        return
    else
        
        tempInfoStruct                   = struct();
        tempInfoStruct.(fnames{ind - 1}) = gui.GraphStruct.(fnames{ind - 1});
        gui.plotter.GraphStruct          = tempInfoStruct;
        graphInfoStruct(gui.plotter);
        
    end
    
    % Check the dislpayed graph
    set(displayedGraphMenu,'checked','off');
    displayedGraphMenu = findobj(gui.graphMenu,'label',fnames{ind - 1});
    set(displayedGraphMenu,'checked','on');
    
end
