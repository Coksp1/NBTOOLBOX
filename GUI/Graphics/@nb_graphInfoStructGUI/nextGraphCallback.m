function nextGraphCallback(gui,~,~)
% Syntax:
%
% nextGraphCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Display next graph callback
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the current struct name
    displayedGraphMenu = findobj(gui.graphMenu,'checked','on');
    displayedStruct    = get(displayedGraphMenu,'label');
    
    % Locate the previous struct to display
    fnames = fieldnames(gui.GraphStruct);
    ind    = find(strcmpi(displayedStruct,fnames),1);
    if ind == length(fnames)
        return
    else
        
        tempInfoStruct                   = struct();
        tempInfoStruct.(fnames{ind + 1}) = gui.GraphStruct.(fnames{ind + 1});
        gui.plotter.GraphStruct          = tempInfoStruct;
        graphInfoStruct(gui.plotter);
        
    end
    
    % Check the dislpayed graph
    set(displayedGraphMenu,'checked','off');
    displayedGraphMenu = findobj(gui.graphMenu,'label',fnames{ind + 1});
    set(displayedGraphMenu,'checked','on');
    
end
