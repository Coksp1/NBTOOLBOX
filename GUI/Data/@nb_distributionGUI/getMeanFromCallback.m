function getMeanFromCallback(gui,~,~)
% Syntax:
%
% getMeanFromCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    dists = {gui.distribution.name};
    dists = [dists(1:gui.currentDistributionIndex-1),dists(gui.currentDistributionIndex+1:end)];

    % Make window to select which distribution to get the mean from
    f = nb_guiFigure(gui.parent,'Get mean from',[40   15  50   8],'modal','off');
    
    distSelection = uicontrol(...
        nb_constant.POPUP,...
        'parent',   f,...
        'String',   dists, ...
        'Position', [0.04, .75, 0.92, 0.1]);
    
    uicontrol(...
        nb_constant.BUTTON,...
        'parent',             f,...
        'Position',           [0.2, 0.14, 0.6, 0.24],...
        'string',             'Get mean',...
        'callback',           {@getMean,gui,distSelection});
    
    set(f, 'Visible', 'on');

end

function getMean(~,~,gui,distSelection)

    current  = gui.distribution(gui.currentDistributionIndex);
    dists    = gui.distribution;
    dists    = [dists(1:gui.currentDistributionIndex-1),dists(gui.currentDistributionIndex+1:end)];
    value    = get(distSelection,'value');
    selected = dists(value);
    
    % Get diff in mean
    cMean = mean(current);
    if ~isempty(current.meanShift)
        cMean = cMean - current.meanShift;
    end
    sMean = mean(selected);
    set(current,'meanShift',sMean - cMean);

    % Update GUI
    updateGUI(gui)
    
end
