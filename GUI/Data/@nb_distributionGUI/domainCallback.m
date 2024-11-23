function domainCallback(gui, ~, ~)
% Syntax:
%
% domainCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    lowerBoundStr = get(gui.domainLowerBox, 'string');
    if isempty(lowerBoundStr)
        lowerBound = [];
    else
        lowerBound = str2double(lowerBoundStr);
    end
    
    upperBoundStr = get(gui.domainUpperBox, 'string');
    if isempty(upperBoundStr)
        upperBound = [];
    else
        upperBound = str2double(upperBoundStr);
    end
    
    meanShiftStr = get(gui.meanShiftBox, 'string');
    if isempty(meanShiftStr)
        meanShift = [];
    else
        meanShift = str2double(meanShiftStr);
    end
    
    try
        set(gui.currentDistribution, 'lowerBound', lowerBound);
        set(gui.currentDistribution, 'upperBound', upperBound);
        set(gui.currentDistribution, 'meanShift', meanShift);
    catch Err
        nb_errorWindow(Err.message);
    end
    
    gui.addToHistory();
    gui.updateGUI();
end
