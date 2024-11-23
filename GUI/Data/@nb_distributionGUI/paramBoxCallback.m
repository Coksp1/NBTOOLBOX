function paramBoxCallback(gui, ~, ~)
% Syntax:
%
% paramBoxCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    paramBoxes  = findobj(horzcat(gui.paramBoxes{:}), 'visible', 'on');
    paramValues = get(paramBoxes, 'string');
    if ~iscell(paramValues)
        paramValues = {paramValues};
    end
    paramValues = cellfun(@(x) str2double(x), paramValues);
    
    try
        set(gui.currentDistribution, 'parameters', num2cell(paramValues'));
    catch Err
        nb_errorWindow(Err.message);
    end
    
    gui.addToHistory();
    gui.updateGUI();
end
