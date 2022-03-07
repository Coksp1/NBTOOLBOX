function getModeFromCallback(gui,~,~)
% Syntax:
%
% getModeFromCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    dists = {gui.distribution.name};
    dists = [dists(1:gui.currentDistributionIndex-1),dists(gui.currentDistributionIndex+1:end)];

    % Make window to select which distribution to get the mean from
    f = nb_guiFigure(gui.parent,'Get mode from',[40   15  50   8],'modal','off');
    
    distSelection = uicontrol(...
        nb_constant.POPUP,...
        'parent',   f,...
        'String',   dists, ...
        'Position', [0.04, .75, 0.92, 0.1]);
    
    uicontrol(...
        nb_constant.BUTTON,...
        'parent',             f,...
        'Position',           [0.2, 0.14, 0.6, 0.24],...
        'string',             'Get mode',...
        'callback',           {@getMode,gui,distSelection});
    
    set(f, 'Visible', 'on');

end

function getMode(~,~,gui,distSelection)

    current  = gui.distribution(gui.currentDistributionIndex);
    dists    = gui.distribution;
    dists    = [dists(1:gui.currentDistributionIndex-1),dists(gui.currentDistributionIndex+1:end)];
    value    = get(distSelection,'value');
    selected = dists(value);
    
    % Get diff in mean
    cMode = mode(current);
    if ~isempty(current.meanShift)
        cMode = cMode - current.meanShift;
    end
    sMode = mode(selected);
    set(current,'meanShift',sMode - cMode);

    % Update GUI
    updateGUI(gui)
    
end
