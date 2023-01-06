function momentsBoxCallback(gui, ~, ~)
% Syntax:
%
% momentsBoxCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    mean     = str2double(get(gui.meanText, 'string'));
    variance = str2double(get(gui.varianceText, 'string'));
    type     = get(gui.currentDistribution, 'type');
    
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
    if ~isempty(meanShiftStr)
        meanShift = str2double(meanShiftStr);
        mean      = mean - meanShift;
    end
    
    try
        [~, params] = nb_distribution.parametrization(mean, variance, type, lowerBound, upperBound);
        set(gui.currentDistribution, 'parameters', params);
    catch Err
        nb_errorWindow(Err.message,Err);
    end
    
    gui.addToHistory();
    gui.updateGUI();
end
